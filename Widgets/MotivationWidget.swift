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
    private let database: AppDatabase

    init(database: AppDatabase) {
        self.database = database
    }

    func placeholder(in context: Context) -> MotivationWidgtEntry {
        MotivationWidgtEntry(
            date: Date(),
            configuration: MotivationWidgetConfigurationIntent(),
            resources: [],
            highlights: []
        )
    }

    func snapshot(for configuration: MotivationWidgetConfigurationIntent, in context: Context) async -> MotivationWidgtEntry {
        do {
            let (resources, highlights) = try await loadMotivationWidgetData(
                for: configuration.content
            )

            return MotivationWidgtEntry(
                date: Date(),
                configuration: configuration,
                resources: resources,
                highlights: highlights
            )
        }
        catch {
            // Fallback to empty data on error
            return MotivationWidgtEntry(
                date: Date(),
                configuration: configuration,
                resources: [],
                highlights: []
            )
        }
    }

    func timeline(for configuration: MotivationWidgetConfigurationIntent, in context: Context) async -> Timeline<MotivationWidgtEntry> {
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        do {
            let (resources, highlights) = try await loadMotivationWidgetData(
                for: configuration.content
            )

            let entry = MotivationWidgtEntry(
                date: currentDate,
                configuration: configuration,
                resources: resources,
                highlights: highlights
            )

            return Timeline(entries: [entry], policy: .after(nextDate))
        }
        catch {
            // Fallback to empty data on error
            let entry = MotivationWidgtEntry(
                date: currentDate,
                configuration: configuration,
                resources: [],
                highlights: []
            )

            return Timeline(entries: [entry], policy: .after(nextDate))
        }
    }

    // MARK: - Data Loading

    public func loadMotivationWidgetData(for placeholder: WidgetMotivationType) async throws -> (
        resources: [Resource], highlights: [Moment]
    ) {
        let (resources, highlights) = try loadMotivationData(for: placeholder)
        return (resources: resources, highlights: highlights)
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

    private func loadProcessedImage(for moment: Moment?, size: CGSize) async -> UIImage? {
        guard let moment = moment,
            let photoFileName = moment.photo
        else {
            return nil
        }

        return await ImageProcessingService.shared.getProcessedImage(
            for: photoFileName,
            size: size
        )
    }
}

struct MotivationWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MotivationWidgetConfigurationIntent
    let resources: [Resource]
    let highlights: [Moment]
}

struct MotivationWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MotivationWidgtEntry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            MotivationSmall(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        case .systemMedium:
            MotivationMedium(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        default:
            Text(NSLocalizedString("not_available", comment: ""))
        }
    }
}

struct MotivationWidget: Widget {
    @Environment(\.appDatabase) var appDatabase
    let kind: String = "app.stayhappy.StayHappy.MotivationWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MotivationWidgetConfigurationIntent.self,
            provider: MotivationWidgetProvider(database: appDatabase)
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
    let appDatabase = AppDatabase.random()

    let provider = MotivationWidgetProvider(database: appDatabase)
    let data = try? await provider.loadMotivationWidgetData(for: .highlights)

    MotivationWidgtEntry(
        date: .now,
        configuration: MotivationWidgetConfigurationIntent(),
        resources: data!.resources,
        highlights: data!.highlights,
    )
}
