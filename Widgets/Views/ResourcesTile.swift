//
//  ResourcesTile.swift
//  Widgets
//
//  Created by Peter Oesteritz on 23.05.24.
//

import SwiftUI

struct ResourcesTile: View {
    @Environment(\.widgetFamily) var widgetFamily

    var resources: [Resource]

    var body: some View {
        let widgetSize = getWidgetSize(for: widgetFamily)

        VStack {
            Text(resources.map { resource in
                "\(resource.title)."
            }.joined(separator: " "))
                .minimumScaleFactor(0.8)
                .foregroundStyle(.white)
                .padding(.all)
                .frame(maxWidth: widgetSize.width, alignment: .leading)

            Spacer()
        }
    }
}
