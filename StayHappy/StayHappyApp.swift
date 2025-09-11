//
//  StayHappyApp.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Combine
import GRDBQuery
import SwiftUI

enum Views: String {
    case moments
    case resources
    case highlights
    case help
}

class GlobalData: ObservableObject {
    @Published var activeView: Views
    @Published var highlightImageToShow: Int64? = nil

    init(activeView: Views) {
        self.activeView = activeView
    }

    func openHighlightImage(momentId: Int64) {
        self.activeView = .highlights
        self.highlightImageToShow = momentId
    }
}

class AppStateManager: ObservableObject {
    @Published var globalData = GlobalData(activeView: .moments)
    @Published var onboardingState = OnboardingState()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Set up observation for onboarding state changes
        onboardingState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
}

@main
struct StayHappyApp: App {
    @StateObject private var appStateManager = AppStateManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if appStateManager.onboardingState.hasCompletedOnboarding {
                    RootView()
                        .environment(\.appDatabase, .shared)
                        .environmentObject(appStateManager.globalData)
                        .environmentObject(appStateManager.onboardingState)
                        .onOpenURL { url in
                            handleDeepLink(url: url)
                        }
                }
                else {
                    OnboardingView()
                        .environmentObject(appStateManager.onboardingState)
                }
            }

        }
    }

    private func handleDeepLink(url: URL) {
        guard url.scheme == "stayhappy" else { return }

        let pathComponents = url.pathComponents

        // Handle stayhappy://highlights/image/{momentId}
        // URL structure: stayhappy://highlights/image/11
        // url.host = "highlights", url.path = "/image/11"
        // pathComponents = ["/", "image", "11"]
        if url.host == "highlights" && pathComponents.count >= 3 && pathComponents[1] == "image" {
            if let momentId = Int64(pathComponents[2]) {
                DispatchQueue.main.async {
                    self.appStateManager.globalData.openHighlightImage(momentId: momentId)
                }
            }
        }
    }
}
