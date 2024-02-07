//
//  EventFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import SwiftUI
import os.log

struct EventFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    let event: Event?

    @State private var title: String
    @State private var startAt: Date
    // @State private var endAt: Date
    @State private var isHighlight: Bool

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
            var newEvent = EventMutation(title: title, isHighlight: isHighlight, startAt: startAt)
            try appDatabase.saveEvent(&newEvent)

            dismiss()
        } catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack {
            Form {
                HStack(spacing: 0) {
                    Text("Add Event")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    
                    
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image("x-symbol")
                            .resizable()
                            .frame(width: 18.0, height: 18.0)
                         
                    })
                }.listRowBackground(Color("AppBackgroundColor"))
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                Section {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $startAt, displayedComponents: [.date])
                    // DatePicker("End", selection: $endAt, displayedComponents: [.date])
                    Toggle("Highlight", isOn: $isHighlight)
                }.listRowBackground(Color("CardBackgroundColor"))

                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Close")
                            Spacer()
                        }
                    }).buttonStyle(.bordered).tint(Color("TextColor"))

                    Spacer(minLength: 20)

                    Button(action: addEvent, label: {
                        HStack {
                            Spacer()
                            Text("Save")
                            Spacer()
                        }
                    }).buttonStyle(.borderedProminent).disabled(disableForm)

                }.listRowInsets(.init()).listRowBackground(Color("AppBackgroundColor"))
            }.background(Color("AppBackgroundColor")).scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    EventFormView(event: nil)
}
