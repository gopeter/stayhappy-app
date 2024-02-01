//
//  StayHappyApp.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftUI
import SwiftData

enum Views: String {
    case events
    case moments
    case search
    case profile
}

class GlobalData: ObservableObject {
    @Published var activeView: Views
    
    init(activeView: Views) {
        self.activeView = activeView
    }
}

@main
struct StayHappyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Event.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(GlobalData(activeView: .events))

        }
        .modelContainer(sharedModelContainer)
    }
}
