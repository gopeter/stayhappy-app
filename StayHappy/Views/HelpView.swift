//
//  HelpView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

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
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text("restart_onboarding")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            Text("restart_onboarding_description")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Section {
                    Text("help")
                    Text("thanks")
                    Text("buy_me_coffee")
                }
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("help")
        }
    }
}

#Preview {
    HelpView()
        .environmentObject(OnboardingState())
}
