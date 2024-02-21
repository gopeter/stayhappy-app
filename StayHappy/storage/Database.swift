//
//  Database.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 06.02.24.
//
// See: https://github.com/groue/GRDB.swift/blob/master/Documentation/DemoApps/GRDBAsyncDemo/GRDBAsyncDemo/AppDatabase.swift

import Foundation
import GRDB
import os.log

struct AppDatabase {
    /// Provides access to the database
    internal var db: DatabaseQueue
    
    /// Creates an `Database`, and make sure the database schema is ready
    init() {
        let fileManager = FileManager()
        
        do {
            // Locate Application Support directory
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            
            // Create database folder
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to the database
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            self.db = try DatabaseQueue(path: dbURL.path)
            try migrator.migrate(db)
            
        } catch {
            /* As a fallback, create/connect to the database in memory */
            self.db = try! DatabaseQueue()
            try? migrator.migrate(db)
        }
    }
}



extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("createEvent") { db in
            try db.create(table: "event") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("isHighlight", .boolean).defaults(to: false)
                t.column("startAt", .date).notNull()
                t.column("endAt", .date).notNull()
                t.column("createdAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
                t.column("updatedAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }
        }
        
        migrator.registerMigration("createMoment") { db in
            try db.create(table: "moment") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("createdAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
                t.column("updatedAt", .date).defaults(sql: "CURRENT_TIMESTAMP")
            }
        }
        
        migrator.registerMigration("addPhotoColumnToEvent") { db in
            try db.alter(table: "event") { t in
                t.add(column: "photo", .text)
            }
        }
        
        return migrator
    }
}

extension AppDatabase {
    enum ValidationError: LocalizedError {
        case missingName
        
        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Please provide a name"
            }
        }
    }
}
