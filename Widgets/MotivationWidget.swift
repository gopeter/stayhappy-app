//
//  MotivationWidget.swift
//  Widgets
//
//  Created by Peter Oesteritz on 11.05.24.
//

import GRDBQuery
import SwiftUI
import WidgetKit

struct MotivationWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MotivationWidgtEntry {
        MotivationWidgtEntry(date: Date(), configuration: MotivationWidgetConfigurationIntent())
    }

    func snapshot(for configuration: MotivationWidgetConfigurationIntent, in context: Context) async -> MotivationWidgtEntry {
        MotivationWidgtEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: MotivationWidgetConfigurationIntent, in context: Context) async -> Timeline<MotivationWidgtEntry> {
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        return Timeline(entries: [MotivationWidgtEntry(date: currentDate, configuration: configuration)], policy: .after(nextDate))
    }
}

struct MotivationWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MotivationWidgetConfigurationIntent
}

struct MotivationWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MotivationWidgtEntry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            MotivationSmall(placeholder: entry.configuration.content)
                .background(HappyGradients.stayHappy.linear())
        case .systemMedium:
            MotivationMedium(placeholder: entry.configuration.content)
                .background(HappyGradients.stayHappy.linear())
        default:
            Text(NSLocalizedString("not_available", comment: ""))
        }
    }
}

struct MotivationWidget: Widget {
    let kind: String = "app.stayhappy.StayHappy.MotivationWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MotivationWidgetConfigurationIntent.self,
            provider: MotivationWidgetProvider()
        ) { entry in
            MotivationWidgetEntryView(entry: entry)
                .unredacted()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName(NSLocalizedString("motivation_widget_name", comment: ""))
        .description(NSLocalizedString("motivation_widget_description", comment: ""))
    }
}

#Preview(as: .systemMedium) {
    MotivationWidget()
} timeline: {
    MotivationWidgtEntry(date: .now, configuration: MotivationWidgetConfigurationIntent())
}
