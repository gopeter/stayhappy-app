//
//  HighlightView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 22.02.24.
//

import SwiftUI
import Throttler

struct HighlightView: View {
    var moment: Moment
    var setImage: (UIImage) -> Void
    var thumbnailImage: UIImage?
    var photoImage: UIImage?
    
    init(moment: Moment, setImage: @escaping (UIImage) -> Void) {
        self.moment = moment
        self.setImage = setImage

        if moment.photo != nil {
            let thumbnailUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: moment.photo!))-systemMedium.jpg")
            self.thumbnailImage = UIImage(contentsOfFile: thumbnailUrl.path)
            
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: moment.photo!)).jpg")
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        let widgetSize = getWidgetSize(for: .systemMedium)
        
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(thumbnailImage == nil ? HappyGradients(rawValue: moment.background)!.radial(startRadius: -50, endRadius: deviceSize.width) : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0))
            .frame(height: widgetSize.height)
            .padding(.horizontal, 20)
            .background {
                if thumbnailImage != nil {
                    Image(uiImage: thumbnailImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(height: widgetSize.height, alignment: .center)
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
                            Text(moment.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(.white)
                                .font(.caption)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                            Text(moment.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        if photoImage != nil {
                            Button(action: {
                                debounce(.seconds(0.1), option: .runFirst) {
                                    setImage(photoImage!)
                                }
                            }, label: {
                                Image("maximize-symbol")
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                                    .padding(10)
                            }).buttonStyle(HighlightButtonStyle())
                                .contentShape(Rectangle())
                                .offset(x: 5, y: 5)

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
    
    return HighlightView(moment: Moment(id: 1, title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date(), isHighlight: true, background: HappyGradients.loveKiss.rawValue, createdAt: Date(), updatedAt: Date()), setImage: setImage)
}
