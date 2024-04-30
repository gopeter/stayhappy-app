//
//  AppIntent.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import WidgetKit
import AppIntents

enum MomentsWidgetLimitType: String, AppEnum {
    case month
    case quarter
    case year
    case all
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Limit Type"
    static var caseDisplayRepresentations: [MomentsWidgetLimitType: DisplayRepresentation] = [
        .month: "Month",
        .quarter: "Quarter",
        .year: "Year",
        .all: "All"
    ]
}

enum MomentsWidgetPlaceholderType: String, AppEnum {
    case resources
    case highlights
    case all
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Placeholder Type"
    static var caseDisplayRepresentations: [MomentsWidgetPlaceholderType: DisplayRepresentation] = [
        .resources: "Resources",
        .highlights: "Highlights",
        .all: "Resources & Highlights"
    ]
}

struct MomentsWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Configure the widget")

    @Parameter(title: "Limit", default: .month)
    var limit: MomentsWidgetLimitType

    @Parameter(title: "Placeholder", default: .resources)
    var placeholder: MomentsWidgetPlaceholderType
}
