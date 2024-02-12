//
//  Event.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery

// MARK: - Event Mutation Model

struct EventMutation {
    var id: Int64?
    var title: String
    var isHighlight: Bool?
    var startAt: Date
    var endAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    init(id: Int64? = nil, title: String, isHighlight: Bool? = nil, startAt: Date, endAt: Date? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.isHighlight = isHighlight ?? false
        self.startAt = startAt
        self.endAt = endAt ?? startAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension EventMutation: Encodable, MutablePersistableRecord {
    static var databaseTableName: String { "event" }

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

// MARK: - Event Mutation Operations

extension AppDatabase {
    func saveEvent(_ event: inout EventMutation) throws {
        if event.title.isEmpty {
            throw ValidationError.missingName
        }

        try db.write { db in
            try event.save(db)
        }
    }

    func deleteEvents(_ ids: [Int64]) throws {
        try db.write { db in
            _ = try Event.deleteAll(db, ids: ids)
        }
    }
}

// MARK: - Event Model

struct Event: Identifiable, Equatable, Hashable {
    var id: Int64
    var title: String
    var isHighlight: Bool
    var startAt: Date
    var endAt: Date
    var createdAt: Date
    var updatedAt: Date
}

extension Event: Codable, FetchableRecord, PersistableRecord {
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let startAt = Column(CodingKeys.startAt)
    }
}

extension DerivableRequest<Event> {
    func filterBySearchText(_ searchText: String) -> Self {
        let pattern = "%\(searchText)%"
        return filter(sql: "event.title LIKE ?", arguments: [pattern])
    }

    func filterByPeriod(_ dateCompareOperator: String) -> Self {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return filter(sql: "event.startAt \(dateCompareOperator) ?", arguments: [formatter.string(from: startOfToday)])
    }
}

// MARK: - Event Model Requests

struct EventListRequest: Queryable {
    enum Period {
        case upcoming
        case past
    }

    enum Ordering {
        case asc
        case desc
    }

    var searchText: String = ""
    var period: Period
    var ordering: Ordering

    static var defaultValue: [Event] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Event], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Event] {
        let dateCompareOperator = period == Period.upcoming ? ">=" : "<"
        var events = Event.all()

        if searchText == "" {
            events = events.filterByPeriod(dateCompareOperator)
        } else {
            events = events.filterBySearchText(searchText)
        }
        
        // we want to reverse the order when viewing past events
        if period == Period.upcoming {
            events = events.order(ordering == Ordering.desc ? Event.Columns.startAt.desc : Event.Columns.startAt.asc)
        } else {
            events = events.order(ordering == Ordering.asc ? Event.Columns.startAt.desc : Event.Columns.startAt.asc)
        }
            
        return try events.fetchAll(db)
    }
}
