//
//  EventFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import os.log
import SwiftUI

struct EventFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var startAt: Date
    // @State private var endAt: Date
    @State private var isHighlight: Bool

    @FocusState private var isFocused: Bool

    let event: Event?

    var disableForm: Bool {
        title == ""
    }

    init(event: Event?) {
        self.event = event

        self._title = State(initialValue: event?.title ?? "")
        self._startAt = State(initialValue: event?.startAt ?? Date())
        // self._endAt = State(initialValue: event?.endAt ?? Date())
        self._isHighlight = State(initialValue: event?.isHighlight ?? false)
    }

    func addEvent() {
        do {
            var newEvent = EventMutation(
                id: event?.id,
                title: title,
                isHighlight: isHighlight,
                startAt: startAt,
                endAt: event?.endAt,
                createdAt: event?.createdAt,
                updatedAt: event?.updatedAt
            )

            try appDatabase.saveEvent(&newEvent)

            dismiss()
        } catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    func deleteEvent() {
        do {
            try appDatabase.deleteEvents([event!.id])
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
                DatePicker("Date", selection: $startAt, displayedComponents: [.date])
                // DatePicker("End", selection: $endAt, displayedComponents: [.date])
                Toggle("Highlight", isOn: $isHighlight)
                
                Button(action: addEvent, label: {
                    Text("Save")
                }).disabled(disableForm)
            } header: {
                if event != nil {
                    Text("Update event")
                } else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
            }.listRowBackground(Color("CardBackgroundColor"))
            
            if event != nil {
                Button(role: .destructive, action: deleteEvent, label: {
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
    EventFormView(event: nil)
}
