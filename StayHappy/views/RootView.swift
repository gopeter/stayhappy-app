//
//  ContentView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @EnvironmentObject var globalData: GlobalData

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                switch globalData.activeView {
                case .events:
                    EventsView()
                case .moments:
                    MomentsView()
                case .search:
                    SearchView()
                case .profile:
                    ProfileView()
                }
            }

            NavigationBarView()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Event.self, configurations: config)

        let calendar = Calendar.current
        let today = Date()
        
        container.mainContext.insert(Event(title: "Essen mit Christoph", startAt: calendar.date(byAdding: .day, value: 10, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Zocken mit Chris und Philipp", isHighlight: true, startAt: calendar.date(byAdding: .day, value: 9, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Jan und Andreas da", startAt: calendar.date(byAdding: .day, value: 8, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Therapie", startAt: calendar.date(byAdding: .day, value: 7, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Skiurlaub", startAt: calendar.date(byAdding: .day, value: 6, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Connie Frühschoppen", startAt: calendar.date(byAdding: .day, value: 5, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Arctic Monkeys Konzert", isHighlight: true, startAt: calendar.date(byAdding: .day, value: 4, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "StayHappy Livegang", startAt: calendar.date(byAdding: .day, value: 3, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Zocken mit Chris und Philipp", startAt: calendar.date(byAdding: .day, value: 2, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Entenbraten", startAt: calendar.date(byAdding: .day, value: 1, to: Date())!, endAt: Date()))
        
        container.mainContext.insert(Event(title: "TV Total", startAt: today, endAt: Date()))
        
        container.mainContext.insert(Event(title: "Killers of the Flower Moon", startAt: calendar.date(byAdding: .day, value: -1, to: Date())!, endAt: Date()))
        
        
        container.mainContext.insert(Event(title: "BBQ", startAt: calendar.date(byAdding: .day, value: -2, to: Date())!, endAt: Date()))
        
        return RootView().modelContainer(container).environmentObject(GlobalData(activeView: .events))

    } catch {
        fatalError("Failed to create model container.")
    }
}
