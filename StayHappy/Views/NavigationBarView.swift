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
                    .foregroundStyle(isActive ? Color.accentColor : Color.gray)
                Spacer()
            }.frame(height: 54)
                .contentShape(Rectangle())
        }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 54, maxHeight: 54)
            .buttonStyle(HighlightButtonStyle())
            
            
    }
}

struct NavigationBarView: View {
    @EnvironmentObject private var globalData: GlobalData
    @State private var isPresented: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color("ToolbarBackgroundColor"))
                .frame(height: 54)
                .padding(.horizontal, 28)
                .shadow(color: Color.black.opacity(0.35), radius: 5, y: 2)
            
            HStack(spacing: 0) {
                NavigationItem(icon: "calendar-range-symbol", action: {
                    globalData.activeView = Views.moments
                }, isActive: globalData.activeView == Views.moments).button()
                
                NavigationItem(icon: "coffee-symbol", action: {
                    globalData.activeView = Views.resources
                }, isActive: globalData.activeView == Views.resources).button()
                
                NavigationItem(icon: "plus-circle-symbol", action: {
                    isPresented.toggle()
                }, isActive: false).button().sheet(isPresented: $isPresented) {
                    NavigationStack {
                        FormView(for: globalData.activeView == Views.resources ? .resource : .moment)
                    }
                }
                
                NavigationItem(icon: "heart-symbol", action: {
                    globalData.activeView = Views.highlights
                }, isActive: globalData.activeView == Views.highlights).button()
                
                NavigationItem(icon: "badge-help-symbol", action: {
                    globalData.activeView = Views.help
                }, isActive: globalData.activeView == Views.help).button()
            }.padding(.horizontal, 35)
        }
    }
}

#Preview {
    NavigationBarView().environmentObject(GlobalData(activeView: .moments))
}
