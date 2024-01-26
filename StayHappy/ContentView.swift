//
//  ContentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MomentsView().tabItem {
                Label("Events", systemImage: "heart")
            }
            MomentsView().tabItem {
                Label("Moments", systemImage: "heart")
            }
            Text("Highlights").tabItem {
                Label("Highlights", systemImage: "plus.circle")
            }
            Text("Profile").tabItem {
                Label("Profile", systemImage: "slider.horizontal.3")
            }
        }
    }
}

#Preview {
    ContentView()
}
