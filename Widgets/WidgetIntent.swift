//
//  WidgetIntent.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import AppIntents
import UIKit
import WidgetKit

/// A gradient as something the widget configuration can offer for selection.
///
/// An entity rather than a plain `String` parameter: the configuration row
/// shows whatever the value renders as, and a string renders as itself — the
/// untouched default read "stayHappy" instead of "Stay Happy". The entity also
/// carries the colour dot and makes the list searchable.
struct GradientEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("widget_background")
    )

    static let defaultQuery = GradientQuery()

    /// The gradient's `rawValue`, which is what a widget's configuration
    /// stores — the same string a moment persists as its background.
    var id: String

    private var gradient: HappyGradients {
        HappyGradients.named(id)
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: gradient.displayName),
            // The system draws this list, so a gradient can't be rendered —
            // a dot tinted with the gradient's middle colour is as close as
            // the configuration UI allows.
            image: .init(systemName: "circle.fill", tintColor: gradient.swatchColor)
        )
    }
}

struct GradientQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [GradientEntity] {
        identifiers.map { GradientEntity(id: $0) }
    }

    /// Returns the same collection type as `suggestedEntities()`, which is
    /// what the query's result type is inferred from.
    func entities(matching string: String) async throws -> ItemCollection<GradientEntity> {
        let matches = HappyGradients.allCases
            .filter { $0.displayName.localizedCaseInsensitiveContains(string) }
            .sorted { $0.displayName < $1.displayName }

        return ItemCollection(items: matches.map { GradientEntity(id: $0.rawValue) })
    }

    /// Grouped by colour family: 117 gradients in one flat list are impossible
    /// to scan, and the names give no hint of the colour.
    func suggestedEntities() async throws -> ItemCollection<GradientEntity> {
        let sections = HappyGradients.Family.allCases.compactMap { family -> ItemSection<GradientEntity>? in
            let gradients = HappyGradients.allCases
                .filter { $0.family == family }
                .sorted { $0.displayName < $1.displayName }

            guard !gradients.isEmpty else { return nil }

            return ItemSection(
                LocalizedStringResource(stringLiteral: family.localizationKey),
                items: gradients.map { GradientEntity(id: $0.rawValue) }
            )
        }

        return ItemCollection(sections: sections)
    }

    func defaultResult() async -> GradientEntity? {
        GradientEntity(id: HappyGradients.stayHappy.rawValue)
    }
}

enum WidgetPeriodType: String, AppEnum {
    case month
    case quarter
    case year
    case all

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_period"))
    static let caseDisplayRepresentations: [WidgetPeriodType: DisplayRepresentation] = [
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

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_placeholder"))
    static let caseDisplayRepresentations: [WidgetMotivationType: DisplayRepresentation] = [
        .resources: DisplayRepresentation(title: LocalizedStringResource("motivation_resources")),
        .highlights: DisplayRepresentation(title: LocalizedStringResource("motivation_highlights")),
        .all: DisplayRepresentation(title: LocalizedStringResource("motivation_all")),
    ]
}

struct MomentsWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title = LocalizedStringResource("moments_widget_configuration")

    @Parameter(title: LocalizedStringResource("widget_period"), default: .all)
    var period: WidgetPeriodType

    @Parameter(title: LocalizedStringResource("widget_placeholder"), default: .all)
    var placeholder: WidgetMotivationType

    @Parameter(
        title: LocalizedStringResource("widget_background"),
        default: GradientEntity(id: HappyGradients.stayHappy.rawValue)
    )
    var background: GradientEntity
}

struct MotivationWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title = LocalizedStringResource("motivation_widget_configuration")

    @Parameter(title: LocalizedStringResource("widget_content"), default: .all)
    var content: WidgetMotivationType

    @Parameter(
        title: LocalizedStringResource("widget_background"),
        default: GradientEntity(id: HappyGradients.stayHappy.rawValue)
    )
    var background: GradientEntity
}
