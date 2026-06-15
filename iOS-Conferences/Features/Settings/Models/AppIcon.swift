import Foundation

/// The app's primary icon plus the collectible alternate icons — a quiet easter egg
/// marking milestones in Apple history. Each alternate maps to an alternate app-icon
/// set in the asset catalog; a `nil` `alternateName` means the primary icon.
enum AppIcon: String, CaseIterable, Identifiable {
    case `default`
    case appleFounding
    case macintosh
    case iPod
    case iPhone
    case visionPro
    case wwdc26

    var id: String { rawValue }

    /// Asset-catalog alternate-icon name, or `nil` for the primary icon.
    var alternateName: String? {
        switch self {
        case .default: nil
        case .appleFounding: "AppIcon1976"
        case .macintosh: "AppIcon1984"
        case .iPod: "AppIcon2001"
        case .iPhone: "AppIcon2007"
        case .visionPro: "AppIcon2023"
        case .wwdc26: "AppIcon2026"
        }
    }

    /// Image-set used to preview the icon in the picker.
    var previewAsset: String {
        switch self {
        case .default: "IconPreview-default"
        case .appleFounding: "IconPreview-1976"
        case .macintosh: "IconPreview-1984"
        case .iPod: "IconPreview-2001"
        case .iPhone: "IconPreview-2007"
        case .visionPro: "IconPreview-2023"
        case .wwdc26: "IconPreview-2026"
        }
    }

    var title: String {
        switch self {
        case .default: "Tickets"
        case .appleFounding: "Apple Computer Co."
        case .macintosh: "Macintosh"
        case .iPod: "iPod"
        case .iPhone: "iPhone"
        case .visionPro: "Vision Pro"
        case .wwdc26: "WWDC26"
        }
    }

    var subtitle: String {
        switch self {
        case .default: "18 May 2026 · First commit"
        case .appleFounding: "1 Apr 1976 · Los Altos"
        case .macintosh: "24 Jan 1984 · Flint Center"
        case .iPod: "23 Oct 2001 · Apple Campus"
        case .iPhone: "9 Jan 2007 · Moscone Center"
        case .visionPro: "5 Jun 2023 · Apple Park"
        case .wwdc26: "8 Jun 2026 · Apple Park"
        }
    }

    /// One line of lore shown under the ticket in the wallet — why this moment earned
    /// a collectible.
    var lore: String {
        switch self {
        case .default: "The ticket fan from dubdub's very first commit."
        case .appleFounding: "Two Steves incorporate Apple Computer — on April Fools' Day."
        case .macintosh: "The Macintosh introduces itself at Flint Center."
        case .iPod: "A thousand songs in your pocket."
        case .iPhone: "An iPod, a phone, an internet communicator."
        case .visionPro: "One more thing: spatial computing arrives at Apple Park."
        case .wwdc26: "WWDC returns to Apple Park — and this app ships."
        }
    }
}

// MARK: - Unlocking

extension AppIcon {
    /// What a ticket asks of the collector before it can be worn. The default ticket is
    /// `.always` free; the rest are earned through real use (a hybrid of usage milestones
    /// and one seasonal easter egg). Evaluated by `AchievementService`.
    enum UnlockRule: Equatable {
        /// Free from the start — the primary icon.
        case always
        /// Earned once the user has favourited at least this many conferences (the only
        /// rule with numeric progress).
        case favourites(Int)
        /// Earned the first time the user performs a one-shot action.
        case event(AchievementEvent)
        /// Earned by opening the app inside a date window — a seasonal collectible.
        case dateWindow(ClosedRange<Date>)
    }

    /// A seasonal ticket gated on a date window — earned by *being there in time* rather than
    /// by an action, so its celebration is deferred to a calm moment rather than cold launch.
    var isSeasonal: Bool {
        if case .dateWindow = unlockRule { return true }
        return false
    }

    var unlockRule: UnlockRule {
        switch self {
        case .default: .always
        case .iPhone: .favourites(1)
        case .iPod: .favourites(5)
        case .macintosh: .event(.addedToCalendar)
        case .visionPro: .event(.visitedWebsite)
        case .appleFounding: .event(.suggestedConference)
        case .wwdc26: .dateWindow(Self.wwdc26Window)
        }
    }

    /// A short, inviting instruction shown on a *locked* ticket — phrased as a goal, not a
    /// gate. Empty for the always-free default.
    var unlockHint: String {
        switch self {
        case .default: ""
        case .iPhone: "Favourite your first conference"
        case .iPod: "Favourite 5 conferences"
        case .macintosh: "Add a conference to your calendar"
        case .visionPro: "Open a conference's website"
        case .appleFounding: "Suggest a conference"
        case .wwdc26: "Open dubdub during WWDC — June 2026"
        }
    }

    /// The WWDC26 ticket's window: any moment in June 2026 (Cupertino time), when the
    /// conference runs and this app shipped.
    private static let wwdc26Window: ClosedRange<Date> = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        let start = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)) ?? .distantFuture
        let end = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)) ?? .distantFuture
        // Up to, but not including, July 1st.
        return start...end.addingTimeInterval(-1)
    }()
}
