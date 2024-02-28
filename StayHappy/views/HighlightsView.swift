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
    
    @State var fullscreenImage: UIImage? = nil
    @State var showFullscreen = false
    
    func setImage(image: UIImage) {
        self.fullscreenImage = image
        
        withAnimation {
            self.showFullscreen = true
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if self.events.count > 0 {
                            Spacer(minLength: 20)
                            
                            ForEach(self.events) { event in
                                HighlightView(event: event, setImage: self.setImage)
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
                    .toolbarTitleDisplayMode(.inlineLarge)
            }
            
            if self.showFullscreen && self.fullscreenImage != nil {
                ImageViewer(images: [self.fullscreenImage!], isPresenting: self.$showFullscreen)
            }
        }
    }
}

#Preview {
    HighlightsView()
}
