//
//  Event.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Foundation
import SwiftData

@Model
final class Event {
    var title: String
    var createdAt: Date
    var updatedAt: Date

    init(title: String, createdAt: Date, updatedAt: Date) {
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
