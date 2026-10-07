import Foundation

/// One entry on a personal agenda: what the Live Activity and the "Up next" preview show.
public struct AgendaItem: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let roomName: String?
    public let startsAt: Date
    public let endsAt: Date

    public init(id: String, title: String, roomName: String?, startsAt: Date, endsAt: Date) {
        self.id = id
        self.title = title
        self.roomName = roomName
        self.startsAt = startsAt
        self.endsAt = endsAt
    }
}

/// What's on at a given moment.
///
/// - `current` is set while an agenda item is running. The headline is then `current`, and
///   `next` is the line below it.
/// - Between items (a break, a multi-track slot with no favourite, before the first talk),
///   `current` is nil. The headline is `next`, and `after` is the line below it.
/// - Once the agenda is over, everything is nil.
public struct AgendaSnapshot: Hashable, Sendable {
    public let current: AgendaItem?
    public let next: AgendaItem?
    public let after: AgendaItem?

    public init(current: AgendaItem?, next: AgendaItem?, after: AgendaItem?) {
        self.current = current
        self.next = next
        self.after = after
    }

    /// The title-line item: the running talk, or the next one during a break.
    public var headline: AgendaItem? { current ?? next }

    /// The "Next" line under the headline.
    public var upcoming: AgendaItem? { current == nil ? after : next }

    public var isFinished: Bool { current == nil && next == nil }

    /// When this snapshot stops being true: the current item ends, or the next one starts.
    /// The Live Activity uses it as `staleDate`.
    public var validUntil: Date? { current?.endsAt ?? next?.startsAt }
}

/// The agenda rules from ADR-0009, kept free of UI and storage so they can be tested exhaustively.
public enum AgendaResolver {
    /// The user's agenda for a schedule.
    ///
    /// Single-track conferences put every keynote, talk and workshop on it. Multi-track
    /// conferences use only the favourited ones. Breaks and socials never appear. If
    /// favourites overlap, the earlier-starting one wins (ties go to room order), and any
    /// favourite that starts before the kept one ends is dropped, so the agenda never
    /// double-books.
    public static func agenda(for schedule: Schedule, favouriteTalkIDs: Set<String>) -> [AgendaItem] {
        let candidates = schedule.sessions.filter { session in
            session.kind.isAgendaKind && (schedule.isSingleTrack || favouriteTalkIDs.contains(session.id))
        }

        var agenda: [AgendaItem] = []
        for session in candidates {
            if let last = agenda.last, session.startsAt < last.endsAt { continue }
            agenda.append(item(for: session, in: schedule))
        }
        return agenda
    }

    /// The "Up next" preview: running and upcoming items, at most `limit` of them.
    ///
    /// When the user is attending, pass their `agenda(for:favouriteTalkIDs:)`. Otherwise pass
    /// `allTalks(in:)`, which keeps parallel talks side by side.
    public static func upcoming(_ items: [AgendaItem], at now: Date, limit: Int) -> [AgendaItem] {
        Array(items.filter { $0.endsAt > now }.prefix(limit))
    }

    /// Every keynote, talk and workshop as agenda items, overlaps included.
    public static func allTalks(in schedule: Schedule) -> [AgendaItem] {
        schedule.sessions.filter(\.kind.isAgendaKind).map { item(for: $0, in: schedule) }
    }

    private static func item(for session: ScheduleSession, in schedule: Schedule) -> AgendaItem {
        AgendaItem(
            id: session.id,
            title: session.title,
            roomName: schedule.room(withID: session.roomID)?.name,
            startsAt: session.startsAt,
            endsAt: session.endsAt
        )
    }

    /// Session IDs among `favouriteTalkIDs` that overlap another favourite. The schedule
    /// screen badges these so the user can see why one of them is left off the agenda.
    public static func conflictingFavourites(in schedule: Schedule, favouriteTalkIDs: Set<String>) -> Set<String> {
        let favourites = schedule.sessions.filter { $0.kind.isAgendaKind && favouriteTalkIDs.contains($0.id) }
        var conflicts: Set<String> = []
        for (index, session) in favourites.enumerated() {
            for other in favourites[(index + 1)...] {
                guard other.startsAt < session.endsAt else { break }
                conflicts.insert(session.id)
                conflicts.insert(other.id)
            }
        }
        return conflicts
    }

    /// What's on at `now`. `agenda` must be the output of `agenda(for:favouriteTalkIDs:)`:
    /// sorted, with no overlaps.
    public static func snapshot(of agenda: [AgendaItem], at now: Date) -> AgendaSnapshot {
        if let index = agenda.firstIndex(where: { $0.startsAt <= now && now < $0.endsAt }) {
            return AgendaSnapshot(
                current: agenda[index],
                next: agenda[safe: index + 1],
                after: agenda[safe: index + 2]
            )
        }
        guard let index = agenda.firstIndex(where: { $0.startsAt > now }) else {
            return AgendaSnapshot(current: nil, next: nil, after: nil)
        }
        return AgendaSnapshot(current: nil, next: agenda[index], after: agenda[safe: index + 1])
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
