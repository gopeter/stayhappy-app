//
//  OnboardingView.swift
//  StayHappy
//
//  Created by Assistant on 10.01.24.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var onboardingState: OnboardingState
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                // Custom Pager
                HStack(spacing: 0) {
                    ForEach(Array(onboardingState.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(
                            page: page
                        )
                        .frame(width: geometry.size.width)
                    }
                }
                .offset(x: -CGFloat(onboardingState.currentPageIndex) * geometry.size.width + dragOffset.width)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.dragOffset = value.translation
                            self.isDragging = true
                        }
                        .onEnded { value in
                            let threshold = geometry.size.width * 0.25
                            let newIndex: Int

                            if value.translation.width > threshold && onboardingState.currentPageIndex > 0 {
                                newIndex = onboardingState.currentPageIndex - 1
                            }
                            else if value.translation.width < -threshold && onboardingState.currentPageIndex < onboardingState.pages.count - 1 {
                                newIndex = onboardingState.currentPageIndex + 1
                            }
                            else {
                                newIndex = onboardingState.currentPageIndex
                            }

                            withAnimation(.easeInOut(duration: 0.3)) {
                                onboardingState.currentPageIndex = newIndex
                                self.dragOffset = .zero
                                self.isDragging = false
                            }
                        }
                )
                .animation(.easeInOut(duration: 0.4), value: onboardingState.currentPageIndex)

            }
        }
        // Pin top controls into the safe area
        .safeAreaInset(edge: .top) {
            HStack {
                OnboardingProgressView(
                    currentIndex: onboardingState.currentPageIndex,
                    totalPages: onboardingState.pages.count
                )
                Spacer()
                if !onboardingState.isLastPage {
                    Button("onboarding_skip") {
                        onboardingState.skipOnboarding()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .buttonStyle(.glass)
                    .tint(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        // Pin bottom navigation into the safe area
        .safeAreaInset(edge: .bottom) {
            HStack {
                bottomNavigationSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.clear)
        }
        .statusBarHidden(true)
        .onAppear {
            // Optional: Add analytics or other setup
        }
    }

    // MARK: - Bottom Navigation

    /// Both buttons sit in one `GlassEffectContainer` so the system treats them
    /// as a single pane of glass: their highlights and refraction are sampled
    /// together instead of each button dimming the gradient behind it on its own.
    ///
    /// The previous `.ultraThinMaterial` background was the pre-iOS-26 approach
    /// — a flat blur with no specular edge, which is what made these read as
    /// plain rectangles against the colourful pages.
    private var bottomNavigationSection: some View {
        GlassEffectContainer(spacing: 16) {
            HStack {
                // Back button
                if !onboardingState.isFirstPage {
                    Button(action: {
                        onboardingState.previousPage()
                    }) {
                        HStack(spacing: 8) {
                            Image("chevron-left-symbol")
                            Text(NSLocalizedString("onboarding_back", comment: ""))
                        }
                        .font(.headline)
                        .frame(height: 28)
                    }
                    .buttonStyle(.glass)
                    .tint(.white)
                }

                Spacer()

                // Next/Continue button — the primary action, so it gets the
                // prominent variant rather than a second identical button.
                Button(action: {
                    if onboardingState.isLastPage {
                        onboardingState.completeOnboarding()
                    }
                    else {
                        onboardingState.nextPage()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(NSLocalizedString(onboardingState.isLastPage ? "onboarding_finish_button" : "onboarding_next", comment: ""))
                        if !onboardingState.isLastPage {
                            Image("chevron-right-symbol")
                        }
                    }
                    .font(.headline)
                    .frame(height: 28)
                }
                .buttonStyle(.glassProminent)
                .tint(.white)
                .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Action Handlers (not needed anymore)
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(OnboardingState())
}
