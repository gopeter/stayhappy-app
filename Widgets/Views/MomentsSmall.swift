//
//  MomentsSmall.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentsSmall: View {
    var entry: MomentsWidgtEntry

    private var moments: [Moment] {
        Array(entry.moments.prefix(4))
    }

    var body: some View {
        if moments.count == 0 {
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
        else {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if moments.count == 4 {
                        Spacer()
                    }

                    ForEach(moments) { moment in
                        MomentTile(moment: moment)
                    }

                    Spacer()
                }

                Spacer()
            }
            .padding(.all)
        }
    }
}
