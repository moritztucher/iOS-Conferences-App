import ConferenceKit
import Foundation
import Observation
import SwiftData

/// One start time on the schedule, with every session that begins then (parallel tracks
/// side by side in room order).
struct ScheduleSlot: Identifiable, Equatable {
    var id: Date { startsAt }
    let startsAt: Date
    let sessions: [ScheduleSession]

    /// Running at `now`: some session in the slot has started and not ended.
    func isLive(at now: Date) -> Bool {
        startsAt <= now && sessions.contains { now < $0.endsAt }
    }
}

@MainActor
@Observable
final class ConferenceScheduleViewModel {
    enum Filter: String, CaseIterable, Identifiable {
        case all
        case myAgenda

        var id: String { rawValue }

        var label: String {
            switch self {
            case .all: "All Sessions"
            case .myAgenda: "My Agenda"
            }
        }

        var systemImage: String {
            switch self {
            case .all: "list.bullet"
            case .myAgenda: "heart"
            }
        }
    }

    // MARK: - Properties

    let conferenceID: String
    /// Midnight (venue time) of the day being shown. `nil` until a schedule is available.
    var selectedDay: Date?
    var filter: Filter = .all
    private(set) var isRefreshing = false
    /// False until the first refresh finishes, so the empty state doesn't flash before it.
    private(set) var hasAttemptedLoad = false
    private(set) var loadError: String?

    private let service: any ScheduleServiceProtocol

    init(conferenceID: String, service: (any ScheduleServiceProtocol)? = nil) {
        self.conferenceID = conferenceID
        self.service = service ?? ScheduleServiceFactory.make()
    }

    // MARK: - Loading

    /// Refreshes the cached schedule. A failure is only surfaced when there's nothing cached
    /// to show: an offline refresh over a cached schedule stays silent.
    func refresh(context: ModelContext, hasCachedSchedule: Bool) async {
        isRefreshing = true
        defer {
            isRefreshing = false
            hasAttemptedLoad = true
        }
        do {
            try await service.refreshCache(conferenceID: conferenceID, into: context)
            loadError = nil
        } catch {
            loadError = hasCachedSchedule ? nil : error.localizedDescription
        }
    }

    // MARK: - Days

    /// Conference days in venue time, in order.
    func days(in schedule: Schedule) -> [Date] {
        let calendar = venueCalendar(for: schedule)
        let starts = schedule.sessions.map { calendar.startOfDay(for: $0.startsAt) }
        return Array(Set(starts)).sorted()
    }

    /// Picks a day when none is selected yet, or the selection isn't in this schedule:
    /// today if it's a conference day, otherwise the first day.
    func selectDefaultDayIfNeeded(in schedule: Schedule, now: Date = .now) {
        let days = days(in: schedule)
        if let selectedDay, days.contains(selectedDay) { return }
        let today = venueCalendar(for: schedule).startOfDay(for: now)
        selectedDay = days.contains(today) ? today : days.first
    }

    // MARK: - Slots

    /// The selected day's sessions grouped by start time. "My Agenda" keeps favourited talks
    /// only (multi-track); breaks and socials stay in "All Sessions" as context.
    func slots(in schedule: Schedule, favouriteTalkIDs: Set<String>) -> [ScheduleSlot] {
        guard let selectedDay else { return [] }
        let calendar = venueCalendar(for: schedule)
        let showsAgendaOnly = filter == .myAgenda && !schedule.isSingleTrack
        let sessions = schedule.sessions.filter { session in
            guard calendar.isDate(session.startsAt, inSameDayAs: selectedDay) else { return false }
            return !showsAgendaOnly || (session.kind.isAgendaKind && favouriteTalkIDs.contains(session.id))
        }
        let byStart = Dictionary(grouping: sessions, by: \.startsAt)
        return byStart.keys.sorted().map { ScheduleSlot(startsAt: $0, sessions: byStart[$0] ?? []) }
    }

    /// The slot to scroll to on open: the live one, or failing that the next to start.
    func focusSlotID(in slots: [ScheduleSlot], now: Date) -> Date? {
        slots.last { $0.isLive(at: now) }?.id ?? slots.first { $0.startsAt > now }?.id
    }

    // MARK: - Favourites

    /// Talk hearts only make sense with a choice to make: multi-track, agenda kinds.
    func canFavourite(_ session: ScheduleSession, in schedule: Schedule) -> Bool {
        !schedule.isSingleTrack && session.kind.isAgendaKind
    }

    func toggleFavourite(_ session: ScheduleSession, in favourites: [FavouriteTalk], context: ModelContext) {
        if let existing = favourites.first(where: { $0.talkID == session.id }) {
            context.delete(existing)
        } else {
            context.insert(FavouriteTalk(talkID: session.id, conferenceID: conferenceID))
        }
        try? context.save()
    }

    // MARK: - Helpers

    private func venueCalendar(for schedule: Schedule) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = schedule.timeZone
        return calendar
    }
}
