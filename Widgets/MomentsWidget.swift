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
    private let database: AppDatabase

    init(database: AppDatabase) {
        self.database = database
    }

    func placeholder(in context: Context) -> MomentsWidgtEntry {
        MomentsWidgtEntry(
            date: Date(),
            configuration: MomentsWidgetConfigurationIntent(),
            moments: [],
            placeholderResources: [],
            placeholderHighlights: []
        )
    }

    func snapshot(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> MomentsWidgtEntry {
        do {
            let moments = try loadMoments(for: configuration.period, limit: 8)
            let (resources, highlights) = await loadPlaceholderData(for: configuration.placeholder)

            return MomentsWidgtEntry(
                date: Date(),
                configuration: configuration,
                moments: moments,
                placeholderResources: resources,
                placeholderHighlights: highlights
            )
        }
        catch {
            // Fallback to empty data on error
            return MomentsWidgtEntry(
                date: Date(),
                configuration: configuration,
                moments: [],
                placeholderResources: [],
                placeholderHighlights: []
            )
        }
    }

    func timeline(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> Timeline<MomentsWidgtEntry> {
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        do {
            let moments = try loadMoments(for: configuration.period, limit: 8)
            let (resources, highlights) = await loadPlaceholderData(for: configuration.placeholder)

            let entry = MomentsWidgtEntry(
                date: currentDate,
                configuration: configuration,
                moments: moments,
                placeholderResources: resources,
                placeholderHighlights: highlights
            )

            return Timeline(entries: [entry], policy: .after(nextUpdateDate))
        }
        catch {
            // Fallback to empty data on error
            let entry = MomentsWidgtEntry(
                date: currentDate,
                configuration: configuration,
                moments: [],
                placeholderResources: [],
                placeholderHighlights: []
            )

            return Timeline(entries: [entry], policy: .after(nextUpdateDate))
        }
    }

    // MARK: - Data Loading

    public func loadMoments(for period: WidgetPeriodType, limit: Int = 8) throws -> [Moment] {
        let appDatabase = database

        return try appDatabase.reader.read { db in
            try Moment
                .all()
                .filterByPeriod(">=")
                .filterByPeriod("<=", period: period)
                .order(Moment.Columns.startAt.asc)
                .limit(limit)
                .fetchAll(db)
        }
    }

    public func loadPlaceholderData(for placeholder: WidgetMotivationType) async -> (
        resources: [Resource], highlights: [Moment]
    ) {
        do {
            let (resources, highlights) = try loadMotivationData(for: placeholder)
            return (resources: resources, highlights: highlights)
        }
        catch {
            return (resources: [], highlights: [])
        }
    }

    private func loadMotivationData(for placeholder: WidgetMotivationType, resourceLimit: Int = 6) throws -> (resources: [Resource], highlights: [Moment]) {
        var resources: [Resource] = []
        var highlights: [Moment] = []

        let appDatabase = database

        try appDatabase.reader.read { db in
            if placeholder == .all || placeholder == .highlights {
                highlights =
                    try Moment
                    .all()
                    .filterByPeriod("<")
                    .filterByHighlight()
                    .order(sql: "RANDOM()")
                    .limit(1)
                    .fetchAll(db)
            }

            // Adjust resource limit if we have highlights in .all mode
            let actualResourceLimit = placeholder == .all && highlights.count > 0 ? 3 : resourceLimit

            if placeholder == .all || placeholder == .resources {
                resources =
                    try Resource
                    .all()
                    .randomRows()
                    .limit(actualResourceLimit)
                    .fetchAll(db)
            }
        }

        return (resources: resources, highlights: highlights)
    }
}

struct MomentsWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MomentsWidgetConfigurationIntent
    let moments: [Moment]
    let placeholderResources: [Resource]
    let placeholderHighlights: [Moment]
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
    @Environment(\.appDatabase) var appDatabase
    let kind: String = "app.stayhappy.StayHappy.MomentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MomentsWidgetConfigurationIntent.self,
            provider: MomentsWidgetProvider(database: appDatabase)
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
    let appDatabase = AppDatabase.random()

    let provider = MomentsWidgetProvider(database: appDatabase)
    let moments = try? provider.loadMoments(for: .all, limit: 4)
    let (resources, highlights) = await provider.loadPlaceholderData(for: .highlights)

    MomentsWidgtEntry(
        date: .now,
        configuration: MomentsWidgetConfigurationIntent(),
        moments: moments!,
        placeholderResources: resources,
        placeholderHighlights: highlights
    )
}
