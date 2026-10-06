import Foundation
import SwiftData

/// A conference the user is going to (ADR-0009). Same pattern as `FavouriteConference`:
/// keyed by conference ID only, so it survives feed refreshes and never mutates the cache.
/// Attending unlocks the personal talk agenda and the conference-day Live Activity.
@Model
final class AttendingConference {
    #Unique<AttendingConference>([\.conferenceID])

    var conferenceID: String
    var markedAt: Date

    init(conferenceID: String, markedAt: Date = .now) {
        self.conferenceID = conferenceID
        self.markedAt = markedAt
    }
}
