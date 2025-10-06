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
        print("DEBUG ImageProcessingService: getProcessedImage for widget - fileName: \(fileName), widgetSize: \(widgetSize), cacheKey: \(cacheKey)")

        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            print("DEBUG ImageProcessingService: Found cached image for \(cacheKey)")
            return cachedImage
        }

        print("DEBUG ImageProcessingService: No cached image found, processing new image")

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        print("DEBUG ImageProcessingService: Loading image from path: \(originalImagePath.path)")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            print("DEBUG ImageProcessingService: Failed to load original image from path: \(originalImagePath.path)")
            return nil
        }
        print("DEBUG ImageProcessingService: Loaded original image with size: \(originalImage.size)")

        // Process image with device scale
        let deviceScale = UIScreen.main.scale
        let targetSize = CGSize(width: widgetSize.width * deviceScale, height: widgetSize.height * deviceScale)
        print("DEBUG ImageProcessingService: Device scale: \(deviceScale), scaled target size: \(targetSize)")
        let processedImage = await processImage(originalImage, targetSize: targetSize)
        print("DEBUG ImageProcessingService: processImage result: \(processedImage != nil ? "SUCCESS" : "FAILED")")

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
        print("DEBUG ImageProcessingService: getProcessedImage for target size - fileName: \(fileName), targetSize: \(targetSize), cacheKey: \(cacheKey)")

        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            print("DEBUG ImageProcessingService: Found cached image for \(cacheKey)")
            return cachedImage
        }

        print("DEBUG ImageProcessingService: No cached image found, processing new image")

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        print("DEBUG ImageProcessingService: Loading image from path: \(originalImagePath.path)")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            print("DEBUG ImageProcessingService: Failed to load original image from path: \(originalImagePath.path)")
            return nil
        }
        print("DEBUG ImageProcessingService: Loaded original image with size: \(originalImage.size)")

        // Process image
        print("DEBUG ImageProcessingService: Processing image with target size: \(targetSize)")
        let processedImage = await processImage(originalImage, targetSize: targetSize)
        print("DEBUG ImageProcessingService: processImage result: \(processedImage != nil ? "SUCCESS" : "FAILED")")

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
        print("DEBUG ImageProcessingService: processImage called with image size: \(image.size), target size: \(targetSize)")

        // Get focal point using modern async saliency analysis
        let focalPoint = await getSalientFocalPoint(for: image)
        print("DEBUG ImageProcessingService: Using focal point: \(focalPoint)")

        // Generate cropped thumbnail
        print("DEBUG ImageProcessingService: Generating cropped thumbnail")
        let result = await generateCroppedThumbnail(from: image, with: targetSize, around: focalPoint)
        print("DEBUG ImageProcessingService: Generated thumbnail size: \(result.size)")
        return result
    }

    private func getSalientFocalPoint(for image: UIImage) async -> CGPoint {
        print("DEBUG ImageProcessingService: Starting modern async saliency analysis")

        // Optimize image for saliency analysis
        let optimizedImage = await optimizeImageForSaliency(image)
        print("DEBUG ImageProcessingService: Optimized image size for saliency: \(optimizedImage.size)")

        // Use modern async ImageSaliencyService
        let imageSaliency = ImageSaliencyService(uiImage: optimizedImage)
        let focalPoint = await imageSaliency.focalPoint()

        print("DEBUG ImageProcessingService: Saliency focal point: \(focalPoint)")
        return focalPoint
    }

    private func generateCroppedThumbnail(from sourceImage: UIImage, with size: CGSize, around sourceOrigin: CGPoint) async -> UIImage {
        print("DEBUG ImageProcessingService: generateCroppedThumbnail - source size: \(sourceImage.size), target size: \(size), focal point: \(sourceOrigin)")

        let image = await generateThumbnail(from: sourceImage, size: size)
        print("DEBUG ImageProcessingService: generateThumbnail result size: \(image.size)")

        let origin = CGPoint(x: sourceOrigin.x * image.size.width, y: sourceOrigin.y * image.size.height)
        let originX = min(max(origin.x - size.width / 2, 0), image.size.width - size.width)
        let originY = min(max(origin.y - size.height / 2, 0), image.size.height - size.height)

        let thumbnailRect = CGRect(x: originX, y: originY, width: size.width, height: size.height)
        print("DEBUG ImageProcessingService: Crop rect: \(thumbnailRect)")

        // Crop the image
        if let croppedImage = image.cgImage?.cropping(to: thumbnailRect) {
            let result = UIImage(cgImage: croppedImage)
            print("DEBUG ImageProcessingService: Cropping successful, final size: \(result.size)")
            return result
        }
        else {
            print("DEBUG ImageProcessingService: Cropping failed, returning resized image")
            return image
        }
    }

    private func generateThumbnail(from sourceImage: UIImage, size: CGSize) async -> UIImage {
        let sourceImagesize = sourceImage.size
        let aspectRatio = sourceImagesize.width / sourceImagesize.height
        print("DEBUG ImageProcessingService: generateThumbnail - source: \(sourceImagesize), target: \(size), aspect ratio: \(aspectRatio)")

        // Calculate the new dimensions to ensure we have at least the required size
        var newWidth = size.width
        var newHeight = size.width / aspectRatio

        // If the new height is lower than the given height, recalculate by starting with the given height
        if newHeight < size.height {
            newHeight = size.height
            newWidth = newHeight * aspectRatio
        }

        let targetSize = CGSize(width: newWidth, height: newHeight)
        print("DEBUG ImageProcessingService: Calculated target size: \(targetSize)")

        // Use UIGraphicsImageRenderer for better performance and memory management
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let result = renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        print("DEBUG ImageProcessingService: Rendered image size: \(result.size)")
        return result
    }

    private func optimizeImageForSaliency(_ image: UIImage) async -> UIImage {
        // For saliency analysis, we don't need huge images - resize to max 1024px on the longest side
        let maxDimension: CGFloat = 1024
        let currentSize = image.size

        if max(currentSize.width, currentSize.height) <= maxDimension {
            print("DEBUG ImageProcessingService: Image already small enough for saliency analysis")
            return image
        }

        let scale = maxDimension / max(currentSize.width, currentSize.height)
        let newSize = CGSize(width: currentSize.width * scale, height: currentSize.height * scale)

        print("DEBUG ImageProcessingService: Resizing image for saliency from \(currentSize) to \(newSize)")

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let result = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        print("DEBUG ImageProcessingService: Optimized image created with size: \(result.size)")
        return result
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
