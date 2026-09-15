//
//  Database.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 06.02.24.
//
//  See: https://github.com/groue/GRDB.swift/blob/4b934fda754b1cab34394ea89c2dd5acd170d50e/Documentation/DemoApps/GRDBCombineDemo/GRDBCombineDemo/AppDatabase.swift
//  See: https://github.com/groue/GRDB.swift/blob/4b934fda754b1cab34394ea89c2dd5acd170d50e/Documentation/DemoApps/GRDBCombineDemo/GRDBCombineDemo/Persistence.swift

import Foundation
import GRDB
import os.log

struct AppDatabase: Sendable {
    /// Creates an `AppDatabase`, and makes sure the database schema
    /// is ready.
    ///
    /// - important: Create the `DatabaseWriter` with a configuration
    ///   returned by ``makeConfiguration(_:)``.
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// Provides access to the database.
    ///
    /// Application can use a `DatabasePool`, while SwiftUI previews and tests
    /// can use a fast in-memory `DatabaseQueue`.
    ///
    /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
    let dbWriter: any DatabaseWriter
}

// MARK: - Database Configuration

extension AppDatabase {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
    
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base
        
        // An opportunity to add required custom SQL functions or
        // collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }
        
        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }
        
#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif
        
        return config
    }
}

// MARK: - Database Persistence

extension AppDatabase {
    /// The database for the application
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
            //
            // Create the "Database" directory if needed
            let fileManager = FileManager.default
            let directoryURL = FileManager.documentsDirectory.appendingPathComponent("database", isDirectory: true)
            
            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") {
                try? fileManager.removeItem(at: directoryURL)
            }
            
            // Create the database folder if needed
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(
                path: databaseURL.path,
                // Use default AppDatabase configuration
                configuration: AppDatabase.makeConfiguration())
            
            // Snapshot the database before any migration of this build runs.
            // Must happen before `AppDatabase(_:)`, which migrates.
            backupBeforeGRDB7MigrationIfNeeded(dbPool, in: directoryURL)
            
            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
            
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Marker file recording that the pre-GRDB-7 snapshot has already been taken.
    private static let grdb7BackupMarkerName = ".grdb7-backup-done"
    
    /// Takes a one-time snapshot of the database before the first migration run
    /// of the GRDB 7 build, so an unexpected schema problem can never be a
    /// one-way door.
    ///
    /// Uses SQLite's online backup API through GRDB rather than copying files,
    /// so the snapshot stays consistent even though the database runs in WAL
    /// mode and may have uncheckpointed content in its `-wal` sidecar.
    private static func backupBeforeGRDB7MigrationIfNeeded(
        _ dbPool: DatabasePool,
        in directoryURL: URL
    ) {
        let fileManager = FileManager.default
        let markerURL = directoryURL.appendingPathComponent(grdb7BackupMarkerName)
        
        guard !fileManager.fileExists(atPath: markerURL.path) else { return }
        
        do {
            // A database without a migrations table has never been migrated,
            // so it is a fresh install with nothing worth preserving.
            let isExistingDatabase = try dbPool.read { db in
                try db.tableExists("grdb_migrations")
            }
            
            if isExistingDatabase {
                let backupURL = directoryURL.appendingPathComponent("db.sqlite.bak-pre-grdb7")
                try? fileManager.removeItem(at: backupURL)
                
                let backup = try DatabaseQueue(path: backupURL.path)
                try dbPool.backup(to: backup)
                
                NSLog("Pre-GRDB7 database backup written to \(backupURL.path)")
            }
            
            try Data().write(to: markerURL)
        }
        catch {
            // A failed backup must not stop the app from launching. The
            // migration itself is non-destructive; this is only a safety net.
            NSLog("Pre-GRDB7 database backup failed: \(error)")
        }
    }
    
    /// Creates an empty database for SwiftUI previews
    static func empty() -> AppDatabase {
        // Connect to an in-memory database
        // See https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections
        let dbQueue = try! DatabaseQueue(configuration: AppDatabase.makeConfiguration())
        return try! AppDatabase(dbQueue)
    }
    
    /// Creates a database full of random data for SwiftUI previews
    static func random() -> AppDatabase {
        let appDatabase = empty()
        try! appDatabase.createRandomMomentsIfEmpty()
        try! appDatabase.createRandomPastHighlightsIfEmpty()
        try! appDatabase.createRandomResourcesIfEmpty()
        return appDatabase
    }
}

// MARK: - Database Test Writers

extension AppDatabase {
    func createRandomMomentsIfEmpty() throws {
        try dbWriter.write { db in
            if try Moment.all().isEmpty(db) {
                try createRandomMoments(db)
            }
        }
    }
    
    private func createRandomMoments(_ db: Database) throws {
        for i in 0 ..< 10 {
            _ = try Moment.makeRandom(index: i).inserted(db)
        }
    }
    
    func createRandomResourcesIfEmpty() throws {
        try dbWriter.write { db in
            if try Resource.all().isEmpty(db) {
                try createRandomResources(db)
            }
        }
    }
    
    private func createRandomResources(_ db: Database) throws {
        for i in 0 ..< 30 {
            _ = try Resource.makeRandom(index: i).inserted(db)
        }
    }
    
    func createRandomPastHighlightsIfEmpty() throws {
        try dbWriter.write { db in
            if try Moment.all().filterByHighlight().filterByPeriod("<").isEmpty(db) {
                try createRandomPastHighlights(db)
            }
        }
    }
    
    private func createRandomPastHighlights(_ db: Database) throws {
        for i in 0 ..< 10 {
            _ = try Moment.makeRandomPastHighlight(index: i).inserted(db)
        }
    }
}

// MARK: - Database Migrations

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Erasing the database on schema change is convenient while iterating
        // on migrations, but it destroys data silently. Gate it behind the same
        // `-reset` launch argument that tests already use (see `makeShared()`),
        // so a debug build on a real device can never wipe real data.
        if CommandLine.arguments.contains("-reset") {
            migrator.eraseDatabaseOnSchemaChange = true
        }
        
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

// MARK: - Database Validations

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

// MARK: - Database Access: Reads

// This demo app does not provide any specific reading method, and instead
// gives an unrestricted read-only access to the rest of the application.
// In your app, you are free to choose another path, and define focused
// reading methods.
extension AppDatabase {
    /// Provides a read-only access to the database
    var reader: DatabaseReader {
        dbWriter
    }
}
