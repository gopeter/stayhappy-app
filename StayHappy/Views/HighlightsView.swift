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
    }
}

#Preview {
    HighlightsView().environmentObject(GlobalData(activeView: .highlights))
}
