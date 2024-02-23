//
//  HighlightView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 22.02.24.
//

import Gradients
import SwiftUI

struct HighlightView: View {
    var event: Event
    var photoImage: UIImage?

    init(event: Event) {
        self.event = event

        if event.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: event.photo!)).jpg")
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(photoImage == nil ? HappyGradients(rawValue: event.background)!.gradient : LinearGradient(gradient: Gradient(colors: [.clear, .clear]), startPoint: .top, endPoint: .bottom))
            .frame(height: 175)
            .padding(.horizontal, 20)
            .background {
                if photoImage != nil {
                    Image(uiImage: photoImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 175, alignment: .center)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .clipped()
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(.white)
                                .font(.caption)
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            Text(event.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                        
                        Spacer()
                    }.padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
            }
    }
}

#Preview {
    HighlightView(event: Event(id: 1, title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date(), isHighlight: true, background: HappyGradients.aboveTheSky.rawValue, createdAt: Date(), updatedAt: Date()))
}
