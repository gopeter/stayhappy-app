//
//  HighlightsView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import GRDBQuery
import SwiftUI

struct HighlightsView: View {
    @Query(HighlightListRequest()) private var events: [Event]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if events.count > 0 {
                        Spacer(minLength: 20)
                        
                        ForEach(events) { event in
                            HighlightView(event: event)
                        }
                    } else {
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

                Spacer(minLength: 70)
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("Highlights")
                .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

#Preview {
    HighlightsView()
}
