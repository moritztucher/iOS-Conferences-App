import ConferenceKit
import SwiftData
import SwiftUI

/// The schedule's entry point on the conference detail screen (ADR-0009): a glass card
/// with the next few sessions and a link to the full schedule. When the user is attending,
/// "next" means their own agenda; otherwise it's every upcoming talk, with parallel tracks
/// side by side. Owns its queries and refresh, so the detail screen only decides whether
/// to show it (`Conference.hasSchedule`).
struct ScheduleUpNextCard: View {
    let conference: Conference

    @Environment(\.modelContext) private var modelContext
    @Query private var cachedSchedules: [ConferenceSchedule]
    @Query private var favouriteTalks: [FavouriteTalk]
    @Query private var attending: [AttendingConference]

    private static let previewLimit = 3

    init(conference: Conference) {
        self.conference = conference
        let id = conference.id
        _cachedSchedules = Query(filter: #Predicate<ConferenceSchedule> { $0.conferenceID == id })
        _favouriteTalks = Query(filter: #Predicate<FavouriteTalk> { $0.conferenceID == id })
        _attending = Query(filter: #Predicate<AttendingConference> { $0.conferenceID == id })
    }

    private var schedule: Schedule? { cachedSchedules.first?.schedule }

    var body: some View {
        TimelineView(.everyMinute) { timeline in
            let items = upcomingItems(at: timeline.date)
            GlassSectionCard(title: items.isEmpty ? "Schedule" : "Up Next") {
                if let schedule {
                    if items.isEmpty {
                        Text(emptyMessage(for: schedule, now: timeline.date))
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(items) { item in
                                itemRow(item, timeZone: schedule.timeZone, now: timeline.date)
                            }
                        }
                    }
                } else {
                    Text("Loading the schedule…")
                        .foregroundStyle(.secondary)
                }
                NavigationLink(value: Route.conferenceSchedule(conferenceID: conference.id)) {
                    Label("Full Schedule", systemImage: "list.bullet.rectangle.portrait")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(.top, 2)
            }
        }
        .task(id: conference.id) {
            // Silent: the full schedule screen surfaces errors; the card just shows what's cached.
            _ = try? await ScheduleServiceFactory.make().refreshCache(conferenceID: conference.id, into: modelContext)
        }
    }

    // MARK: - Content

    private func upcomingItems(at now: Date) -> [AgendaItem] {
        guard let schedule else { return [] }
        let items = attending.isEmpty
            ? AgendaResolver.allTalks(in: schedule)
            : AgendaResolver.agenda(for: schedule, favouriteTalkIDs: Set(favouriteTalks.map(\.talkID)))
        return AgendaResolver.upcoming(items, at: now, limit: Self.previewLimit)
    }

    private func emptyMessage(for schedule: Schedule, now: Date) -> String {
        if let last = schedule.sessions.last, last.endsAt <= now {
            return "That's a wrap. Browse every session from the conference."
        }
        if !attending.isEmpty && !schedule.isSingleTrack {
            return "Heart the talks you want to see and they'll show up here."
        }
        return "Browse every session, day by day."
    }

    private func itemRow(_ item: AgendaItem, timeZone: TimeZone, now: Date) -> some View {
        let isLive = item.startsAt <= now && now < item.endsAt
        let time = ConferenceDateStyle.sessionTime(item.startsAt, in: timeZone)
        return HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(isLive ? "NOW" : time)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(isLive ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .frame(minWidth: 52, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                if let roomName = item.roomName, !(schedule?.isSingleTrack ?? true) {
                    Text(roomName)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [isLive ? "Happening now" : time, item.title, schedule?.isSingleTrack == false ? item.roomName : nil]
                .compactMap(\.self)
                .joined(separator: ", ")
        )
    }
}
