//
//  HelpView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Help")
                Text("Thanks")
                Text("Buy me a coffee")
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Help")
                .toolbarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HelpView()
}
