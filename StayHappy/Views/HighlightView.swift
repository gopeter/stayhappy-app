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
    @State private var isImagePresented = false
    @State private var showShareSheet = false
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
                                        isImagePresented = true
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
            .onChange(of: globalData.highlightImageToShow) { _ in
                checkAndOpenImage()
            }
            .fadeInFullScreenCover(isPresented: $isImagePresented) {
                Group {
                    if let image = photoImage {
                        ZStack {
                            ImageViewer(image: image)
                                .ignoresSafeArea(.all)

                            VStack {
                                Spacer()

                                HStack {
                                    Spacer()
                                    ImageViewerNavigationBarView(
                                        onShare: { showShareSheet = true },
                                        onClose: {
                                            isImagePresented = false
                                        }
                                    )
                                    Spacer()
                                }
                            }
                        }
                        .ignoresSafeArea(.all)

                        .sheet(isPresented: $showShareSheet) {
                            if let image = photoImage {
                                ShareSheet(activityItems: [image])
                            }
                        }
                    }
                    else {
                        EmptyView()
                    }
                }

            }
    }

    private func checkAndOpenImage() {
        let shouldOpenImage = globalData.highlightImageToShow == moment.id

        if shouldOpenImage && photoImage != nil && !isImagePresented {
            // Clear the trigger first to prevent multiple views from reacting
            globalData.highlightImageToShow = nil
            // Open the image immediately
            isImagePresented = true
        }
    }

    private func loadImages(viewSize: CGSize) {
        guard let photoFileName = moment.photo else {
            return
        }

        // Load original image for full-screen view
        let photoUrl = FileManager.documentsDirectory
            .appendingPathComponent("\(photoFileName).jpg")
        photoImage = UIImage(contentsOfFile: photoUrl.path)

        // Generate thumbnail using ImageProcessingService
        Task {
            let targetSize = CGSize(width: viewSize.width - 40, height: 120)

            let processedImage = await ImageProcessingService.shared.getProcessedImage(
                for: photoFileName,
                targetSize: targetSize
            )

            await MainActor.run {
                thumbnailImage = processedImage
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ImageViewerNavigationBarView: View {
    let onShare: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            ImageNavigationItem(
                icon: "share-symbol",
                action: onShare,
                isActive: false
            )

            Spacer()

            ImageNavigationItem(
                icon: "minimize-symbol",
                action: onClose,
                isActive: false
            )

            Spacer()
        }
        .frame(width: 120, height: 54)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("ToolbarBackgroundColor"))
                .shadow(color: Color.black.opacity(0.35), radius: 5, y: 2)
        )
        .padding(.bottom, 34)
    }
}

struct ImageNavigationItem: View {
    let id: String = UUID().uuidString
    let icon: String
    let action: () -> Void
    let isActive: Bool

    var body: some View {
        Button(
            action: action,
            label: {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 20.0)
                    .foregroundStyle(Color.gray)
            }
        ).frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
            .buttonStyle(HighlightButtonStyle())
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
