//
//  Event.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Foundation
import SwiftData

@Model
final class Event: Identifiable {
    var id: UUID
    var title: String
    var isHighlight: Bool
    var startAt: Date
    var endAt: Date
    var createdAt: Date
    var updatedAt: Date

    init(title: String, isHighlight: Bool = false, startAt: Date, endAt: Date) {
        self.id = UUID()
        self.title = title
        self.isHighlight = isHighlight
        self.startAt = startAt
        self.endAt = endAt
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
