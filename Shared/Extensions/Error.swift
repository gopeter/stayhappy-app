//
//  Error.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 24.03.24.
//

import Foundation

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
