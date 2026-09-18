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
    @State private var isCreatePresented = false

    var body: some View {
        NavigationStack {
            // A GeometryReader rather than `UIScreen.main.bounds`: the tile
            // height is derived from its width, so it has to follow the actual
            // container instead of a process-wide global.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        if self.moments.count > 0 {
                            Spacer(minLength: 4)

                            ForEach(self.moments, id: \.id) { moment in
                                HighlightView(
                                    moment: moment,
                                    deviceSize: proxy.size
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
                }
            }
            .background(Color("AppBackgroundColor"))
            .scrollContentBackground(.hidden)
            .navigationTitle("highlights")
            // A highlight is a moment with its flag set, so creating here
            // opens the moment form.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatePresented = true
                    } label: {
                        Label("add", image: "plus-symbol")
                            .imageScale(.large)
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
}

#Preview {
    HighlightsView().environmentObject(GlobalData(activeView: .highlights))
}
