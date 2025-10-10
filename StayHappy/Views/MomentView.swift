//
//  MomentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

import os.log
import Pow
import SwiftUI

struct MomentView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State private var isMomentDetailSheetVisible: Bool = false
    
    let formatter = DateComponentsFormatter()
    var moment: Moment
    
    init(moment: Moment) {
        self.moment = moment
    }
    
    func toggleHighlight(for moment: Moment) {
        do {
            var updatedMoment = MomentMutation(
                id: moment.id,
                title: moment.title,
                startAt: moment.startAt,
                endAt: moment.endAt,
                isHighlight: !moment.isHighlight,
                background: moment.background,
                photo: moment.photo,
                createdAt: moment.createdAt,
                updatedAt: moment.updatedAt
            )
        
            try appDatabase.saveMoment(&updatedMoment)
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
            VStack(spacing: 1) {
                Text(moment.startAt.formatted(.dateTime.weekday(.wide)))
                    .frame(alignment: .leading)
                    .font(.footnote)
                
                Text(moment.startAt.formatted(.dateTime.month().day()))
                    .frame(alignment: .leading)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(moment.startAt.formatted(.dateTime.year()))
                    .frame(alignment: .leading)
                    .font(.footnote)
            }.frame(minWidth: 50, maxWidth: 75)

            // Heart
            ZStack {
                Rectangle()
                    .fill(Color(uiColor: .systemGray4))
                    .frame(width: 1, alignment: .center)
                
                Button {
                    toggleHighlight(for: moment)
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
                            .opacity(moment.isHighlight ? 0 : 1)
                            .scaleEffect(moment.isHighlight ? CGSize(width: 0.3, height: 0.3) : CGSize(width: 1.0, height: 1.0))
                            .animation(.easeInOut(duration: 0.2), value: moment.isHighlight)
                        
                        Image("heart-filled-symbol")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.red)
                            .opacity(moment.isHighlight ? 1 : 0)
                            .scaleEffect(moment.isHighlight ? CGSize(width: 1.0, height: 1.0) : CGSize(width: 0.3, height: 0.3))
                            .animation(.easeInOut(duration: 0.2), value: moment.isHighlight)
                    }
                }
                .changeEffect(
                    .spray {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }, value: moment.isHighlight, isEnabled: !moment.isHighlight
                )
                .buttonStyle(HighlightButtonStyle())
                .tint(moment.isHighlight ? .red : .gray)
            }
            
            // Content Card
            NavigationLink(value: moment) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("CardBackgroundColor"))
                        .frame(alignment: Alignment.top)
                
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatStartAtDate(startAt: moment.startAt))
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            
                            Text(moment.title)
                        }.padding(12)
                        
                        Spacer()
                        
                        Image("chevron-right-symbol")
                            .foregroundStyle(Color(uiColor: .systemFill))
                            .padding(.trailing, 12)
                    }.listRowBackground(Color("CardBackgroundColor"))
                }.padding(.vertical, 8)
            }.buttonStyle(HighlightButtonStyle())
        }.padding(.horizontal)
    }
}

#Preview {
    MomentView(moment: Moment(id: 1, title: "Arctic Monkeys Concert", startAt: Date(), endAt: Date(), isHighlight: true, background: HappyGradients.loveKiss.rawValue, createdAt: Date(), updatedAt: Date()))
}
