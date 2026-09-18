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
    
    /// Callers pass the scale explicitly. The previous convenience overload
    /// defaulted it from `UIScreen.main.scale`, which is deprecated in iOS 26
    /// because it has no meaning in a multi-window context — the scale has to
    /// come from the view's own trait collection.
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
