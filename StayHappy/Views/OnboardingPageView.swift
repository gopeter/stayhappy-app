//
//  OnboardingPageView.swift
//  StayHappy
//
//  Created by Assistant on 10.01.24.
//

import SwiftUI

// MARK: - Individual Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                page.gradient.linear()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Icon/Image Section
                    iconSection
                        .padding(.bottom, 40)

                    // Content Section
                    contentSection
                        .padding(.horizontal, 32)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Icon Section
    private var iconSection: some View {
        Group {
            if let systemImage = page.systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            else if let imageName = page.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: 16) {
            // Title
            Text(NSLocalizedString(page.title, comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)

            // Subtitle (for welcome page)
            if let subtitle = page.subtitle {
                Text(NSLocalizedString(subtitle, comment: ""))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }

            // Description
            if !page.description.isEmpty {
                Text(NSLocalizedString(page.description, comment: ""))
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, 8)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
            }
        }
    }

    // (Buttons are provided by the bottom navigation in OnboardingView.)
}

// MARK: - Custom Button Style
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Progress Indicator
struct OnboardingProgressView: View {
    let currentIndex: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? .white : .white.opacity(0.3))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingPageView(
        page: OnboardingData.pages[0]
    )
}
