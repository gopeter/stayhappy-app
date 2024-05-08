// ImageSaliencyService.swift
//
// This class is responsible for analyzing an input UIImage using the Vision framework's VNGenerateAttentionBasedSaliencyImageRequest to generate a saliency map and extract salient object's bounding box points. The resulting points (topLeft, topRight, bottomLeft, bottomRight) are then used to draw a rectangle around the salient object on the original image.
//
// Created by Sarim Khan on 28/07/2023.
// See: https://medium.com/@sarimk80/enhancing-visual-focus-exploring-vngenerateattentionbasedsaliencyimagerequest-in-swiftui-f7f925f519c3

import Combine
import Foundation
import Vision
import VisionKit

class ImageSaliencyService {
    var uiImage: UIImage
    
    // MARK: - Public Properties
    
    // The four corner points of the salient object's bounding box
    public var topLeft: CGPoint = .init(x: 0.0, y: 0.0)
    public var topRight: CGPoint = .init(x: 0.0, y: 0.0)
    public var bottomLeft: CGPoint = .init(x: 0.0, y: 0.0)
    public var bottomRight: CGPoint = .init(x: 0.0, y: 0.0)
    
    // MARK: - Init
    
    init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    // MARK: - Image Analysis
    
    /// Analyzes the given UIImage to generate the saliency map and extract the salient object's bounding box points.
    /// - Parameter uiImage: The input UIImage to be analyzed.
    func analyzeImage() {
        // Resize the image to a fixed size for better processing
        let resizeImage = self.uiImage.resize(withSize: CGSize(width: 250, height: 250), contentMode: .contentFill)
        
        // Convert the UIImage to a CIImage
        guard let ciImage = CIImage(image: resizeImage!) else { return }
        
        // Create a VNImageRequestHandler with the CIImage
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
        
        // Create a VNGenerateAttentionBasedSaliencyImageRequest
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        request.revision = VNGenerateAttentionBasedSaliencyImageRequestRevision1
        request.preferBackgroundProcessing = true
        
        // Use CPU-only mode for simulator to improve performance
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        do {
            // Perform the request to generate the saliency map
            try requestHandler.perform([request])
            
            // Retrieve the saliency image observation
            guard let observation = request.results?.first as? VNSaliencyImageObservation else { return }
            
            // Extract and update the bounding box points of the salient object
            observation.salientObjects?.first.map { rectangle in
                self.topLeft = rectangle.topLeft
                self.topRight = rectangle.topRight
                self.bottomRight = rectangle.bottomRight
                self.bottomLeft = rectangle.bottomLeft
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func focalPoint() -> CGPoint {
        self.analyzeImage()
        
        // It seems that the points are sometimes turned up, so collect the values and take the min/max of it
        let xCoords = [self.topLeft.x, self.topRight.x, self.bottomLeft.x, self.bottomRight.x]
        let yCoords = [self.topLeft.y, self.topRight.y, self.bottomLeft.y, self.bottomRight.y]
        
        let xMin = xCoords.min()!
        let xMax = xCoords.max()!
        let yMin = yCoords.min()!
        let yMax = yCoords.max()!
        
        let focalX = xMin + ((xMax - xMin) / 2)
        let focalY = yMin + ((yMax - yMin) / 2)
        
        return CGPoint(x: focalX, y: focalY)
    }
}
