//
//  MomentTile.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentTile: View {
    var moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetDate(date: moment.startAt, size: .small)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.white)
                .opacity(0.5)

            Text(moment.title)
                .font(.system(size: 13, weight: .regular))
                .minimumScaleFactor(0.92)
                .lineLimit(1)
                .foregroundStyle(.white)
        }
    }
}
