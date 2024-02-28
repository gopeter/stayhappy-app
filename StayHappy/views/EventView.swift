//
//  EventView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import os.log
import Pow
import SwiftUI

struct EventView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State private var isEventDetailSheetVisible: Bool = false
    
    let formatter = DateComponentsFormatter()
    var event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    func toggleHighlight(for event: Event) {
        do {
            // TODO: is there really no simple way to destruct the event as params?
            var updatedEvent = EventMutation(
                id: event.id,
                title: event.title,
                startAt: event.startAt,
                endAt: event.endAt,
                isHighlight: !event.isHighlight,
                background: event.background,
                photo: event.photo,
                createdAt: event.createdAt,
                updatedAt: event.updatedAt
            )
        
            try appDatabase.saveEvent(&updatedEvent)
        } catch {
            // TODO: log something useful
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
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
                Text("\(event.startAt.formatted(.dateTime.month())) \(event.startAt.formatted(.dateTime.year(.twoDigits)))")
                    .frame(alignment: .leading)
                    .font(.footnote)
                
                Text(event.startAt.formatted(.dateTime.day()))
                    .frame(alignment: .leading)
                    .font(.title2)
                    .fontWeight(.bold)
            }.frame(minWidth: 50, maxWidth: 50)

            // Heart
            ZStack {
                Rectangle()
                    .fill(Color(uiColor: .systemGray4))
                    .frame(width: 1, alignment: .center)
                
                Button {
                    toggleHighlight(for: event)
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 26, height: 26)
                            .foregroundStyle(Color("AppBackgroundColor"))
                            
                        Image("heart-symbol")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(uiColor: .systemGray4))
                            .opacity(event.isHighlight ? 0 : 1)
                            .scaleEffect(event.isHighlight ? CGSize(width: 0.3, height: 0.3) : CGSize(width: 1.0, height: 1.0))
                            .animation(.easeInOut(duration: 0.2), value: event.isHighlight)
                        
                        Image("heart-filled-symbol")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.red)
                            .opacity(event.isHighlight ? 1 : 0)
                            .scaleEffect(event.isHighlight ? CGSize(width: 1.0, height: 1.0) : CGSize(width: 0.3, height: 0.3))
                            .animation(.easeInOut(duration: 0.2), value: event.isHighlight)
                    }
                }
                .changeEffect(
                    .spray {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }, value: event.isHighlight, isEnabled: !event.isHighlight
                )
                .buttonStyle(HighlightButtonStyle())
                .tint(event.isHighlight ? .red : .gray)
            }
            
            // Content Card
            NavigationLink(value: event) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("CardBackgroundColor"))
                        .frame(alignment: Alignment.top)
                
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatStartAtDate(startAt: event.startAt))
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            
                            Text(event.title)
                            
                        }.padding(.horizontal, 20).padding(.vertical, 10)
                        
                        Spacer()
                        
                        Image("chevron-right-symbol")
                            .foregroundStyle(Color(uiColor: .systemFill))
                            .padding(.trailing, 12)
                    }.listRowBackground(Color("CardBackgroundColor"))
                }.padding(.vertical, 10)
            }.buttonStyle(HighlightButtonStyle())
        }.padding(.horizontal)
    }
}

#Preview {
    EventView(event: Event(id: 1, title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date(), isHighlight: true, background: HappyGradients.aboveTheSky.rawValue, createdAt: Date(), updatedAt: Date()))
}
