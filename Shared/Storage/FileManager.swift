//
//  FileManager.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 18.02.24.
//  See: https://www.hackingwithswift.com/forums/swiftui/saving-and-displaying-images-using-the-image-picker/19338
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let appIdentifier = "group.app.stayhappy.StayHappy"
        let sharedFileManager = FileManager.default
        let sharedContainerFolderURL = sharedFileManager.containerURL(forSecurityApplicationGroupIdentifier: appIdentifier)
        
        return sharedContainerFolderURL!
    }
}
