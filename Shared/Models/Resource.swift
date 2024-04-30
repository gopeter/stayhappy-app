//
//  Resource.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 09.02.24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery

// MARK: - Resource Mutation Model

struct ResourceMutation {
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

extension ResourceMutation: Encodable, MutablePersistableRecord {
    static var databaseTableName: String { "resource" }

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

// MARK: - Resource Mutation Operations

extension AppDatabase {
    func saveResource(_ resource: inout ResourceMutation) throws {
        if resource.title.isEmpty {
            throw ValidationError.missingName
        }
        
        if db == nil {
            throw ValidationError.missingName
        }

        try db!.write { db in
            try resource.save(db)
        }
    }

    func deleteResources(_ ids: [Int64]) throws {
        try db!.write { db in
            _ = try Resource.deleteAll(db, ids: ids)
        }
    }
}

// MARK: - Resource Model

struct Resource: Identifiable, Equatable, Hashable {
    var id: Int64
    var title: String
    var createdAt: Date
    var updatedAt: Date
}

extension Resource: Codable, FetchableRecord, PersistableRecord {
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension DerivableRequest<Resource> {
    func filterBySearchText(_ searchText: String) -> Self {
        let pattern = "%\(searchText)%"
        return filter(sql: "resource.title LIKE ?", arguments: [pattern])
    }
}

// MARK: - Resource Model Requests

struct ResourceListRequest: Queryable {
    var searchText: String = ""

    static var defaultValue: [Resource] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Resource], Error> {  
        if appDatabase.db == nil {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db!, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Resource] {
        var resources = Resource.all()

        if searchText != "" {
            resources = resources.filterBySearchText(searchText)
        }

        return try resources
            .order(Resource.Columns.createdAt.desc)
            .fetchAll(db)
    }
}