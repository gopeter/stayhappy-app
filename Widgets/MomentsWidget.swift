//
//  Widgets.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import GRDBQuery
import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MomentsWidgtEntry {
        MomentsWidgtEntry(date: Date(), configuration: MomentsWidgetConfigurationIntent())
    }

    func snapshot(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> MomentsWidgtEntry {
        MomentsWidgtEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: MomentsWidgetConfigurationIntent, in context: Context) async -> Timeline<MomentsWidgtEntry> {
        var entries: [MomentsWidgtEntry] = []

        // Our timeline consists of one update per day – or once the data has changed, which will be handled in the app itself
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MomentsWidgtEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct MomentsWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MomentsWidgetConfigurationIntent
}

struct MomentsWidgetEntryView: View {
    @Query(MomentsWidgetRequest()) private var moments: [Moment]

    var entry: MomentsWidgtEntry

    var body: some View {
        VStack {
            Text("Moments")
            Text(entry.configuration.limit.rawValue)
        }
    }
}

struct MomentsWidget: Widget {
    let kind: String = "Moments Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MomentsWidgetConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            MomentsWidgetEntryView(entry: entry)
                .environment(\.appDatabase, .init(mode: .write))
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

// MARK: - Give SwiftUI access to the database

//
// Define a new environment key that grants access to an AppDatabase.
//
// The technique is documented at
// https://developer.apple.com/documentation/swiftui/environmentkey

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .init(mode: .read) }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

// In this app, views observe the database with the @Query property
// wrapper, defined in the GRDBQuery package. Its documentation recommends to
// define a dedicated initializer for `appDatabase` access, so we comply:

extension Query where Request.DatabaseContext == AppDatabase {
    /// Convenience initializer for requests that feed from `AppDatabase`.
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}

#Preview(as: .systemSmall) {
    MomentsWidget()
} timeline: {
    MomentsWidgtEntry(date: .now, configuration: MomentsWidgetConfigurationIntent())
}
