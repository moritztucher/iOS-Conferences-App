import ActivityKit
import BackgroundTasks
import ConferenceKit
import Foundation
import Observation
import OSLog
import SwiftData

/// Runs the conference-day Live Activity (ADR-0009), with local updates only (no push server).
///
/// `sync()` makes the system's activities match what should be on screen right now, and is
/// called whenever that could have changed:
/// - the app becomes active,
/// - the user marks a conference as attended or hearts a talk,
/// - the Settings toggle changes,
/// - a background app refresh runs (opportunistic; `earliestBeginDate` is a floor, not a promise).
///
/// Between those moments the activity relies on `staleDate` plus the one-step lookahead in
/// `LiveAgendaDisplay`. Before a conference day it uses iOS 26 scheduled start, so the
/// activity appears 15 minutes before the first talk even if the app isn't running.
@MainActor
@Observable
final class LiveAgendaManager {
    static let refreshTaskIdentifier = "com.moritztucher.dubdub-ios-conference.live-agenda"
    static let settingKey = "settings.liveActivities"

    /// How far ahead a day's activity is scheduled. Kept short because the system's limits on
    /// pending scheduled activities aren't documented; the next app launch schedules the rest.
    private static let schedulingHorizon: TimeInterval = 48 * 60 * 60
    /// How old a cached schedule may be before a sync re-fetches it (room swaps on the day).
    private static let scheduleMaxAge: TimeInterval = 60 * 60
    /// How long the "That's a wrap" state stays after the day's last talk.
    private static let wrapDisplayTime: TimeInterval = 15 * 60

    private let container: ModelContainer
    private let defaults: UserDefaults
    private let scheduleService: @MainActor () -> any ScheduleServiceProtocol
    private let logger = Logger(subsystem: "com.moritztucher.dubdub-ios-conference", category: "LiveAgenda")

    init(
        container: ModelContainer,
        defaults: UserDefaults = .standard,
        scheduleService: @escaping @MainActor () -> any ScheduleServiceProtocol = { ScheduleServiceFactory.make() }
    ) {
        self.container = container
        self.defaults = defaults
        self.scheduleService = scheduleService
    }

    var isEnabledInSettings: Bool {
        defaults.object(forKey: Self.settingKey) as? Bool ?? true
    }

    /// Whether iOS allows this app's Live Activities (Settings › dubdub › Live Activities).
    /// Kept current by `observeAuthorization()`; Settings shows it next to the app's toggle.
    private(set) var systemAllowsActivities = ActivityAuthorizationInfo().areActivitiesEnabled

    /// Follows system-level changes for the app's lifetime and re-syncs on each one, so
    /// turning Live Activities back on in iOS Settings restores today's activity.
    func observeAuthorization() async {
        for await enabled in ActivityAuthorizationInfo().activityEnablementUpdates {
            systemAllowsActivities = enabled
            await sync()
        }
    }

    // MARK: - Sync

    func sync(now: Date? = nil) async {
        let now = now ?? Self.currentDate
        let activities = Activity<ConferenceDayAttributes>.activities
        systemAllowsActivities = ActivityAuthorizationInfo().areActivitiesEnabled
        guard isEnabledInSettings, systemAllowsActivities else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }

        let context = container.mainContext
        await refreshStaleSchedules(context: context, now: now)
        let plans = plans(context: context, now: now)
        let attending = attendingIDs(context)

        // Already-ended activities linger in `activities` until dismissed; ending them again
        // would push their dismissal date back on every sync.
        for activity in activities where !matches(activity, plans) && activity.activityState != .ended && activity.activityState != .dismissed {
            await retire(activity, stillAttending: attending.contains(activity.attributes.conferenceID), now: now)
        }
        for plan in plans.values {
            await apply(plan, existing: activities.first { matches($0, plan) }, now: now)
        }
        scheduleBackgroundRefresh(for: Array(plans.values), now: now)
    }

    /// The clock. Debug builds accept a `-LiveAgendaNow 2026-10-07T08:30:00Z` launch argument
    /// to rehearse a conference day in the Simulator.
    private static var currentDate: Date {
        #if DEBUG
        if let override = UserDefaults.standard.string(forKey: "LiveAgendaNow"),
           let date = try? Date(override, strategy: .iso8601) {
            return date
        }
        #endif
        return .now
    }

    // MARK: - Planning

    /// One plan per attended conference that still has something on its agenda.
    private func plans(context: ModelContext, now: Date) -> [String: LiveAgendaPlan] {
        let attending = attendingIDs(context)
        guard !attending.isEmpty else { return [:] }

        let schedules = (try? context.fetch(FetchDescriptor<ConferenceSchedule>())) ?? []
        let favourites = (try? context.fetch(FetchDescriptor<FavouriteTalk>())) ?? []
        let conferences = (try? context.fetch(FetchDescriptor<Conference>())) ?? []
        let names = Dictionary(conferences.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })

        var plans: [String: LiveAgendaPlan] = [:]
        for cached in schedules where attending.contains(cached.conferenceID) {
            guard let schedule = cached.schedule else { continue }
            let favouriteIDs = Set(favourites.filter { $0.conferenceID == cached.conferenceID }.map(\.talkID))
            plans[cached.conferenceID] = LiveAgendaPlanner.plan(
                for: schedule,
                conferenceName: names[cached.conferenceID] ?? cached.conferenceID,
                favouriteTalkIDs: favouriteIDs,
                now: now
            )
        }
        return plans
    }

    /// Attended conferences need a fresh schedule even if the user never opened it.
    private func refreshStaleSchedules(context: ModelContext, now: Date) async {
        let attending = attendingIDs(context)
        let conferences = (try? context.fetch(FetchDescriptor<Conference>())) ?? []
        let cached = (try? context.fetch(FetchDescriptor<ConferenceSchedule>())) ?? []
        for conference in conferences where attending.contains(conference.id) && conference.hasSchedule && !conference.isPast {
            let fetchedAt = cached.first { $0.conferenceID == conference.id }?.fetchedAt
            guard fetchedAt.map({ now.timeIntervalSince($0) > Self.scheduleMaxAge }) ?? true else { continue }
            do {
                try await scheduleService().refreshCache(conferenceID: conference.id, into: context)
            } catch {
                logger.info("Schedule refresh for \(conference.id, privacy: .public) failed: \(error.localizedDescription)")
            }
        }
    }

    private func attendingIDs(_ context: ModelContext) -> Set<String> {
        Set(((try? context.fetch(FetchDescriptor<AttendingConference>())) ?? []).map(\.conferenceID))
    }

    // MARK: - Activities

    private func matches(_ activity: Activity<ConferenceDayAttributes>, _ plans: [String: LiveAgendaPlan]) -> Bool {
        plans[activity.attributes.conferenceID].map { matches(activity, $0) } ?? false
    }

    private func matches(_ activity: Activity<ConferenceDayAttributes>, _ plan: LiveAgendaPlan) -> Bool {
        activity.attributes == plan.attributes
            && [.active, .pending, .stale].contains(activity.activityState)
    }

    private func apply(_ plan: LiveAgendaPlan, existing: Activity<ConferenceDayAttributes>?, now: Date) async {
        let content = ActivityContent(
            state: plan.state(at: now),
            staleDate: plan.validUntil(at: now) ?? plan.endsAt
        )

        if now >= plan.startsAt {
            // The day is underway: update, or start right away (e.g. after the 8-hour cap
            // ended it, or the user swiped it away and reopened the app).
            if let existing {
                await existing.update(content)
            } else {
                request(plan, content: content, start: nil)
            }
            return
        }

        guard plan.startsAt.timeIntervalSince(now) <= Self.schedulingHorizon else { return }
        if let existing, Self.sameAgenda(existing.content.state, content.state) {
            return  // Already scheduled with this agenda.
        }
        // Not scheduled yet, or the agenda changed since: (re)schedule for the morning.
        if let existing {
            await existing.end(nil, dismissalPolicy: .immediate)
        }
        request(plan, content: content, start: plan.startsAt)
    }

    /// Equal apart from `asOf`, which changes on every sync.
    private static func sameAgenda(
        _ lhs: ConferenceDayAttributes.ContentState,
        _ rhs: ConferenceDayAttributes.ContentState
    ) -> Bool {
        lhs.current == rhs.current && lhs.next == rhs.next && lhs.after == rhs.after
    }

    private func request(_ plan: LiveAgendaPlan, content: ActivityContent<ConferenceDayAttributes.ContentState>, start: Date?) {
        do {
            if let start, let first = plan.items.first {
                let alert = AlertConfiguration(
                    title: "\(plan.attributes.conferenceName) · Day \(plan.attributes.dayNumber)",
                    body: "First up at \(ScheduleTimeFormat.time(first.startsAt, in: plan.attributes.timeZone)): \(first.title)",
                    sound: .default
                )
                _ = try Activity.request(
                    attributes: plan.attributes, content: content, pushType: nil,
                    style: .standard, alertConfiguration: alert, start: start
                )
            } else {
                _ = try Activity.request(attributes: plan.attributes, content: content, pushType: nil)
            }
        } catch {
            logger.error("Live Activity request failed: \(error.localizedDescription)")
        }
    }

    /// An activity that no longer matches a plan: its day is over, or the user stopped attending.
    private func retire(_ activity: Activity<ConferenceDayAttributes>, stillAttending: Bool, now: Date) async {
        let isSameDay = now < activity.attributes.dayStart.addingTimeInterval(24 * 60 * 60)
        guard stillAttending, isSameDay, activity.activityState != .pending else {
            await activity.end(nil, dismissalPolicy: .immediate)
            return
        }
        // Earlier today: leave "That's a wrap" up briefly.
        let wrap = ConferenceDayAttributes.ContentState(current: nil, next: nil, after: nil, asOf: now)
        await activity.end(
            ActivityContent(state: wrap, staleDate: nil),
            dismissalPolicy: .after(now.addingTimeInterval(Self.wrapDisplayTime))
        )
    }

    // MARK: - Background refresh

    /// Asks for a background run at the next moment the headline changes (or when the
    /// day's activity starts). Best effort: the system may run it later, or not at all.
    private func scheduleBackgroundRefresh(for plans: [LiveAgendaPlan], now: Date) {
        let nextChange = plans
            .compactMap { plan in now >= plan.startsAt ? plan.validUntil(at: now) : plan.startsAt }
            .filter { $0.timeIntervalSince(now) <= Self.schedulingHorizon }
            .min()
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.refreshTaskIdentifier)
        guard let nextChange else { return }

        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
        request.earliestBeginDate = nextChange
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Expected in the Simulator (.unavailable); not fatal anywhere.
            logger.info("Background refresh not scheduled: \(error.localizedDescription)")
        }
    }
}
