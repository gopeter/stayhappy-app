//
//  MomentsSmall.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentsSmall: View {
    @Environment(\.appDatabase) var appDatabase

    var entry: MomentsWidgtEntry
    var moments: [Moment] = []

    init(entry: MomentsWidgtEntry) {
        self.entry = entry

        do {
            try appDatabase.reader.read { db in
                self.moments =
                    try Moment
                    .all()
                    .filterByPeriod(">=")
                    .filterByPeriod("<=", period: entry.configuration.period)
                    .order(Moment.Columns.startAt.asc)
                    .limit(4)
                    .fetchAll(db)
            }
        }
        catch {
            // TODO: log something useful
            print("error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        if moments.count == 0 {
            MotivationSmall(placeholder: entry.configuration.placeholder)
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
