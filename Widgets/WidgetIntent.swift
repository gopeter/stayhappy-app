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

    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_period"))
    static var caseDisplayRepresentations: [WidgetPeriodType: DisplayRepresentation] = [
        .month: DisplayRepresentation(title: LocalizedStringResource("period_month")),
        .quarter: DisplayRepresentation(title: LocalizedStringResource("period_quarter")),
        .year: DisplayRepresentation(title: LocalizedStringResource("period_year")),
        .all: DisplayRepresentation(title: LocalizedStringResource("period_all")),
    ]
}

enum WidgetMotivationType: String, AppEnum {
    case resources
    case highlights
    case all

    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_placeholder"))
    static var caseDisplayRepresentations: [WidgetMotivationType: DisplayRepresentation] = [
        .resources: DisplayRepresentation(title: LocalizedStringResource("motivation_resources")),
        .highlights: DisplayRepresentation(title: LocalizedStringResource("motivation_highlights")),
        .all: DisplayRepresentation(title: LocalizedStringResource("motivation_all")),
    ]
}

struct MomentsWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("moments_widget_configuration")

    @Parameter(title: LocalizedStringResource("widget_period"), default: .all)
    var period: WidgetPeriodType

    @Parameter(title: LocalizedStringResource("widget_placeholder"), default: .all)
    var placeholder: WidgetMotivationType
}

struct MotivationWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("motivation_widget_configuration")

    @Parameter(title: LocalizedStringResource("widget_content"), default: .highlights)
    var content: WidgetMotivationType
}
