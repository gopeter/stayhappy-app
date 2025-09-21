//
//  QuickLookService.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.05.24.
//

import QuickLookThumbnailing
import UIKit

actor QuicklookService {
    static let shared = QuicklookService()
    
    private let generator = QLThumbnailGenerator.shared
    
    func image(for url: URL, size: CGSize) async -> UIImage {
        let deviceScale = await UIScreen.main.scale
        return await image(for: url, size: size, scale: deviceScale)
    }
    
    func image(for url: URL, size: CGSize, scale: CGFloat) async -> UIImage {
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )
        
        do {
            let representation = try await generator.generateBestRepresentation(for: request)
            
            return representation.uiImage
        } catch {
            return UIImage()
        }
    }
}
