//
//  NavigationBarView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 29.01.24.
//

import SwiftUI

struct NavigationItem: Identifiable {
    let id: String = UUID().uuidString
    let icon: String
    let view: Views?
    let action: () -> Void
    let isActive: Bool
    
    func button() -> some View {
        return Button(action: action, label: {
            HStack {
                Spacer()
                Image(self.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0, height: 20.0)
                    .foregroundStyle(isActive ? Color("TextColor") : Color.gray)
                Spacer()
            }.frame(height: 54)
            
                    
        }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
    }
}

struct NavigationBarView: View {
    @EnvironmentObject private var globalData: GlobalData
    @State private var isPresented: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color("ToolbarBackgroundColor"))
                .frame(height: 54)
                .padding(.horizontal)
                .shadow(radius: 15)
            
            HStack(spacing: 0) {
                NavigationItem(icon: "calendar-range-symbol", view: Views.events, action: {
                    globalData.activeView = Views.events
                }, isActive: globalData.activeView == Views.events).button()
                
                NavigationItem(icon: "coffee-symbol", view: Views.moments, action: {
                    globalData.activeView = Views.moments
                }, isActive: globalData.activeView == Views.moments).button()
                
                NavigationItem(icon: "plus-circle-symbol", view: Views.events, action: {
                    isPresented.toggle()
                }, isActive: false).button().sheet(isPresented: $isPresented) {
                    NavigationStack {
                        EventFormView(event: nil)
                    }
                }
                
                NavigationItem(icon: "search-symbol", view: Views.search, action: {
                    globalData.activeView = Views.search
                }, isActive: globalData.activeView == Views.search).button()
                
                NavigationItem(icon: "user-symbol", view: Views.profile, action: {
                    globalData.activeView = Views.profile
                }, isActive: globalData.activeView == Views.profile).button()
            }.padding(.horizontal)
        }
    }
}

#Preview {
    NavigationBarView().environmentObject(GlobalData(activeView: .events))
}
