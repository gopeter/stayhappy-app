//
//  MomentFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import os.log
import SwiftUI

struct MomentFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    @State private var title: String

    @FocusState private var isFocused: Bool

    let moment: Moment?

    var disableForm: Bool {
        title == ""
    }

    init(moment: Moment?) {
        self.moment = moment

        self._title = State(initialValue: moment?.title ?? "")
    }

    func addMoment() {
        do {
            var newMoment = MomentMutation(
                id: moment?.id,
                title: title,
                createdAt: moment?.createdAt,
                updatedAt: moment?.updatedAt
            )

            try appDatabase.saveMoment(&newMoment)

            dismiss()
        } catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    func deleteMoment() {
        do {
            try appDatabase.deleteMoments([moment!.id])
            dismiss()
        } catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title).focused($isFocused)
                
                Button(action: addMoment, label: {
                    Text("Save")
                }).disabled(disableForm)
            } header: {
                if moment != nil {
                    Text("Update moment")
                } else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            if moment != nil {
                Button(role: .destructive, action: deleteMoment, label: {
                    Text("Delete")
                }).listRowBackground(Color("CardBackgroundColor"))
            }
        }.scrollContentBackground(.hidden)
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    MomentFormView(moment: nil)
}
