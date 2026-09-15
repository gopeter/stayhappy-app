//
//  IImageExtensions.swift
//  VisionFrameworkApp
//
//  Created by sarim khan on 25/07/2023.
//  See: https://github.com/sarimk80/VisionFrameworkApp/blob/32c270ec0f2a4c00dcdf8f71fa81f7e0f9b869ea/VisionFrameworkApp/Helper/UIImageExtensions.swift#L20
//

import Foundation
import UIKit

extension UIImage {
    enum ContentMode {
        case contentFill
        case contentAspectFill
        case contentAspectFit
    }
      
    func resize(withSize size: CGSize, contentMode: ContentMode = .contentAspectFill) -> UIImage? {        
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
          
        switch contentMode {
        case .contentFill:
            return self.resize(withSize: size)
        case .contentAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            return self.resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        case .contentAspectFill:
            let aspectRatio = max(aspectWidth, aspectHeight)
            return self.resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        }
    }
      
    private func resize(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func convertToBuffer() -> CVPixelBuffer? {
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

// MARK: - Preview Placeholder

extension UIImage {
    /// A deterministic stand-in photo for SwiftUI previews and seeded data.
    ///
    /// The `highlight` image in `Preview Content` cannot be relied on: that
    /// catalog is only bundled into the app target's debug builds, so
    /// `UIImage(named:)` returns nil in the widget extension and in release
    /// builds. When that happened, `ImageSaver.writeToDisk()` threw, the sample
    /// moment was stored with a photo name but no file on disk, and tiles
    /// silently fell back to their gradient.
    ///
    /// - Parameter seed: Varies the colours and the position of the bright
    ///   feature, so seeded moments stay distinguishable — and so the
    ///   focal-point crop has something off-centre to aim at.
    static func previewPhoto(seed: Int) -> UIImage {
        let size = CGSize(width: 1200, height: 1600)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true

        let hue = CGFloat(seed % 8) / 8.0
        let top = UIColor(hue: hue, saturation: 0.55, brightness: 0.75, alpha: 1)
        let bottom = UIColor(
            hue: (hue + 0.12).truncatingRemainder(dividingBy: 1),
            saturation: 0.7,
            brightness: 0.35,
            alpha: 1
        )

        let featureCentre = CGPoint(
            x: size.width * (0.3 + 0.4 * CGFloat(seed % 3) / 2),
            y: size.height * (0.2 + 0.5 * CGFloat(seed % 5) / 4)
        )

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cg = context.cgContext

            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [top.cgColor, bottom.cgColor] as CFArray,
                locations: [0, 1]
            ) {
                cg.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            }

            UIColor(white: 1, alpha: 0.85).setFill()
            let radius: CGFloat = 170
            cg.fillEllipse(
                in: CGRect(
                    x: featureCentre.x - radius,
                    y: featureCentre.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )
        }
    }
}
