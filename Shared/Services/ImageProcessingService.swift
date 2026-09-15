//
//  ImageProcessingService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.05.24.
//

import UIKit

/// Renders and reads the pre-generated image variants for a photo.
///
/// `@unchecked Sendable` is justified here because the only stored state is an
/// `NSCache`, which is documented as thread-safe. (The previous version also
/// guarded a plain Swift `Set` behind a dispatch queue and kept an entire disk
/// cache that was never written to; both are gone.)
final class ImageProcessingService: @unchecked Sendable {
    static let shared = ImageProcessingService()

    private let cache = NSCache<NSString, UIImage>()

    /// Source images are normalized to this many pixels on their longest edge
    /// before analysis and cropping. It has to stay above the widest variant
    /// (1200px) so that cropping never has to upscale.
    private static let maxSourcePixelDimension: CGFloat = 2048

    /// Saliency and face detection run on a much smaller copy — the focal point
    /// is normalized, so the extra detail buys nothing but latency.
    private static let maxAnalysisPixelDimension: CGFloat = 512

    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
    }

    // MARK: - Reading pre-generated variants

    /// Loads the pre-generated variant for a photo, falling back to the
    /// original image when the variant hasn't been generated (yet).
    func processedImage(for fileName: String, variant: ImageVariant) -> UIImage? {
        let variantFileName = variant.fileName(for: fileName)

        if let cached = cache.object(forKey: variantFileName as NSString) {
            return cached
        }

        let variantURL = FileManager.documentsDirectory.appendingPathComponent("\(variantFileName).jpg")

        guard let image = UIImage(contentsOfFile: variantURL.path) else {
            let originalURL = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
            return UIImage(contentsOfFile: originalURL.path)
        }

        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: variantFileName as NSString, cost: cost)

        return image
    }

    /// Convenience for callers that only know the size they want to fill.
    func processedImage(for fileName: String, size: CGSize) -> UIImage? {
        processedImage(for: fileName, variant: .bestMatch(for: size))
    }

    // MARK: - Generating variants

    /// Crops `image` around its focal point and renders it at `variant`'s size.
    func processImage(_ image: UIImage, variant: ImageVariant) async -> UIImage? {
        // One orientation-correcting, downscaling pass. Everything after this
        // works in a single top-left origin pixel space.
        guard let source = normalizedCGImage(from: image, maxPixelDimension: Self.maxSourcePixelDimension) else {
            return nil
        }

        let focalPoint = await focalPoint(for: source)

        let sourceSize = CGSize(width: source.width, height: source.height)
        let rect = cropRect(in: sourceSize, aspectRatio: variant.aspectRatio, focalPoint: focalPoint)

        // `cropping(to:)` is a pure window onto the existing pixels, so the
        // only resampling in the whole pipeline is the final render below.
        guard let cropped = source.cropping(to: rect) else { return nil }

        return render(cropped, at: variant.pixelSize)
    }

    private func focalPoint(for source: CGImage) async -> CGPoint {
        guard let analysisImage = downscaledCGImage(source, maxPixelDimension: Self.maxAnalysisPixelDimension) else {
            return CGPoint(x: 0.5, y: 0.5)
        }

        return await ImageSaliencyService.focalPoint(for: analysisImage)
    }

    /// The largest rect with `aspectRatio` that fits inside `imageSize`,
    /// positioned so it is centered on `focalPoint` without leaving the image.
    ///
    /// Internal rather than private so `ImageCropTests` can pin the geometry;
    /// this is the part that decides whether a subject survives the crop.
    func cropRect(in imageSize: CGSize, aspectRatio: CGFloat, focalPoint: CGPoint) -> CGRect {
        var cropWidth = imageSize.width
        var cropHeight = cropWidth / aspectRatio

        if cropHeight > imageSize.height {
            cropHeight = imageSize.height
            cropWidth = cropHeight * aspectRatio
        }

        let focalX = focalPoint.x * imageSize.width
        let focalY = focalPoint.y * imageSize.height

        let x = min(max(0, focalX - cropWidth / 2), imageSize.width - cropWidth)
        let y = min(max(0, focalY - cropHeight / 2), imageSize.height - cropHeight)

        return CGRect(x: x, y: y, width: cropWidth, height: cropHeight).integral
    }

    // MARK: - Rendering helpers

    private func renderFormat() -> UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat.default()
        // Sizes throughout this service are explicit pixel counts. Without
        // this the renderer would silently multiply them by the screen scale.
        format.scale = 1
        format.opaque = true
        return format
    }

    /// Applies `image`'s EXIF orientation and downscales it, so that Vision and
    /// the crop both see the image the way the user sees it.
    private func normalizedCGImage(from image: UIImage, maxPixelDimension: CGFloat) -> CGImage? {
        let pixelSize = CGSize(
            width: image.size.width * image.scale,
            height: image.size.height * image.scale
        )

        guard pixelSize.width > 0, pixelSize.height > 0 else { return nil }

        let longestEdge = max(pixelSize.width, pixelSize.height)
        let factor = longestEdge > maxPixelDimension ? maxPixelDimension / longestEdge : 1
        let targetSize = CGSize(
            width: (pixelSize.width * factor).rounded(),
            height: (pixelSize.height * factor).rounded()
        )

        return autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: renderFormat())
            // `draw(in:)` honours imageOrientation, which is exactly the
            // normalization we want. `UIImage.cgImage` would not.
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }.cgImage
        }
    }

    private func downscaledCGImage(_ cgImage: CGImage, maxPixelDimension: CGFloat) -> CGImage? {
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let longestEdge = max(size.width, size.height)

        guard longestEdge > maxPixelDimension else { return cgImage }

        let factor = maxPixelDimension / longestEdge
        let targetSize = CGSize(width: (size.width * factor).rounded(), height: (size.height * factor).rounded())

        return autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: renderFormat())
            return renderer.image { _ in
                UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: targetSize))
            }.cgImage
        }
    }

    private func render(_ cgImage: CGImage, at size: CGSize) -> UIImage {
        autoreleasepool {
            let renderer = UIGraphicsImageRenderer(size: size, format: renderFormat())
            return renderer.image { _ in
                UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }

    // MARK: - Cache management

    /// Drops every in-memory variant.
    func clearCache() {
        cache.removeAllObjects()
    }

    /// Drops the in-memory variants belonging to one photo.
    func removeCachedImages(for fileName: String) {
        for variant in ImageVariant.allCases {
            cache.removeObject(forKey: variant.fileName(for: fileName) as NSString)
        }
    }
}
