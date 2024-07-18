// ImageSaliencyService.swift
//
// This class is responsible for analyzing an input UIImage using the Vision framework's VNGenerateAttentionBasedSaliencyImageRequest to generate a saliency map and extract salient object's bounding box points. The resulting points (topLeft, topRight, bottomLeft, bottomRight) are then used to draw a rectangle around the salient object on the original image.
//
// Created by Peter Oesteritz on 11.05.24.
// See: https://medium.com/@sarimk80/enhancing-visual-focus-exploring-vngenerateattentionbasedsaliencyimagerequest-in-swiftui-f7f925f519c3
// See: https://medium.com/@kamil.tustanowski/saliency-detection-using-the-vision-framework-d53a38e4ccaa

import Combine
import Foundation
import Vision
import VisionKit

class ImageSaliencyService {
    var uiImage: UIImage
    var salientRect: CGRect
    
    // MARK: - Init
    
    init(uiImage: UIImage) {
        self.uiImage = uiImage
        self.salientRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes the given UIImage to generate the saliency map and extract the salient object's bounding box points.
    /// - Parameter uiImage: The input UIImage to be analyzed.
    func analyzeImage() {
        guard let cgImage = self.uiImage.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        
        // Use CPU-only mode for simulator to improve performance
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        do {
            // Perform the request to generate the saliency map
            try requestHandler.perform([request])
            
            // There is just on result when using AttentionBasedSaliency
            guard let observation = request.results?.first as? VNSaliencyImageObservation else { return }
            guard let observationBoundingBox = observation.salientObjects?.first?.boundingBox.rectangle(in: self.uiImage) else { return }
            
            self.salientRect = CGRect(origin: observationBoundingBox.origin.translateFromCoreImageToUIKitCoordinateSpace(using: self.uiImage.size.height - observationBoundingBox.size.height),
                                      size: observationBoundingBox.size)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // returns the focal point as percentage
    func focalPoint() -> CGPoint {
        self.analyzeImage()
        
        // return center
        if self.salientRect.width == 0 {
            return CGPoint(x: 0.5, y: 0.5)
        }
        
        return CGPoint(
            x: (self.salientRect.origin.x + self.salientRect.width / 2) / self.uiImage.size.width,
            y: (self.salientRect.origin.y + self.salientRect.height / 2) / self.uiImage.size.height
        )
    }
}

extension CGRect {
    func rectangle(in image: UIImage) -> CGRect {
        VNImageRectForNormalizedRect(self,
                                     Int(image.size.width),
                                     Int(image.size.height))
    }
    
    var points: [CGPoint] {
        return [origin, CGPoint(x: origin.x + width, y: origin.y),
                CGPoint(x: origin.x + width, y: origin.y + height), CGPoint(x: origin.x, y: origin.y + height)]
    }
}

extension CGPoint {
    func translateFromCoreImageToUIKitCoordinateSpace(using height: CGFloat) -> CGPoint {
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -height)
        
        return self.applying(transform)
    }
}
