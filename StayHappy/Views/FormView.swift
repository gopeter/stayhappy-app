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
        VStack(spacing: 0) {
            if isInSheet {
                HStack {
                    Text("add").font(.title).fontWeight(.bold)
                    Menu {
                        Picker("select_entry_type", selection: $selection) {
                            Text("moment").tag(Selection.moment)
                            Text("resource").tag(Selection.resource)
                        }
                    } label: {
                        HStack {
                            Text(selection == Selection.resource ? "Resource" : "Moment").font(.title).fontWeight(.bold)
                            Image("chevron-down-symbol").padding(.top, 5)
                        }
                    }

                    Spacer()

                    if isInSheet {
                        Button(
                            action: {
                                dismiss()
                            },
                            label: {
                                Image("x-symbol")
                                    .resizable()
                                    .frame(width: 18.0, height: 18.0)

                            }
                        )
                    }
                }.padding(.horizontal, 20)
                    .padding(.top, moment == nil && resource == nil ? 40 : 20)
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

        }.background(Color("AppBackgroundColor"))
    }
}

#Preview {
    FormView(for: .moment, isInSheet: false)
}
