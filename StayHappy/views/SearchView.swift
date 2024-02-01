//
//  SearchView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("List of search results")
                    Spacer()
                }.padding()
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
