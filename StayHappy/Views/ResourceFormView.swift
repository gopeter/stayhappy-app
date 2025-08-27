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
                TextField("Description", text: $title).focused($isFocused)
            } header: {
                if resource != nil {
                    Text("update_resource")
                }
                else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            Section {
                Button(
                    action: addResource,
                    label: {
                        Text("save")
                    }
                ).disabled(disableForm)

                if resource != nil {
                    Button(
                        role: .destructive,
                        action: deleteResource,
                        label: {
                            Text("delete")
                        }
                    )
                }
            }.listRowBackground(Color("CardBackgroundColor"))
        }.scrollContentBackground(.hidden)
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    ResourceFormView(resource: nil)
}
