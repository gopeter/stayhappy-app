//
//  ImageProcessingService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.05.24.
//

import UIKit

final class ImageProcessingService: @unchecked Sendable {
    static let shared = ImageProcessingService()

    private var cache: NSCache<NSString, UIImage> = NSCache()
    private var cacheKeys: Set<String> = Set()
    private let cacheQueue = DispatchQueue(label: "ImageProcessingService.cache", attributes: .concurrent)

    private init() {
        cache.countLimit = 50  // Limit cache to 50 images
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB limit
    }

    // MARK: - Public Interface

    /// Generates a processed image for the given widget size
    /// - Parameters:
    ///   - fileName: The base filename of the image
    ///   - widgetSize: The actual widget size from GeometryReader
    /// - Returns: Processed UIImage or nil if not found
    func getProcessedImage(for fileName: String, widgetSize: CGSize) async -> UIImage? {
        let cacheKey = "\(fileName)-\(Int(widgetSize.width))x\(Int(widgetSize.height))"

        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            return nil
        }

        // Process image with device scale
        let deviceScale = await UIScreen.main.scale
        let targetSize = CGSize(width: widgetSize.width * deviceScale, height: widgetSize.height * deviceScale)
        let processedImage = await processImage(originalImage, targetSize: targetSize)

        // Cache the result with cost (image size in bytes)
        let cost = Int(processedImage.size.width * processedImage.size.height * 4)  // 4 bytes per pixel (RGBA)
        cacheQueue.async(flags: .barrier) {
            self.cache.setObject(processedImage, forKey: cacheKey as NSString, cost: cost)
            self.cacheKeys.insert(cacheKey)
        }

        return processedImage
    }

    /// Generates a processed image for a custom size (used in main app views)
    /// - Parameters:
    ///   - fileName: The base filename of the image
    ///   - targetSize: The target size for the processed image
    /// - Returns: Processed UIImage or nil if not found
    func getProcessedImage(for fileName: String, targetSize: CGSize) async -> UIImage? {
        let cacheKey = "\(fileName)-\(Int(targetSize.width))x\(Int(targetSize.height))"

        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            return nil
        }

        // Process image
        let processedImage = await processImage(originalImage, targetSize: targetSize)

        // Cache the result with cost (image size in bytes)
        let cost = Int(processedImage.size.width * processedImage.size.height * 4)  // 4 bytes per pixel (RGBA)
        cacheQueue.async(flags: .barrier) {
            self.cache.setObject(processedImage, forKey: cacheKey as NSString, cost: cost)
            self.cacheKeys.insert(cacheKey)
        }

        return processedImage
    }

    // MARK: - Private Processing Methods

    private func processImage(_ image: UIImage, targetSize: CGSize) async -> UIImage {
        // Get focal point using ImageSaliency
        let imageSaliency = ImageSaliencyService(uiImage: image)
        let focalPoint = imageSaliency.focalPoint()

        // Generate cropped thumbnail
        return await generateCroppedThumbnail(from: image, with: targetSize, around: focalPoint)
    }

    private func generateCroppedThumbnail(from sourceImage: UIImage, with size: CGSize, around sourceOrigin: CGPoint) async -> UIImage {
        let image = await generateThumbnail(from: sourceImage, size: size)

        let origin = CGPoint(x: sourceOrigin.x * image.size.width, y: sourceOrigin.y * image.size.height)
        let originX = min(max(origin.x - size.width / 2, 0), image.size.width - size.width)
        let originY = min(max(origin.y - size.height / 2, 0), image.size.height - size.height)

        let thumbnailRect = CGRect(x: originX, y: originY, width: size.width, height: size.height)

        // Crop the image
        if let croppedImage = image.cgImage?.cropping(to: thumbnailRect) {
            return UIImage(cgImage: croppedImage)
        }
        else {
            print("Cropping failed")
            return image
        }
    }

    private func generateThumbnail(from sourceImage: UIImage, size: CGSize) async -> UIImage {
        let sourceImagesize = sourceImage.size
        let aspectRatio = sourceImagesize.width / sourceImagesize.height

        // Calculate the new dimensions to ensure we have at least the required size
        var newWidth = size.width
        var newHeight = size.width / aspectRatio

        // If the new height is lower than the given height, recalculate by starting with the given height
        if newHeight < size.height {
            newHeight = size.height
            newWidth = newHeight * aspectRatio
        }

        let targetSize = CGSize(width: newWidth, height: newHeight)

        // Use UIGraphicsImageRenderer for better performance and memory management
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // MARK: - Cache Management

    /// Clears the entire image cache
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.cache.removeAllObjects()
            self.cacheKeys.removeAll()
        }
    }

    /// Removes cached images for a specific filename
    /// - Parameter fileName: The base filename to remove from cache
    func removeCachedImages(for fileName: String) {
        cacheQueue.async(flags: .barrier) {
            let keysToRemove = self.cacheKeys.filter { $0.hasPrefix(fileName) }
            for key in keysToRemove {
                self.cache.removeObject(forKey: key as NSString)
                self.cacheKeys.remove(key)
            }
        }
    }
}
