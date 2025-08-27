//
//  StayHappyApp.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

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

@main
struct StayHappyApp: App {
    @StateObject private var globalData = GlobalData(activeView: .moments)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDatabase, .shared)
                .environmentObject(globalData)
                .onOpenURL { url in
                    handleDeepLink(url: url)
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
                    self.globalData.openHighlightImage(momentId: momentId)
                }
            }
        }
    }
}
