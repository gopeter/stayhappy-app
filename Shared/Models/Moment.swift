//
//  Moment.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 10.01.24.
//

import Combine
import Foundation
import GRDB
import GRDBQuery

// MARK: - Moment Mutation Model

struct MomentMutation {
    var id: Int64?
    var title: String
    var startAt: Date
    var endAt: Date?
    var isHighlight: Bool?
    var background: String
    var photo: String?
    var createdAt: Date?
    var updatedAt: Date?

    init(
        id: Int64? = nil,
        title: String,
        startAt: Date,
        endAt: Date? = nil,
        isHighlight: Bool? = nil,
        background: String,
        photo: String?,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.startAt = startAt
        self.endAt = endAt ?? startAt
        self.isHighlight = isHighlight ?? false
        self.background = background
        self.photo = photo
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

        try db!.write { db in
            try moment.save(db)
        }
    }

    func deleteMoments(_ ids: [Int64]) throws {
        try db!.write { db in
            _ = try Moment.deleteAll(db, ids: ids)
        }
    }
}

// MARK: - Moment Model

struct Moment: Identifiable, Equatable, Hashable {
    var id: Int64
    var title: String
    var startAt: Date
    var endAt: Date
    var isHighlight: Bool
    var background: String
    var photo: String?
    var createdAt: Date
    var updatedAt: Date
}

extension Moment: Codable, FetchableRecord, PersistableRecord {
    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
        static let startAt = Column(CodingKeys.startAt)
    }
}

extension DerivableRequest<Moment> {
    func filterBySearchText(_ searchText: String) -> Self {
        let pattern = "%\(searchText)%"
        return filter(sql: "moment.title LIKE ?", arguments: [pattern])
    }

    func filterByPeriod(_ dateCompareOperator: String) -> Self {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return filter(sql: "moment.startAt \(dateCompareOperator) ?", arguments: [formatter.string(from: startOfToday)])
    }
    
    func filterByHighlight() -> Self {
        return filter(sql: "moment.isHighlight = true")
    }
}

// MARK: - Moment Model Requests

struct MomentListRequest: Queryable {
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

    static var defaultValue: [Moment] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Moment], Error> {
        if appDatabase.db == nil {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db!, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Moment] {
        let dateCompareOperator = period == Period.upcoming ? ">=" : "<"
        var moments = Moment.all()

        if searchText == "" {
            moments = moments.filterByPeriod(dateCompareOperator)
        } else {
            moments = moments.filterBySearchText(searchText)
        }
        
        // we want to reverse the order when viewing past moments
        if period == Period.upcoming {
            moments = moments.order(ordering == Ordering.desc ? Moment.Columns.startAt.desc : Moment.Columns.startAt.asc)
        } else {
            moments = moments.order(ordering == Ordering.asc ? Moment.Columns.startAt.desc : Moment.Columns.startAt.asc)
        }
            
        return try moments.fetchAll(db)
    }
}

struct HighlightListRequest: Queryable {
    static var defaultValue: [Moment] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Moment], Error> {
        if appDatabase.db == nil {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db!, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Moment] {
        let moments = Moment.all().filterByHighlight().order(Moment.Columns.startAt.desc)
        return try moments.fetchAll(db)
    }
}

struct MomentsWidgetRequest: Queryable {
    static var defaultValue: [Moment] { [] }

    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Moment], Error> {
        if appDatabase.db == nil {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.db!, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Moment] {
        let moments = Moment.all().filterByPeriod(">=").order(Moment.Columns.startAt.asc).limit(5)
        return try moments.fetchAll(db)
    }
}
