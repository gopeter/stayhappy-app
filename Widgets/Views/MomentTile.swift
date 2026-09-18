//
//  MomentTile.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentTile: View {
    /// The widget's background, which decides whether a white label still has
    /// enough contrast — on the pale gradients it does not.
    @Environment(\.happyGradient) private var gradient

    var moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetDate(date: moment.startAt, size: .small)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(gradient.textColor)
                .opacity(0.5)

            Text(moment.title)
                .font(.system(size: 14, weight: .regular))
                .minimumScaleFactor(0.92)
                .lineLimit(1)
                .foregroundStyle(gradient.textColor)
        }
    }
}
