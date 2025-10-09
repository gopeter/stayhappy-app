//
//  MomentsMedium.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentsMedium: View {
    var entry: MomentsWidgtEntry

    var body: some View {
        if entry.moments.count == 0 {
            MotivationMedium(
                entry: MotivationWidgtEntry(
                    date: entry.date,
                    configuration: {
                        let config = MotivationWidgetConfigurationIntent()
                        config.content = entry.configuration.placeholder
                        return config
                    }(),
                    resources: entry.placeholderResources,
                    highlights: entry.placeholderHighlights
                )
            )
        }
        else {
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: entry.moments.count > 4 ? 8 : 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(entry.moments.prefix(4)) { moment in
                            MomentTile(moment: moment)
                        }

                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    .padding(.trailing, entry.moments.count > 4 ? 0 : 8)

                    if entry.moments.count > 4 {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(entry.moments.dropFirst(4).prefix(4)) { moment in
                                MomentTile(moment: moment)
                            }

                            Spacer()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.leading, 8)
                        .padding(.trailing, 16)
                    }
                    else {
                        MotivationSmall(
                            entry: MotivationWidgtEntry(
                                date: entry.date,
                                configuration: {
                                    let config = MotivationWidgetConfigurationIntent()
                                    config.content = entry.configuration.placeholder
                                    return config
                                }(),
                                resources: entry.placeholderResources,
                                highlights: entry.placeholderHighlights
                            )
                        )
                    }
                }
                .frame(maxHeight: geometry.size.height)
            }
        }
    }
}
