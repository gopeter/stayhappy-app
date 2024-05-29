//
//  MotivationMedium.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI

struct MotivationMedium: View {
    @Environment(\.appDatabase) var appDatabase
    @Environment(\.widgetFamily) var widgetFamily

    var placeholder: WidgetMotivationType
    var resources: [Resource] = []
    var highlights: [Moment] = []

    init(placeholder: WidgetMotivationType) {
        self.placeholder = placeholder

        do {
            try appDatabase.reader.read { db in
                if placeholder == .all || placeholder == .highlights {
                    self.highlights = try Moment
                        .all()
                        .filterByPeriod("<")
                        .filterByHighlight()
                        .order(sql: "RANDOM()")
                        .limit(1)
                        .fetchAll(db)
                }
                
                let limit = placeholder == .all && self.highlights.count > 0 ? 3 : 6
                
                if placeholder == .all || placeholder == .resources {
                    self.resources = try Resource
                        .all()
                        .randomRows()
                        .limit(limit)
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

        if (placeholder == .all && resources.count == 0 && highlights.count == 0) ||
            (placeholder == .resources && resources.count == 0) ||
            (placeholder == .highlights && highlights.count == 0)
        {
            Text("Start adding your first moments")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(24)
                .frame(maxWidth: widgetSize.width)
                .frame(maxHeight: widgetSize.height)
        }

        // TODO: this looks ugly, there must be a way to achieve this ... smarter?
        if placeholder == .all {
            if resources.count > 0 && highlights.count > 0 {
                HStack {
                    HighlightsTile(highlights: highlights, size: .systemSmall)
                    ResourcesTile(resources: resources)
                }
            } else if resources.count > 0 && highlights.count == 0 {
                ResourcesTile(resources: resources)
            } else if resources.count == 0 && highlights.count > 0 {
                HighlightsTile(highlights: highlights, size: .systemMedium)
            }
        } else if placeholder == .resources && resources.count > 0 {
            ResourcesTile(resources: resources)
        } else if placeholder == .highlights && highlights.count > 0 {
            HighlightsTile(highlights: highlights, size: .systemMedium)
        }
    }
}
