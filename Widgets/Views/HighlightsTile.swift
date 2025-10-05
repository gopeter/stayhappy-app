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
                    }.padding(.all)
                }
                .widgetURL(URL(string: "stayhappy://highlights/image/\(highlight.id)"))
                .onAppear {
                    loadImage(widgetSize: geometry.size)
                }
        }
    }

    private func loadImage(widgetSize: CGSize) {
        guard let photoFileName = highlight.photo else { return }

        Task {
            let processedImage = await processImageForWidget(
                fileName: photoFileName,
                targetSize: widgetSize
            )

            await MainActor.run {
                photoImage = processedImage
            }
        }
    }

    // MARK: - Local Image Processing

    private func processImageForWidget(fileName: String, targetSize: CGSize) async -> UIImage? {
        // Load original image
        let originalImagePath = FileManager.documentsDirectory.appendingPathComponent("\(fileName).jpg")
        guard let originalImage = UIImage(contentsOfFile: originalImagePath.path) else {
            return nil
        }

        // Calculate size with device scale
        let deviceScale = UIScreen.main.scale
        let scaledTargetSize = CGSize(width: targetSize.width * deviceScale, height: targetSize.height * deviceScale)

        // Get focal point using local saliency detection
        let focalPoint = await getFocalPoint(for: originalImage)

        // Process image
        return await generateCroppedThumbnail(from: originalImage, with: scaledTargetSize, around: focalPoint)
    }

    private func getFocalPoint(for image: UIImage) async -> CGPoint {
        guard let cgImage = image.cgImage else {
            return CGPoint(x: 0.5, y: 0.5)
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNGenerateAttentionBasedSaliencyImageRequest()

        #if targetEnvironment(simulator)
            request.usesCPUOnly = true
        #endif

        do {
            try requestHandler.perform([request])

            guard let observation = request.results?.first as? VNSaliencyImageObservation,
                let boundingBox = observation.salientObjects?.first?.boundingBox
            else {
                return CGPoint(x: 0.5, y: 0.5)
            }

            let imageRect = VNImageRectForNormalizedRect(boundingBox, Int(image.size.width), Int(image.size.height))
            let centerX = (imageRect.origin.x + imageRect.width / 2) / image.size.width
            let centerY = (imageRect.origin.y + imageRect.height / 2) / image.size.height

            return CGPoint(x: centerX, y: 1.0 - centerY)  // Convert from Core Image to UIKit coordinates
        }
        catch {
            return CGPoint(x: 0.5, y: 0.5)
        }
    }

    private func generateCroppedThumbnail(from sourceImage: UIImage, with size: CGSize, around sourceOrigin: CGPoint) async -> UIImage {
        let image = await generateThumbnail(from: sourceImage, size: size)

        let origin = CGPoint(x: sourceOrigin.x * image.size.width, y: sourceOrigin.y * image.size.height)
        let originX = min(max(origin.x - size.width / 2, 0), image.size.width - size.width)
        let originY = min(max(origin.y - size.height / 2, 0), image.size.height - size.height)

        let thumbnailRect = CGRect(x: originX, y: originY, width: size.width, height: size.height)

        if let croppedImage = image.cgImage?.cropping(to: thumbnailRect) {
            return UIImage(cgImage: croppedImage)
        }
        else {
            return image
        }
    }

    private func generateThumbnail(from sourceImage: UIImage, size: CGSize) async -> UIImage {
        let sourceImagesize = sourceImage.size
        let aspectRatio = sourceImagesize.width / sourceImagesize.height

        var newWidth = size.width
        var newHeight = size.width / aspectRatio

        if newHeight < size.height {
            newHeight = size.height
            newWidth = newHeight * aspectRatio
        }

        let targetSize = CGSize(width: newWidth, height: newHeight)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
