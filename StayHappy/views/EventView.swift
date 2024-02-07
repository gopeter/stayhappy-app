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
            // Date
            VStack(spacing: 0) {
                Text(event.startAt.formatted(.dateTime.month()))
                    .frame(alignment: .leading)
                    .font(.footnote)
                
                Text(event.startAt.formatted(.dateTime.day()))
                    .frame(alignment: .leading)
                    .font(.title2)
                    .fontWeight(.bold)
            }.frame(minWidth: 40, maxWidth: 40)

            // Heart
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: 1, alignment: .center)
                
                Circle()
                    .frame(width: 26, height: 26)
                    .foregroundStyle(Color("AppBackgroundColor"))
                    .overlay(
                        content: {
                            Image("heart-symbol")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundStyle(event.isHighlight ? Color.yellow : Color.gray)
                        }
                    )
            }
            
            // Content Card
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color("CardBackgroundColor"))
                    .frame(alignment: Alignment.top)
                       
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatStartAtDate(startAt: event.startAt)).font(.footnote).foregroundStyle(.gray)
                    
                    Text(event.title)
                    
                }.padding(.horizontal, 15).padding(.vertical, 10)
            }.padding(.vertical, 10)
            
        }.padding(.horizontal)
    }
}

#Preview {
    EventView(event: Event(id: 1, title: "Arctic Monkeys Concert", isHighlight: true, startAt: Date(), endAt: Date(), createdAt: Date(), updatedAt: Date()))
}
