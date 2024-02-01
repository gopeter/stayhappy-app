//
//  ProfileView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("Profile settings")
                    Spacer()
                }.padding()
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
