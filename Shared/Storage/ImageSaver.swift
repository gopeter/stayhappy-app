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
            try? jpegData.write(to: FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg"), options: [.atomic, .completeFileProtection])
        }
    }
    
    func deleteFromDisk() {
        let fileManager = FileManager.default

        DispatchQueue.global(qos: .background).async {
            do {
                try fileManager.removeItem(at: self.filePath)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    func generateWidgetThumbnails() throws {
        if self.image == nil {
            throw RuntimeError("Image not defined")
        }
        
        Task {
            // Get focus point of image with Apple's Saliency tools
            let imageSaliency = ImageSaliencyService(uiImage: self.image!)
            let focalPoint = imageSaliency.focalPoint()
            let sizes: [WidgetFamily] = [.systemSmall, .systemMedium]
            
            for widgetFamily in sizes {
                let deviceScale = await UIScreen.main.scale
                let widgetSize = getWidgetSize(for: widgetFamily)
                let size = CGSize(width: widgetSize.width * deviceScale, height: widgetSize.height * deviceScale)
                let thumbnailImage = await self.generateCroppedThumbnail(from: self.image!, with: size, around: CGPoint(x: focalPoint.x, y: focalPoint.y))
                self.writeToDisk(image: thumbnailImage, fileName: "\(self.fileName)-\(widgetFamily)")
            }
            
            // Reload widget once thumbnails are written
            WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
        }
    }
    
    private func generateThumbnail(size: CGSize) async -> UIImage {
        let sourceImagesize = image!.size
        let aspectRatio = sourceImagesize.width / sourceImagesize.height
        
        // Calling the QuicklookService with the new dimensions can result into smaller images, since the QuicklookService keeps the aspect ratio
        // But we want an image that has **at least** this dimension, so we may need to increase on side
        
        // Let's start the calculation with the new given width
        var newWidth = size.width
        var newHeight = size.width / aspectRatio
        
        // If the new height is lower than the given height, recalculate by starting with the given height
        if newHeight < size.height {
            newHeight = size.height
            newWidth = newHeight * aspectRatio
        }
        
        return await QuicklookService().image(for: self.filePath, size: CGSize(width: newWidth, height: newHeight), scale: 1)
    }
    
    private func generateCroppedThumbnail(from sourceImage: UIImage, with size: CGSize, around sourceOrigin: CGPoint) async -> UIImage {
        let image = await generateThumbnail(size: size)
        
        let origin = CGPoint(x: sourceOrigin.x * image.size.width, y: sourceOrigin.y * image.size.height)
        let originX = min(max(origin.x - size.width / 2, 0), image.size.width - size.width)
        let originY = min(max(origin.y - size.height / 2, 0), image.size.height - size.height)
        
        let thumbnailRect = CGRect(x: originX, y: originY, width: size.width, height: size.height)
        
        // Crop the image
        if let croppedImage = image.cgImage?.cropping(to: thumbnailRect) {
            return UIImage(cgImage: croppedImage)
        } else {
            print("Cropping failed")
            return image
        }
    }
}
 
