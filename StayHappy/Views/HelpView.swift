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

// MARK: - Building Blocks

/// One headline-plus-text block of static help copy.
///
/// The screens below are plain reading material, so they are built from `List`
/// sections rather than a `ScrollView` of `VStack`s: the card background, the
/// insets and the separators then come from the system instead of from
/// hand-placed colours, which is what made these pages the only ones in the app
/// without a card behind their content.
private struct HelpTopic: View {
    let icon: String
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(icon)
                    .overlay(HappyGradients.stayHappy.linear())
                    .mask(Image(icon))
                    .font(.title2)
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Text(text)
                .font(.body)
                .lineSpacing(4)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}

/// An aside — disclaimers and cost notes. Deliberately quieter than `HelpTopic`.
private struct HelpNote: View {
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("info-symbol")
                    .foregroundColor(.primary.opacity(0.8))
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary.opacity(0.8))
            }

            Text(text)
                .font(.callout)
                .lineSpacing(3)
                .foregroundColor(.primary.opacity(0.8))
        }
        .padding(.vertical, 8)
    }
}

private extension View {
    /// The list chrome shared by every help screen.
    func helpListStyle() -> some View {
        listRowBackground(Color("CardBackgroundColor"))
            .listRowSeparator(.hidden)
    }

    func helpScreenStyle() -> some View {
        listStyle(.insetGrouped)
            // The default section spacing is roughly 40pt, which left the cards
            // floating further apart than the title sits from the first card.
            // 16pt matches the gap the large title already leaves above it.
            .listSectionSpacing(16)
            .scrollContentBackground(.hidden)
            .background(Color("AppBackgroundColor"))
    }
}

// MARK: - Example Sheets

struct MomentHelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // A `NavigationStack` with a real toolbar, rather than the hand-built
        // header this used to carry: that header's fixed `padding(.top, 40)` was
        // what pushed the title away from the top edge.
        NavigationStack {
            List {
                Section {
                    HelpTopic(
                        icon: "smile-symbol",
                        title: "moment_help_title",
                        text: "moment_help_intro"
                    )
                }
                .helpListStyle()

                Section {
                    HelpTopic(
                        icon: "lightbulb-symbol",
                        title: "moment_help_examples_title",
                        text: "moment_help_examples"
                    )
                }
                .helpListStyle()

                Section {
                    HelpTopic(
                        icon: "heart-symbol",
                        title: "moment_help_highlights_title",
                        text: "moment_help_highlights"
                    )
                }
                .helpListStyle()

                Section {
                    HelpNote(title: "moment_help_tips_title", text: "moment_help_tips")
                }
                .listRowBackground(Color.secondary.opacity(0.08))
                .listRowSeparator(.hidden)
            }
            .helpScreenStyle()
            .navigationTitle("help_examples")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("close", image: "x-symbol")
                    }
                }
            }
        }
    }
}

struct ResourceHelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HelpTopic(
                        icon: "coffee-symbol",
                        title: "resource_help_title",
                        text: "resource_help_intro"
                    )
                }
                .helpListStyle()

                Section {
                    HelpTopic(
                        icon: "lightbulb-symbol",
                        title: "resource_help_examples_title",
                        text: "resource_help_examples"
                    )
                }
                .helpListStyle()
            }
            .helpScreenStyle()
            .navigationTitle("help_examples")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("close", image: "x-symbol")
                    }
                }
            }
        }
    }
}

// MARK: - Pushed Screens

// These three are pushed from `HelpView`'s own `NavigationStack`, so they must
// not bring a navigation container of their own. The `NavigationView` they used
// to be wrapped in put a second navigation bar inside the first one's content
// area, which is what pushed their large titles so far down the screen.

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HelpTopic(
                    icon: "smile-symbol",
                    title: "about_what_is_stayhappy",
                    text: "about_app_intro"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "lightbulb-symbol",
                    title: "about_the_idea",
                    text: "about_app_concept"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "layout-grid-symbol",
                    title: "about_widgets_title",
                    text: "about_app_widgets"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "coffee-symbol",
                    title: "about_resources_title",
                    text: "about_app_resources"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "heart-symbol",
                    title: "about_highlights_title",
                    text: "about_app_highlights"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "sun-symbol",
                    title: "about_the_beginning",
                    text: "about_app_encouragement"
                )
            }
            .helpListStyle()

            Section {
                HelpNote(title: "about_important_note", text: "about_app_disclaimer")
            }
            .listRowBackground(Color.secondary.opacity(0.08))
            .listRowSeparator(.hidden)
        }
        .helpScreenStyle()
        .navigationTitle("about_app")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ThanksView: View {
    var body: some View {
        List {
            Section {
                HelpTopic(
                    icon: "heart-symbol",
                    title: "thanks_family_title",
                    text: "thanks_family_text"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "sparkles-symbol",
                    title: "thanks_therapist_title",
                    text: "thanks_therapist_text"
                )
            }
            .helpListStyle()
        }
        .helpScreenStyle()
        .navigationTitle("thanks")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CoffeeView: View {
    var body: some View {
        List {
            Section {
                HelpTopic(
                    icon: "smile-symbol",
                    title: "coffee_intro_title",
                    text: "coffee_intro_text"
                )
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "square-code-symbol",
                    title: "coffee_opensource_title",
                    text: "coffee_opensource_text"
                )

                Link(destination: URL(string: "https://github.com/gopeter/stayhappy-app")!) {
                    HStack {
                        Text(verbatim: "github.com/gopeter/stayhappy-app")
                            .font(.callout)
                        Spacer()
                        // Matches the label's text size instead of `.caption2`,
                        // which rendered the glyph at roughly two thirds of it.
                        Image("external-link-symbol")
                            .foregroundColor(.primary)
                            .font(.callout)
                    }
                    .foregroundColor(.primary)
                }
            }
            .helpListStyle()

            Section {
                HelpTopic(
                    icon: "coffee-symbol",
                    title: "coffee_support_title",
                    text: "coffee_support_text"
                )

                // The one call to action on these screens, so it keeps its own
                // gradient fill instead of blending into the card.
                Link(destination: URL(string: "https://buymeacoffee.com/stayhappy")!) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("coffee_button_title")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("coffee_button_subtitle")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        Spacer()
                        Image("external-link-symbol")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    // A concentric shape shares its corner centres with the
                    // card's, so the inset button's curve follows the card's
                    // instead of cutting across it with a fixed radius of 12.
                    .background(
                        HappyGradients.stayHappy.linear(),
                        in: ConcentricRectangle(corners: .concentric, isUniform: true)
                    )
                    .foregroundColor(.white)
                    // The inset lives in the content rather than in
                    // `listRowInsets`, whose bottom value the row ignored —
                    // which is why the button sat flush with the card's edge.
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
                .listRowInsets(EdgeInsets())
            }
            .helpListStyle()

            Section {
                HelpNote(title: "coffee_costs_title", text: "coffee_costs_text")
            }
            .listRowBackground(Color.secondary.opacity(0.08))
            .listRowSeparator(.hidden)
        }
        .helpScreenStyle()
        .navigationTitle("buy_me_coffee")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Help Index

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
                                Image("rotate-ccw-symbol")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                Text("restart_onboarding")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Spacer()
                                Image("chevron-right-symbol")
                                    .foregroundStyle(Color(uiColor: .systemFill))
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
