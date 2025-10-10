//
//  MotivationMedium.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI

struct MotivationMedium: View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: MotivationWidgtEntry

    private var placeholder: WidgetMotivationType {
        entry.configuration.content
    }

    private var resources: [Resource] {
        entry.resources
    }

    private var highlights: [Moment] {
        entry.highlights
    }

    var body: some View {
        if (placeholder == .all && resources.count == 0 && highlights.count == 0) || (placeholder == .resources && resources.count == 0)
            || (placeholder == .highlights && highlights.count == 0)
        {
            Text(NSLocalizedString("start_adding_moments", comment: ""))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(24)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }

        // TODO: this looks ugly, there must be a way to achieve this ... smarter?
        if placeholder == .all {
            if resources.count > 0 && highlights.count > 0 {
                HStack(spacing: 0) {
                    HighlightsTile(highlights: highlights, size: .systemSmall)
                    ResourcesTile(resources: resources)
                }
            }
            else if resources.count > 0 && highlights.count == 0 {
                ResourcesTile(resources: resources)
            }
            else if resources.count == 0 && highlights.count > 0 {
                HighlightsTile(highlights: highlights, size: .systemMedium)
            }
        }
        else if placeholder == .resources && resources.count > 0 {
            ResourcesTile(resources: resources)
        }
        else if placeholder == .highlights && highlights.count > 0 {
            HighlightsTile(highlights: highlights, size: .systemMedium)
        }
    }
}
