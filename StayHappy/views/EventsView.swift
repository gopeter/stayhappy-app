//
//  EventsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import GRDBQuery
import SwiftUI
import SwiftUIIntrospect

struct EventsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(EventListRequest(period: .upcoming, ordering: .asc)) private var events: [Event]
    @State private var isSearching = false
    @State private var toggledSearch = false // activate transform
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if events.count > 0 {
                        ForEach(events) { event in
                            EventView(event: event)
                        }
                    } else {
                        VStack {
                            Spacer(minLength: 80)
                            HStack {
                                Spacer()
                                Text(isSearching ? "No events found" : "No events created").foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                    }
                }

                Spacer(minLength: 70)
            }
            .searchable(text: $events.searchText, isPresented: $isSearching)
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
            // .scrollContentBackground(.hidden)
            .navigationTitle("Events")
            .transaction { transaction in
                transaction.animation = nil
            }
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
                        .frame(width: 20.0, height: 20.0)
                }
            }
        }.introspect(.searchField, on: .iOS(.v17)) { searchField in
            if colorScheme == .dark {
                searchField.searchTextField.backgroundColor = UIColor(named: "CardBackgroundColor")
                searchField.searchTextField.borderStyle = .none
                searchField.searchTextField.layer.cornerRadius = 10
            }
        }
    }
}

#Preview {
    EventsView()
}
