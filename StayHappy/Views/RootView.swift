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
                SettingsView().tag(Views.settings)
            }
   
            NavigationBarView()
        }.ignoresSafeArea(.keyboard)
    }
}

private func applyUIStyling() {
    UITabBar.appearance().isHidden = true
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "search-symbol"), for: .search, state: .normal)
    UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(UIImage(named: "x-circle-symbol"), for: .clear, state: .normal)
}

#Preview {
    RootView()
        .environment(\.appDatabase, .init(mode: .write))
        .environmentObject(GlobalData(activeView: .moments))
}
