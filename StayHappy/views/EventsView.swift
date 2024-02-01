//
//  EventsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import SwiftData
import SwiftUI

struct EventsView: View {
    @Query(sort: \Event.startAt, order: .reverse) var events: [Event]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(events) { event in
                        EventView(event: event)
                    }
                }
                Spacer(minLength: 70)
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Events '24")
                .toolbar {
                    Menu {
                        Section("Primary Actions") {
                            Button("First") {}
                            Button("Second") {}
                        }

                        Button {
                            // Add this item to a list of favorites.
                        } label: {
                            Label("Add to Favorites", systemImage: "heart")
                        }

                        Divider()

                        Button(role: .destructive) {} label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        
                        Image("settings-2-symbol").resizable().frame(width: 18.0, height: 18.0).foregroundStyle(.gray)
                    }
                }
        }
    }
}

#Preview {
    EventsView()
}
