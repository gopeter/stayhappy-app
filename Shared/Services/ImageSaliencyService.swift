//
//  ImageSaliencyService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 11.05.24.
//  Rewritten using modern Vision async/await API
//

import Foundation
import UIKit
import Vision

class ImageSaliencyService {
    private let image: UIImage

    // MARK: - Init

    init(uiImage: UIImage) {
        self.image = uiImage
    }

    // MARK: - Public Interface

    /// Returns the focal point as percentage using modern Vision async/await API
    func focalPoint() async -> CGPoint {
        print("DEBUG ImageSaliencyService: Starting modern async saliency analysis")

        do {
            let saliencyObservation = try await performSaliencyAnalysis()
            let focalPoint = calculateFocalPoint(from: saliencyObservation)
            print("DEBUG ImageSaliencyService: Successfully calculated focal point: \(focalPoint)")
            return focalPoint
        }
        catch {
            print("DEBUG ImageSaliencyService: Saliency analysis failed: \(error.localizedDescription)")
            print("DEBUG ImageSaliencyService: Using center point as fallback")
            return CGPoint(x: 0.5, y: 0.5)
        }
    }

    // MARK: - Private Methods

    private func performSaliencyAnalysis() async throws -> SaliencyImageObservation {
        print("DEBUG ImageSaliencyService: Converting UIImage to CGImage")
        guard let cgImage = image.cgImage else {
            throw SaliencyError.invalidImage
        }

        print("DEBUG ImageSaliencyService: Creating attention-based saliency request")
        let request = GenerateAttentionBasedSaliencyImageRequest()

        print("DEBUG ImageSaliencyService: Performing saliency analysis...")
        let observation = try await request.perform(on: cgImage)
        print("DEBUG ImageSaliencyService: Saliency analysis completed successfully")

        return observation
    }

    private func calculateFocalPoint(from observation: SaliencyImageObservation) -> CGPoint {
        print("DEBUG ImageSaliencyService: Processing saliency observation")

        // Check if we have salient objects
        guard !observation.salientObjects.isEmpty else {
            print("DEBUG ImageSaliencyService: No salient objects found, using center point")
            return CGPoint(x: 0.5, y: 0.5)
        }

        // Get the first (most prominent) salient object
        let primaryObject = observation.salientObjects.first!
        let boundingBox = primaryObject.boundingBox

        print("DEBUG ImageSaliencyService: Found salient object with bounding box: \(boundingBox)")

        // Calculate center of bounding box (Vision coordinates are normalized 0-1)
        let centerX = boundingBox.origin.x + boundingBox.width / 2
        let centerY = 1.0 - (boundingBox.origin.y + boundingBox.height / 2)  // Convert from Vision (bottom-left origin) to UIKit (top-left origin)

        // Ensure values are within bounds
        let focalPoint = CGPoint(
            x: max(0.0, min(1.0, centerX)),
            y: max(0.0, min(1.0, centerY))
        )

        print("DEBUG ImageSaliencyService: Calculated focal point: \(focalPoint)")
        return focalPoint
    }
}

// MARK: - Error Handling

enum SaliencyError: Error, LocalizedError {
    case invalidImage
    case analysisTimeout
    case visionFrameworkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not convert UIImage to CGImage"
        case .analysisTimeout:
            return "Saliency analysis timed out"
        case .visionFrameworkError(let error):
            return "Vision Framework error: \(error.localizedDescription)"
        }
    }
}
