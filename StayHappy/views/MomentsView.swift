//
//  MomentsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import SwiftUI

struct MomentsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("List of moments")
                    Spacer()
                }.padding()
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Moments")
           
        }
    }
}

#Preview {
    MomentsView()
}
