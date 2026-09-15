//
//  WidgetImageMigrationService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.10.25.
//

import Foundation
import GRDB
import OSLog
import UIKit
import WidgetKit

/// Keeps the on-disk image variants in sync with the current rendering logic.
///
/// This used to be a one-shot boolean ("have the widget images been created
/// yet?"), which meant it could only ever *create missing* files — a change to
/// the crop logic would never reach existing users. It is now versioned: bump
/// `currentVersion` whenever `ImageProcessingService` or `ImageVariant` changes
/// in a way that should be reflected in already-generated files, and every
/// install rebuilds its variants exactly once.
final class WidgetImageMigrationService: Sendable {
    static let shared = WidgetImageMigrationService()

    /// Version history:
    ///   1 — initial generation of `_widget_2x1` / `_widget_1x1`
    ///   2 — focal point now prefers faces, crop no longer double-resamples,
    ///       fixed pixel sizes, added `_tile_3x1` for the in-app tiles
    private static let currentVersion = 2

    // `UserDefaults.standard` is accessed inline rather than stored: it is not
    // a `Sendable` type, and holding it as a property would keep this service
    // from being `Sendable` even though it has no mutable state of its own.
    private static let versionKey = "widget_images_version"

    private init() {}

    /// Rebuilds the variants if this install hasn't seen the current version.
    func runMigrationIfNeeded() async {
        let storedVersion = UserDefaults.standard.integer(forKey: Self.versionKey)

        guard storedVersion < Self.currentVersion else { return }

        Logger.debug.notice("Regenerating image variants: version \(storedVersion) -> \(Self.currentVersion)")

        // Anything older than the current version was produced by different
        // crop logic, so existing files are replaced rather than kept.
        let result = await performMigration(regenerateExisting: true)

        if result.regenerated > 0 {
            await reloadWidgetTimelines()
        }

        // The version is only recorded once nothing failed. Otherwise an
        // interrupted or failing run (low memory, no disk space, app killed
        // mid-migration) would mark this install as migrated and leave the old
        // crops in place permanently. Missing source files don't count — those
        // will never succeed, so retrying them forever is pointless.
        guard result.failed == 0 else {
            Logger.debug.error(
                "Image variant regeneration incomplete (\(result.regenerated) done, \(result.failed) failed); retrying on next launch"
            )
            return
        }

        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
        Logger.debug.notice("Image variants now at version \(Self.currentVersion) (\(result.regenerated) regenerated, \(result.skipped) skipped)")
    }

    /// Rebuilds every variant regardless of the stored version.
    func forceMigration() async {
        let result = await performMigration(regenerateExisting: true)

        if result.failed == 0 {
            UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
        }

        await reloadWidgetTimelines()
    }

    /// Reload widget timelines to use new images
    private func reloadWidgetTimelines() async {
        await MainActor.run {
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MotivationWidget")
        }
    }

    /// What happened to one moment's variants.
    private enum RegenerationOutcome {
        case regenerated
        /// Nothing to do, or the original photo is gone — retrying won't help.
        case skipped
        /// Something went wrong that could succeed on a later launch.
        case failed
    }

    private struct MigrationResult {
        var regenerated = 0
        var skipped = 0
        var failed = 0
    }

    private func performMigration(regenerateExisting: Bool) async -> MigrationResult {
        var result = MigrationResult()

        do {
            let moments = try momentsWithPhotos()

            // Batched so a large library doesn't hold several decoded
            // full-resolution images in memory at once.
            let batchSize = 5
            for batch in moments.chunked(into: batchSize) {
                let outcomes = await withTaskGroup(of: RegenerationOutcome.self) { group -> [RegenerationOutcome] in
                    for moment in batch {
                        group.addTask {
                            await self.regenerateVariants(for: moment, regenerateExisting: regenerateExisting)
                        }
                    }

                    var collected: [RegenerationOutcome] = []
                    for await outcome in group {
                        collected.append(outcome)
                    }
                    return collected
                }

                for outcome in outcomes {
                    switch outcome {
                    case .regenerated: result.regenerated += 1
                    case .skipped: result.skipped += 1
                    case .failed: result.failed += 1
                    }
                }

                // Small delay between batches to prevent overwhelming the system
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
        catch {
            // Couldn't even read the moment list, so nothing was regenerated.
            // Counted as a failure so the version is not recorded.
            Logger.debug.error("Widget image migration failed: \(error.localizedDescription)")
            result.failed += 1
        }

        return result
    }

    private func momentsWithPhotos() throws -> [Moment] {
        try AppDatabase.shared.reader.read { db in
            try Moment
                .all()
                .filter(sql: "photo IS NOT NULL AND photo != ''")
                .fetchAll(db)
        }
    }

    private func regenerateVariants(for moment: Moment, regenerateExisting: Bool) async -> RegenerationOutcome {
        guard let photoFileName = moment.photo else { return .skipped }

        let variantsToBuild = ImageVariant.allCases.filter { variant in
            let path = FileManager.documentsDirectory
                .appendingPathComponent("\(variant.fileName(for: photoFileName)).jpg")
            return regenerateExisting || !FileManager.default.fileExists(atPath: path.path)
        }

        guard !variantsToBuild.isEmpty else { return .skipped }

        let originalPath = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")

        guard let originalImage = UIImage(contentsOfFile: originalPath.path) else {
            // The original is gone, so the variants can never be rebuilt.
            // Not a failure: retrying on every launch would never succeed.
            Logger.debug.notice("Skipping \(photoFileName): original photo is missing")
            return .skipped
        }

        for variant in variantsToBuild {
            guard let processed = await ImageProcessingService.shared.processImage(originalImage, variant: variant),
                let jpegData = processed.jpegData(compressionQuality: 0.85)
            else {
                Logger.debug.error("Failed to render \(variant.rawValue) for \(photoFileName)")
                return .failed
            }

            let destination = FileManager.documentsDirectory
                .appendingPathComponent("\(variant.fileName(for: photoFileName)).jpg")

            do {
                try jpegData.write(to: destination, options: [.atomic])
            }
            catch {
                Logger.debug.error("Failed to write \(variant.rawValue) for \(photoFileName): \(error.localizedDescription)")
                return .failed
            }
        }

        ImageProcessingService.shared.removeCachedImages(for: photoFileName)
        return .regenerated
    }

    /// The image variant version this install has already been migrated to.
    var migratedVersion: Int {
        UserDefaults.standard.integer(forKey: Self.versionKey)
    }

    /// Reset migration status (for testing)
    func resetMigrationStatus() {
        UserDefaults.standard.set(0, forKey: Self.versionKey)
    }
}

// MARK: - Array Extension for Chunking

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
