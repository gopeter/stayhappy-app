//
//  MomentFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import os.log
import PhotosUI
import SwiftUI

struct BackgroundOptionView: View {
    @Environment(\.dismiss) var dismiss

    var gradients: [String]
    @Binding var selectedGradient: String

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Button(action: {
                    self.selectedGradient = self.gradients.randomElement()!
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Choose random color").padding(.vertical, 14)
                        Spacer()
                    }
                })

                ForEach(0 ..< gradients.count, id: \.self) { index in
                    Button(action: {
                        self.selectedGradient = self.gradients[index]
                    }, label: {
                        HStack {
                            Image(self.selectedGradient == self.gradients[index] ? "check-circle-symbol" : "circle-symbol")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.text.opacity(self.selectedGradient == self.gradients[index] ? 1 : 0.3))
                                .padding(.trailing, 10)

                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(HappyGradients(rawValue: self.gradients[index])!.linear())
                                .frame(height: 80)
                                .overlay {
                                    Text(self.gradients[index].titleCased()).foregroundStyle(.white) .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                                }
                        }
                    }).padding(.horizontal, 20)
                }
            }
        }.navigationTitle("Background")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AppBackgroundColor"))
    }
}

struct MomentFormView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var startAt: Date
    // @State private var endAt: Date
    @State private var isHighlight: Bool
    @State private var background: String
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var photoImage: UIImage?

    @FocusState private var isFocused: Bool

    let moment: Moment?

    var disableForm: Bool {
        title == ""
    }

    init(moment: Moment?) {
        self.moment = moment

        self._title = State(initialValue: moment?.title ?? "")
        self._startAt = State(initialValue: moment?.startAt ?? Date())
        // self._endAt = State(initialValue: moment?.endAt ?? Date())
        self._background = State(initialValue: moment?.background ?? HappyGradients.allCases.map { $0.rawValue }.randomElement()!)
        self._isHighlight = State(initialValue: moment?.isHighlight ?? false)

        if moment?.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: moment!.photo!)).jpg")
            self._photoImage = State(initialValue: UIImage(contentsOfFile: photoUrl.path))
        }
    }

    func saveMoment() {
        var photo: String? = moment?.photo

        // remove image from file system if ...
        if moment?.photo != nil {
            // ... photoPickerItem is set, a new photo was chosen
            // ... photoImage is nil, the present photo was deleted
            if photoPickerItem != nil || photoImage == nil {
                let imageSaver = ImageSaver(fileName: moment!.photo!)
                imageSaver.deleteFromDisk()
            }
        }

        // save image to file system if ...
        if
            // ... no photo was given and a photo was selected
            (moment?.photo == nil && photoImage != nil) ||
            // ... a photo was given and a new one was chosen
            (moment?.photo != nil && photoPickerItem != nil && photoImage != nil)
        {
            photo = UUID().uuidString
            let imageSaver = ImageSaver(image: photoImage!, fileName: photo!)
            
            do {
                try imageSaver.writeToDisk()    
                try imageSaver.generateWidgetThumbnails()
            } catch {
                // TODO: log something useful
                Logger.debug.error("Error: \(error.localizedDescription)")
            }
        }

        do {
            var newMoment = MomentMutation(
                id: moment?.id,
                title: title,
                startAt: startAt,
                endAt: moment?.endAt,
                isHighlight: isHighlight,
                background: background,
                photo: photo,
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

    func removeImage() {
        photoImage = nil
    }

    var body: some View {
        Form {
            Section {
                TextField("Description", text: $title).focused($isFocused)
                DatePicker("Date", selection: $startAt, displayedComponents: [.date])
                // DatePicker("End", selection: $endAt, displayedComponents: [.date])
                Toggle("Highlight", isOn: $isHighlight)
            } header: {
                if moment != nil {
                    Text("Update moment")
                } else {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            if isHighlight {
                Section {
                    if photoImage == nil {
                        ZStack {
                            NavigationLink(destination: BackgroundOptionView(gradients: HappyGradients.allCases.map { $0.rawValue }, selectedGradient: $background)) {
                                EmptyView()
                            } .opacity(0.0)
                                .buttonStyle(PlainButtonStyle())

                            HStack {
                                Text("Background")
                                    .foregroundStyle(.text)
                                    .padding(.leading, 20)

                                Spacer()

                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(HappyGradients(rawValue: background)!.radial(startRadius: 0, endRadius: 50))

                                Image("chevron-right-symbol")
                                    .foregroundStyle(Color(uiColor: .systemFill))
                                    .padding(.trailing, 12)
                            }
                        }
                    }

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
            }

            Section {
                Button(action: saveMoment, label: {
                    Text("Save")
                }).disabled(disableForm)

                if moment != nil {
                    Button(role: .destructive, action: deleteMoment, label: {
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
    NavigationStack {
        MomentFormView(moment: nil)
    }
}
