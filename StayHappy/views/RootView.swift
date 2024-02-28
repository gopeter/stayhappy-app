//
//  ContentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var globalData: GlobalData
    
    // TODO: check if this is the right place to do this
    init() {
       applyUIStyling()
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $globalData.activeView) {
                EventsView().tag(Views.events).toolbar(.hidden, for: .tabBar)
                MomentsView().tag(Views.moments).toolbar(.hidden, for: .tabBar)
                HighlightsView().tag(Views.highlights).toolbar(.hidden, for: .tabBar)
                SettingsView().tag(Views.settings).toolbar(.hidden, for: .tabBar)
            }

            NavigationBarView()
        }.ignoresSafeArea(.keyboard)
    }
}

private func applyUIStyling() {
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "search-symbol"), for: .search, state: .normal)
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "x-circle-symbol"), for: .clear, state: .normal)
}

#Preview {
    RootView()
        .environment(\.appDatabase, .init())
        .environmentObject(GlobalData(activeView: .events))
}
