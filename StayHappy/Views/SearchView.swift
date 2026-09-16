//
//  SearchView.swift
//  StayHappy
//
//  The dedicated search area behind the tab bar's trailing search tab.
//
//  Searching across both moments and resources at once is a consequence of
//  putting search in the tab bar: the HIG describes a search tab as "an area
//  dedicated to discovery", and a single field over everything fits that better
//  than two separate per-list searches.
//
//  Both existing queryable requests are reused as-is. `MomentListRequest`
//  already ignores its period filter once a search text is set (see its
//  `fetch(_:)`), so a search covers past and upcoming moments alike.
//

import Combine
import GRDBQuery
import SwiftUI

struct SearchView: View {
    @Query(MomentListRequest(period: .upcoming, ordering: .asc)) private var moments: [Moment]
    @Query(ResourceListRequest()) private var resources: [Resource]

    @State private var searchText = ""
    /// Bound so the field is already focused when the search tab opens, rather
    /// than asking for a second tap.
    @State private var isSearchPresented = false

    private var hasQuery: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasResults: Bool {
        !moments.isEmpty || !resources.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                if !hasQuery {
                    placeholder("search_prompt")
                }
                else if !hasResults {
                    placeholder("search_no_results")
                }
                else {
                    if !moments.isEmpty {
                        Section("moments") {
                            ForEach(moments) { moment in
                                NavigationLink(value: moment) {
                                    MomentSearchRow(moment: moment)
                                }
                            }
                        }
                        .listRowBackground(Color("CardBackgroundColor"))
                    }

                    if !resources.isEmpty {
                        Section("resources") {
                            ForEach(resources) { resource in
                                NavigationLink(value: resource) {
                                    Text(resource.title)
                                }
                            }
                        }
                        .listRowBackground(Color("CardBackgroundColor"))
                    }
                }
            }
            .navigationTitle("search")
            .searchable(text: $searchText, isPresented: $isSearchPresented)
            .navigationDestination(for: Moment.self) { moment in
                FormView(moment: moment)
            }
            .navigationDestination(for: Resource.self) { resource in
                FormView(resource: resource)
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
        }
        // Keep both requests in step with the field.
        .onChange(of: searchText, initial: true) { _, newValue in
            $moments.searchText.wrappedValue = newValue
            $resources.searchText.wrappedValue = newValue
        }
        .onAppear { isSearchPresented = true }
    }

    private func placeholder(_ key: LocalizedStringKey) -> some View {
        VStack {
            Spacer(minLength: 60)
            HStack {
                Spacer()
                Text(key).foregroundStyle(.gray)
                Spacer()
            }
        }
        .listRowBackground(Color("AppBackgroundColor"))
    }
}

/// A moment in the search results, with its date for context — the lists
/// elsewhere rely on their own grouping for that.
private struct MomentSearchRow: View {
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(moment.title)
            Text(moment.startAt.formatted(.dateTime.day().month().year()))
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    SearchView()
}
