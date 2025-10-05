//
//  ImageSaver.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 18.02.24.
//  See: https://www.hackingwithswift.com/forums/swiftui/saving-and-displaying-images-using-the-image-picker/19338
//

import PhotosUI
import SwiftUI
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

    func writeToDisk() throws {
        if self.image == nil {
            throw RuntimeError("Image not defined")
        }

        self.writeToDisk(image: self.image!, fileName: self.fileName)
    }

    func writeToDisk(image: UIImage, fileName: String) {
        if let jpegData = image.jpegData(compressionQuality: 0.85) {
            try? jpegData.write(to: FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg"), options: [.atomic])
        }
    }

    func deleteFromDisk() {
        let fileManager = FileManager.default

        DispatchQueue.global(qos: .background).async {
            do {
                try fileManager.removeItem(at: self.filePath)
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
