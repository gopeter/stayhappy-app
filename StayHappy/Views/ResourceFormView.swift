//
//  ResourceFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import SwiftUI
import os.log

struct ResourceFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var showingHelpSheet = false

    @FocusState private var isFocused: Bool

    let resource: Resource?

    var disableForm: Bool {
        title == ""
    }

    init(resource: Resource?) {
        self.resource = resource

        self._title = State(initialValue: resource?.title ?? "")
    }

    func addResource() {
        do {
            var newResource = ResourceMutation(
                id: resource?.id,
                title: title,
                createdAt: resource?.createdAt,
                updatedAt: resource?.updatedAt
            )

            try appDatabase.saveResource(&newResource)

            dismiss()
        }
        catch {
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    func deleteResource() {
        do {
            try appDatabase.deleteResources([resource!.id])
            dismiss()
        }
        catch {
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("description", text: $title).focused($isFocused)
            } header: {
                // See `MomentFormView`: an empty placeholder view still
                // reserves the section's header height.
                if resource != nil {
                    Text("update_resource")
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            // Saving moved to the checkmark in the toolbar, so this section
            // only remains for the destructive action when editing.
            if resource != nil {
                Section {
                    Button(
                        role: .destructive,
                        action: deleteResource,
                        label: {
                            Text("delete")
                        }
                    )
                }.listRowBackground(Color("CardBackgroundColor"))
            }

            Section {
                Button(
                    action: {
                        showingHelpSheet = true
                    },
                    label: {
                        Text("help_examples")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0))
        }.scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addResource) {
                        Label("save", image: "check-symbol")
                    }
                    // See `MomentFormView`: the prominent glass variant fills
                    // the capsule with the tint instead of only the glyph.
                    .buttonStyle(.glassProminent)
                    .tint(.yellow)
                    .disabled(disableForm)
                }
            }
            .sheet(isPresented: $showingHelpSheet) {
                ResourceHelpView()
            }
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    ResourceFormView(resource: nil)
}
