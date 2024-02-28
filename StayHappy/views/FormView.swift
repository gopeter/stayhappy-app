//
//  FormView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 09.02.24.
//

import SwiftUI

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    
    var event: Event?
    var moment: Moment?
    var isInSheet: Bool
    
    init(event: Event? = nil, moment: Moment? = nil, isInSheet: Bool = false) {
        self.event = event
        self.moment = moment
        self.isInSheet = event == nil && moment == nil
    }
    
    enum Selection {
        case event
        case moment
    }
    
    @State var selection: Selection = .event
    
    var body: some View {
        VStack(spacing: 0) {
            if isInSheet {
                HStack {
                    Text("Add").font(.title).fontWeight(.bold)
                    Menu {
                        Picker("Select entry type", selection: $selection) {
                            Text("Event").tag(Selection.event)
                            Text("Moment").tag(Selection.moment)
                        }
                    } label: {
                        HStack {
                            Text(selection == Selection.moment ? "Moment" : "Event").font(.title).fontWeight(.bold)
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
                    .padding(.top, event == nil && moment == nil ? 40 : 20)
            }
            
            if event != nil {
                EventFormView(event: event)
                    .navigationTitle("Event")
                    .navigationBarTitleDisplayMode(.inline)
            } else if moment != nil {
                MomentFormView(moment: moment)
                    .navigationTitle("Moment")
                    .navigationBarTitleDisplayMode(.inline)
            } else if selection == Selection.event {
                EventFormView(event: nil)
            } else if selection == Selection.moment {
                MomentFormView(moment: nil)
            }
                
        }.background(Color("AppBackgroundColor"))
    }
}

#Preview {
    FormView(isInSheet: false)
}
