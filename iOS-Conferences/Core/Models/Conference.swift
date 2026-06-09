import Foundation
import SwiftData

/// What an entry in the list represents.
/// "Conference" — multi-day developer conference. "Watch Party" — keynote/SOTU viewing event.
/// "Event" — everything else (meetups, hack days, satellite gatherings around a conference).
enum ConferenceKind: String, Codable, CaseIterable, Sendable {
    case conference = "Conference"
    case watchParty = "Watch Party"
    case event = "Event"

    /// SF Symbol used to label the kind in the list. Matches the kind-filter symbols.
    var symbolName: String {
        switch self {
        case .conference: return "building.columns.fill"
        case .watchParty: return "tv"
        case .event: return "calendar.badge.plus"
        }
    }

    /// Plural label used as the list's kind section header (e.g. "Watch Parties").
    var pluralLabel: String {
        switch self {
        case .conference: return "Conferences"
        case .watchParty: return "Watch Parties"
        case .event: return "Events"
        }
    }

    /// Order kind sections appear in the list: Conferences, Events, Watch Parties.
    static let displayOrder: [ConferenceKind] = [.conference, .event, .watchParty]
}

@Model
final class Conference {
    #Unique<Conference>([\.id])

    var id: String
    /// Default keeps existing stored rows valid after the field was added.
    var kind: ConferenceKind = ConferenceKind.conference
    var name: String
    var startDate: Date
    var endDate: Date
    var locationName: String
    var mapQuery: String?
    var summary: String
    var websiteURLString: String
    var logoURLString: String?
    var tags: [String]

    init(
        id: String,
        kind: ConferenceKind = .conference,
        name: String,
        startDate: Date,
        endDate: Date,
        locationName: String,
        mapQuery: String?,
        summary: String,
        websiteURLString: String,
        logoURLString: String? = nil,
        tags: [String]
    ) {
        self.id = id
        self.kind = kind
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locationName = locationName
        self.mapQuery = mapQuery
        self.summary = summary
        self.websiteURLString = websiteURLString
        self.logoURLString = logoURLString
        self.tags = tags
    }
}

extension Conference {
    var websiteURL: URL? { URL(string: websiteURLString) }
    var logoURL: URL? {
        guard let logoURLString else { return nil }
        return URL(string: logoURLString)
    }
    var isPast: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        let eventEndDay = Calendar.current.startOfDay(for: endDate)
        return today > eventEndDay
    }
    var isOnline: Bool { mapQuery == nil || locationName.localizedCaseInsensitiveContains("online") }

    /// Display-only: trims a redundant trailing country so list rows read "Cupertino, California"
    /// instead of the truncated "Cupertino, California, USA". No effect on map queries or storage.
    var locationShort: String {
        let parts = locationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard parts.count >= 3 else { return locationName }
        let trailingCountries: Set<String> = [
            "usa", "u.s.a.", "us", "united states", "united states of america",
            "uk", "u.k.", "united kingdom"
        ]
        if let last = parts.last, trailingCountries.contains(last.lowercased()) {
            return parts.dropLast().joined(separator: ", ")
        }
        return locationName
    }
}
