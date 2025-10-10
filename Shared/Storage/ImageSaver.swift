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

    // Get screen width for widget sizing
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    func writeToDisk() throws {
        if self.image == nil {
            throw RuntimeError("Image not defined")
        }

        // Save original image
        self.writeToDisk(image: self.image!, fileName: self.fileName)

        // Generate widget-optimized versions
        self.generateWidgetImages()
    }

    func writeToDisk(image: UIImage, fileName: String) {
        if let jpegData = image.jpegData(compressionQuality: 0.85) {
            try? jpegData.write(to: FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg"), options: [.atomic])
        }
    }

    // Generate widget-optimized images using intelligent processing
    private func generateWidgetImages() {
        guard let originalImage = self.image else { return }

        Task {
            // Generate 2x1 aspect ratio (for medium widgets)
            let widget2x1Size = CGSize(width: screenWidth * 0.9, height: (screenWidth * 0.9) / 2.0)
            let widget2x1 = await ImageProcessingService.shared.processImage(originalImage, targetSize: widget2x1Size)
            writeToDisk(image: widget2x1, fileName: "\(fileName)_widget_2x1")

            // Generate 1x1 aspect ratio (for small widgets)
            let widget1x1Size = CGSize(width: screenWidth * 0.45, height: screenWidth * 0.45)
            let widget1x1 = await ImageProcessingService.shared.processImage(originalImage, targetSize: widget1x1Size)
            writeToDisk(image: widget1x1, fileName: "\(fileName)_widget_1x1")
        }
    }

    func deleteFromDisk() {
        let fileManager = FileManager.default

        DispatchQueue.global(qos: .background).async {
            do {
                // Delete original image
                try fileManager.removeItem(at: self.filePath)

                // Delete widget variants
                let widget2x1Path = FileManager.documentsDirectory.appendingPathComponent("\(self.fileName)_widget_2x1.jpg")
                let widget1x1Path = FileManager.documentsDirectory.appendingPathComponent("\(self.fileName)_widget_1x1.jpg")

                try? fileManager.removeItem(at: widget2x1Path)
                try? fileManager.removeItem(at: widget1x1Path)
            }
            catch {
                print("Error removing file: \(error)")
            }
        }
    }

    func reloadWidgets() {
        // Reload widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
    }

}
