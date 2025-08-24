//
//  FadeInFullScreenCover.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 04.03.25.
//  See: https://gist.github.com/philipshen/8bfc229d986ad0ac13cbc3ac890f3c8e
//

import SwiftUI

struct FadeInFullScreenCoverModifier<V: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let view: () -> V

    @State var isPresentedInternal = false

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: Binding<Bool>(
                get: { isPresented },
                set: { isPresentedInternal = $0 }
            )) {
                Group {
                    if isPresentedInternal {
                        view()
                            .transition(.opacity)
                            .onDisappear { isPresented = false }
                    }
                }
                .onAppear { isPresentedInternal = true }
                .presentationBackground(.clear)
            }
            .transaction {
                // Disable default fullScreenCover animation
                $0.disablesAnimations = true

                // Add custom animation
                $0.animation = .easeInOut
            }
    }
}

extension View {
    func fadeInFullScreenCover<V: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> V
    ) -> some View {
        modifier(FadeInFullScreenCoverModifier(
            isPresented: isPresented,
            view: content
        ))
    }
}
