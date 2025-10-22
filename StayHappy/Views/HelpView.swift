//
//  HelpView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct NavLink: View {
    var label: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
        }

    }
}

struct MomentHelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackgroundColor")
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    HStack {
                        Text("help_examples").font(.title).fontWeight(.bold)

                        Spacer()

                        Button(
                            action: {
                                dismiss()
                            },
                            label: {
                                Image("x-symbol")
                                    .resizable()
                                    .frame(width: 18.0, height: 18.0)
                            }
                        )
                    }.padding(.horizontal, 20)
                        .padding(.top, 40)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            // Intro Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink)
                                        .font(.title2)
                                    Text("moment_help_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }

                                Text("moment_help_intro")
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundColor(.primary)
                            }

                            // Examples Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                        .font(.title2)
                                    Text("moment_help_examples_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }

                                Text("moment_help_examples")
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
                                    Text("moment_help_highlights_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }

                                Text("moment_help_highlights")
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundColor(.primary)
                            }

                            // Tips Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    Text("moment_help_tips_title")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary.opacity(0.8))
                                }

                                Text("moment_help_tips")
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

                    Spacer()
                }
            }
        }
    }
}

struct ResourceHelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackgroundColor")
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    HStack {
                        Text("help_examples").font(.title).fontWeight(.bold)

                        Spacer()

                        Button(
                            action: {
                                dismiss()
                            },
                            label: {
                                Image("x-symbol")
                                    .resizable()
                                    .frame(width: 18.0, height: 18.0)
                            }
                        )
                    }.padding(.horizontal, 20)
                        .padding(.top, 40)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            // Intro Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title2)
                                    Text("resource_help_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }

                                Text("resource_help_intro")
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundColor(.primary)
                            }

                            // Examples Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                        .font(.title2)
                                    Text("resource_help_examples_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }

                                Text("resource_help_examples")
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }

                    Spacer()
                }
            }
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

                    // Widgets Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("about_widgets_title")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("about_app_widgets")
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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Intro Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.title2)
                            Text("coffee_intro_title")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("coffee_intro_text")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }

                    // GitHub Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("coffee_opensource_title")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Text("coffee_opensource_text")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)

                        Link(destination: URL(string: "https://github.com/gopeter/stayhappy-app")!) {
                            HStack {
                                Image(systemName: "link")
                                    .font(.caption)
                                Text("github.com/gopeter/stayhappy-app")
                                    .font(.callout)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.secondary.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                    }

                    // Buy Me a Coffee Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("coffee_support_title")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Text("coffee_support_text")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)

                        // Call to Action Button
                        Link(destination: URL(string: "https://buymeacoffee.com/stayhappy")!) {
                            HStack {
                                Image(systemName: "link")
                                    .font(.caption)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("coffee_button_title")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("coffee_button_subtitle")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(HappyGradients.stayHappy.linear())
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }

                        // Cost Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                Text("coffee_costs_title")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }

                            Text("coffee_costs_text")
                                .font(.callout)
                                .lineSpacing(3)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .padding(20)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color("AppBackgroundColor"))
            .navigationTitle("buy_me_coffee")
            .navigationBarTitleDisplayMode(.large)
        }
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
                            NavLink(label: "about_app")
                        }
                    )

                    NavigationLink(
                        destination: {
                            ThanksView()
                        },
                        label: {
                            NavLink(label: "thanks")
                        }
                    )

                    NavigationLink(
                        destination: {
                            CoffeeView()
                        },
                        label: {
                            NavLink(label: "buy_me_coffee")
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
