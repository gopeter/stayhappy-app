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
    var size: ImageSize

    init(highlights: [Moment], size: ImageSize) {
        self.highlight = highlights[0]
        self.size = size
    }

    var body: some View {
        GeometryReader { geometry in
            HighlightsTileContent(
                highlight: highlight,
                size: size,
                widgetSize: geometry.size
            )
        }
    }
}

struct HighlightsTileContent: View {
    var highlight: Moment
    var size: ImageSize
    var widgetSize: CGSize

    @State private var photoImage: UIImage?
    @State private var hasTriedLoading: Bool = false

    init(highlight: Moment, size: ImageSize, widgetSize: CGSize) {
        self.highlight = highlight
        self.size = size
        self.widgetSize = widgetSize
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 0, style: .continuous)
            .fill(
                photoImage == nil
                    ? HappyGradients(rawValue: highlight.background)!.radial(startRadius: -50, endRadius: widgetSize.width)
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
            .onChange(of: hasTriedLoading) { oldValue, newValue in
                if !newValue && !hasTriedLoading {
                    loadImage()
                }
            }
            .onAppear {
                if !hasTriedLoading {
                    loadImage()
                }
            }
    }

    private func loadImage() {
        guard !hasTriedLoading else { return }
        hasTriedLoading = true

        guard let photoFileName = highlight.photo else {
            return
        }

        loadImageSync(photoFileName: photoFileName)
    }

    private func loadImageSync(photoFileName: String) {
        let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.app.stayhappy.StayHappy")
        let documentsPath = FileManager.documentsDirectory

        let paths = [
            documentsPath.appendingPathComponent("\(photoFileName).jpg"),
            appGroupURL?.appendingPathComponent("\(photoFileName).jpg"),
            appGroupURL?.appendingPathComponent("Documents/\(photoFileName).jpg"),
        ].compactMap { $0 }

        for path in paths {
            if FileManager.default.fileExists(atPath: path.path),
                let image = UIImage(contentsOfFile: path.path)
            {

                // Proper aspect ratio handling
                let imageSize = image.size
                let widgetAspectRatio = widgetSize.width / widgetSize.height
                let imageAspectRatio = imageSize.width / imageSize.height

                let drawRect: CGRect
                if imageAspectRatio > widgetAspectRatio {
                    // Image is wider - fit height and crop width
                    let drawWidth = widgetSize.height * imageAspectRatio
                    drawRect = CGRect(
                        x: -(drawWidth - widgetSize.width) / 2,
                        y: 0,
                        width: drawWidth,
                        height: widgetSize.height
                    )
                }
                else {
                    // Image is taller - fit width and crop height
                    let drawHeight = widgetSize.width / imageAspectRatio
                    drawRect = CGRect(
                        x: 0,
                        y: -(drawHeight - widgetSize.height) / 2,
                        width: widgetSize.width,
                        height: drawHeight
                    )
                }

                let renderer = UIGraphicsImageRenderer(size: widgetSize)
                let resizedImage = renderer.image { _ in
                    image.draw(in: drawRect)
                }

                photoImage = resizedImage
                return
            }
        }
    }
}
