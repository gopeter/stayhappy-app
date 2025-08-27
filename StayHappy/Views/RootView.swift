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
        }.ignoresSafeArea(.keyboard)
            .onAppear {
                #if DEBUG
                    // Simple localization debug
                    let momentsText = NSLocalizedString("moments", comment: "")
                    let helpText = NSLocalizedString("help", comment: "")
                    print("🧪 Localization Debug:")
                    print("   'moments' -> '\(momentsText)'")
                    print("   'help' -> '\(helpText)'")
                    print("   Bundle localizations: \(Bundle.main.localizations)")
                #endif
            }
    }
}

private func applyUIStyling() {
    UITabBar.appearance().isHidden = true
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "search-symbol"), for: .search, state: .normal)
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "x-circle-symbol"), for: .clear, state: .normal)
}

#Preview {
    RootView()
        .environment(\.appDatabase, .random())
        .environmentObject(GlobalData(activeView: .help))
}
