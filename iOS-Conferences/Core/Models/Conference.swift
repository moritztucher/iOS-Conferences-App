import Foundation
import SwiftData

/// What an entry in the list represents.
/// "Conference" — multi-day developer conference. "Event" — anything else listed alongside
/// (meetups, watch parties, hack days, satellite gatherings around a conference).
enum ConferenceKind: String, Codable, CaseIterable, Sendable {
    case conference = "Conference"
    case event = "Event"
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
}
