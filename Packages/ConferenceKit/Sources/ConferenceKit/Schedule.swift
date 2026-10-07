import Foundation

/// A conference's talk schedule (ADR-0009), resolved from `data/schedules/<id>.json`.
/// Session times are absolute instants: the feed's venue-local wall-clock times are
/// anchored in `timeZoneIdentifier` once, at decode time (see `ScheduleFeed`).
public struct Schedule: Codable, Hashable, Sendable {
    public let conferenceID: String
    /// The venue's IANA zone, used to show times as the organiser published them.
    public let timeZoneIdentifier: String
    public let updatedAt: Date
    /// Stages in display order.
    public let rooms: [ScheduleRoom]
    /// Sorted by start, then room order.
    public let sessions: [ScheduleSession]

    public init(
        conferenceID: String,
        timeZoneIdentifier: String,
        updatedAt: Date,
        rooms: [ScheduleRoom],
        sessions: [ScheduleSession]
    ) {
        self.conferenceID = conferenceID
        self.timeZoneIdentifier = timeZoneIdentifier
        self.updatedAt = updatedAt
        self.rooms = rooms
        self.sessions = sessions
    }

    public var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    /// One stage: every talk is on everyone's agenda and there is nothing to pick.
    public var isSingleTrack: Bool { rooms.count <= 1 }

    public func room(withID id: String?) -> ScheduleRoom? {
        guard let id else { return nil }
        return rooms.first { $0.id == id }
    }
}

public struct ScheduleRoom: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct ScheduleSession: Codable, Hashable, Sendable, Identifiable {
    /// Stable across schedule edits; talk favourites are keyed on it.
    public let id: String
    public let kind: SessionKind
    public let title: String
    public let speakers: [String]
    public let roomID: String?
    public let url: URL?
    public let startsAt: Date
    public let endsAt: Date

    public init(
        id: String,
        kind: SessionKind,
        title: String,
        speakers: [String] = [],
        roomID: String? = nil,
        url: URL? = nil,
        startsAt: Date,
        endsAt: Date
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.speakers = speakers
        self.roomID = roomID
        self.url = url
        self.startsAt = startsAt
        self.endsAt = endsAt
    }
}

public enum SessionKind: String, Codable, Hashable, Sendable, CaseIterable {
    case keynote, talk, workshop, `break`, social

    /// Only these can be on a personal agenda or headline the Live Activity. Breaks and
    /// socials stay in the full schedule as context.
    public var isAgendaKind: Bool {
        switch self {
        case .keynote, .talk, .workshop: true
        case .break, .social: false
        }
    }
}
