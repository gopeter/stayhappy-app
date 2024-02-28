//
//  MomentsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import Combine
import GRDBQuery
import SwiftUI
import SwiftUIIntrospect

struct MomentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(MomentListRequest()) private var moments: [Moment]
    @State private var isSearching = false
    @State var searchText = ""

    let searchTextPublisher = PassthroughSubject<String, Never>()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    if moments.count > 0 {
                        ForEach(moments) { moment in
                            HStack {
                                Text(moment.title)
                                    .background(NavigationLink(moment.title, value: moment).opacity(0))
                                Spacer()
                                Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
                            }.listRowBackground(Color("CardBackgroundColor")).listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 12))
                        }
                    } else {
                        VStack {
                            Spacer(minLength: 80)
                            HStack {
                                Spacer()
                                Text(isSearching ? "No moments found" : "No moments created").foregroundStyle(.gray)
                                Spacer()
                            }
                        }.listRowBackground(Color("AppBackgroundColor"))
                    }
                }
                // Navigation
                .navigationTitle("Moments")
                .toolbarTitleDisplayMode(.inlineLarge)
                .navigationDestination(for: Moment.self) { moment in
                    FormView(moment: moment)
                }
                // Style
                .scrollContentBackground(.hidden)
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
                // disable jumpy behaviour when search is active
                .transaction { transaction in
                    transaction.animation = nil
                }

                Spacer(minLength: 80)
            }.background(Color("AppBackgroundColor").ignoresSafeArea(.all))

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
