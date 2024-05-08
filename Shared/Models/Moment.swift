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
import WidgetKit

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
    
    func didSave(_ saved: PersistenceSuccess) {
        WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
    }
    
    func didDelete(deleted: Bool) {
        WidgetCenter.shared.reloadTimelines(ofKind: "app.stayhappy.StayHappy.MomentsWidget")
    }

    mutating func willInsert(_ db: Database) throws {
        if createdAt == nil {
            createdAt = try db.transactionDate
        }

        if updatedAt == nil {
            updatedAt = try db.transactionDate
        }
    }
    
    mutating func willUpdate(_ db: Database) throws {
        updatedAt = try db.transactionDate
    }
}

// MARK: - Moment Mutation Operations

extension AppDatabase {
    func saveMoment(_ moment: inout MomentMutation) throws {
        if moment.title.isEmpty {
            throw ValidationError.missingName
        }

        try dbWriter.write { db in
            try moment.save(db)
        }
    }

    func deleteMoments(_ ids: [Int64]) throws {
        try dbWriter.write { db in
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
    public enum Columns {
        static let title = Column(CodingKeys.title)
        static let startAt = Column(CodingKeys.startAt)
    }
}

extension DerivableRequest<Moment> {
    func filterBySearchText(_ searchText: String) -> Self {
        let pattern = "%\(searchText)%"
        return filter(sql: "moment.title LIKE ?", arguments: [pattern])
    }

    func filterByPeriod(_ dateCompareOperator: String, period: MomentsWidgetLimitType? = nil) -> Self {
        var arguments: [String] = []

        let startOfToday = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if period != nil {
            var periodDate = startOfToday

            switch period {
                case .month:
                    if dateCompareOperator.contains("<") {
                        periodDate = startOfToday.withAddedDays(days: 30)
                    } else {
                        periodDate = startOfToday.withSubtractedDays(days: 30)
                    }

                case .quarter:
                    if dateCompareOperator.contains("<") {
                        periodDate = startOfToday.withAddedDays(days: 90)
                    } else {
                        periodDate = startOfToday.withSubtractedDays(days: 90)
                    }

                case .year:
                    if dateCompareOperator.contains("<") {
                        periodDate = startOfToday.withAddedDays(days: 365)
                    } else {
                        periodDate = startOfToday.withSubtractedDays(days: 365)
                    }

                case .all:
                    return self

                default: break
            }

            arguments.append(formatter.string(from: periodDate))
        } else {
            arguments.append(formatter.string(from: startOfToday))
        }

        return filter(sql: "moment.startAt \(dateCompareOperator) ?", arguments: StatementArguments(arguments))
    }

    func filterByHighlight() -> Self {
        return filter(sql: "moment.isHighlight = true")
    }
}

// MARK: - Moment Test Data

extension Moment {
    static func makeRandom(index: Int) -> MomentMutation {
        MomentMutation(
            title: "A really long test moment \(index)",
            startAt: Date().withAddedHours(hours: 24 * Double(index) * 15),
            background: HappyGradients.allCases.map { $0.rawValue }.randomElement()!,
            photo: nil
        )
    }
    
    static func makeRandomPastHighlight(index: Int) -> MomentMutation {
        MomentMutation(
            title: "A really long test moment \(index)",
            startAt: Date().withSubtractedHours(hours: 24 * Double(index + 1)),
            isHighlight: true,
            background: HappyGradients.allCases.map { $0.rawValue }.randomElement()!,
            photo: nil
        )
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
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.dbWriter, scheduling: .immediate)
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
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.reader, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Moment] {
        let moments = Moment
            .all()
            .filterByHighlight()
            .order(Moment.Columns.startAt.desc)

        return try moments.fetchAll(db)
    }
}
