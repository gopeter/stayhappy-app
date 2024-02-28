//
//  FileManager.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 18.02.24.
//  See: https://www.hackingwithswift.com/forums/swiftui/saving-and-displaying-images-using-the-image-picker/19338see
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
