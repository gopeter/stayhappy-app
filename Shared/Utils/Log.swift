//
//  Log.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 06.02.24.
//

import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static let subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like a view that appeared.
    static let debug = Logger(subsystem: subsystem, category: "debug")

    /// Image focal-point detection. Worth its own category so it can be
    /// filtered in Console.app when checking crops on a real device.
    static let saliency = Logger(subsystem: subsystem, category: "saliency")
}
