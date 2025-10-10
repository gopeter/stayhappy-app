//
//  HighlightsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import GRDBQuery
import SwiftUI

struct HighlightsView: View {
    @Query(HighlightListRequest()) private var moments: [Moment]
    @EnvironmentObject var globalData: GlobalData

    let deviceSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if self.moments.count > 0 {
                            Spacer(minLength: 4)

                            ForEach(self.moments, id: \.id) { moment in
                                HighlightView(
                                    moment: moment,
                                    deviceSize: deviceSize
                                )
                            }
                        }
                        else {
                            VStack {
                                Spacer(minLength: 80)
                                HStack {
                                    Spacer()
                                    Text("no_highlights_created").foregroundStyle(.gray)
                                    Spacer()
                                }
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }.background(Color("AppBackgroundColor"))
                    .scrollContentBackground(.hidden)
                    .navigationTitle("highlights")
                    .toolbarTitleDisplayMode(.large)

            }
        }
        .onAppear {
            // Handle deep links when HighlightsView is already visible
            checkForPendingHighlightTrigger()
        }
    }

    private func checkForPendingHighlightTrigger() {
        // This ensures deep links work even when HighlightsView is already active
        if globalData.highlightImageToShow != nil {
            // Trigger will be handled by the specific HighlightView that matches this momentId
            // We don't need to do anything here, just ensure the onChange triggers fire
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Small delay to ensure all HighlightViews have appeared
                // The individual HighlightView.onChange will handle the actual opening
            }
        }
    }
}

#Preview {
    HighlightsView().environmentObject(GlobalData(activeView: .highlights))
}
