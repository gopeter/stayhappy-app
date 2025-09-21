//
//  OnboardingData.swift
//  StayHappy
//
//  Created by Assistant on 10.01.24.
//

import Foundation
import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable, Hashable {
    let id = UUID()
    let type: PageType
    let title: String
    let subtitle: String?
    let description: String
    let imageName: String?
    let systemImage: String?
    let gradient: HappyGradients
    let primaryButtonText: String?
    let secondaryButtonText: String?

    enum PageType {
        case welcome
        case feature
        case finish
    }
}

// MARK: - Onboarding Data Provider
struct OnboardingData {

    static let pages: [OnboardingPage] = [
        // Welcome Page
        OnboardingPage(
            type: .welcome,
            title: "onboarding_welcome_title",
            subtitle: "onboarding_welcome_subtitle",
            description: "",
            imageName: nil,
            systemImage: "heart.fill",
            gradient: .stayHappy,
            primaryButtonText: "onboarding_welcome_button",
            secondaryButtonText: "onboarding_skip"
        ),

        // Purpose Page
        OnboardingPage(
            type: .feature,
            title: "onboarding_purpose_title",
            subtitle: nil,
            description: "onboarding_purpose_text",
            imageName: nil,
            systemImage: "brain.head.profile",
            gradient: .trueSunset,
            primaryButtonText: nil,
            secondaryButtonText: nil
        ),

        // Moments Page
        OnboardingPage(
            type: .feature,
            title: "onboarding_moments_title",
            subtitle: nil,
            description: "onboarding_moments_text",
            imageName: nil,
            systemImage: "calendar.badge.plus",
            gradient: .deepBlue,
            primaryButtonText: nil,
            secondaryButtonText: nil
        ),

        // Resources Page
        OnboardingPage(
            type: .feature,
            title: "onboarding_resources_title",
            subtitle: nil,
            description: "onboarding_resources_text",
            imageName: nil,
            systemImage: "cup.and.saucer.fill",
            gradient: .springWarmth,
            primaryButtonText: nil,
            secondaryButtonText: nil
        ),

        // Widgets Page
        OnboardingPage(
            type: .finish,
            title: "onboarding_widgets_title",
            subtitle: nil,
            description: "onboarding_widgets_text",
            imageName: nil,
            systemImage: "apps.iphone",
            gradient: .nightFade,
            primaryButtonText: "onboarding_finish_button",
            secondaryButtonText: nil
        ),
    ]
}

// MARK: - Onboarding State Manager
class OnboardingState: ObservableObject {
    @Published var currentPageIndex: Int = 0
    @Published var hasCompletedOnboarding: Bool = false

    let pages = OnboardingData.pages

    init() {
        let savedValue = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.hasCompletedOnboarding = savedValue
    }

    private func saveToUserDefaults() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.synchronize()
    }

    var currentPage: OnboardingPage {
        pages[currentPageIndex]
    }

    var isFirstPage: Bool {
        currentPageIndex == 0
    }

    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }

    var progress: Double {
        Double(currentPageIndex + 1) / Double(pages.count)
    }

    func nextPage() {
        guard currentPageIndex < pages.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPageIndex += 1
        }
    }

    func previousPage() {
        guard currentPageIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPageIndex -= 1
        }
    }

    func completeOnboarding() {
        // Notify observers before changing the state
        objectWillChange.send()

        // Update the state immediately
        hasCompletedOnboarding = true
        saveToUserDefaults()
    }

    func skipOnboarding() {
        completeOnboarding()
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentPageIndex = 0
    }
}
