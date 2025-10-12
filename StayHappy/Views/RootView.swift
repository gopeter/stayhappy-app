//
//  ContentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var globalData: GlobalData
    @State var visibility = Visibility.hidden

    // TODO: check if this is the right place to do this
    init() {
        applyUIStyling()
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $globalData.activeView) {
                MomentsView().tag(Views.moments)
                ResourcesView().tag(Views.resources)
                HighlightsView().tag(Views.highlights)
                HelpView().tag(Views.help)
            }

            NavigationBarView()
        }

        .ignoresSafeArea(.keyboard)
        .overlay {
            // Global fullscreen image overlay - completely independent
            if globalData.isFullscreenPresented, let image = globalData.fullscreenImage {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(.all)
                    .opacity(globalData.isFullscreenPresented ? 1.0 : 0.0)
                    .overlay {
                        ImageViewer(image: image)
                            .ignoresSafeArea(.all)
                            .opacity(globalData.isFullscreenPresented ? 1.0 : 0.0)
                    }
                    .overlay(alignment: .bottom) {
                        FullscreenImageNavigationBar(
                            image: image,
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    globalData.closeFullscreenImage()
                                }
                            }
                        )
                        .opacity(globalData.isFullscreenPresented ? 1.0 : 0.0)
                        .padding(.bottom, 34)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            globalData.closeFullscreenImage()
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: globalData.isFullscreenPresented)
            }
        }
    }
}

private func applyUIStyling() {
    UITabBar.appearance().isHidden = true

    let searchBar = UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
    searchBar.setImage(UIImage(named: "search-symbol"), for: .search, state: .normal)
    searchBar.setImage(UIImage(named: "x-circle-symbol"), for: .clear, state: .normal)
    searchBar.backgroundColor = .clear
}

// MARK: - Fullscreen Image Navigation

struct FullscreenImageNavigationBar: View {
    let image: UIImage
    let onClose: () -> Void
    @State private var showShareSheet = false

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            Button(action: { showShareSheet = true }) {
                Image("share-symbol")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 20.0)
                    .foregroundStyle(Color.gray)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
            .buttonStyle(HighlightButtonStyle())

            Spacer()

            Button(action: onClose) {
                Image("minimize-symbol")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 20.0)
                    .foregroundStyle(Color.gray)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
            .buttonStyle(HighlightButtonStyle())

            Spacer()
        }
        .frame(width: 120, height: 54)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("ToolbarBackgroundColor"))
                .shadow(color: Color.black.opacity(0.35), radius: 5, y: 2)
        )
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [image])
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    RootView()
        .environment(\.appDatabase, .random())
        .environmentObject(GlobalData(activeView: .moments))
}
