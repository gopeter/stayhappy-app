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
///
/// Results carry their photo and highlight state, because neither was visible
/// here before: a moment that had both looked exactly like a bare one, and its
/// photo was unreachable from the edit form the row leads to.
private struct MomentSearchRow: View {
    let moment: Moment

    @EnvironmentObject private var globalData: GlobalData
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            if let thumbnail {
                // Deliberately outside the `NavigationLink`: a button nested in
                // a link's label never sees the tap, the whole row does. Side
                // by side, the thumbnail opens the photo and the rest of the
                // row still navigates to the form.
                Button {
                    openFullscreen()
                } label: {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("show_photo")
            }

            NavigationLink(value: moment) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(moment.title)
                        Text(moment.startAt.formatted(.dateTime.day().month().year()))
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    if moment.isHighlight {
                        Image("heart-filled-symbol")
                            .foregroundStyle(.red)
                    }
                }
            }
            // Since the link no longer fills the row, it draws an indicator of
            // its own on top of the cell's — one chevron is enough.
            .navigationLinkIndicatorVisibility(.hidden)
        }
        .task(id: moment) {
            await loadThumbnail()
        }
    }

    /// Uses the square variant that is written alongside every photo, so the
    /// row costs a cache lookup rather than a full-size JPEG decode.
    ///
    /// Only highlights show their photo. The file stays on disk when the flag
    /// is turned off, but the moment is a plain entry again from then on, so it
    /// should not be the one result in the list carrying an image.
    private func loadThumbnail() async {
        guard moment.isHighlight, let photoFileName = moment.photo else {
            thumbnail = nil
            return
        }

        thumbnail = await Task.detached(priority: .userInitiated) {
            ImageProcessingService.shared.processedImage(for: photoFileName, variant: .widget1x1)
        }.value
    }

    private func openFullscreen() {
        guard let photoFileName = moment.photo else { return }

        let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")
        guard let image = UIImage(contentsOfFile: photoUrl.path) else { return }

        globalData.fullscreenImage = image
        withAnimation(.easeInOut(duration: 0.3)) {
            globalData.isFullscreenPresented = true
        }
    }
}

#Preview {
    SearchView()
        .environment(\.appDatabase, .random())
        .environmentObject(GlobalData(activeView: .search))
}
