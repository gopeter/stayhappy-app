//
//  TitleCased.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 27.02.24.
//

import Foundation

extension String {
    func titleCased() -> String {
        return self.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: self.range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
