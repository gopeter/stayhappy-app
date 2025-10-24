//
//  ResourcesView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import Combine
import GRDBQuery
import SwiftUI
import SwiftUIIntrospect

struct ResourcesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(ResourceListRequest()) private var resources: [Resource]
    @State private var isSearching = false
    @State var searchText = ""

    let searchTextPublisher = PassthroughSubject<String, Never>()

    var body: some View {
        NavigationStack {
            List {
                if resources.count > 0 {
                    ForEach(resources) { resource in
                        HStack {
                            Text(resource.title)
                                .background(NavigationLink(resource.title, value: resource).opacity(0))
                            Spacer()
                            Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
                        }.listRowBackground(Color("CardBackgroundColor")).listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 12))
                    }

                }
                else {
                    VStack {
                        Spacer(minLength: 60)
                        HStack {
                            Spacer()
                            Text(isSearching ? "no_resources_found" : "no_resources_created").foregroundStyle(.gray)
                            Spacer()
                        }
                    }.listRowBackground(Color("AppBackgroundColor"))
                }
            }
            // Navigation
            .navigationTitle("resources")
            .toolbarTitleDisplayMode(.large)
            .navigationDestination(for: Resource.self) { resource in
                FormView(resource: resource)
            }
            // Style
            .scrollContentBackground(.hidden)
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 60, trailing: 0))
            // Search
            .searchable(text: $searchText, isPresented: $isSearching)
            .onChange(of: searchText) { _, newSearchText in
                searchTextPublisher.send(newSearchText)
            }
            .onReceive(
                searchTextPublisher
                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            ) { _ in
                $resources.searchText.wrappedValue = searchText
            }
            // disable jumpy behaviour when search is active
            .transaction { transaction in
                transaction.animation = nil
            }
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
        }.introspect(.searchField, on: .iOS(.v18, .v26)) { searchField in
            searchField.searchTextField.backgroundColor = UIColor(named: "CardBackgroundColor")
            searchField.searchTextField.borderStyle = .none
            searchField.searchTextField.layer.cornerRadius = 10
        }
    }
}

#Preview {
    ResourcesView()
}
