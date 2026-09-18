//
//  ResourcesView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 30.01.24.
//

import GRDBQuery
import SwiftUI

struct ResourcesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(ResourceListRequest()) private var resources: [Resource]
    @State private var isCreatePresented = false

    var body: some View {
        NavigationStack {
            List {
                if resources.count > 0 {
                    ForEach(resources) { resource in
                        HStack {
                            Text(resource.title)
                                .background(NavigationLink(resource.title, value: resource).opacity(0))
                            Spacer()
                            Image("chevron-right-symbol").foregroundStyle(Color(uiColor: .systemFill))
                        }.listRowBackground(Color("CardBackgroundColor")).listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 12))
                    }

                }
                else {
                    VStack {
                        Spacer(minLength: 60)
                        HStack {
                            Spacer()
                            Text("no_resources_created").foregroundStyle(.gray)
                            Spacer()
                        }
                    }.listRowBackground(Color("AppBackgroundColor"))
                }
            }
            // Navigation
            .navigationTitle("resources")
            .navigationDestination(for: Resource.self) { resource in
                FormView(resource: resource)
            }
            // Style
            .scrollContentBackground(.hidden)
            .background(Color("AppBackgroundColor").ignoresSafeArea(.all))
            // Actions
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatePresented = true
                    } label: {
                        Label("add", image: "plus-symbol")
                    }
                }
            }
            .sheet(isPresented: $isCreatePresented) {
                NavigationStack {
                    FormView(for: .resource)
                }
            }
        }
    }
}

#Preview {
    ResourcesView()
}
