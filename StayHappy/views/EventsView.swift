//
//  EventsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import Combine
import GRDBQuery
import SwiftUI
import SwiftUIIntrospect

struct EventsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(EventListRequest(period: .upcoming, ordering: .asc)) private var events: [Event]
    @State private var isSearching = false
    @State var searchText = ""

    let searchTextPublisher = PassthroughSubject<String, Never>()

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
            // Navigation
            .navigationTitle("Events")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(for: Event.self) { event in
                FormView(event: event)
            }
            // Style
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
            // Search
            .searchable(text: $searchText, isPresented: $isSearching)
            .onChange(of: searchText) { _, newSearchText in
                searchTextPublisher.send(newSearchText)
            }
            .onReceive(
                searchTextPublisher
                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            ) { _ in
                $events.searchText.wrappedValue = searchText
            }
            // Disable jumpy behaviour when search is active
            .transaction { transaction in
                transaction.animation = nil
            }
            // Actions
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
                    VStack(spacing: 0) {
                        Spacer()
                        Image("filter-symbol")
                        
                    }
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
