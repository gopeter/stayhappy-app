//
//  MomentFormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import PhotosUI
import SwiftUI
import os.log

/// The gradient picker, as a grid grouped by colour family.
///
/// 117 full-width cards in one flat scroll meant a lot of scrolling to compare
/// colours that look alike, so the swatches are laid out side by side, grouped
/// the same way the widget configuration groups them, and searchable by name.
struct BackgroundOptionView: View {
    @Environment(\.dismiss) var dismiss

    var gradients: [String]
    @Binding var selectedGradient: String

    @State private var searchText = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    private var matches: [HappyGradients] {
        let all = gradients.compactMap { HappyGradients(rawValue: $0) }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else { return all }
        return all.filter { $0.displayName.localizedCaseInsensitiveContains(query) }
    }

    private var groups: [(family: HappyGradients.Family, gradients: [HappyGradients])] {
        let matches = matches

        return HappyGradients.Family.allCases.compactMap { family in
            let gradients = matches
                .filter { $0.family == family }
                .sorted { $0.displayName < $1.displayName }

            return gradients.isEmpty ? nil : (family, gradients)
        }
    }

    var body: some View {
        ScrollView {
            if groups.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .padding(.top, 60)
            }
            else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(groups, id: \.family) { group in
                        Section {
                            ForEach(group.gradients, id: \.self) { gradient in
                                GradientSwatch(
                                    gradient: gradient,
                                    isSelected: selectedGradient == gradient.rawValue
                                ) {
                                    selectedGradient = gradient.rawValue
                                    dismiss()
                                }
                            }
                        } header: {
                            Text(LocalizedStringKey(group.family.localizationKey))
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("background")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let random = gradients.randomElement() {
                        selectedGradient = random
                    }
                    dismiss()
                } label: {
                    // Icon only: spelled out, the label is wide enough to
                    // squeeze the navigation title.
                    Label("choose_random_color", image: "sparkles-symbol")
                }
            }
        }
    }
}

/// One gradient in the picker.
///
/// Selection is a ring around the swatch rather than a symbol beside it: it
/// leaves the colour itself unobscured, which matters for a gradient, and it
/// is what the system's own colour pickers use.
private struct GradientSwatch: View {
    let gradient: HappyGradients
    let isSelected: Bool
    let action: () -> Void

    private let cornerRadius: CGFloat = 12
    private let ringGap: CGFloat = 4

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(gradient.linear())
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        // Concentric with the swatch: the ring's radius grows
                        // by exactly the gap, so both curves share a centre.
                        RoundedRectangle(cornerRadius: cornerRadius + ringGap, style: .continuous)
                            .stroke(Color("AccentColor"), lineWidth: 2.5)
                            .padding(-ringGap)
                            .opacity(isSelected ? 1 : 0)
                    }

                Text(gradient.displayName)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color("AccentColor") : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            // Room for the ring, which is drawn outside the swatch.
            .padding(ringGap + 2)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(gradient.displayName)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
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
    @State private var previewImage: UIImage?
    @State private var isProcessingImage = false
    @State private var showingHelpSheet = false

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

    func saveMoment() async {
        // Only a highlight keeps its photo. The switch itself discards nothing
        // — everything is cleaned up here, so turning it off and on again
        // before saving leaves the selection untouched.
        let keepsPhoto = isHighlight && photoImage != nil

        // `nil` whenever no photo survives this save: the file is deleted below
        // in that case, and keeping the old name here left the row pointing at
        // a photo that no longer existed on disk.
        var photo: String? = keepsPhoto ? moment?.photo : nil

        // remove image from file system if ...
        if moment?.photo != nil {
            // ... photoPickerItem is set, a new photo was chosen
            // ... no photo is kept: it was removed, or the moment is not a
            //     highlight anymore
            if photoPickerItem != nil || !keepsPhoto {
                let imageSaver = ImageSaver(fileName: moment!.photo!)
                imageSaver.deleteFromDisk()
            }
        }

        // save image to file system if ...
        if keepsPhoto,
            // ... no photo was given and a photo was selected
            moment?.photo == nil
                // ... a photo was given and a new one was chosen
                || photoPickerItem != nil
        {
            photo = UUID().uuidString
            let imageSaver = ImageSaver(image: photoImage!, fileName: photo!)

            do {
                // Awaited, so the variants are on disk before the widget
                // timelines are told to reload below. Previously this returned
                // immediately and the widget rendered the uncropped original.
                try await imageSaver.writeToDisk()
                imageSaver.reloadWidgets()
            }
            catch {
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
        }
        catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    func deleteMoment() {
        do {
            try appDatabase.deleteMoments([moment!.id])
            dismiss()
        }
        catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }

    func removeImage() {
        photoImage = nil
        previewImage = nil
        // Otherwise the picked item would still count as "a new photo was
        // chosen" when saving.
        photoPickerItem = nil
    }

    /// `PhotosPicker`'s label closure is `@Sendable`, so main-actor state can't
    /// be read inside it. The state is therefore read once here and handed to a
    /// plain value type.
    @MainActor
    private var photoPicker: some View {
        let label = PhotoPickerLabel(
            preview: previewImage,
            isBusy: isProcessingImage || photoImage != nil
        )

        return PhotosPicker(selection: $photoPickerItem, matching: .images) {
            label
        }
    }

    private func generatePreviewImage(from image: UIImage) async {
        // Exactly the variant the highlight tile will later display, so what
        // you approve while editing is what ends up in the list. This used to
        // compute its own size from the screen width, producing a third,
        // different aspect ratio.
        let processedImage = await ImageProcessingService.shared.processImage(image, variant: .tile3x1)

        await MainActor.run {
            previewImage = processedImage
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("description", text: $title).focused($isFocused)
                DatePicker("date", selection: $startAt, displayedComponents: [.date])
                // DatePicker("End", selection: $endAt, displayedComponents: [.date])
                Toggle("Highlight", isOn: $isHighlight)
            } header: {
                // No placeholder view in the `else` branch: a zero-sized
                // `Color` is still a view, so the grouped section kept its
                // full header height and pushed the card down the sheet.
                if moment != nil {
                    Text("update_moment")
                }
            }.listRowBackground(Color("CardBackgroundColor"))

            if isHighlight {
                Section {
                    if photoImage == nil {
                        ZStack {
                            NavigationLink(
                                destination: BackgroundOptionView(gradients: HappyGradients.allCases.map { $0.rawValue }, selectedGradient: $background)
                            ) {
                                EmptyView()
                            }.opacity(0.0)
                                .buttonStyle(PlainButtonStyle())

                            HStack {
                                Text("background")
                                    .foregroundStyle(.text)
                                    .padding(.leading, 20)

                                Spacer()

                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(HappyGradients.named(background).radial(startRadius: 0, endRadius: 50))

                                Image("chevron-right-symbol")
                                    .foregroundStyle(Color(uiColor: .systemFill))
                                    .padding(.trailing, 12)
                            }
                        }
                    }

                    photoPicker

                    if photoImage != nil {
                        Button(
                            role: .destructive,
                            action: removeImage,
                            label: {
                                Text("remove_photo")
                            }
                        ).padding(.horizontal, 20)
                    }
                }.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color("CardBackgroundColor"))
                    .onChange(of: photoPickerItem) {
                        Task {
                            if let loaded = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                                photoImage = UIImage(data: loaded)
                                isProcessingImage = true

                                // Generate saliency-based preview
                                if let image = photoImage {
                                    await generatePreviewImage(from: image)
                                    isProcessingImage = false
                                }
                            }
                            else {
                                print("Failed")
                                isProcessingImage = false
                            }
                        }
                    }
            }

            // Saving moved to the checkmark in the toolbar, so this section
            // only remains for the destructive action when editing.
            if moment != nil {
                Section {
                    Button(
                        role: .destructive,
                        action: deleteMoment,
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
            .animation(.none, value: isHighlight)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await saveMoment() }
                    } label: {
                        Label("save", image: "check-symbol")
                    }
                    // `.glass` (the toolbar default) only tints the glyph;
                    // the prominent variant fills the whole capsule.
                    .buttonStyle(.glassProminent)
                    .tint(.yellow)
                    .disabled(disableForm)
                }
            }
            .sheet(isPresented: $showingHelpSheet) {
                MomentHelpView()
            }
            .onAppear {
                isFocused = true

                // Generate preview for existing moment
                if moment?.photo != nil, let photoFileName = moment?.photo {
                    let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(photoFileName).jpg")
                    if let image = UIImage(contentsOfFile: photoUrl.path) {
                        isProcessingImage = true
                        Task {
                            await generatePreviewImage(from: image)
                            isProcessingImage = false
                        }
                    }
                }
            }
    }
}

/// The `PhotosPicker` label, as a plain value type so it can be constructed
/// outside the picker's `@Sendable` closure.
private struct PhotoPickerLabel: View {
    let preview: UIImage?
    /// A photo is selected but its preview is still being rendered.
    let isBusy: Bool

    var body: some View {
        if let preview {
            // Shown at the tile's own aspect ratio, so the preview matches the
            // highlight tile exactly instead of being cropped again here.
            Image(uiImage: preview)
                .resizable()
                .aspectRatio(ImageVariant.tile3x1.aspectRatio, contentMode: .fit)
                .padding(0)
        }
        else if isBusy {
            ZStack {
                Color.gray.opacity(0.3)
                    .aspectRatio(ImageVariant.tile3x1.aspectRatio, contentMode: .fit)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            }
        }
        else {
            Text("select_photo").padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        MomentFormView(moment: nil)
    }
}
