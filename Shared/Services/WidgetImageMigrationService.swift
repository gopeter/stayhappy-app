//
//  WidgetImageMigrationService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.10.25.
//

import Foundation
import GRDB
import UIKit
import WidgetKit

final class WidgetImageMigrationService {
    static let shared = WidgetImageMigrationService()

    private let userDefaults = UserDefaults.standard
    private let migrationKey = "widget_images_migration_completed"

    private init() {}

    // Get screen width for widget sizing
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    /// Check if migration is needed and run it
    func runMigrationIfNeeded() async {
        // Check if migration was already completed
        if userDefaults.bool(forKey: migrationKey) {
            return
        }

        await performMigration()

        // Mark migration as completed
        userDefaults.set(true, forKey: migrationKey)
    }

    /// Force migration (useful for testing or manual triggers)
    func forceMigration() async {
        userDefaults.set(false, forKey: migrationKey)
        await performMigration()
        
        userDefaults.set(true, forKey: migrationKey)
        await reloadWidgetTimelines()
    }

    /// Reload widget timelines to use new images
    private func reloadWidgetTimelines() async {
        await MainActor.run {
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MotivationWidget")
        }
    }

    private func performMigration() async {
        do {
            // Get all moments with photos
            let moments = try await getMomentsWithPhotos()

            var successCount = 0
            var errorCount = 0

            // Process images in batches to avoid memory issues
            let batchSize = 5
            for batch in moments.chunked(into: batchSize) {
                await withTaskGroup(of: Bool.self) { group in
                    for moment in batch {
                        group.addTask {
                            await self.processWidgetImagesForMoment(moment)
                        }
                    }

                    for await success in group {
                        if success {
                            successCount += 1
                        }
                        else {
                            errorCount += 1
                        }
                    }
                }

                // Small delay between batches to prevent overwhelming the system
                try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
            }

            // Reload widget timelines after successful migration
            if successCount > 0 {
                await reloadWidgetTimelines()
            }
        }
        catch {
            // ... silent error
        }
    }

    private func getMomentsWithPhotos() async throws -> [Moment] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let appDatabase = AppDatabase.shared
                let moments = try appDatabase.reader.read { db in
                    try Moment
                        .all()
                        .filter(sql: "photo IS NOT NULL AND photo != ''")
                        .fetchAll(db)
                }
                continuation.resume(returning: moments)
            }
            catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func processWidgetImagesForMoment(_ moment: Moment) async -> Bool {
        guard let photoFileName = moment.photo else {
            return false
        }

        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")

        // Check if widget images already exist
        let widget2x1Path = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName)_widget_2x1.jpg")
        let widget1x1Path = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName)_widget_1x1.jpg")

        if FileManager.default.fileExists(atPath: widget2x1Path.path) && FileManager.default.fileExists(atPath: widget1x1Path.path) {
            return true
        }

        // Load original image
        guard FileManager.default.fileExists(atPath: originalImagePath.path),
            let originalImage = UIImage(contentsOfFile: originalImagePath.path)
        else {
            return false
        }

        do {
            // Generate 2x1 aspect ratio (for medium widgets)
            let widget2x1Size = CGSize(width: screenWidth * 0.9, height: (screenWidth * 0.9) / 2.0)
            let widget2x1 = await ImageProcessingService.shared.processImage(originalImage, targetSize: widget2x1Size)
            try saveImage(widget2x1, to: widget2x1Path)

            // Generate 1x1 aspect ratio (for small widgets)
            let widget1x1Size = CGSize(width: screenWidth * 0.45, height: screenWidth * 0.45)
            let widget1x1 = await ImageProcessingService.shared.processImage(originalImage, targetSize: widget1x1Size)
            try saveImage(widget1x1, to: widget1x1Path)

            return true
        }
        catch {
            return false
        }
    }

    private func saveImage(_ image: UIImage, to url: URL) throws {
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else {
            throw RuntimeError("Failed to convert image to JPEG data")
        }
        try jpegData.write(to: url, options: [.atomic])
    }

    /// Check migration status
    var isMigrationCompleted: Bool {
        return userDefaults.bool(forKey: migrationKey)
    }

    /// Reset migration status (for testing)
    func resetMigrationStatus() {
        userDefaults.set(false, forKey: migrationKey)
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
