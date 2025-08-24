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
    var widgetSize: CGSize

    var thumbnailImage: UIImage?
    var photoImage: UIImage?

    @State private var isImagePresented = false
    @State private var showShareSheet = false

    init(moment: Moment, deviceSize: CGSize, widgetSize: CGSize) {
        self.moment = moment
        self.deviceSize = deviceSize
        self.widgetSize = widgetSize

        if moment.photo != nil {
            let thumbnailUrl = FileManager.documentsDirectory
                .appendingPathComponent(
                    "\(String(describing: moment.photo!))-systemMedium.jpg"
                )
            self.thumbnailImage = UIImage(contentsOfFile: thumbnailUrl.path)

            let photoUrl = FileManager.documentsDirectory
                .appendingPathComponent(
                    "\(String(describing: moment.photo!)).jpg"
                )
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                thumbnailImage == nil
                    ? HappyGradients(rawValue: moment.background)!.radial(
                        startRadius: -50,
                        endRadius: deviceSize.width
                    )
                    : RadialGradient(
                        gradient: Gradient(colors: [.clear, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 0
                    )
            )
            .frame(height: 120)
            .padding(.horizontal, 20)
            .background {
                if thumbnailImage != nil {
                    Image(uiImage: thumbnailImage!)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120, alignment: .center)
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
                    .foregroundStyle(isActive ? Color.accentColor : Color.white)
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
        try imageSaver.generateWidgetThumbnails()
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
        deviceSize: UIScreen.main.bounds.size,
        widgetSize: getWidgetSize(for: .systemMedium)
    )
}
