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

        // Anything older than the current version was produced by different
        // crop logic, so existing files are replaced rather than kept.
        await performMigration(regenerateExisting: true)

        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
        await reloadWidgetTimelines()
    }

    /// Rebuilds every variant regardless of the stored version.
    func forceMigration() async {
        await performMigration(regenerateExisting: true)

        UserDefaults.standard.set(Self.currentVersion, forKey: Self.versionKey)
        await reloadWidgetTimelines()
    }

    /// Reload widget timelines to use new images
    private func reloadWidgetTimelines() async {
        await MainActor.run {
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MotivationWidget")
        }
    }

    private func performMigration(regenerateExisting: Bool) async {
        do {
            let moments = try momentsWithPhotos()

            // Batched so a large library doesn't hold several decoded
            // full-resolution images in memory at once.
            let batchSize = 5
            for batch in moments.chunked(into: batchSize) {
                await withTaskGroup(of: Void.self) { group in
                    for moment in batch {
                        group.addTask {
                            await self.regenerateVariants(for: moment, regenerateExisting: regenerateExisting)
                        }
                    }
                }

                // Small delay between batches to prevent overwhelming the system
                try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
            }
        }
        catch {
            Logger.debug.error("Widget image migration failed: \(error.localizedDescription)")
        }
    }

    private func momentsWithPhotos() throws -> [Moment] {
        try AppDatabase.shared.reader.read { db in
            try Moment
                .all()
                .filter(sql: "photo IS NOT NULL AND photo != ''")
                .fetchAll(db)
        }
    }

    private func regenerateVariants(for moment: Moment, regenerateExisting: Bool) async {
        guard let photoFileName = moment.photo else { return }

        let missingVariants = ImageVariant.allCases.filter { variant in
            let path = FileManager.documentsDirectory
                .appendingPathComponent("\(variant.fileName(for: photoFileName)).jpg")
            return regenerateExisting || !FileManager.default.fileExists(atPath: path.path)
        }

        guard !missingVariants.isEmpty else { return }

        let originalPath = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")

        guard let originalImage = UIImage(contentsOfFile: originalPath.path) else {
            return
        }

        for variant in missingVariants {
            guard let processed = await ImageProcessingService.shared.processImage(originalImage, variant: variant) else {
                continue
            }

            let destination = FileManager.documentsDirectory
                .appendingPathComponent("\(variant.fileName(for: photoFileName)).jpg")

            guard let jpegData = processed.jpegData(compressionQuality: 0.85) else { continue }
            try? jpegData.write(to: destination, options: [.atomic])
        }

        ImageProcessingService.shared.removeCachedImages(for: photoFileName)
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
