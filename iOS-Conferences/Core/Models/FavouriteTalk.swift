import Foundation
import SwiftData

/// A favourited talk on a multi-track conference (ADR-0009). Keyed by the schedule's stable
/// session ID, the same pattern as `FavouriteConference`, so it survives schedule refreshes.
/// `conferenceID` lets one conference's favourites be fetched without decoding any schedule.
@Model
final class FavouriteTalk {
    #Unique<FavouriteTalk>([\.talkID])

    var talkID: String
    var conferenceID: String
    var favouritedAt: Date

    init(talkID: String, conferenceID: String, favouritedAt: Date = .now) {
        self.talkID = talkID
        self.conferenceID = conferenceID
        self.favouritedAt = favouritedAt
    }
}
