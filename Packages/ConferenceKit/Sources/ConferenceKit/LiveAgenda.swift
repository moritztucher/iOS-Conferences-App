import Foundation
#if os(iOS)
import ActivityKit
#endif

// MARK: - Activity attributes

/// The conference-day Live Activity (ADR-0009): one per attended conference day.
/// Static facts live here; what changes during the day lives in `ContentState`.
/// Shared by the app (which starts and updates it) and the widget extension (which draws it).
public struct ConferenceDayAttributes: Codable, Hashable, Sendable {
    public let conferenceID: String
    public let conferenceName: String
    /// 1-based conference day, e.g. 2 for "Day 2".
    public let dayNumber: Int
    /// Venue midnight of the day this activity covers. Identifies the activity with `conferenceID`.
    public let dayStart: Date
    public let timeZoneIdentifier: String

    public init(conferenceID: String, conferenceName: String, dayNumber: Int, dayStart: Date, timeZoneIdentifier: String) {
        self.conferenceID = conferenceID
        self.conferenceName = conferenceName
        self.dayNumber = dayNumber
        self.dayStart = dayStart
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    public var timeZone: TimeZone { TimeZone(identifier: timeZoneIdentifier) ?? .current }

    /// Only the few items the presentation draws; well under ActivityKit's 4 KB state limit.
    public struct ContentState: Codable, Hashable, Sendable {
        public let current: AgendaItem?
        public let next: AgendaItem?
        public let after: AgendaItem?
        /// When this state was computed: the lower bound for the self-ticking countdowns.
        public let asOf: Date

        public init(current: AgendaItem?, next: AgendaItem?, after: AgendaItem?, asOf: Date) {
            self.current = current
            self.next = next
            self.after = after
            self.asOf = asOf
        }

        public init(snapshot: AgendaSnapshot, asOf: Date) {
            self.init(current: snapshot.current, next: snapshot.next, after: snapshot.after, asOf: asOf)
        }
    }
}

#if os(iOS)
extension ConferenceDayAttributes: ActivityAttributes {}
#endif

// MARK: - Presentation rules

/// What the Live Activity shows for a state, following ADR-0009:
/// - **Title:** the running talk, or the next one during a break.
/// - **Below it:** the room, plus a countdown to the end (running) or the start (next).
/// - **If there's room:** the talk after that.
///
/// The app can only push updates while it runs, so the system marks a state stale once
/// its `staleDate` passes. A stale state is read one step ahead: the item that was "next"
/// is promoted to the title. One missed update still shows the right talk.
public struct LiveAgendaDisplay: Equatable, Sendable {
    public enum Phase: Equatable, Sendable {
        /// `headline` is running now; the countdown runs to its end.
        case inSession
        /// `headline` is up next; the countdown runs to its start.
        case upNext
        /// Nothing left today.
        case finished
    }

    public let phase: Phase
    public let headline: AgendaItem?
    public let upcoming: AgendaItem?

    public init(state: ConferenceDayAttributes.ContentState, isStale: Bool) {
        switch (state.current, isStale) {
        case let (current?, false):
            // A talk is running.
            self.init(phase: .inSession, headline: current, upcoming: state.next)
        case (_?, true):
            // The running talk has ended without an update: the next one is now the headline.
            self.init(phase: state.next == nil ? .finished : .upNext, headline: state.next, upcoming: state.after)
        case (nil, false):
            // Break or free slot: the next talk is the headline.
            self.init(phase: state.next == nil ? .finished : .upNext, headline: state.next, upcoming: state.after)
        case (nil, true):
            // The next talk has started without an update: treat it as running.
            self.init(phase: state.next == nil ? .finished : .inSession, headline: state.next, upcoming: state.after)
        }
    }

    private init(phase: Phase, headline: AgendaItem?, upcoming: AgendaItem?) {
        self.phase = phase
        self.headline = headline
        self.upcoming = upcoming
    }

    /// The countdown target: the headline's end while it runs, its start while it's next.
    public var countdownTarget: Date? {
        switch phase {
        case .inSession: headline?.endsAt
        case .upNext: headline?.startsAt
        case .finished: nil
        }
    }
}

// MARK: - Day planning

/// Which conference day a Live Activity should cover right now, and when it should run.
public struct LiveAgendaPlan: Equatable, Sendable {
    public let attributes: ConferenceDayAttributes
    /// The day's agenda, in order.
    public let items: [AgendaItem]
    /// When the activity should appear: `leadTime` before the first item.
    public let startsAt: Date
    /// When the last item ends.
    public let endsAt: Date

    public func state(at now: Date) -> ConferenceDayAttributes.ContentState {
        ConferenceDayAttributes.ContentState(snapshot: AgendaResolver.snapshot(of: items, at: now), asOf: now)
    }

    /// The staleDate for the state at `now`: when its headline changes.
    public func validUntil(at now: Date) -> Date? {
        AgendaResolver.snapshot(of: items, at: now).validUntil
    }
}

public enum LiveAgendaPlanner {
    /// How long before the first talk the activity appears.
    public static let defaultLeadTime: TimeInterval = 15 * 60

    /// The plan for the first conference day whose agenda isn't over yet at `now`, or nil
    /// when nothing is left (or the agenda is empty).
    public static func plan(
        for schedule: Schedule,
        conferenceName: String,
        favouriteTalkIDs: Set<String>,
        now: Date,
        leadTime: TimeInterval = defaultLeadTime
    ) -> LiveAgendaPlan? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = schedule.timeZone

        let agenda = AgendaResolver.agenda(for: schedule, favouriteTalkIDs: favouriteTalkIDs)
        let agendaByDay = Dictionary(grouping: agenda) { calendar.startOfDay(for: $0.startsAt) }
        // Day numbers count every conference day, including ones with nothing on the agenda.
        let conferenceDays = Set(schedule.sessions.map { calendar.startOfDay(for: $0.startsAt) }).sorted()

        guard let day = agendaByDay.keys.sorted().first(where: { day in
            agendaByDay[day]?.last.map { $0.endsAt > now } ?? false
        }), let items = agendaByDay[day], let first = items.first, let last = items.last else {
            return nil
        }

        return LiveAgendaPlan(
            attributes: ConferenceDayAttributes(
                conferenceID: schedule.conferenceID,
                conferenceName: conferenceName,
                dayNumber: (conferenceDays.firstIndex(of: day) ?? 0) + 1,
                dayStart: day,
                timeZoneIdentifier: schedule.timeZoneIdentifier
            ),
            items: items,
            startsAt: first.startsAt.addingTimeInterval(-leadTime),
            endsAt: last.endsAt
        )
    }
}

// MARK: - Formatting

/// Session times in the venue's zone, as the organiser published them. Shared by the app's
/// `ConferenceDateStyle` and the widget extension, so both read the same.
public enum ScheduleTimeFormat {
    /// Locale-aware short time, e.g. "09:30" / "9:30 AM".
    public static func time(_ date: Date, in timeZone: TimeZone) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = timeZone
        return date.formatted(style)
    }
}
