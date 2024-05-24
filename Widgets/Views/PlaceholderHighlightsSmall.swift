//
//  PlaceholderHighlightsSmall.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI

struct PlaceholderHighlightsSmall: View {
    var highlight: Moment
    var photoImage: UIImage?

    init(highlights: [Moment]) {
        self.highlight = highlights[0]

        if highlight.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: highlight.photo!))-systemSmall.jpg")
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        let widgetSize = getWidgetSize(for: .systemSmall)

        RoundedRectangle(cornerRadius: 0, style: .continuous)
            .fill(photoImage == nil ? HappyGradients(rawValue: highlight.background)!.radial(startRadius: -50, endRadius: widgetSize.width) : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0))
            .frame(height: widgetSize.height)
            .background {
                if photoImage != nil {
                    Image(uiImage: photoImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: widgetSize.height, alignment: .center)
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
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .padding(0)
                        }

                        Spacer()
                    }
                }.padding(.all)
            }
    }
}
