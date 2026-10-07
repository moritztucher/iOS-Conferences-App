import XCTest
@testable import ConferenceKit

final class LiveAgendaTests: XCTestCase {
    // MARK: - Fixtures

    private let london = TimeZone(identifier: "Europe/London")!

    /// Venue-local wall-clock time on October `day`, 2026.
    private func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute)
        components.timeZone = london
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    private func item(_ id: String, from start: Date, minutes: Int = 45) -> AgendaItem {
        AgendaItem(id: id, title: id, roomName: "A", startsAt: start, endsAt: start.addingTimeInterval(TimeInterval(minutes * 60)))
    }

    private func session(_ id: String, _ start: Date, kind: SessionKind = .talk, minutes: Int = 45) -> ScheduleSession {
        ScheduleSession(id: id, kind: kind, title: id, roomID: "a", startsAt: start, endsAt: start.addingTimeInterval(TimeInterval(minutes * 60)))
    }

    /// Single track over three days; day 13 has only a break, so the agenda starts on day 14.
    private var schedule: Schedule {
        Schedule(
            conferenceID: "test-2026",
            timeZoneIdentifier: "Europe/London",
            updatedAt: at(1, 0),
            rooms: [ScheduleRoom(id: "a", name: "A")],
            sessions: [
                session("welcome-drinks", at(13, 18), kind: .social),
                session("d2-first", at(14, 9)),
                session("d2-last", at(14, 16)),
                session("d3-only", at(15, 10))
            ]
        )
    }

    private func state(_ current: AgendaItem?, _ next: AgendaItem?, _ after: AgendaItem?) -> ConferenceDayAttributes.ContentState {
        ConferenceDayAttributes.ContentState(current: current, next: next, after: after, asOf: at(14, 0))
    }

    // MARK: - LiveAgendaDisplay

    func test_display_runningTalk_headlinesItWithCountdownToEnd() {
        let talk = item("talk", from: at(14, 9)), next = item("next", from: at(14, 10))

        let sut = LiveAgendaDisplay(state: state(talk, next, nil), isStale: false)

        XCTAssertEqual(sut.phase, .inSession)
        XCTAssertEqual(sut.headline, talk)
        XCTAssertEqual(sut.upcoming, next)
        XCTAssertEqual(sut.countdownTarget, talk.endsAt)
    }

    func test_display_break_headlinesNextTalkWithCountdownToStart() {
        let next = item("next", from: at(14, 10)), after = item("after", from: at(14, 11))

        let sut = LiveAgendaDisplay(state: state(nil, next, after), isStale: false)

        XCTAssertEqual(sut.phase, .upNext)
        XCTAssertEqual(sut.headline, next)
        XCTAssertEqual(sut.upcoming, after)
        XCTAssertEqual(sut.countdownTarget, next.startsAt)
    }

    func test_display_staleRunningTalk_promotesNext() {
        let talk = item("talk", from: at(14, 9)), next = item("next", from: at(14, 10)), after = item("after", from: at(14, 11))

        let sut = LiveAgendaDisplay(state: state(talk, next, after), isStale: true)

        XCTAssertEqual(sut.phase, .upNext)
        XCTAssertEqual(sut.headline, next)
        XCTAssertEqual(sut.upcoming, after)
    }

    func test_display_staleBreak_treatsNextAsRunning() {
        let next = item("next", from: at(14, 10)), after = item("after", from: at(14, 11))

        let sut = LiveAgendaDisplay(state: state(nil, next, after), isStale: true)

        XCTAssertEqual(sut.phase, .inSession)
        XCTAssertEqual(sut.headline, next)
        XCTAssertEqual(sut.countdownTarget, next.endsAt)
    }

    func test_display_staleLastTalk_isFinished() {
        let talk = item("talk", from: at(14, 16))

        let sut = LiveAgendaDisplay(state: state(talk, nil, nil), isStale: true)

        XCTAssertEqual(sut.phase, .finished)
        XCTAssertNil(sut.headline)
        XCTAssertNil(sut.countdownTarget)
    }

    func test_display_emptyState_isFinished() {
        let sut = LiveAgendaDisplay(state: state(nil, nil, nil), isStale: false)

        XCTAssertEqual(sut.phase, .finished)
    }

    // MARK: - LiveAgendaPlanner

    func test_plan_beforeConference_isFirstDayWithAnAgenda() throws {
        let sut = try XCTUnwrap(LiveAgendaPlanner.plan(for: schedule, conferenceName: "Test", favouriteTalkIDs: [], now: at(12, 12)))

        XCTAssertEqual(sut.attributes.dayStart, at(14, 0))
        XCTAssertEqual(sut.attributes.dayNumber, 2, "Day 13 counts as day 1 even with nothing on the agenda")
        XCTAssertEqual(sut.items.map(\.id), ["d2-first", "d2-last"])
        XCTAssertEqual(sut.startsAt, at(14, 8, 45))
        XCTAssertEqual(sut.endsAt, at(14, 16, 45))
    }

    func test_plan_duringDay_staysOnThatDay() throws {
        let sut = try XCTUnwrap(LiveAgendaPlanner.plan(for: schedule, conferenceName: "Test", favouriteTalkIDs: [], now: at(14, 12)))

        XCTAssertEqual(sut.attributes.dayStart, at(14, 0))
        XCTAssertEqual(sut.state(at: at(14, 12)).next?.id, "d2-last")
        XCTAssertEqual(sut.validUntil(at: at(14, 12)), at(14, 16))
    }

    func test_plan_afterDaysLastTalk_movesToNextDay() throws {
        let sut = try XCTUnwrap(LiveAgendaPlanner.plan(for: schedule, conferenceName: "Test", favouriteTalkIDs: [], now: at(14, 17)))

        XCTAssertEqual(sut.attributes.dayStart, at(15, 0))
        XCTAssertEqual(sut.attributes.dayNumber, 3)
    }

    func test_plan_afterConference_isNil() {
        XCTAssertNil(LiveAgendaPlanner.plan(for: schedule, conferenceName: "Test", favouriteTalkIDs: [], now: at(16, 9)))
    }

    func test_plan_multiTrackWithoutFavourites_isNil() {
        let multi = Schedule(
            conferenceID: "m", timeZoneIdentifier: "Europe/London", updatedAt: at(1, 0),
            rooms: [ScheduleRoom(id: "a", name: "A"), ScheduleRoom(id: "b", name: "B")],
            sessions: [session("x", at(14, 9))]
        )

        XCTAssertNil(LiveAgendaPlanner.plan(for: multi, conferenceName: "M", favouriteTalkIDs: [], now: at(12, 0)))
    }

    // MARK: - ContentState

    func test_contentState_staysWellUnderActivityKitLimit() throws {
        let long = String(repeating: "Swift Concurrency in Practice ", count: 6)
        let item = AgendaItem(id: "x", title: long, roomName: long, startsAt: at(14, 9), endsAt: at(14, 10))
        let state = ConferenceDayAttributes.ContentState(current: item, next: item, after: item, asOf: at(14, 9))

        XCTAssertLessThan(try JSONEncoder().encode(state).count, 4096 / 2)
    }

    // MARK: - ScheduleTimeFormat

    func test_time_isVenueWallClock() {
        let formatted = ScheduleTimeFormat.time(at(14, 9, 30), in: london)

        XCTAssertTrue(formatted.contains("9:30") || formatted.contains("09:30"), formatted)
    }
}
