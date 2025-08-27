//
//  MomentsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import Combine
import GRDBQuery
import SwiftUI
import SwiftUIIntrospect

struct MomentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(MomentListRequest(period: .upcoming, ordering: .asc)) private var moments: [Moment]
    @State private var isSearching = false
    @State var searchText = ""

    let searchTextPublisher = PassthroughSubject<String, Never>()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if moments.count > 0 {
                        ForEach(moments) { moment in
                            MomentView(moment: moment)
                        }
                    }
                    else {
                        VStack {
                            Spacer(minLength: 80)
                            HStack {
                                Spacer()
                                Text(isSearching ? "no_moments_found" : "no_moments_created").foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                    }
                }

                Spacer(minLength: 80)
            }
            // Navigation
            .navigationTitle("moments")
            .toolbarTitleDisplayMode(.large)
            .navigationDestination(for: Moment.self) { moment in
                FormView(moment: moment)
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
                $moments.searchText.wrappedValue = searchText
            }
            // Disable jumpy behaviour when search is active
            .transaction { transaction in
                transaction.animation = nil
            }
            // Actions
            .toolbar {
                Menu {
                    Section("period") {
                        Picker("period", selection: $moments.period) {
                            Text("upcoming_moments").tag(MomentListRequest.Period.upcoming)
                            Text("past_moments").tag(MomentListRequest.Period.past)
                        }
                    }

                    Section("ordering") {
                        Picker("ordering", selection: $moments.ordering) {
                            Text("ascending").tag(MomentListRequest.Ordering.asc)
                            Text("descending").tag(MomentListRequest.Ordering.desc)
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
    MomentsView()
}
