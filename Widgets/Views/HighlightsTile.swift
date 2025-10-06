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
            return
        }

        Task {
            let processedImage = await ImageProcessingService.shared.getProcessedImage(
                for: photoFileName,
                widgetSize: widgetSize
            )

            await MainActor.run {
                photoImage = processedImage
            }
        }
    }
}
