//
//  DatabaseMigrationTests.swift
//  StayHappyTests
//
//  Guards the GRDB 6 -> 7 upgrade against data loss.
//
//  The upgrade is only safe as long as three things stay true:
//    1. The set of migration identifiers never changes, so existing databases
//       never re-run a migration.
//    2. Re-opening an already migrated database is a no-op.
//    3. Dates keep being stored in the exact same on-disk string format, so
//       rows written by GRDB 6 remain readable by GRDB 7.
//
//  Point 3 is the subtle one: a change in the default date encoding strategy
//  would not throw, it would silently shift every date in the app. The tests
//  below pin the raw column text instead of just round-tripping through Swift.
//

import Foundation
import GRDB
import Testing

@testable import StayHappy

@Suite("Database migrations")
struct DatabaseMigrationTests {

    /// The complete, ordered set of migrations as of the GRDB 7 upgrade.
    /// Adding a migration here is fine. Renaming or removing one is not: it
    /// would make existing databases re-run schema changes.
    static let expectedMigrations = [
        "createEvent",
        "createMoment",
        "addPhotoColumnToEvent",
        "addBackgroundColumnToEvent",
        "renameTables",
    ]

    /// 2023-11-14 22:13:20 UTC
    static let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
    /// 2020-09-13 12:26:40 UTC
    static let olderDate = Date(timeIntervalSince1970: 1_600_000_000)

    // MARK: - Helpers

    /// An on-disk database in a temporary directory, so it can be reopened
    /// within a test the same way the app reopens its database across launches.
    private func makeTemporaryDatabaseURL() -> URL {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("StayHappyTests-\(UUID().uuidString)", isDirectory: true)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("db.sqlite")
    }

    private func seed(_ appDatabase: AppDatabase) throws {
        var moment = MomentMutation(
            title: "Seeded moment",
            startAt: Self.referenceDate,
            endAt: Self.referenceDate,
            isHighlight: true,
            background: "stayHappy",
            photo: "seeded-photo",
            createdAt: Self.olderDate,
            updatedAt: Self.olderDate
        )
        try appDatabase.saveMoment(&moment)

        var resource = ResourceMutation(
            title: "Seeded resource",
            createdAt: Self.olderDate,
            updatedAt: Self.olderDate
        )
        try appDatabase.saveResource(&resource)
    }

    // MARK: - Tests

    @Test("All expected migrations are applied, and only those")
    func appliesExactlyTheExpectedMigrations() throws {
        let appDatabase = try AppDatabase(DatabaseQueue())

        let applied = try appDatabase.reader.read { db in
            try String.fetchAll(db, sql: "SELECT identifier FROM grdb_migrations")
        }

        // Compared as sets so the assertion describes the contract (which
        // migrations exist) rather than SQLite's row order.
        #expect(Set(applied) == Set(Self.expectedMigrations))
        #expect(applied.count == Self.expectedMigrations.count, "a migration was applied twice")
    }

    @Test("Reopening a migrated database preserves all rows")
    func reopeningPreservesData() throws {
        let url = makeTemporaryDatabaseURL()

        // First launch: migrate and write data.
        do {
            let pool = try DatabasePool(path: url.path, configuration: AppDatabase.makeConfiguration())
            let appDatabase = try AppDatabase(pool)
            try seed(appDatabase)
        }

        // Second launch: the migrator runs again against the same file.
        let pool = try DatabasePool(path: url.path, configuration: AppDatabase.makeConfiguration())
        let appDatabase = try AppDatabase(pool)

        let (moments, resources, migrations) = try appDatabase.reader.read { db in
            (
                try Moment.fetchAll(db),
                try Resource.fetchAll(db),
                try String.fetchAll(db, sql: "SELECT identifier FROM grdb_migrations")
            )
        }

        #expect(moments.count == 1)
        #expect(resources.count == 1)
        #expect(migrations.count == Self.expectedMigrations.count, "a migration re-ran on reopen")

        let moment = try #require(moments.first)
        #expect(moment.title == "Seeded moment")
        #expect(moment.isHighlight)
        #expect(moment.photo == "seeded-photo")
        #expect(moment.background == "stayHappy")
        #expect(moment.startAt == Self.referenceDate)
        #expect(moment.endAt == Self.referenceDate)
        #expect(moment.createdAt == Self.olderDate)

        let resource = try #require(resources.first)
        #expect(resource.title == "Seeded resource")
        #expect(resource.createdAt == Self.olderDate)
    }

    @Test("Dates are stored in the GRDB 6 on-disk format")
    func datesKeepTheirOnDiskFormat() throws {
        let appDatabase = try AppDatabase(DatabaseQueue())
        try seed(appDatabase)

        let row = try appDatabase.reader.read { db in
            try Row.fetchOne(db, sql: "SELECT startAt, createdAt FROM moment LIMIT 1")
        }
        let momentRow = try #require(row)

        // GRDB's default date strategy writes UTC "YYYY-MM-DD HH:MM:SS.SSS".
        // These literals are what GRDB 6 wrote; if GRDB ever changes its
        // default encoding, this fails loudly instead of shifting user data.
        #expect(momentRow["startAt"] == "2023-11-14 22:13:20.000")
        #expect(momentRow["createdAt"] == "2020-09-13 12:26:40.000")
    }

    @Test("A database written with the old date format decodes correctly")
    func decodesLegacyDateStrings() throws {
        let appDatabase = try AppDatabase(DatabaseQueue())

        // Bypass the record layer and write the raw strings a GRDB 6 build
        // would have left on disk, then read them back through the model.
        try appDatabase.dbWriter.write { db in
            try db.execute(
                sql: """
                    INSERT INTO moment (title, isHighlight, startAt, endAt, background, photo, createdAt, updatedAt)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                arguments: [
                    "Legacy row", true,
                    "2023-11-14 22:13:20.000", "2023-11-14 22:13:20.000",
                    "stayHappy", nil,
                    "2020-09-13 12:26:40.000", "2020-09-13 12:26:40.000",
                ]
            )
        }

        let moment = try appDatabase.reader.read { db in
            try Moment.fetchOne(db)
        }
        let legacy = try #require(moment)

        #expect(legacy.startAt == Self.referenceDate)
        #expect(legacy.createdAt == Self.olderDate)
    }

    @Test("Queryable requests still fetch through the GRDBQuery protocols")
    func queryableRequestsFetch() throws {
        let appDatabase = try AppDatabase(DatabaseQueue())
        try seed(appDatabase)

        try appDatabase.reader.read { db in
            // The seeded moment is a highlight in the past.
            #expect(try HighlightListRequest().fetch(db).count == 1)
            #expect(try ResourceListRequest().fetch(db).count == 1)
            #expect(try MomentListRequest(period: .past, ordering: .asc).fetch(db).count == 1)
            #expect(try MomentListRequest(period: .upcoming, ordering: .asc).fetch(db).isEmpty)

            // Search bypasses the period filter by design (see `fetch`).
            let found = try MomentListRequest(searchText: "Seeded", period: .past, ordering: .asc).fetch(db)
            #expect(found.count == 1)
        }
    }
}
