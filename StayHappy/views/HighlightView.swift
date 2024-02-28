//
//  HighlightView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 22.02.24.
//

import SwiftUI

struct HighlightView: View {
    var event: Event
    var setImage: (UIImage) -> Void
    var photoImage: UIImage?
    
    init(event: Event, setImage: @escaping (UIImage) -> Void) {
        self.event = event
        self.setImage = setImage

        if event.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: event.photo!)).jpg")
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(photoImage == nil ? HappyGradients(rawValue: event.background)!.radial(startRadius: -50, endRadius: 350) : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0))
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
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text(event.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(.white)
                                .font(.caption)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                            Text(event.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        if photoImage != nil {
                            Button(action: {
                                setImage(photoImage!)
                            }, label: {
                                Image("maximize-symbol")
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                            })
                        }
                    }.padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
            }
    }
}
 
#Preview {
    func setImage(image: UIImage) {
        // no need to do this in the Preview
    }
    
    return HighlightView(event: Event(id: 1, title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date(), isHighlight: true, background: HappyGradients.loveKiss.rawValue, createdAt: Date(), updatedAt: Date()), setImage: setImage)
}
