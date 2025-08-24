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

    let deviceSize = UIScreen.main.bounds.size
    let widgetSize = getWidgetSize(for: .systemMedium)

    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if self.moments.count > 0 {
                            Spacer(minLength: 4)

                            ForEach(self.moments, id: \.id) { moment in
                                HighlightView(moment: moment, deviceSize: deviceSize, widgetSize: widgetSize)

                            }
                        }
                        else {
                            VStack {
                                Spacer(minLength: 80)
                                HStack {
                                    Spacer()
                                    Text("No highlights created").foregroundStyle(.gray)
                                    Spacer()
                                }
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }.background(Color("AppBackgroundColor"))
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Highlights")
                    .toolbarTitleDisplayMode(.large)
            }
        }
    }
}

#Preview {
    HighlightsView()
}
