//
//  HighlightsTile.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI
import WidgetKit

enum ImageSize: String, CaseIterable {
    case systemSmall
    case systemMedium
}

struct HighlightsTile: View {
    var highlight: Moment
    var photoImage: UIImage?
    var size: ImageSize

    init(highlights: [Moment], size: ImageSize) {
        self.highlight = highlights[0]
        self.size = size

        if let photo = highlight.photo {
            let variant: ImageVariant = size == .systemMedium ? .widget2x1 : .widget1x1
            self.photoImage = ImageProcessingService.shared.processedImage(for: photo, variant: variant)
        }
    }

    /// The tile paints the highlight's own gradient, not the widget's, so the
    /// label follows that one. Over a photo it stays white: what is under it
    /// is unknown.
    private var labelColor: Color {
        photoImage == nil ? HappyGradients.named(highlight.background).textColor : .white
    }

    private var labelShadowColor: Color {
        photoImage == nil ? HappyGradients.named(highlight.background).textShadowColor : .black.opacity(0.4)
    }

    var body: some View {
        GeometryReader { geometry in

            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(
                    photoImage == nil
                        ? HappyGradients.named(highlight.background).radial(startRadius: -50, endRadius: geometry.size.width)
                        : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0)
                )
                .frame(maxWidth: .infinity)
                .background {
                    if photoImage != nil {
                        Image(uiImage: photoImage!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width)
                            .clipped()
                    }
                }
                .overlay {
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 3) {
                                Spacer()
                                Text(highlight.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(labelColor)
                                    .font(.caption)
                                    .shadow(color: labelShadowColor, radius: 2, x: 0, y: 1)
                                    .padding(0)

                                Text(highlight.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(labelColor)
                                    .shadow(color: labelShadowColor, radius: 2, x: 0, y: 1)
                                    .padding(0)
                            }

                            Spacer()
                        }
                    }
                    .padding(16)
                }
                .widgetURL(URL(string: "stayhappy://highlights/image/\(highlight.id)"))
        }
    }
}
