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
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
    private var bottomNavigationSection: some View {
        HStack {
            // Back button
            if !onboardingState.isFirstPage {
                Button(action: {
                    onboardingState.previousPage()
                }) {
                    HStack(spacing: 8) {
                        Image("chevron-left-symbol")
                            .font(.headline)
                        Text(NSLocalizedString("onboarding_back", comment: ""))
                            .font(.headline)
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .frame(height: 44)
                    .padding(.horizontal, 20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(OnboardingButtonStyle())
            }

            Spacer()

            // Next/Continue button
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
                        .font(.headline)
                    if !onboardingState.isLastPage {
                        Image("chevron-right-symbol")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(height: 44)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(OnboardingButtonStyle())
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Handlers (not needed anymore)
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(OnboardingState())
}
