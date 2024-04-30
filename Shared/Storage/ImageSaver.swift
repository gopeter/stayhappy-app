//
//  ImageSaver.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 18.02.24.
//  See: https://www.hackingwithswift.com/forums/swiftui/saving-and-displaying-images-using-the-image-picker/19338
//

import PhotosUI

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) ->Void)?

    func writeToDisk(image: UIImage, imageName: String) {
        let savePath = FileManager.documentsDirectory.appendingPathComponent("\(imageName).jpg")
        if let jpegData = image.jpegData(compressionQuality: 0.85) {
            try? jpegData.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
    }
    
    func deleteFromDisk(imageName: String) {
        let fileUrl = FileManager.documentsDirectory.appendingPathComponent("\(imageName).jpg")
        let fileManager = FileManager.default

        DispatchQueue.global(qos: .background).async {
            do {
                try fileManager.removeItem(at: fileUrl)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
}
