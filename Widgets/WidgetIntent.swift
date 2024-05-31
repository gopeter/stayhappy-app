//
//  WidgetIntent.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import AppIntents
import WidgetKit

enum WidgetPeriodType: String, AppEnum {
    case month
    case quarter
    case year
    case all
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Period"
    static var caseDisplayRepresentations: [WidgetPeriodType: DisplayRepresentation] = [
        .month: "Month",
        .quarter: "Quarter",
        .year: "Year",
        .all: "All"
    ]
}

enum WidgetMotivationType: String, AppEnum {
    case resources
    case highlights
    case all
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Placeholder"
    static var caseDisplayRepresentations: [WidgetMotivationType: DisplayRepresentation] = [
        .resources: "Resources",
        .highlights: "Highlights",
        .all: "Resources & Highlights"
    ]
}

struct MomentsWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Moments Widget Configuration"

    @Parameter(title: "Period", default: .all)
    var period: WidgetPeriodType

    @Parameter(title: "Placeholder", default: .all)
    var placeholder: WidgetMotivationType
}


struct MotivationWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Motivation Widget Configuration"

    @Parameter(title: "Content", default: .highlights)
    var content: WidgetMotivationType
}
