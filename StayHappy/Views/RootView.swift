//
//  ContentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var globalData: GlobalData

    /// Lifts the search tab out of the tab bar into its own trailing bubble.
    ///
    /// `TabRole.prominent` arrived in iOS 27, one version above this app's
    /// deployment target, so on iOS 26 the tab simply stays inside the capsule
    /// alongside the other four.
    private var searchRole: TabRole? {
        if #available(iOS 27, *) {
            return .prominent
        }
        return nil
    }

    var body: some View {
        TabView(selection: $globalData.activeView) {
            // `Tab(_:image:…)` takes an asset catalog name, so the app's own
            // symbolsets go straight into the system tab bar and pick up
            // Liquid Glass without any custom chrome.
            Tab("moments", image: "calendar-range-symbol", value: Views.moments) {
                MomentsView()
            }

            Tab("resources", image: "coffee-symbol", value: Views.resources) {
                ResourcesView()
            }

            Tab("highlights", image: "heart-symbol", value: Views.highlights) {
                HighlightsView()
            }

            Tab("help", image: "badge-help-symbol", value: Views.help) {
                HelpView()
            }

            // `searchable` deliberately lives inside `SearchView` instead of on
            // this `TabView`: applied here it propagates into every tab and
            // leaves a search drawer under each list's large title, which
            // `toolbar(removing: .search)` in those tabs does not take away.
            //
            // That rules out `role: .search`, whose separate bubble *is* that
            // tab-bar search integration. `.prominent` buys the same bubble
            // without it — see `searchRole`.
            Tab("search", image: "search-symbol", value: Views.search, role: searchRole) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color("AccentColor"))
        .fullScreenCover(isPresented: $globalData.isFullscreenPresented) {
            if let image = globalData.fullscreenImage {
                FullscreenPhotoView(image: image) {
                    globalData.closeFullscreenImage()
                }
            }
        }
    }
}

// MARK: - Fullscreen Photo

/// A photo at full size with its two actions in a real toolbar.
///
/// Following the Photos app: dismissal is a navigation-level action at the top
/// leading edge, sharing is a content action in the bottom bar. Both are
/// rendered by the system, so they get Liquid Glass without custom styling.
private struct FullscreenPhotoView: View {
    let image: UIImage
    let onClose: () -> Void

    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ImageViewer(image: image)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onClose) {
                            Label("close", image: "x-symbol")
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("share", image: "share-symbol")
                        }
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [image])
                }
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
        .environmentObject(OnboardingState())
}
