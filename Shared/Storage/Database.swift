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

enum DatabaseMode: String, CaseIterable {
    case read
    case write
}

struct AppDatabase {
    /// Provides access to the database
    var db: DatabasePool?
    
    /// Creates an `Database`, and make sure the database schema is ready
    init(mode: DatabaseMode) {
        let fileManager = FileManager()
        
        do {
            // Locate Application Support directory
            let folderURL = FileManager.documentsDirectory.appendingPathComponent("database", isDirectory: true)
            
            // Create database folder
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to the database
            let databaseURL = folderURL.appendingPathComponent("db.sqlite")
        
            if mode == .read {
                if let readOnlyDb = try openReadOnlyDatabase(at: databaseURL) {
                    self.db = readOnlyDb
                }
            } else {
                self.db = try self.openSharedDatabase(at: databaseURL)
            }
        } catch {
            Logger.debug.error("Error: \(error.localizedDescription)")
        }
    }
    
    func openSharedDatabase(at databaseURL: URL) throws -> DatabasePool {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinatorError: NSError?
        var dbPool: DatabasePool?
        var dbError: Error?
        
        coordinator.coordinate(writingItemAt: databaseURL, options: .forMerging, error: &coordinatorError) { url in
            do {
                dbPool = try self.openDatabase(at: url)
            } catch {
                dbError = error
            }
        }
        
        if let error = dbError ?? coordinatorError {
            throw error
        }
        
        return dbPool!
    }
    
    private func openDatabase(at databaseURL: URL) throws -> DatabasePool {
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            // Activate the persistent WAL mode so that
            // read-only processes can access the database.
            //
            // See https://www.sqlite.org/walformat.html#operations_that_require_locks_and_which_locks_those_operations_use
            // and https://www.sqlite.org/c3ref/c_fcntl_begin_atomic_write.html#sqlitefcntlpersistwal
            if db.configuration.readonly == false {
                var flag: CInt = 1
                let code = withUnsafeMutablePointer(to: &flag) { flagP in
                    sqlite3_file_control(db.sqliteConnection, nil, SQLITE_FCNTL_PERSIST_WAL, flagP)
                }
                
                guard code == SQLITE_OK else {
                    throw DatabaseError(resultCode: ResultCode(rawValue: code))
                }
            }
        }
        
        let dbPool = try DatabasePool(path: databaseURL.path, configuration: configuration)
        
        // Perform here other database setups, such as defining
        // the database schema with a DatabaseMigrator, and
        // checking if the application can open the file:
        try migrator.migrate(dbPool)
        
        if try dbPool.read(migrator.hasBeenSuperseded) {
            // Database is too recent
            // throw /* some error */
            // TODO: return something useful to the user
            Logger.debug.error("Error: Migrator has been superseded")
        }
        
        return dbPool
    }
    
    private func openSharedReadOnlyDatabase(at databaseURL: URL) throws -> DatabasePool? {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinatorError: NSError?
        var dbPool: DatabasePool?
        var dbError: Error?
        
        coordinator.coordinate(readingItemAt: databaseURL, options: .withoutChanges, error: &coordinatorError) { url in
            do {
                dbPool = try self.openReadOnlyDatabase(at: url)
            } catch {
                dbError = error
            }
        }
        
        if let error = dbError ?? coordinatorError {
            throw error
        }
        
        return dbPool
    }

    private func openReadOnlyDatabase(at databaseURL: URL) throws -> DatabasePool? {
        do {
            var configuration = Configuration()
            configuration.readonly = true
            let dbPool = try DatabasePool(path: databaseURL.path, configuration: configuration)
            
            // Check here if the database schema is the expected one,
            // for example with a DatabaseMigrator:
            return try dbPool.read { db in
                if try migrator.hasBeenSuperseded(db) {
                    // Database is too recent
                    return nil
                } else if try migrator.hasCompletedMigrations(db) == false {
                    // Database is too old
                    return nil
                }
                
                return dbPool
            }
        } catch {
            if FileManager.default.fileExists(atPath: databaseURL.path) {
                throw error
            } else {
                return nil
            }
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
        
        migrator.registerMigration("addBackgroundColumnToEvent") { db in
            try db.alter(table: "event") { t in
                t.add(column: "background", .text)
            }
        }
        
        migrator.registerMigration("renameTables") { db in
            try db.rename(table: "moment", to: "resource")
            try db.rename(table: "event", to: "moment")
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
