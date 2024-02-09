//
//  Moment.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 09.02.24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery

// MARK: - Moment Mutation Model

struct MomentMutation {
    var id: Int64?
    var title: String
    var createdAt: Date?
    var updatedAt: Date?

    init(id: Int64? = nil, title: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension MomentMutation: Encodable, MutablePersistableRecord {
    static var databaseTableName: String { "moment" }

    /// Updates auto-incremented id upon successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    /// Sets both `creationDate` and `modificationDate` to the
    /// transaction date, if they are not set yet.
    mutating func willInsert(_ db: Database) throws {
        if createdAt == nil {
            createdAt = try db.transactionDate
        }

        if updatedAt == nil {
            updatedAt = try db.transactionDate
        }
    }
}

// MARK: - Moment Mutation Operations

extension AppDatabase {
    func saveMoment(_ moment: inout MomentMutation) throws {
        if moment.title.isEmpty {
            throw ValidationError.missingName
        }

        try db.write { db in
            try moment.save(db)
        }
    }

    func deleteMoments(_ ids: [Int64]) throws {
        try db.write { db in
            _ = try Moment.deleteAll(db, ids: ids)
        }
    }
}

// MARK: - Moment Model

struct Moment: Identifiable, Equatable, Hashable {
    var id: Int64
    var title: String
    var createdAt: Date
    var updatedAt: Date
}

extension Moment: Codable, FetchableRecord, PersistableRecord {
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension DerivableRequest<Moment> {
    func filterBySearchText(_ searchText: String) -> Self {
        let pattern = "%\(searchText)%"
        return filter(sql: "moment.title LIKE ?", arguments: [pattern])
    }
}

// MARK: - Moment Model Requests

struct MomentListRequest: Queryable {
    var searchText: String = ""

    static var defaultValue: [Moment] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Moment], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Moment] {
        var moments = Moment.all()

        if searchText != "" {
            moments = moments.filterBySearchText(searchText)
        }

        return try moments
            .order(Moment.Columns.createdAt.desc)
            .fetchAll(db)
    }
}

