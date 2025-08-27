//
//  Localization.swift
//  StayHappy
//
//  Created by Assistant on 10.01.24.
//

import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    /// Returns a localized string for the current key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - LocalizedStringKey Extension
extension LocalizedStringKey {
    /// Create a LocalizedStringKey from a string key
    init(_ key: String) {
        self.init(stringLiteral: key)
    }
}

// MARK: - Localization Helper
struct L {
    // MARK: - Navigation and Tabs
    static let moments = "moments"
    static let resources = "resources"
    static let highlights = "highlights"
    static let help = "help"

    // MARK: - General Actions
    static let add = "add"
    static let save = "save"
    static let delete = "delete"
    static let cancel = "cancel"

    // MARK: - Moments
    static let noMomentsFound = "no_moments_found"
    static let noMomentsCreated = "no_moments_created"
    static let updateMoment = "update_moment"
    static let upcomingMoments = "upcoming_moments"
    static let pastMoments = "past_moments"

    // MARK: - Resources
    static let noResourcesFound = "no_resources_found"
    static let noResourcesCreated = "no_resources_created"
    static let updateResource = "update_resource"

    // MARK: - Highlights
    static let noHighlightsCreated = "no_highlights_created"

    // MARK: - Form Elements
    static let selectEntryType = "select_entry_type"
    static let moment = "moment"
    static let resource = "resource"
    static let chooseRandomColor = "choose_random_color"
    static let background = "background"
    static let selectPhoto = "select_photo"
    static let removePhoto = "remove_photo"

    // MARK: - Sorting and Filtering
    static let period = "period"
    static let ordering = "ordering"
    static let ascending = "ascending"
    static let descending = "descending"

    // MARK: - Date References
    static let today = "today"
    static let tomorrow = "tomorrow"
    static let inDays = "in_days"

    // MARK: - Help Section
    static let thanks = "thanks"
    static let buyMeCoffee = "buy_me_coffee"

    // MARK: - Search
    static let search = "search"

    // MARK: - Widget
    static let notAvailable = "not_available"
    static let startAddingMoments = "start_adding_moments"
}

// MARK: - Text Extension for SwiftUI
extension Text {
    /// Initialize Text with a localized string key
    init(_ key: String) {
        self.init(LocalizedStringKey(key))
    }
}
