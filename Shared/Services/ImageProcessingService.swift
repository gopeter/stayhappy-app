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

    // Disk cache directory
    private let diskCacheDirectory: URL

    private init() {
        cache.countLimit = 50  // Limit cache to 50 images
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB limit

        // Setup disk cache directory
        diskCacheDirectory = FileManager.documentsDirectory.appendingPathComponent("ProcessedImageCache", isDirectory: true)
        createCacheDirectoryIfNeeded()
    }

    private func createCacheDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            // Silent failure - cache will be disabled if directory can't be created
        }
    }

    // MARK: - Public Interface

    /// Gets the appropriate pre-generated widget image
    /// - Parameters:
    ///   - fileName: The base filename of the image
    ///   - size: The widget size (used to determine aspect ratio)
    /// - Returns: Pre-generated widget image or nil if not found
    func getProcessedImage(for fileName: String, size: CGSize) async -> UIImage? {
        // Determine which pre-generated image to use based on aspect ratio
        let aspectRatio = size.width / size.height
        let widgetSuffix: String

        if aspectRatio > 1.5 {
            // Wide widget (medium) - use 2x1 variant
            widgetSuffix = "_widget_2x1"
        }
        else {
            // Square-ish widget (small) - use 1x1 variant
            widgetSuffix = "_widget_1x1"
        }

        let widgetFileName = "\(fileName)\(widgetSuffix)"
        let cacheKey = "\(widgetFileName)-\(Int(size.width))x\(Int(size.height))"

        // Check memory cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        // Try to load pre-generated widget image
        let widgetImagePath = FileManager.documentsDirectory.appendingPathComponent("\(widgetFileName).jpg")
        guard let widgetImage = UIImage(contentsOfFile: widgetImagePath.path) else {
            // Fallback: try original image if widget image doesn't exist
            let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
            return UIImage(contentsOfFile: originalImagePath.path)
        }

        // Cache the widget image in memory
        let cost = Int(widgetImage.size.width * widgetImage.size.height * 4)
        cacheQueue.async(flags: .barrier) {
            self.cache.setObject(widgetImage, forKey: cacheKey as NSString, cost: cost)
            self.cacheKeys.insert(cacheKey)
        }

        return widgetImage
    }

    // MARK: - Private Processing Methods

    public func processImage(_ image: UIImage, targetSize: CGSize) async -> UIImage {
        let focalPoint = await getSalientFocalPoint(image)

        // Scale down first to avoid memory issues with large images
        let scaledImage = await scaleImageDown(image, maxDimension: 1024)

        // Then intelligent crop around focal point
        let result = await intelligentScaleAndCrop(scaledImage, targetSize: targetSize, focalPoint: focalPoint)
        return result
    }

    private func getSalientFocalPoint(_ originalImage: UIImage) async -> CGPoint {
        // Create very small image ONLY for saliency (512px max)
        let saliencyImage = await scaleImageDown(originalImage, maxDimension: 512)

        // Use saliency on small image
        let imageSaliency = ImageSaliencyService(uiImage: saliencyImage)
        let focalPoint = await imageSaliency.focalPoint()

        return focalPoint
    }

    private func scaleImageDown(_ image: UIImage, maxDimension: CGFloat) async -> UIImage {
        let currentSize = image.size
        if max(currentSize.width, currentSize.height) <= maxDimension {
            return image
        }

        let scale = maxDimension / max(currentSize.width, currentSize.height)
        let newSize = CGSize(width: currentSize.width * scale, height: currentSize.height * scale)

        return autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: newSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
    }

    private func intelligentScaleAndCrop(_ image: UIImage, targetSize: CGSize, focalPoint: CGPoint) async -> UIImage {
        // Step 1: Crop around focal point
        let croppedImage = await cropAroundFocalPoint(image, focalPoint: focalPoint, targetAspectRatio: targetSize.width / targetSize.height)

        // Step 2: Scale to target size
        return await scaleToFinalSize(croppedImage, targetSize: targetSize)
    }

    private func cropAroundFocalPoint(_ image: UIImage, focalPoint: CGPoint, targetAspectRatio: CGFloat) async -> UIImage {
        let sourceSize = image.size
        let sourceAspectRatio = sourceSize.width / sourceSize.height

        // Calculate crop dimensions maintaining target aspect ratio
        let cropWidth: CGFloat
        let cropHeight: CGFloat

        if sourceAspectRatio > targetAspectRatio {
            // Image is wider - base on height
            cropHeight = sourceSize.height
            cropWidth = cropHeight * targetAspectRatio
        }
        else {
            // Image is taller - base on width
            cropWidth = sourceSize.width
            cropHeight = cropWidth / targetAspectRatio
        }

        // Calculate crop position centered around focal point
        let focalX = focalPoint.x * sourceSize.width
        let focalY = focalPoint.y * sourceSize.height

        let cropX = max(0, min(focalX - cropWidth / 2, sourceSize.width - cropWidth))
        let cropY = max(0, min(focalY - cropHeight / 2, sourceSize.height - cropHeight))

        return autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropWidth, height: cropHeight))
            return renderer.image { _ in
                // Draw the image with offset to crop the desired region
                image.draw(at: CGPoint(x: -cropX, y: -cropY))
            }
        }
    }

    private func scaleToFinalSize(_ image: UIImage, targetSize: CGSize) async -> UIImage {
        return autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
    }

    // MARK: - Disk Cache Methods

    private func saveToDiskCache(image: UIImage, cacheKey: String) async {
        let cacheFileURL = diskCacheDirectory.appendingPathComponent("\(cacheKey).jpg")

        guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
            return
        }

        do {
            try jpegData.write(to: cacheFileURL)
        }
        catch {
            // Silent failure for cache operations
        }
    }

    private func loadFromDiskCache(cacheKey: String) async -> UIImage? {
        let cacheFileURL = diskCacheDirectory.appendingPathComponent("\(cacheKey).jpg")

        guard FileManager.default.fileExists(atPath: cacheFileURL.path) else {
            return nil
        }

        return UIImage(contentsOfFile: cacheFileURL.path)
    }

    private func removeFromDiskCache(cacheKey: String) {
        let cacheFileURL = diskCacheDirectory.appendingPathComponent("\(cacheKey).jpg")

        do {
            try FileManager.default.removeItem(at: cacheFileURL)
        }
        catch {
            // Silent failure for cache operations
        }
    }

    // MARK: - Cache Management

    /// Clears the entire image cache (both memory and disk)
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.cache.removeAllObjects()
            self.cacheKeys.removeAll()
        }

        // Clear disk cache
        Task {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: diskCacheDirectory, includingPropertiesForKeys: nil)
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            }
            catch {
                // Silent failure for cache operations
            }
        }
    }

    /// Removes cached images for a specific filename (both memory and disk)
    /// - Parameter fileName: The base filename to remove from cache
    func removeCachedImages(for fileName: String) {
        cacheQueue.async(flags: .barrier) {
            let keysToRemove = self.cacheKeys.filter { $0.hasPrefix(fileName) }
            for key in keysToRemove {
                self.cache.removeObject(forKey: key as NSString)
                self.cacheKeys.remove(key)

                // Remove from disk cache too
                Task {
                    self.removeFromDiskCache(cacheKey: key)
                }
            }
        }
    }
}
