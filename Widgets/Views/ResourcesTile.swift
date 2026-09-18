//
//  ResourcesTile.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI
import WidgetKit

struct ResourcesTile: View {
    @Environment(\.widgetFamily) var widgetFamily
    /// See `MomentTile`: the label follows the widget's background.
    @Environment(\.happyGradient) private var gradient

    var resources: [Resource]

    var body: some View {
        VStack {
            Text(
                resources.map { resource in
                    "\(resource.title)."
                }.joined(separator: " ")
            )
            .minimumScaleFactor(0.8)
            .foregroundStyle(gradient.textColor)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
    }
}
