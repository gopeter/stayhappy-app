//
//  FormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 09.02.24.
//

import SwiftUI

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    
    var moment: Moment?
    var resource: Resource?
    var isInSheet: Bool
    
    init(moment: Moment? = nil, resource: Resource? = nil, isInSheet: Bool = false) {
        self.moment = moment
        self.resource = resource
        self.isInSheet = moment == nil && resource == nil
    }
    
    enum Selection {
        case moment
        case resource
    }
    
    @State var selection: Selection = .moment
    
    var body: some View {
        VStack(spacing: 0) {
            if isInSheet {
                HStack {
                    Text("Add").font(.title).fontWeight(.bold)
                    Menu {
                        Picker("Select entry type", selection: $selection) {
                            Text("Moment").tag(Selection.moment)
                            Text("Resource").tag(Selection.resource)
                        }
                    } label: {
                        HStack {
                            Text(selection == Selection.resource ? "Resource" : "Moment").font(.title).fontWeight(.bold)
                            Image("chevron-down-symbol").padding(.top, 5)
                        }
                    }
                    
                    Spacer()
                    
                    if isInSheet {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image("x-symbol")
                                .resizable()
                                .frame(width: 18.0, height: 18.0)
                            
                        })
                    }
                }.padding(.horizontal, 20)
                    .padding(.top, moment == nil && resource == nil ? 40 : 20)
            }
            
            if moment != nil {
                MomentFormView(moment: moment)
                    .navigationTitle("Moment")
                    .navigationBarTitleDisplayMode(.inline)
            } else if resource != nil {
                ResourceFormView(resource: resource)
                    .navigationTitle("Resource")
                    .navigationBarTitleDisplayMode(.inline)
            } else if selection == Selection.moment {
                MomentFormView(moment: nil)
            } else if selection == Selection.resource {
                ResourceFormView(resource: nil)
            }
                
        }.background(Color("AppBackgroundColor"))
    }
}

#Preview {
    FormView(isInSheet: false)
}
