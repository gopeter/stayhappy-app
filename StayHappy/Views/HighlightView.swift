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

    private var tileWidth: CGFloat {
        deviceSize.width - 40
    }

    /// Derived from the variant's aspect ratio instead of a hard-coded 120pt.
    ///
    /// The height used to be fixed, so the tile's ratio changed with the screen
    /// width (3.02:1 on an iPhone 17 Pro, 2.79:1 on an SE) while the image was
    /// always 2:1 — and SwiftUI silently center-cropped the difference away.
    private var tileHeight: CGFloat {
        (tileWidth / ImageVariant.tile3x1.aspectRatio).rounded()
    }

    /// Always white, carried by its shadow.
    ///
    /// The tiles sit in a single scrolling list, and switching the label
    /// between white and a dark tint per tile made that list look inconsistent
    /// — the contrast of one tile is not worth the restlessness of the whole
    /// column. The widget does switch: there, one background covers everything
    /// and nothing sits next to it to clash with.
    private let labelColor: Color = .white
    private let labelShadowColor: Color = .black.opacity(0.4)

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                thumbnailImage == nil
                    ? HappyGradients.named(moment.background).radial(
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
            .frame(width: tileWidth, height: tileHeight)
            .padding(.horizontal, 20)
            .background {
                if thumbnailImage != nil {
                    Image(uiImage: thumbnailImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: tileWidth, height: tileHeight, alignment: .center)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .clipped()
                }
            }
            // A scrim under the labels, the way the system darkens the bottom
            // of a photo it puts text on. Fixed for every tile, so the column
            // stays calm, and it carries the white text on the pale gradients
            // where the shadow alone gave out.
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        EllipticalGradient(
                            colors: [.black.opacity(0.38), .clear],
                            center: .bottomLeading,
                            startRadiusFraction: 0,
                            endRadiusFraction: 0.75
                        )
                    )
                    .frame(width: tileWidth, height: tileHeight)
                    .padding(.horizontal, 20)
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
                            ).foregroundStyle(labelColor)
                                .font(.caption)
                                .shadow(
                                    color: labelShadowColor,
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                            Text(moment.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(labelColor)
                                .shadow(
                                    color: labelShadowColor,
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
                                        .foregroundStyle(labelColor)
                                        .shadow(
                                            color: labelShadowColor,
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

        // Load the pre-generated tile variant. Detached so the JPEG decode
        // happens off the main actor instead of on it.
        Task.detached(priority: .userInitiated) {
            let processedImage = ImageProcessingService.shared.processedImage(
                for: photoFileName,
                variant: .tile3x1
            )

            await MainActor.run {
                thumbnailImage = processedImage
                // Check if we need to open the image after loading
                checkAndOpenImage()
            }
        }
    }
}

/// The extremes of the palette side by side: the gradients where white text
/// has the least room, and the dark ones the scrim must not turn to mud.
#Preview("Lightest and darkest") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(["lemonGate", "newYork", "saintPetersburg", "stayHappy", "deepBlue", "nightParty"], id: \.self) { background in
                HighlightView(
                    moment: Moment(
                        id: 1,
                        title: "Arctic Monkeys Concert",
                        startAt: Date(),
                        endAt: Date(),
                        isHighlight: true,
                        background: background,
                        photo: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    deviceSize: CGSize(width: 402, height: 874)
                )
            }
        }
    }
    .background(Color("AppBackgroundColor"))
    .environmentObject(GlobalData(activeView: .highlights))
}

#Preview {
    let imageSaver = ImageSaver(
        image: UIImage(named: "highlight") ?? .previewPhoto(seed: 0),
        fileName: "preview"
    )

    Task {
        do {
            try await imageSaver.writeToDisk()
            imageSaver.reloadWidgets()
        }
        catch {
            // ...
        }
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
        // A fixed size rather than UIScreen.main: previews have no window, and
        // the real view now gets its size from a GeometryReader anyway.
        deviceSize: CGSize(width: 402, height: 874)
    ).environmentObject(GlobalData(activeView: .highlights))
}
