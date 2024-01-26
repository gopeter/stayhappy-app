//
//  MomentsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import SwiftUI

struct MomentsView: View {
    enum DataOptions: String, CaseIterable, Identifiable {
        case events = "Events"
        case highlights = "Highlights"
        
        var id: Self { return self }
    }
    
    var body: some View {
        NavigationStack {
            
            
            List {
                Text("A List Itemmm")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
                Text("A List Item")
            }
            .navigationTitle("Moments")
            .toolbar {
                

                
                      Menu {
                        Section("Primary Actions") {
                            Button("First") {  }
                            Button("Second") {  }
                        }
                        
                        Button {
                            // Add this item to a list of favorites.
                        } label: {
                            Label("Add to Favorites", systemImage: "heart")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
         
                
            }
        }
    }
}

#Preview {
    MomentsView()
}
