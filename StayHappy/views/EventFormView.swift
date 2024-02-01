//
//  EventFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import SwiftData
import SwiftUI

struct EventFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

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
        let newEvent = Event(title: title, isHighlight: isHighlight, startAt: startAt, endAt: startAt)
        context.insert(newEvent)
        dismiss()
    }

    var body: some View {
        VStack {
            Form {
                Text("Add Event").font(.title).fontWeight(.bold).listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0)).listRowBackground(Color("AppBackgroundColor"))

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
