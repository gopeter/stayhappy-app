//
//  ImageSaliencyService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 11.05.24.
//  Rewritten using modern Vision async/await API
//

import CoreGraphics
import Foundation
import Vision

/// Finds the point an image should be cropped around.
///
/// Callers pass a CGImage whose orientation has already been normalized (see
/// `ImageProcessingService`), so every coordinate here lives in the same
/// top-left origin space the crop later uses.
enum ImageSaliencyService {

    /// The focal point as a normalized coordinate with a top-left origin.
    ///
    /// Faces win over generic saliency: for an app about personal memories the
    /// subject is usually a person, and attention-based saliency happily
    /// centers on a bright sky or a colourful sign instead.
    static func focalPoint(for cgImage: CGImage) async -> CGPoint {
        if let facePoint = await faceFocalPoint(for: cgImage) {
            return facePoint
        }

        if let salientPoint = await salientFocalPoint(for: cgImage) {
            return salientPoint
        }

        return CGPoint(x: 0.5, y: 0.5)
    }

    // MARK: - Faces

    private static func faceFocalPoint(for cgImage: CGImage) async -> CGPoint? {
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        do {
            let request = DetectFaceRectanglesRequest()
            let faces = try await request.perform(on: cgImage)

            guard !faces.isEmpty else { return nil }

            // Union of all faces, so group photos stay centered on the group
            // rather than on whichever face Vision happened to report first.
            let boxes = faces.map { $0.boundingBox.toImageCoordinates(imageSize, origin: .upperLeft) }
            guard var union = boxes.first else { return nil }
            for box in boxes.dropFirst() {
                union = union.union(box)
            }

            return CGPoint(
                x: clamped(union.midX / imageSize.width),
                y: clamped(union.midY / imageSize.height)
            )
        }
        catch {
            return nil
        }
    }

    // MARK: - Attention-based saliency

    private static func salientFocalPoint(for cgImage: CGImage) async -> CGPoint? {
        do {
            let request = GenerateAttentionBasedSaliencyImageRequest()
            let observation = try await request.perform(on: cgImage)

            guard let primaryObject = observation.salientObjects.first else {
                return nil
            }

            let boundingBox = primaryObject.boundingBox

            let centerX = boundingBox.origin.x + boundingBox.width / 2
            // Vision reports a bottom-left origin; the crop expects top-left.
            let centerY = 1.0 - (boundingBox.origin.y + boundingBox.height / 2)

            return CGPoint(x: clamped(centerX), y: clamped(centerY))
        }
        catch {
            return nil
        }
    }

    // MARK: - Helpers

    private static func clamped(_ value: CGFloat) -> CGFloat {
        max(0.0, min(1.0, value))
    }
}
