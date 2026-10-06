import ConferenceKit
import SwiftData
import XCTest
@testable import iOS_Conferences

@MainActor
final class ConferenceScheduleViewModelTests: XCTestCase {
    // MARK: - Fixtures

    private struct StubScheduleService: ScheduleServiceProtocol {
        var result: Result<Schedule, Error>

        func fetchSchedule(conferenceID: String) async throws -> Schedule {
            try result.get()
        }
    }

    private let london = TimeZone(identifier: "Europe/London")!

    /// Venue-local wall-clock time, e.g. `at(13, 9, 30)` = 13 Oct 2026, 09:30 in London.
    private func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute)
        components.timeZone = london
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    private func session(
        _ id: String,
        _ kind: SessionKind = .talk,
        day: Int,
        _ hour: Int,
        _ minute: Int = 0,
        minutes: Int = 45,
        room: String? = "a"
    ) -> ScheduleSession {
        let start = at(day, hour, minute)
        return ScheduleSession(
            id: id, kind: kind, title: id, roomID: room,
            startsAt: start, endsAt: start.addingTimeInterval(TimeInterval(minutes * 60))
        )
    }

    /// Two days, two rooms. Day 13: a1 + b1 09:00–09:45, coffee 09:45–10:05, a2 10:15–11:00.
    /// Day 14: a3 at 09:00.
    private var schedule: Schedule {
        Schedule(
            conferenceID: "test-2026",
            timeZoneIdentifier: "Europe/London",
            updatedAt: at(1, 0),
            rooms: [ScheduleRoom(id: "a", name: "A"), ScheduleRoom(id: "b", name: "B")],
            sessions: [
                session("a1", day: 13, 9),
                session("b1", day: 13, 9, room: "b"),
                session("coffee", .break, day: 13, 9, 45, minutes: 20, room: nil),
                session("a2", day: 13, 10, 15),
                session("a3", day: 14, 9)
            ]
        )
    }

    private func makeSUT(service: StubScheduleService? = nil) -> ConferenceScheduleViewModel {
        ConferenceScheduleViewModel(conferenceID: "test-2026", service: service)
    }

    // MARK: - Days

    func test_days_areVenueMidnightsInOrder() {
        let sut = makeSUT()

        XCTAssertEqual(sut.days(in: schedule), [at(13, 0), at(14, 0)])
    }

    func test_selectDefaultDay_duringConference_picksToday() {
        let sut = makeSUT()

        sut.selectDefaultDayIfNeeded(in: schedule, now: at(14, 11))

        XCTAssertEqual(sut.selectedDay, at(14, 0))
    }

    func test_selectDefaultDay_beforeConference_picksFirstDay() {
        let sut = makeSUT()

        sut.selectDefaultDayIfNeeded(in: schedule, now: at(1, 12))

        XCTAssertEqual(sut.selectedDay, at(13, 0))
    }

    func test_selectDefaultDay_keepsAValidSelection() {
        let sut = makeSUT()
        sut.selectedDay = at(14, 0)

        sut.selectDefaultDayIfNeeded(in: schedule, now: at(13, 9))

        XCTAssertEqual(sut.selectedDay, at(14, 0))
    }

    // MARK: - Slots

    func test_slots_groupParallelSessionsByStart() {
        let sut = makeSUT()
        sut.selectedDay = at(13, 0)

        let slots = sut.slots(in: schedule, favouriteTalkIDs: [])

        XCTAssertEqual(slots.map { $0.sessions.map(\.id) }, [["a1", "b1"], ["coffee"], ["a2"]])
    }

    func test_slots_myAgenda_keepsOnlyFavouritedTalks() {
        let sut = makeSUT()
        sut.selectedDay = at(13, 0)
        sut.filter = .myAgenda

        let slots = sut.slots(in: schedule, favouriteTalkIDs: ["b1", "coffee", "a3"])

        XCTAssertEqual(slots.flatMap { $0.sessions.map(\.id) }, ["b1"])
    }

    func test_focusSlot_duringSlot_isTheLiveSlot() {
        let sut = makeSUT()
        sut.selectedDay = at(13, 0)
        let slots = sut.slots(in: schedule, favouriteTalkIDs: [])

        XCTAssertEqual(sut.focusSlotID(in: slots, now: at(13, 9, 50)), at(13, 9, 45))
    }

    func test_focusSlot_betweenSlots_isTheNextSlot() {
        let sut = makeSUT()
        sut.selectedDay = at(13, 0)
        let slots = sut.slots(in: schedule, favouriteTalkIDs: [])

        XCTAssertEqual(sut.focusSlotID(in: slots, now: at(13, 10, 10)), at(13, 10, 15))
    }

    // MARK: - Favourites

    func test_canFavourite_onlyTalksOnMultiTrack() {
        let sut = makeSUT()
        let single = Schedule(
            conferenceID: "s", timeZoneIdentifier: "Europe/London", updatedAt: .now,
            rooms: [ScheduleRoom(id: "a", name: "A")], sessions: []
        )

        XCTAssertTrue(sut.canFavourite(session("a1", day: 13, 9), in: schedule))
        XCTAssertFalse(sut.canFavourite(session("coffee", .break, day: 13, 9), in: schedule))
        XCTAssertFalse(sut.canFavourite(session("a1", day: 13, 9), in: single))
    }

    func test_toggleFavourite_insertsThenRemoves() throws {
        let container = try ModelContainer(
            for: FavouriteTalk.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let sut = makeSUT()
        let talk = session("a1", day: 13, 9)

        sut.toggleFavourite(talk, in: [], context: context)
        let afterAdd = try context.fetch(FetchDescriptor<FavouriteTalk>())
        XCTAssertEqual(afterAdd.map(\.talkID), ["a1"])
        XCTAssertEqual(afterAdd.first?.conferenceID, "test-2026")

        sut.toggleFavourite(talk, in: afterAdd, context: context)
        XCTAssertTrue(try context.fetch(FetchDescriptor<FavouriteTalk>()).isEmpty)
    }

    // MARK: - Refresh

    func test_refresh_failureWithoutCache_surfacesError() async throws {
        let container = try ModelContainer(
            for: ConferenceSchedule.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let sut = makeSUT(service: StubScheduleService(result: .failure(ScheduleServiceError.unavailable)))

        await sut.refresh(context: container.mainContext, hasCachedSchedule: false)

        XCTAssertEqual(sut.loadError, ScheduleServiceError.unavailable.errorDescription)
        XCTAssertFalse(sut.isRefreshing)
    }

    func test_refresh_failureWithCache_staysSilent() async throws {
        let container = try ModelContainer(
            for: ConferenceSchedule.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let sut = makeSUT(service: StubScheduleService(result: .failure(ScheduleServiceError.unavailable)))

        await sut.refresh(context: container.mainContext, hasCachedSchedule: true)

        XCTAssertNil(sut.loadError)
    }

    func test_refresh_success_cachesSchedule() async throws {
        let container = try ModelContainer(
            for: ConferenceSchedule.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let sut = makeSUT(service: StubScheduleService(result: .success(schedule)))

        await sut.refresh(context: container.mainContext, hasCachedSchedule: false)

        let cached = try container.mainContext.fetch(FetchDescriptor<ConferenceSchedule>())
        XCTAssertEqual(cached.first?.schedule, schedule)
        XCTAssertNil(sut.loadError)
    }
}
