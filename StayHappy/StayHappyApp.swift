//
//  StayHappyApp.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Combine
import GRDB
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

    // Global fullscreen image state
    @Published var fullscreenImage: UIImage? = nil
    @Published var isFullscreenPresented: Bool = false

    internal var highlightTriggerTimer: Timer?

    init(activeView: Views) {
        self.activeView = activeView
    }

    func openHighlightImage(momentId: Int64) {
        self.activeView = .highlights

        // Try to load image immediately for instant opening
        if let image = loadImageForMoment(momentId: momentId) {
            // Image loaded successfully - open with animation
            self.fullscreenImage = image
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isFullscreenPresented = true
            }
            self.clearHighlightImageTrigger()
        }
        else {
            // Fallback to old system with much shorter timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.highlightImageToShow = momentId
                self.startSafetyTimer(for: momentId)
            }
        }
    }

    private func loadImageForMoment(momentId: Int64) -> UIImage? {
        // Try to load the image directly from the database
        do {
            let appDatabase = AppDatabase.shared
            let moment = try appDatabase.reader.read { db in
                try Moment.fetchOne(db, key: momentId)
            }

            guard let moment = moment,
                let photoFileName = moment.photo
            else {
                return nil
            }

            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")
            return UIImage(contentsOfFile: photoUrl.path)
        }
        catch {
            return nil
        }
    }

    private func startSafetyTimer(for momentId: Int64) {
        // Much shorter timeout - only 2 seconds total
        highlightTriggerTimer?.invalidate()
        highlightTriggerTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.highlightImageToShow == momentId {
                    self.highlightImageToShow = nil
                }
            }
        }
    }

    func clearHighlightImageTrigger() {
        highlightTriggerTimer?.invalidate()
        highlightTriggerTimer = nil
        highlightImageToShow = nil
    }

    func closeFullscreenImage() {
        isFullscreenPresented = false
        // Delay clearing the image to allow fade-out animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.fullscreenImage = nil
        }
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
                        .task {
                            // Run widget image migration on app startup
                            await WidgetImageMigrationService.shared.runMigrationIfNeeded()
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
