//
//  HelpView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct Link: View {
    var label: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
        }

    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Intro Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.title2)
                            Text("about_what_is_stayhappy")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_intro")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // Concept Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("about_the_idea")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_concept")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // Resources Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("about_resources_title")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_resources")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // Highlights Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("about_highlights_title")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_highlights")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // Encouragement Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.mint)
                                .font(.title2)
                            Text("about_the_beginning")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_encouragement")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // Disclaimer
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title3)
                            Text("about_important_note")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary.opacity(0.8))
                        }

                        Text("about_app_disclaimer")
                            .font(.callout)
                            .lineSpacing(3)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    .padding(20)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color("AppBackgroundColor"))
            .navigationTitle("about_app")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ThanksView: View {
    var body: some View {
        Text("thanks")
    }
}

struct CoffeeView: View {
    var body: some View {
        Text("coffee")
    }
}

struct HelpView: View {
    @EnvironmentObject var onboardingState: OnboardingState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        onboardingState.resetOnboarding()
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title2)
                                Text("restart_onboarding")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Spacer()
                                Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
                            }

                            Text("restart_onboarding_description")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }.padding(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color("CardBackgroundColor"))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    NavigationLink(
                        destination: {
                            AboutView()
                        },
                        label: {
                            Link(label: "about_app")
                        }
                    )

                    NavigationLink(
                        destination: {
                            ThanksView()
                        },
                        label: {
                            Link(label: "thanks")
                        }
                    )

                    NavigationLink(
                        destination: {
                            CoffeeView()
                        },
                        label: {
                            Link(label: "buy_me_coffee")
                        }
                    )
                }.listRowBackground(Color("CardBackgroundColor"))
            }.navigationLinkIndicatorVisibility(.hidden)
                .background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("help")
        }
    }
}

#Preview {
    HelpView()
        .environmentObject(OnboardingState())
}
