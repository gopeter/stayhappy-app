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
    
    @State var fullscreenImage: UIImage? = nil
    @State var isFullscreenActive = false
    
    func setImage(image: UIImage) {
        self.fullscreenImage = image
        
        withAnimation {
            self.isFullscreenActive = true
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if self.moments.count > 0 {
                            Spacer(minLength: 4)
                            
                            ForEach(self.moments) { moment in
                                HighlightView(moment: moment, setImage: self.setImage)
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
                    
                    Spacer(minLength: 80)
                }.background(Color("AppBackgroundColor"))
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Highlights")
                    .toolbarTitleDisplayMode(.large)
            }
            
            if self.isFullscreenActive && self.fullscreenImage != nil {
                ImageViewer(images: [self.fullscreenImage!], isPresenting: self.$isFullscreenActive)
            }
        }
    }
}

#Preview {
    HighlightsView()
}
