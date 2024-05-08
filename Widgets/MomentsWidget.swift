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
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        return Timeline(entries: [MomentsWidgtEntry(date: currentDate, configuration: configuration)], policy: .after(nextDate))
    }
}

struct MomentsWidgtEntry: TimelineEntry {
    let date: Date
    let configuration: MomentsWidgetConfigurationIntent
}

struct MomentDetail: View {
    var moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetDate(date: moment.startAt, size: .small)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.white)
                .opacity(0.5)

            Text(moment.title)
                .font(.system(size: 12, weight: .regular))
                .minimumScaleFactor(0.92)
                .lineLimit(1)
                .foregroundStyle(.white)
        }
    }
}

struct PlaceholderResourcesSmall: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var resources: [Resource]

    var body: some View {
        let widgetSize = getWidgetSize(for: widgetFamily)
        
        VStack {
            Text(resources.map { resource in
                "\(resource.title)."
            }.joined(separator: " "))
                .font(.system(size: 14, weight: .regular))
                .minimumScaleFactor(0.8)
                .foregroundStyle(.white)
                .padding(16)
                .frame(maxWidth: widgetSize.width, alignment: .leading)

            Spacer()
        }
    }
}

struct PlaceholderHighlightsSmall: View {
    var highlight: Moment
    var photoImage: UIImage?

    init(highlights: [Moment]) {
        self.highlight = highlights[0]

        if highlight.photo != nil {
            let photoUrl = FileManager.documentsDirectory.appendingPathComponent("\(String(describing: highlight.photo!))-systemSmall.jpg")
            self.photoImage = UIImage(contentsOfFile: photoUrl.path)
        }
    }

    var body: some View {
        let widgetSize = getWidgetSize(for: .systemSmall)
        
        RoundedRectangle(cornerRadius: 0, style: .continuous)
            .fill(photoImage == nil ? HappyGradients(rawValue: highlight.background)!.radial(startRadius: -50, endRadius: widgetSize.width) : RadialGradient(gradient: Gradient(colors: [.clear, .clear]), center: .center, startRadius: 0, endRadius: 0))
            .frame(height: widgetSize.height)
            .background {
                if photoImage != nil {
                    Image(uiImage: photoImage!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: widgetSize.height, alignment: .center)
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 3) {
                            Spacer()
                            Text(highlight.startAt.formatted(.dateTime.day().month().year())).foregroundStyle(.white)
                                .font(.caption)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .padding(0)

                            Text(highlight.title)
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .padding(0)
                        }

                        Spacer()
                    }
                }.padding(16)
            }
    }
}

struct PlaceholderSmall: View {
    @Environment(\.appDatabase) var appDatabase
    @Environment(\.widgetFamily) var widgetFamily

    var entry: MomentsWidgtEntry
    var resources: [Resource] = []
    var highlights: [Moment] = []

    init(entry: MomentsWidgtEntry) {
        self.entry = entry

        do {
            try appDatabase.reader.read { db in
                if entry.configuration.placeholder == .all || entry.configuration.placeholder == .resources {
                    self.resources = try Resource
                        .all()
                        .randomRows()
                        .limit(3)
                        .fetchAll(db)
                }

                if entry.configuration.placeholder == .all || entry.configuration.placeholder == .highlights {
                    self.highlights = try Moment
                        .all()
                        .filterByPeriod("<")
                        .filterByHighlight()
                        .order(sql: "RANDOM()")
                        .limit(1)
                        .fetchAll(db)
                }
            }
        } catch {
            // TODO: log something useful
            print("error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        let widgetSize = getWidgetSize(for: widgetFamily)
        
        if (entry.configuration.placeholder == .all && resources.count == 0 && highlights.count == 0) ||
            (entry.configuration.placeholder == .resources && resources.count == 0) ||
            (entry.configuration.placeholder == .highlights && highlights.count == 0)
        {
            Text("Start adding your first moments")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(24)
                .frame(maxWidth: widgetSize.width)
                .frame(maxHeight: widgetSize.height)
        }

        // TODO: this looks ugly, there must be a way to achieve this ... smarter?
        if entry.configuration.placeholder == .all {
            if resources.count > 0 && highlights.count > 0 {
                if Bool.random() == true {
                    PlaceholderResourcesSmall(resources: resources)
                } else {
                    PlaceholderHighlightsSmall(highlights: highlights)
                }
            } else if resources.count > 0 && highlights.count == 0 {
                PlaceholderResourcesSmall(resources: resources)
            } else if resources.count == 0 && highlights.count > 0 {
                PlaceholderHighlightsSmall(highlights: highlights)
            }
        } else if entry.configuration.placeholder == .resources && resources.count > 0 {
            PlaceholderResourcesSmall(resources: resources)
        } else if entry.configuration.placeholder == .highlights && highlights.count > 0 {
            PlaceholderHighlightsSmall(highlights: highlights)
        }
    }
}

struct MomentSmall: View {
    @Environment(\.appDatabase) var appDatabase

    var entry: MomentsWidgtEntry
    var moments: [Moment] = []

    init(entry: MomentsWidgtEntry) {
        self.entry = entry

        do {
            try appDatabase.reader.read { _ in
//                self.moments = try Moment
//                    .all()
//                    .filterByPeriod(">=")
//                    .filterByPeriod("<=", period: entry.configuration.limit)
//                    .order(Moment.Columns.startAt.asc)
//                    .limit(4)
//                    .fetchAll(db)
            }
        } catch {
            // TODO: log something useful
            print("error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        if moments.count == 0 {
            PlaceholderSmall(entry: entry)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if moments.count == 4 {
                        Spacer()
                    }

                    ForEach(moments) { moment in
                        MomentDetail(moment: moment)
                    }

                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
        }
    }
}

struct MomentsWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MomentsWidgtEntry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            MomentSmall(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        default:
            Text("Not available")
        }
    }
}

struct MomentsWidget: Widget {
    let kind: String = "app.stayhappy.StayHappy.MomentsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MomentsWidgetConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            MomentsWidgetEntryView(entry: entry)
                .unredacted()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Give SwiftUI access to the database

//
// Define a new environment key that grants access to an AppDatabase.
//
// The technique is documented at
// https://developer.apple.com/documentation/swiftui/environmentkey

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? .random() : .shared }
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
