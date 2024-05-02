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

// MARK: - Give SwiftUI access to the database

//
// Define a new environment key that grants access to an AppDatabase.
//
// The technique is documented at
// https://developer.apple.com/documentation/swiftui/environmentkey

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .empty() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

// In this app, views observe the database with the @Query property
// wrapper, defined in the GRDBQuery package. Its documentation recommends to
// define a dedicated initializer for `appDatabase` access, so we comply:

extension Query where Request.DatabaseContext == AppDatabase {
    /// Convenience initializer for requests that feed from `AppDatabase`.
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
