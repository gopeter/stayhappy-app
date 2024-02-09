//
//  HighlightsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct HighlightsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("Highlights coming soon")
                    Spacer()
                }.padding()
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Highlights")
        }
    }
}

#Preview {
    HighlightsView()
}
