import Foundation

/// Decodes the community-curated schedule file (`data/schedules/<id>.json`, schema in
/// CONTRIBUTING.md) into a `Schedule`. Lenient by design: a malformed session is dropped
/// instead of failing the whole file, and an unknown `kind` reads as a talk, the same
/// trade-off the conference feed makes. `scripts/validate_schedules.py` is the strict gate.
public enum ScheduleFeed {
    public enum DecodingError: LocalizedError, Equatable {
        case invalidTimeZone(String)

        public var errorDescription: String? {
            switch self {
            case .invalidTimeZone(let identifier):
                "The schedule's time zone \"\(identifier)\" isn't a valid IANA identifier."
            }
        }
    }

    public static func decode(_ data: Data) throws -> Schedule {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let raw = try decoder.decode(RawSchedule.self, from: data)

        guard let timeZone = TimeZone(identifier: raw.timeZone) else {
            throw DecodingError.invalidTimeZone(raw.timeZone)
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let roomOrder = Dictionary(uniqueKeysWithValues: raw.rooms.enumerated().map { ($1.id, $0) })
        let sessions = raw.sessions
            .compactMap { $0.resolve(in: calendar) }
            .sorted { lhs, rhs in
                if lhs.startsAt != rhs.startsAt { return lhs.startsAt < rhs.startsAt }
                return roomOrder[lhs.roomID ?? "", default: -1] < roomOrder[rhs.roomID ?? "", default: -1]
            }

        return Schedule(
            conferenceID: raw.conferenceId,
            timeZoneIdentifier: raw.timeZone,
            updatedAt: raw.updatedAt,
            rooms: raw.rooms.map { ScheduleRoom(id: $0.id, name: $0.name) },
            sessions: sessions
        )
    }
}

// MARK: - Wire format

private struct RawSchedule: Decodable {
    let conferenceId: String
    let timeZone: String
    let updatedAt: Date
    let rooms: [RawRoom]
    let sessions: [RawSession]

    private enum CodingKeys: String, CodingKey {
        case conferenceId, timeZone, updatedAt, rooms, sessions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conferenceId = try container.decode(String.self, forKey: .conferenceId)
        timeZone = try container.decode(String.self, forKey: .timeZone)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        rooms = try container.decodeIfPresent([RawRoom].self, forKey: .rooms) ?? []
        // Lossy: one bad session must not take the whole schedule down.
        sessions = try container.decode([Lossy<RawSession>].self, forKey: .sessions).compactMap(\.value)
    }
}

private struct RawRoom: Decodable {
    let id: String
    let name: String
}

private struct RawSession: Decodable {
    let id: String
    let kind: String
    let day: String
    let start: String
    let end: String
    let title: String
    let speakers: [String]?
    let roomId: String?
    let url: String?
    let description: String?

    func resolve(in calendar: Calendar) -> ScheduleSession? {
        guard let startsAt = Self.instant(day: day, time: start, in: calendar),
              let endsAt = Self.instant(day: day, time: end, in: calendar),
              endsAt > startsAt else {
            return nil
        }
        return ScheduleSession(
            id: id,
            kind: SessionKind(rawValue: kind) ?? .talk,
            title: title,
            speakers: speakers ?? [],
            roomID: roomId,
            url: url.flatMap(URL.init(string:)).flatMap { $0.scheme == "https" ? $0 : nil },
            abstract: description.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 },
            startsAt: startsAt,
            endsAt: endsAt
        )
    }

    /// `"2026-10-13"` + `"09:30"` as wall-clock time in the calendar's (venue) zone.
    private static func instant(day: String, time: String, in calendar: Calendar) -> Date? {
        let dayParts = day.split(separator: "-").compactMap { Int($0) }
        let timeParts = time.split(separator: ":").compactMap { Int($0) }
        guard dayParts.count == 3, timeParts.count == 2,
              (0...23).contains(timeParts[0]), (0...59).contains(timeParts[1]) else {
            return nil
        }
        let components = DateComponents(
            year: dayParts[0], month: dayParts[1], day: dayParts[2],
            hour: timeParts[0], minute: timeParts[1]
        )
        return calendar.date(from: components)
    }
}

private struct Lossy<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}
