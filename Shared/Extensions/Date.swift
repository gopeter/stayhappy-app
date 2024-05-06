//
//  Date.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 03.05.24.
//

import Foundation

extension Date {
    func withAddedMinutes(minutes: Double) -> Date {
        addingTimeInterval(minutes * 60)
    }
    
    func withSubtractedMinutes(minutes: Double) -> Date {
        addingTimeInterval(minutes * 60 * -1)
    }

    func withAddedHours(hours: Double) -> Date {
        withAddedMinutes(minutes: hours * 60)
    }
    
    func withSubtractedHours(hours: Double) -> Date {
        withSubtractedMinutes(minutes: hours * 60)
    }
    
    func withAddedDays(days: Double) -> Date {
        withAddedHours(hours: days * 24)
    }
    
    func withSubtractedDays(days: Double) -> Date {
        withSubtractedHours(hours: days * 24)
    }
}
