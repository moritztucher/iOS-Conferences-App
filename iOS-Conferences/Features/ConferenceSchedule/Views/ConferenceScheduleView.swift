import ConferenceKit
import SwiftData
import SwiftUI

/// A conference's full talk schedule (ADR-0009): a day picker, then the day's sessions
/// grouped by start time, with a "Now" marker during the event. On multi-track conferences
/// talks can be hearted, and "My Agenda" narrows the list to them. Overlapping favourites
/// are flagged. Times are always the venue's, as the organiser published them.
struct ConferenceScheduleView: View {
    let conference: Conference

    @Environment(\.modelContext) private var modelContext
    @Environment(LiveAgendaManager.self) private var liveAgenda
    @Query private var cachedSchedules: [ConferenceSchedule]
    @Query private var favouriteTalks: [FavouriteTalk]
    @Query private var attending: [AttendingConference]

    @State private var viewModel: ConferenceScheduleViewModel
    @State private var favouriteTrigger = 0

    init(conference: Conference) {
        self.conference = conference
        let id = conference.id
        _cachedSchedules = Query(filter: #Predicate<ConferenceSchedule> { $0.conferenceID == id })
        _favouriteTalks = Query(filter: #Predicate<FavouriteTalk> { $0.conferenceID == id })
        _attending = Query(filter: #Predicate<AttendingConference> { $0.conferenceID == id })
        _viewModel = State(initialValue: ConferenceScheduleViewModel(conferenceID: id))
    }

    private var schedule: Schedule? { cachedSchedules.first?.schedule }
    private var favouriteTalkIDs: Set<String> { Set(favouriteTalks.map(\.talkID)) }
    private var isAttending: Bool { !attending.isEmpty }

    var body: some View {
        Group {
            if let schedule {
                scheduleContent(schedule)
            } else if viewModel.isRefreshing {
                ProgressView("Loading schedule…")
            } else {
                ContentUnavailableView(
                    "No Schedule Yet",
                    systemImage: "calendar.badge.clock",
                    description: Text(viewModel.loadError ?? "The talk schedule hasn't been published.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .brandBackground()
        .navigationTitle("Schedule")
        .navigationSubtitle(conference.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task { await viewModel.refresh(context: modelContext, hasCachedSchedule: schedule != nil) }
        .onChange(of: schedule, initial: true) { _, schedule in
            if let schedule { viewModel.selectDefaultDayIfNeeded(in: schedule) }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: favouriteTrigger)
    }

    // MARK: - Content

    private func scheduleContent(_ schedule: Schedule) -> some View {
        // Ticks once a minute so the "Now" marker moves without any update logic.
        TimelineView(.everyMinute) { timeline in
            let slots = viewModel.slots(in: schedule, favouriteTalkIDs: favouriteTalkIDs)
            let conflicts = AgendaResolver.conflictingFavourites(in: schedule, favouriteTalkIDs: favouriteTalkIDs)
            ScrollViewReader { proxy in
                List {
                    notes(for: schedule, now: timeline.date)
                    ForEach(slots) { slot in
                        Section {
                            ForEach(slot.sessions) { session in
                                row(for: session, in: schedule, conflicts: conflicts)
                            }
                        } header: {
                            SlotHeader(
                                time: ConferenceDateStyle.sessionTime(slot.startsAt, in: schedule.timeZone),
                                isLive: slot.isLive(at: timeline.date)
                            )
                        }
                        .id(slot.id)
                    }
                }
                .scrollContentBackground(.hidden)
                .overlay {
                    if slots.isEmpty && viewModel.filter == .myAgenda {
                        ContentUnavailableView(
                            "No Favourite Talks",
                            systemImage: "heart",
                            description: Text("Tap the heart on the talks you want to see.")
                        )
                    }
                }
                .refreshable { await viewModel.refresh(context: modelContext, hasCachedSchedule: true) }
                .safeAreaBar(edge: .top) { dayPicker(for: schedule) }
                .task(id: viewModel.selectedDay) {
                    // Only jump while the shown day is underway; otherwise start at the top.
                    guard let first = slots.first, first.startsAt <= .now,
                          let focus = viewModel.focusSlotID(in: slots, now: .now) else { return }
                    proxy.scrollTo(focus, anchor: .top)
                }
            }
        }
    }

    @ViewBuilder
    private func notes(for schedule: Schedule, now: Date) -> some View {
        let zoneNote = ConferenceDateStyle.venueZoneNote(schedule.timeZone, at: now)
        let singleTrackNote = schedule.isSingleTrack && isAttending
        if zoneNote != nil || singleTrackNote {
            Section {
                if let zoneNote {
                    Label("Times are in venue time (\(zoneNote)).", systemImage: "globe")
                }
                if singleTrackNote {
                    Label("One stage, so every talk is on your agenda.", systemImage: "checkmark.circle")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .listRowBackground(Color.clear)
        }
    }

    private func row(for session: ScheduleSession, in schedule: Schedule, conflicts: Set<String>) -> some View {
        SessionRow(
            session: session,
            roomName: schedule.isSingleTrack ? nil : schedule.room(withID: session.roomID)?.name,
            timeZone: schedule.timeZone,
            isFavourite: favouriteTalkIDs.contains(session.id),
            showsFavouriteButton: viewModel.canFavourite(session, in: schedule),
            hasConflict: conflicts.contains(session.id),
            onToggleFavourite: {
                viewModel.toggleFavourite(session, in: favouriteTalks, context: modelContext)
                favouriteTrigger += 1
                Task { await liveAgenda.sync() }
            }
        )
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private func dayPicker(for schedule: Schedule) -> some View {
        let days = viewModel.days(in: schedule)
        if days.count > 1 {
            @Bindable var bindable = viewModel
            Picker("Day", selection: $bindable.selectedDay) {
                ForEach(days, id: \.self) { day in
                    Text(ConferenceDateStyle.scheduleDay(day, in: schedule.timeZone))
                        .accessibilityLabel(ConferenceDateStyle.scheduleDayLong(day, in: schedule.timeZone))
                        .tag(Optional(day))
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if let schedule, !schedule.isSingleTrack {
            ToolbarItem(placement: .topBarTrailing) {
                @Bindable var bindable = viewModel
                Menu {
                    Picker("Show", selection: $bindable.filter) {
                        ForEach(ConferenceScheduleViewModel.Filter.allCases) { filter in
                            Label(filter.label, systemImage: filter.systemImage).tag(filter)
                        }
                    }
                } label: {
                    Image(systemName: viewModel.filter == .myAgenda
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
                .accessibilityLabel("Filter sessions")
            }
        }
    }
}

/// The start time over each slot, with a marigold "NOW" capsule while it's running.
private struct SlotHeader: View {
    let time: String
    let isLive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(time)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.primary)
            if isLive {
                Text("NOW")
                    .font(.caption2.weight(.heavy))
                    .tracking(Theme.eyebrowTracking)
                    .foregroundStyle(.black.opacity(0.85))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Theme.accent, in: .capsule)
            }
        }
        .textCase(nil)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isLive ? "\(time), happening now" : time)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    NavigationStack {
        ConferenceScheduleView(conference: Conference.bundled.first { $0.id == "swiftleeds-2026" }!)
    }
    .modelContainer(PreviewContainer.shared)
    .environment(LiveAgendaManager.preview)
}
