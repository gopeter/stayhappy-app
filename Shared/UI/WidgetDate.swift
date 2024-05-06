//
//  WidgetDate.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 02.05.24.
//

import SwiftUI

func getWeekday(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E"
    let weekDay = dateFormatter.string(from: date)
    
    return weekDay
}

enum WidgetDateSize: String, CaseIterable {
    case small
    case medium
}

struct WidgetDate: View {
    var date: Date
    var size: WidgetDateSize

    let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 0) {
            if calendar.isDateInToday(date) {
                Text("Today")
            } else if calendar.isDateInTomorrow(date) {
                Text("Tomorrow")
            } else {
                let diff = calendar.numberOfDaysBetween(Date(), and: date)
                Text("In \(diff) days")
            }

            if size != .small {
                Text(" – ")
                Text(getWeekday(date))
                Text(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }
}
