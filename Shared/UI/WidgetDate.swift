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
                Text(NSLocalizedString("today", comment: ""))
            }
            else if calendar.isDateInTomorrow(date) {
                Text(NSLocalizedString("tomorrow", comment: ""))
            }
            else if calendar.isDateInYesterday(date) {
                Text(NSLocalizedString("yesterday", comment: ""))
            }
            else {
                let diff = calendar.numberOfDaysBetween(Date(), and: date)
                if diff < 0 {
                    Text(String(format: NSLocalizedString("days_ago", comment: ""), abs(diff)))
                }
                else {
                    Text(String(format: NSLocalizedString("in_days", comment: ""), diff))
                }
            }

            if size != .small {
                Text(" – ")
                Text(getWeekday(date))
                Text(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }
}
