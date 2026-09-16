//
//  MomentsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 25.01.24.
//

import GRDBQuery
import SwiftUI

struct MomentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(MomentListRequest(period: .upcoming, ordering: .asc)) private var moments: [Moment]
    @State private var isCreatePresented = false
    @State private var currentTitle = NSLocalizedString("upcoming_moments", comment: "")

    /// Whether the large title has shrunk into the navigation bar.
    ///
    /// There is no API for "is the title collapsed", so this tracks the scroll
    /// offset instead: the quick filter sits at the top of the content, and once
    /// it has scrolled away the same controls reappear as the toolbar menu.
    @State private var isTitleCollapsed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    quickFilter

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
                                Text("no_moments_created").foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                    }
                }
            }
            // `contentInsets.top` cancels out the large title's own inset, so the
            // comparison is against how far the content has actually travelled.
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top > 40
            } action: { _, collapsed in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isTitleCollapsed = collapsed
                }
            }
            // Navigation
            .navigationTitle(currentTitle)
            .navigationDestination(for: Moment.self) { moment in
                FormView(moment: moment)
            }
            .onAppear {
                syncTitle(with: $moments.period.wrappedValue)
            }
            // Both the quick filter and the toolbar menu write the same binding,
            // so the title follows the period from one place rather than from
            // whichever control happened to change it.
            .onChange(of: $moments.period.wrappedValue) { _, newValue in
                syncTitle(with: newValue)
            }
            // Style
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
            // Actions — creating lives here rather than in the tab bar, which
            // makes it an ordinary button (and therefore tintable) and lets the
            // type be implied by the list you are looking at.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTitleCollapsed {
                        filterMenu
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatePresented = true
                    } label: {
                        Label("add", image: "plus-symbol")
                    }
                }


            }
            .sheet(isPresented: $isCreatePresented) {
                NavigationStack {
                    FormView(for: .moment)
                }
            }
        }
    }

    private func syncTitle(with period: MomentListRequest.Period) {
        currentTitle = NSLocalizedString(period == .past ? "past_moments" : "upcoming_moments", comment: "")
    }
}

extension MomentsView {
    /// The same two choices as `filterMenu`, but spelled out under the headline.
    ///
    /// It lives inside the scroll content rather than pinned below the bar, so
    /// it scrolls away with the title instead of permanently costing a row of
    /// height — which is what makes the toolbar menu a replacement rather than a
    /// duplicate.
    private var quickFilter: some View {
        HStack(spacing: 12) {
            Picker("period", selection: $moments.period) {
                Text("upcoming").tag(MomentListRequest.Period.upcoming)
                Text("past").tag(MomentListRequest.Period.past)
            }
            .pickerStyle(.segmented)

            // The app's own staggered bars, mirrored vertically to state the
            // direction: long-to-short downwards is descending, short-to-long is
            // ascending — the same reading as Lucide's own
            // `arrow-down-wide-narrow` / `arrow-up-narrow-wide` pair.
            //
            // The glyph is centred, so mirroring it keeps the stack tidy and one
            // asset covers both directions.
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    $moments.ordering.wrappedValue = isAscending ? .desc : .asc
                }
            } label: {
                Image("list-filter-symbol")
                    .scaleEffect(x: 1, y: isAscending ? -1 : 1)
                    .accessibilityLabel(Text("ordering"))
            }
            .buttonStyle(.glass)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var isAscending: Bool {
        $moments.ordering.wrappedValue == .asc
    }

    /// Extracted from the toolbar builder to keep that expression small enough
    /// for the type checker.
    private var filterMenu: some View {
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
            Image("filter-symbol")
                .accessibilityLabel(Text("filter"))
        }
    }
}

#Preview {
    MomentsView()
}
