//
//  EventView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import SwiftUI

struct EventView: View {
    let formatter = DateComponentsFormatter()
    var event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    func formatStartAtDate(startAt: Date) -> String {
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        
        let days = formatter.string(from: Calendar.current.startOfDay(for: Date.now), to: Calendar.current.startOfDay(for: startAt))!
        let isPastDate = days.starts(with: /-/)
        
        switch days {
            case "0 days":
                return "Today"
            case "1 day":
                return "Tomorrow"
            case "-1 day":
                return "Yesterday"
            default:
                return isPastDate ? String(days.dropFirst()) + " ago" : "In " + days
        }
    }
   
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(event.startAt.formatted(.dateTime.month())).frame(alignment: .leading).font(.footnote)
                
                Text(event.startAt.formatted(.dateTime.day())).frame(alignment: .leading).font(.title2).fontWeight(.bold)
            }.frame(minWidth: 40, maxWidth: 40)

            ZStack {
                Rectangle().fill(Color(UIColor.systemGray5)).frame(width: 1, alignment: .center)
                
                ZStack {
                    Circle().frame(width: 30, height: 30).foregroundStyle(Color(UIColor.systemGray5)).overlay(content: { Image("star-symbol").foregroundStyle(event.isHighlight ? Color.yellow : Color.gray) })
                }
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("CardBackgroundColor"))
                    .frame(alignment: Alignment.top)
                       
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatStartAtDate(startAt: event.startAt)).font(.footnote).foregroundStyle(.gray)
                    
                    Text(event.title)
                    
                }.padding(.horizontal, 14).padding(.vertical, 10)
            }.padding(.vertical, 10)
            
        }.padding(.horizontal)
    }
}

#Preview {
    EventView(event: Event(title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date()))
}
