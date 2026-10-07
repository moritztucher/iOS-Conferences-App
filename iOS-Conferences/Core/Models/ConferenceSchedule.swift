import ConferenceKit
import Foundation
import SwiftData

/// Cached talk schedule for one conference (ADR-0009). The decoded `Schedule` is stored as
/// encoded data: a schedule is always read and replaced whole, so there's nothing to gain
/// from modelling sessions as SwiftData rows. Talk favourites live in `FavouriteTalk`, so
/// replacing this cache never loses them.
@Model
final class ConferenceSchedule {
    #Unique<ConferenceSchedule>([\.conferenceID])

    var conferenceID: String
    var fetchedAt: Date
    var payload: Data

    init(schedule: Schedule, fetchedAt: Date = .now) throws {
        conferenceID = schedule.conferenceID
        self.fetchedAt = fetchedAt
        payload = try JSONEncoder().encode(schedule)
    }

    /// `nil` only if the stored payload no longer decodes (e.g. after an incompatible
    /// `Schedule` change); the next refresh replaces it.
    var schedule: Schedule? {
        try? JSONDecoder().decode(Schedule.self, from: payload)
    }

    func replace(with schedule: Schedule, fetchedAt: Date = .now) throws {
        payload = try JSONEncoder().encode(schedule)
        self.fetchedAt = fetchedAt
    }
}
