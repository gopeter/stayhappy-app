//
//  ImageSaver.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 18.02.24.
//  See: https://www.hackingwithswift.com/forums/swiftui/saving-and-displaying-images-using-the-image-picker/19338
//

import PhotosUI
import SwiftUI
import UIKit
import WidgetKit

class ImageSaver {
    var image: UIImage?
    var fileName: String
    var filePath: URL

    init(image: UIImage? = nil, fileName: String) {
        self.image = image
        self.fileName = fileName
        self.filePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
    }

    /// Writes the original photo and all of its variants to disk.
    ///
    /// This is `async` on purpose: the variants used to be generated in a
    /// detached `Task` that nobody awaited, so callers went on to reload the
    /// widget timelines before the files existed — and the widget then rendered
    /// the uncropped original as a fallback.
    func writeToDisk() async throws {
        guard let image else {
            throw RuntimeError("Image not defined")
        }

        writeToDisk(image: image, fileName: fileName)
        await generateVariants(from: image)

        // The previous generation of variants for this name is now stale.
        ImageProcessingService.shared.removeCachedImages(for: fileName)
    }

    func writeToDisk(image: UIImage, fileName: String) {
        if let jpegData = image.jpegData(compressionQuality: 0.85) {
            try? jpegData.write(to: FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg"), options: [.atomic])
        }
    }

    private func generateVariants(from image: UIImage) async {
        for variant in ImageVariant.allCases {
            guard let processed = await ImageProcessingService.shared.processImage(image, variant: variant) else {
                continue
            }

            writeToDisk(image: processed, fileName: variant.fileName(for: fileName))
        }
    }

    func deleteFromDisk() {
        let fileManager = FileManager.default
        let fileName = self.fileName
        let filePath = self.filePath

        ImageProcessingService.shared.removeCachedImages(for: fileName)

        Task.detached(priority: .utility) {
            try? fileManager.removeItem(at: filePath)

            // Driven off ImageVariant, so a newly added variant is cleaned up
            // automatically instead of being orphaned on disk forever.
            for variant in ImageVariant.allCases {
                let variantPath = FileManager.documentsDirectory
                    .appendingPathComponent("\(variant.fileName(for: fileName)).jpg")
                try? fileManager.removeItem(at: variantPath)
            }
        }
    }

    func reloadWidgets() {
        // Reload widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
    }

}
