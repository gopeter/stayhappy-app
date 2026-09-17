//
//  FormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 09.02.24.
//

import SwiftUI

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    @State var selection: Selection = .moment

    enum Selection {
        case moment
        case resource
    }

    var moment: Moment?
    var resource: Resource?
    var isInSheet: Bool

    init(for selection: Selection? = nil, moment: Moment? = nil, resource: Resource? = nil, isInSheet: Bool = false) {
        self.moment = moment
        self.resource = resource
        self.isInSheet = moment == nil && resource == nil

        if selection != nil {
            _selection = State(initialValue: selection!)
        }
    }

    private var formContent: some View {
        ZStack {
            Color("AppBackgroundColor")
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                if isInSheet {
                    sheetHeader
                }

                if moment != nil {
                    MomentFormView(moment: moment)
                        .navigationTitle("moment")
                        .navigationBarTitleDisplayMode(.inline)
                }
                else if resource != nil {
                    ResourceFormView(resource: resource)
                        .navigationTitle("resource")
                        .navigationBarTitleDisplayMode(.inline)
                }
                else if selection == Selection.moment {
                    MomentFormView(moment: nil)
                }
                else if selection == Selection.resource {
                    ResourceFormView(resource: nil)
                }

                Spacer()
            }
        }
    }

    /// "Neuer Moment" / "Neue Ressource" — the article and the type name are
    /// separate keys so the type can also be used on its own in the picker.
    private var sheetTitle: String {
        selection == Selection.resource
            ? "\(L.newResource.localized) \("resource".localized)"
            : "\(L.newMoment.localized) \("moment".localized)"
    }

    private var typePicker: some View {
        Picker("select_entry_type", selection: $selection) {
            Text("moment").tag(Selection.moment)
            Text("resource").tag(Selection.resource)
        }
    }

    /// The headline and the type switcher, as content rather than toolbar
    /// chrome. Both navigation-bar routes were dead ends: a `.principal` item
    /// is drawn at inline size while the bar still reserves its empty
    /// large-title row underneath — which is what left the form hanging low —
    /// and a `Menu` in iOS 27's `.largeTitle` placement renders at the right
    /// size but never receives taps.
    private var sheetHeader: some View {
        Menu {
            typePicker
        } label: {
            HStack(spacing: 6) {
                Text(sheetTitle)
                Image("chevron-down-symbol")
                    .font(.body)
            }
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // The headline is text, not an action, so it must not take the accent
        // tint the bar's buttons use.
        .tint(.primary)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // Presentation-level chrome lives here because only `FormView` knows
    // whether it is being shown as a sheet. The save action is contributed
    // by the child form, which is where the data lives.
    var body: some View {
        formContent
            // Without an explicit inline mode the bar keeps an empty
            // large-title row below the buttons, since the sheet sets no
            // navigation title of its own.
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isInSheet {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Label("close", image: "x-symbol")
                        }
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        FormView(for: .moment)
    }
}
