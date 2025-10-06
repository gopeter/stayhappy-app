//
//  MomentsWidget.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import GRDBQuery
import SwiftUI
import WidgetKit

struct MomentsWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MomentsWidgtEntry {
        MomentsWidgtEntry(date: Date(), configuration: MomentsWidgetConfigurationIntent())
    }

    func snapshot(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> MomentsWidgtEntry {
        MomentsWidgtEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> Timeline<MomentsWidgtEntry> {
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        return Timeline(entries: [MomentsWidgtEntry(date: currentDate, configuration: configuration)], policy: .after(nextDate))
    }
}

struct MomentsWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MomentsWidgetConfigurationIntent
}

struct MomentsWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MomentsWidgtEntry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            MomentsSmall(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        case .systemMedium:
            MomentsMedium(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        default:
            Text(NSLocalizedString("not_available", comment: ""))
        }
    }
}

struct MomentsWidget: Widget {
    let kind: String = "app.stayhappy.StayHappy.MomentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MomentsWidgetConfigurationIntent.self,
            provider: MomentsWidgetProvider()
        ) { entry in
            MomentsWidgetEntryView(entry: entry)
                .unredacted()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName(NSLocalizedString("moments_widget_name", comment: ""))
        .description(NSLocalizedString("moments_widget_description", comment: ""))
    }
}

#Preview(as: .systemMedium) {
    MomentsWidget()
} timeline: {
    MomentsWidgtEntry(date: .now, configuration: MomentsWidgetConfigurationIntent())
}
