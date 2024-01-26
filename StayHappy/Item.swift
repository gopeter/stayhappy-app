//
//  Item.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
