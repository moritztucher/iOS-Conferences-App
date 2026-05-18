import Foundation
import SwiftData

@Model
final class FavouriteConference {
    #Unique<FavouriteConference>([\.conferenceID])

    var conferenceID: String
    var favouritedAt: Date

    init(conferenceID: String, favouritedAt: Date = .now) {
        self.conferenceID = conferenceID
        self.favouritedAt = favouritedAt
    }
}
