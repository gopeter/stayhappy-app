//
//  EventFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import os.log
import PhotosUI
import SwiftUI

struct EventFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var startAt: Date
    // @State private var endAt: Date
    @State private var isHighlight: Bool
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var photoImage: UIImage?

    @FocusState private var isFocused: Bool

    let imageSaver = ImageSaver()
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

        if event?.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: event!.photo!)).jpg")
            self._photoImage = State(initialValue: UIImage(contentsOfFile: photoUrl.path))
        }
    }

    func saveEvent() {
        var photo: String? = nil

        // remove image from file system if ...
        if event?.photo != nil {
            // ... photoPickerItem is set, a new photo was chosen
            // ... photoImage is nil, the present photo was deleted
            if photoPickerItem != nil || photoImage == nil {
                imageSaver.deleteFromDisk(imageName: event!.photo!)
            }
        }

        // save image to file system if ...
        if
            // ... no photo was given and a photo was selected
            (event?.photo == nil && photoImage != nil) ||
            // ... a photo was given and a new one was chosen
            (event?.photo != nil && photoPickerItem != nil && photoImage != nil)
        {
            photo = UUID().uuidString
            imageSaver.writeToDisk(image: photoImage!, imageName: photo!)
        }

        do {
            var newEvent = EventMutation(
                id: event?.id,
                title: title,
                isHighlight: isHighlight,
                startAt: startAt,
                endAt: event?.endAt,
                photo: photo,
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

    func removeImage() {
        photoImage = nil
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title).focused($isFocused)
                DatePicker("Date", selection: $startAt, displayedComponents: [.date])
                // DatePicker("End", selection: $endAt, displayedComponents: [.date])
                Toggle("Highlight", isOn: $isHighlight)
            } header: {
                if event != nil {
                    Text("Update event")
                } else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            Section {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    if photoImage != nil {
                        Image(uiImage: photoImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .padding(0)

                    } else {
                        Text("Select photo").padding(.horizontal, 20)
                    }
                }

                if photoImage != nil {
                    Button(role: .destructive, action: removeImage, label: {
                        Text("Remove photo")
                    }).padding(.horizontal, 20)
                }
            }.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color("CardBackgroundColor"))
                .onChange(of: photoPickerItem) {
                    Task {
                        if let loaded = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                            photoImage = UIImage(data: loaded)
                        } else {
                            print("Failed")
                        }
                    }
                }

            Section {
                Button(action: saveEvent, label: {
                    Text("Save")
                }).disabled(disableForm)

                if event != nil {
                    Button(role: .destructive, action: deleteEvent, label: {
                        Text("Delete")
                    })
                }
            }.listRowBackground(Color("CardBackgroundColor"))
        }.scrollContentBackground(.hidden)
            .onAppear {
                isFocused = true
            }
    }
}

#Preview {
    EventFormView(event: nil)
}
