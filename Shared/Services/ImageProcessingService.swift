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

    /// Generates a processed image for the given widget size
    /// - Parameters:
    ///   - fileName: The base filename of the image
    ///   - widgetSize: The actual widget size from GeometryReader
    /// - Returns: Processed UIImage or nil if not found
    func getProcessedImage(for fileName: String, widgetSize: CGSize) async -> UIImage? {
        let cacheKey = "\(fileName)-\(Int(widgetSize.width))x\(Int(widgetSize.height))"
        let cacheKeyNS = cacheKey as NSString

        // Check memory cache first
        if let cachedImage = cache.object(forKey: cacheKeyNS) {
            return cachedImage
        }

        // Check disk cache
        if let diskCachedImage = await loadFromDiskCache(cacheKey: cacheKey) {
            // Put it back in memory cache for faster access
            let cost = Int(diskCachedImage.size.width * diskCachedImage.size.height * 4)
            cacheQueue.async(flags: .barrier) {
                self.cache.setObject(diskCachedImage, forKey: cacheKeyNS, cost: cost)
                self.cacheKeys.insert(cacheKey)
            }
            return diskCachedImage
        }

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            return nil
        }

        // Process image with device scale
        let deviceScale = UIScreen.main.scale
        let targetSize = CGSize(width: widgetSize.width * deviceScale, height: widgetSize.height * deviceScale)
        let processedImage = await processImage(originalImage, targetSize: targetSize)

        // Cache the result in memory and disk
        let cost = Int(processedImage.size.width * processedImage.size.height * 4)  // 4 bytes per pixel (RGBA)
        cacheQueue.async(flags: .barrier) {
            self.cache.setObject(processedImage, forKey: cacheKeyNS, cost: cost)
            self.cacheKeys.insert(cacheKey)
        }

        // Save to disk cache asynchronously
        await saveToDiskCache(image: processedImage, cacheKey: cacheKey)

        return processedImage
    }

    /// Generates a processed image for a custom size (used in main app views)
    /// - Parameters:
    ///   - fileName: The base filename of the image
    ///   - targetSize: The target size for the processed image
    /// - Returns: Processed UIImage or nil if not found
    func getProcessedImage(for fileName: String, targetSize: CGSize) async -> UIImage? {
        let cacheKey = "\(fileName)-\(Int(targetSize.width))x\(Int(targetSize.height))"
        let cacheKeyNS = cacheKey as NSString

        // Check memory cache first
        if let cachedImage = cache.object(forKey: cacheKeyNS) {
            return cachedImage
        }

        // Check disk cache
        if let diskCachedImage = await loadFromDiskCache(cacheKey: cacheKey) {
            // Put it back in memory cache for faster access
            let cost = Int(diskCachedImage.size.width * diskCachedImage.size.height * 4)
            cacheQueue.async(flags: .barrier) {
                self.cache.setObject(diskCachedImage, forKey: cacheKeyNS, cost: cost)
                self.cacheKeys.insert(cacheKey)
            }
            return diskCachedImage
        }

        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            return nil
        }

        // Process image
        let processedImage = await processImage(originalImage, targetSize: targetSize)

        // Cache the result in memory and disk
        let cost = Int(processedImage.size.width * processedImage.size.height * 4)  // 4 bytes per pixel (RGBA)
        cacheQueue.async(flags: .barrier) {
            self.cache.setObject(processedImage, forKey: cacheKeyNS, cost: cost)
            self.cacheKeys.insert(cacheKey)
        }

        // Save to disk cache asynchronously
        await saveToDiskCache(image: processedImage, cacheKey: cacheKey)

        return processedImage
    }

    // MARK: - Private Processing Methods

    private func processImage(_ image: UIImage, targetSize: CGSize) async -> UIImage {
        // MEMORY-OPTIMIZED: Get focal point using small image for saliency
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
