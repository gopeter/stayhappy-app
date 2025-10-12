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
    var deviceSize: CGSize

    @State private var thumbnailImage: UIImage?
    @State private var photoImage: UIImage?
    @EnvironmentObject var globalData: GlobalData

    init(moment: Moment, deviceSize: CGSize) {
        self.moment = moment
        self.deviceSize = deviceSize
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                thumbnailImage == nil
                    ? HappyGradients(rawValue: moment.background)!.radial(
                        startRadius: -50,
                        endRadius: self.deviceSize.width
                    )
                    : RadialGradient(
                        gradient: Gradient(colors: [.clear, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 0
                    )
            )
            .frame(width: self.deviceSize.width - 40, height: 120)
            .padding(.horizontal, 20)
            .background {
                if thumbnailImage != nil {
                    Image(uiImage: thumbnailImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: self.deviceSize.width - 40, height: 120, alignment: .center)
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
                            Text(
                                moment.startAt.formatted(
                                    .dateTime.day().month().year()
                                )
                            ).foregroundStyle(.white)
                                .font(.caption)
                                .shadow(
                                    color: .black.opacity(0.4),
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                            Text(moment.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(
                                    color: .black.opacity(0.4),
                                    radius: 3,
                                    x: 0,
                                    y: 1
                                )
                        }

                        Spacer()

                        if photoImage != nil {
                            Button(
                                action: {
                                    debounce(.seconds(0.1), option: .runFirst) {
                                        // Use global fullscreen system with animation
                                        globalData.fullscreenImage = photoImage
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            globalData.isFullscreenPresented = true
                                        }
                                    }
                                },
                                label: {
                                    Image("maximize-symbol")
                                        .foregroundStyle(.white)
                                        .shadow(
                                            color: .black.opacity(0.4),
                                            radius: 3,
                                            x: 0,
                                            y: 1
                                        )
                                        .padding(10)
                                }
                            )
                            .contentShape(Rectangle())
                            .offset(x: 5, y: 5)
                        }
                    }.padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
            }
            .onAppear {
                checkAndOpenImage()
                loadImages(viewSize: self.deviceSize)
            }
            .onChange(of: globalData.highlightImageToShow) { _, newValue in
                checkAndOpenImage()
            }
    }

    private func checkAndOpenImage() {
        let shouldOpenImage = globalData.highlightImageToShow == moment.id

        if shouldOpenImage {
            if photoImage != nil {
                // Image is loaded, use global fullscreen system with animation
                globalData.fullscreenImage = photoImage
                withAnimation(.easeInOut(duration: 0.3)) {
                    globalData.isFullscreenPresented = true
                }
                globalData.clearHighlightImageTrigger()
            }
            else {
                // If photoImage is nil, we don't clear the trigger yet
                // The image will be checked again when loadImages completes
            }
        }
    }

    private func loadImages(viewSize: CGSize) {
        guard let photoFileName = moment.photo else {
            return
        }

        // Load original image for full-screen view
        let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")
        photoImage = UIImage(contentsOfFile: photoUrl.path)

        // Check if we need to open the image after loading the original image
        checkAndOpenImage()

        // Generate thumbnail using ImageProcessingService
        Task {
            let targetSize = CGSize(width: viewSize.width - 40, height: 120)

            let processedImage = await ImageProcessingService.shared.getProcessedImage(
                for: photoFileName,
                size: targetSize
            )

            await MainActor.run {
                thumbnailImage = processedImage
                // Check if we need to open the image after loading
                checkAndOpenImage()
            }
        }
    }
}

#Preview {
    let imageSaver = ImageSaver(
        image: UIImage(named: "highlight"),
        fileName: "preview"
    )

    do {
        try imageSaver.writeToDisk()
        imageSaver.reloadWidgets()
    }
    catch {
        // ...
    }

    return HighlightView(
        moment: Moment(
            id: 1,
            title: "Arctic Monkeys Concert",
            startAt: Date(),
            endAt: Date(),
            isHighlight: true,
            background: HappyGradients.loveKiss.rawValue,
            photo: "preview",
            createdAt: Date(),
            updatedAt: Date()
        ),
        deviceSize: UIScreen.main.bounds.size
    ).environmentObject(GlobalData(activeView: .highlights))
}
