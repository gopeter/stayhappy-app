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


struct MomentsSmall: View {
    @Environment(\.appDatabase) var appDatabase

    var entry: MomentsWidgtEntry
    var moments: [Moment] = []

    init(entry: MomentsWidgtEntry) {
        self.entry = entry

        do {
            try appDatabase.reader.read { db in
                self.moments = try Moment
                    .all()
                    .filterByPeriod(">=")
                    .filterByPeriod("<=", period: entry.configuration.period)
                    .order(Moment.Columns.startAt.asc)
                    .limit(4)
                    .fetchAll(db)
            }
        } catch {
            // TODO: log something useful
            print("error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        if moments.count == 0 {
            MotivationSmall(placeholder: entry.configuration.placeholder)
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
            .padding(.all)
        }
    }
}

struct MomentsMedium: View {
    @Environment(\.appDatabase) var appDatabase

    var entry: MomentsWidgtEntry
    var moments: [Moment] = []

    init(entry: MomentsWidgtEntry) {
        self.entry = entry

        do {
            try appDatabase.reader.read { db in
                self.moments = try Moment
                    .all()
                    .filterByPeriod(">=")
                    .filterByPeriod("<=", period: entry.configuration.period)
                    .order(Moment.Columns.startAt.asc)
                    .limit(8)
                    .fetchAll(db)
            }
        } catch {
            // TODO: log something useful
            print("error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        if moments.count == 0 {
            MotivationMedium(placeholder: entry.configuration.placeholder)
        } else {
            HStack(alignment: .center, spacing: moments.count > 4 ? 8 : 0) {
                VStack(spacing: 10) {
                    ForEach(moments.prefix(4)) { moment in
                        MomentDetail(moment: moment)
                    }

                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: moments.count > 4 ? 0 : 16))

                if (moments.count > 4) {
                    VStack(spacing: 10) {
                        ForEach(moments.dropFirst(4).prefix(4)) { moment in
                            MomentDetail(moment: moment)
                        }
                        
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 16, leading: moments.count > 4 ? 0 : 16, bottom: 16, trailing: 16))
                } else {
                    MotivationSmall(placeholder: entry.configuration.placeholder)
                }
            }.padding(.top, 16)
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
            MomentsSmall(entry: entry)
                .background(HappyGradients.stayHappy.linear())
        case .systemMedium:
            MomentsMedium(entry: entry)
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
            provider: MomentsWidgetProvider()
        ) { entry in
            MomentsWidgetEntryView(entry: entry)
                .unredacted()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Moments Widget")
        .description("Decide whether you want to see all moments or only for a certain period of time. If there are no moments in view, select a placeholder.")
    }
}

#Preview(as: .systemMedium) {
    MomentsWidget()
} timeline: {
    MomentsWidgtEntry(date: .now, configuration: MomentsWidgetConfigurationIntent())
}
