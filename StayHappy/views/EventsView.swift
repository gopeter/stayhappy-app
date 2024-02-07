//
//  EventsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import GRDBQuery
import SwiftUI

struct EventsView: View {
    @Query(EventListRequest(period: .upcoming, ordering: .asc)) private var events: [Event]

    @State private var searchIsActive = false

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
                .navigationTitle("Events")
                .toolbar {
                    Menu {
                        Section("Period") {
                            Picker("Period", selection: $events.period) {
                                Text("Upcoming events").tag(EventListRequest.Period.upcoming)
                                Text("Past events").tag(EventListRequest.Period.past)
                            }
                        }

                        Section("Ordering") {
                            Picker("Ordering", selection: $events.ordering) {
                                Text("Ascending").tag(EventListRequest.Ordering.asc)
                                Text("Descending").tag(EventListRequest.Ordering.desc)
                            }
                        }

                    } label: {
                        Image("settings-2-symbol")
                            .resizable()
                            .frame(width: 18.0, height: 18.0)
                            .foregroundStyle(.gray)
                    }
                }
        }.searchable(text: $events.searchText, isPresented: $searchIsActive)
    }
}

#Preview {
    EventsView()
}
