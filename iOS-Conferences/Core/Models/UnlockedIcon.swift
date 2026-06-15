import Foundation
import SwiftData

/// A collectible icon the user has earned. Stored by icon ID only, in its own model so an
/// unlock is **permanent** — it survives a conference-cache refresh and is never recomputed
/// away if the user later drops below a threshold (e.g. un-favourites). Mirrors the
/// `FavouriteConference` pattern: the durable record is the ID + a timestamp, nothing more.
@Model
final class UnlockedIcon {
    #Unique<UnlockedIcon>([\.iconID])

    var iconID: String
    var unlockedAt: Date

    init(iconID: String, unlockedAt: Date = .now) {
        self.iconID = iconID
        self.unlockedAt = unlockedAt
    }
}
