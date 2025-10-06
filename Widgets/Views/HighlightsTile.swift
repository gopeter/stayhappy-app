//
//  HighlightsTile.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI
import Vision
import WidgetKit

enum ImageSize: String, CaseIterable {
    case systemSmall
    case systemMedium
}

struct HighlightsTile: View {
    var highlight: Moment
    @State private var photoImage: UIImage?
    var size: ImageSize

    init(highlights: [Moment], size: ImageSize) {
        self.highlight = highlights[0]
        self.size = size
    }

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(
                    photoImage == nil
                        ? HappyGradients(rawValue: highlight.background)!.radial(startRadius: -50, endRadius: geometry.size.width)
                        : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0)
                )
                .frame(maxWidth: .infinity)
                .background {
                    if photoImage != nil {
                        Image(uiImage: photoImage!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                }
                .overlay {
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 3) {
                                Spacer()
                                Text(highlight.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(.white)
                                    .font(.caption)
                                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                    .padding(0)

                                Text(highlight.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                    .padding(0)
                            }

                            Spacer()
                        }
                    }
                    .padding(16)

                }
                .widgetURL(URL(string: "stayhappy://highlights/image/\(highlight.id)"))
                .onAppear {
                    loadImage(widgetSize: geometry.size)
                }
        }
    }

    private func loadImage(widgetSize: CGSize) {
        guard let photoFileName = highlight.photo else {
            print("DEBUG HighlightsTile: No photo filename for highlight \(highlight.id)")
            return
        }

        print("DEBUG HighlightsTile: Loading image '\(photoFileName)' with widget size: \(widgetSize)")

        Task {
            let processedImage = await processImageForWidget(
                fileName: photoFileName,
                targetSize: widgetSize
            )

            print("DEBUG HighlightsTile: Processed image result: \(processedImage != nil ? "SUCCESS" : "FAILED")")
            if let image = processedImage {
                print("DEBUG HighlightsTile: Processed image size: \(image.size)")
            }

            await MainActor.run {
                photoImage = processedImage
                print("DEBUG HighlightsTile: Set photoImage on main thread")
            }
        }
    }

    // MARK: - Local Image Processing

    private func processImageForWidget(fileName: String, targetSize: CGSize) async -> UIImage? {
        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        print("DEBUG HighlightsTile: Looking for image at path: \(originalImagePath.path)")

        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            print("DEBUG HighlightsTile: Failed to load original image from path: \(originalImagePath.path)")
            return nil
        }

        print("DEBUG HighlightsTile: Loaded original image with size: \(originalImage.size)")

        // Calculate size with device scale
        let deviceScale = UIScreen.main.scale
        let scaledTargetSize = CGSize(width: targetSize.width * deviceScale, height: targetSize.height * deviceScale)
        print("DEBUG HighlightsTile: Device scale: \(deviceScale), target size: \(targetSize), scaled target size: \(scaledTargetSize)")

        // Get focal point using local saliency detection
        let focalPoint = await getFocalPoint(for: originalImage)
        print("DEBUG HighlightsTile: Focal point: \(focalPoint)")

        // Process image
        let result = await generateCroppedThumbnail(from: originalImage, with: scaledTargetSize, around: focalPoint)
        print("DEBUG HighlightsTile: Generate cropped thumbnail result: \(result != nil ? "SUCCESS" : "FAILED")")
        return result
    }

    private func getFocalPoint(for image: UIImage) async -> CGPoint {
        guard let cgImage = image.cgImage else {
            print("DEBUG HighlightsTile: Failed to get CGImage from UIImage")
            return CGPoint(x: 0.5, y: 0.5)
        }

        print("DEBUG HighlightsTile: Starting saliency detection for image")

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNGenerateAttentionBasedSaliencyImageRequest()

        #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            print("DEBUG HighlightsTile: Using CPU-only mode for simulator")
        #endif

        do {
            try requestHandler.perform([request])
            print("DEBUG HighlightsTile: Saliency request performed successfully")

            guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                print("DEBUG HighlightsTile: No saliency observation found")
                return CGPoint(x: 0.5, y: 0.5)
            }

            guard let boundingBox = observation.salientObjects?.first?.boundingBox else {
                print("DEBUG HighlightsTile: No salient objects found, using center")
                return CGPoint(x: 0.5, y: 0.5)
            }

            print("DEBUG HighlightsTile: Found salient object with bounding box: \(boundingBox)")

            let imageRect = VNImageRectForNormalizedRect(boundingBox, Int(image.size.width), Int(image.size.height))
            let centerX = (imageRect.origin.x + imageRect.width / 2) / image.size.width
            let centerY = (imageRect.origin.y + imageRect.height / 2) / image.size.height

            let focalPoint = CGPoint(x: centerX, y: 1.0 - centerY)  // Convert from Core Image to UIKit coordinates
            print("DEBUG HighlightsTile: Calculated focal point: \(focalPoint)")
            return focalPoint
        }
        catch {
            print("DEBUG HighlightsTile: Saliency detection failed with error: \(error)")
            return CGPoint(x: 0.5, y: 0.5)
        }
    }

    private func generateCroppedThumbnail(from sourceImage: UIImage, with size: CGSize, around sourceOrigin: CGPoint) async -> UIImage {
        print("DEBUG HighlightsTile: generateCroppedThumbnail - source size: \(sourceImage.size), target size: \(size), focal point: \(sourceOrigin)")

        let image = await generateThumbnail(from: sourceImage, size: size)
        print("DEBUG HighlightsTile: generateThumbnail result size: \(image.size)")

        let origin = CGPoint(x: sourceOrigin.x * image.size.width, y: sourceOrigin.y * image.size.height)
        let originX = min(max(origin.x - size.width / 2, 0), image.size.width - size.width)
        let originY = min(max(origin.y - size.height / 2, 0), image.size.height - size.height)

        let thumbnailRect = CGRect(x: originX, y: originY, width: size.width, height: size.height)
        print("DEBUG HighlightsTile: Crop rect: \(thumbnailRect)")

        if let croppedImage = image.cgImage?.cropping(to: thumbnailRect) {
            let result = UIImage(cgImage: croppedImage)
            print("DEBUG HighlightsTile: Cropping successful, final size: \(result.size)")
            return result
        }
        else {
            print("DEBUG HighlightsTile: Cropping failed, returning original resized image")
            return image
        }
    }

    private func generateThumbnail(from sourceImage: UIImage, size: CGSize) async -> UIImage {
        let sourceImagesize = sourceImage.size
        let aspectRatio = sourceImagesize.width / sourceImagesize.height
        print("DEBUG HighlightsTile: generateThumbnail - source: \(sourceImagesize), target: \(size), aspect ratio: \(aspectRatio)")

        var newWidth = size.width
        var newHeight = size.width / aspectRatio

        if newHeight < size.height {
            newHeight = size.height
            newWidth = newHeight * aspectRatio
        }

        let targetSize = CGSize(width: newWidth, height: newHeight)
        print("DEBUG HighlightsTile: Calculated target size: \(targetSize)")

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let result = renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        print("DEBUG HighlightsTile: Rendered image size: \(result.size)")
        return result
    }
}
