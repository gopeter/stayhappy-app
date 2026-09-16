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

    var body: some View {
        ZStack {
            Color("AppBackgroundColor")
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
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
        // Presentation-level chrome lives here because only `FormView` knows
        // whether it is being shown as a sheet. The save action is contributed
        // by the child form, which is where the data lives.
        .toolbar {
            if isInSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("close", image: "x-symbol")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Menu {
                        Picker("select_entry_type", selection: $selection) {
                            Text("moment").tag(Selection.moment)
                            Text("resource").tag(Selection.resource)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selection == Selection.resource ? "new_resource" : "new_moment")
                            Text(selection == Selection.resource ? "resource" : "moment")
                            Image("chevron-down-symbol")
                                .font(.caption2)
                        }
                        .font(.headline)
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
