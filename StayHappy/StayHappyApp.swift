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
    case settings
}

class GlobalData: ObservableObject {
    @Published var activeView: Views

    init(activeView: Views) {
        self.activeView = activeView
    }
}

@main
struct StayHappyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDatabase, .shared)
                .environmentObject(GlobalData(activeView: .moments))
        }
    }
}
