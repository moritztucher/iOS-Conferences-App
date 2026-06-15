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
    /// Whether this unlock's celebration has been presented. Live earnings are celebrated at
    /// the moment they happen (`true` from the start); a seasonal ticket earned silently at
    /// launch is stored `false` so its celebration can be *deferred* to a calmer moment (the
    /// Appearance screen) instead of slamming a sheet over the first screen on cold launch.
    var celebrationShown: Bool = true

    init(iconID: String, unlockedAt: Date = .now, celebrationShown: Bool = true) {
        self.iconID = iconID
        self.unlockedAt = unlockedAt
        self.celebrationShown = celebrationShown
    }
}
