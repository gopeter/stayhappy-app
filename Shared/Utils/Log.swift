//
//  Log.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 06.02.24.
//

import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like a view that appeared.
    static let debug = Logger(subsystem: subsystem, category: "debug")
}
