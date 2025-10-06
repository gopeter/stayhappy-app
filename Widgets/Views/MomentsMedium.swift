//
//  MomentsMedium.swift
//  WidgetsExtension
//
//  Created by Peter Oesteritz on 06.10.25.
//

import SwiftUI

struct MomentsMedium: View {
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
            MotivationMedium(placeholder: entry.configuration.placeholder)
        }
        else {
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: moments.count > 4 ? 8 : 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(moments.prefix(4)) { moment in
                            MomentTile(moment: moment)
                        }
                        
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    .padding(.trailing, moments.count > 4 ? 0 : 8)
                    
                    if moments.count > 4 {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(moments.dropFirst(4).prefix(4)) { moment in
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
                        MotivationSmall(placeholder: entry.configuration.placeholder)
                    }
                }
                .frame(maxHeight: geometry.size.height)
            }
        }
    }
}
