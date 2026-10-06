import XCTest
@testable import ConferenceKit

final class AgendaResolverTests: XCTestCase {
    // MARK: - Fixtures

    /// 2026-10-13 in UTC; offsets below are minutes from 09:00.
    private let base = Date(timeIntervalSince1970: 1_791_882_000)

    private func at(_ minutes: Int) -> Date {
        base.addingTimeInterval(TimeInterval(minutes * 60))
    }

    private func session(
        _ id: String,
        _ kind: SessionKind = .talk,
        from start: Int,
        to end: Int,
        room: String? = "a"
    ) -> ScheduleSession {
        ScheduleSession(id: id, kind: kind, title: id, roomID: room, startsAt: at(start), endsAt: at(end))
    }

    private func schedule(rooms: [String], _ sessions: [ScheduleSession]) -> Schedule {
        Schedule(
            conferenceID: "test",
            timeZoneIdentifier: "Europe/London",
            updatedAt: base,
            rooms: rooms.map { ScheduleRoom(id: $0, name: $0.uppercased()) },
            sessions: sessions
        )
    }

    /// Single track: talk1 0–45, coffee 45–75, talk2 75–120, talk3 120–150.
    private var singleTrack: Schedule {
        schedule(rooms: ["a"], [
            session("talk1", from: 0, to: 45),
            session("coffee", .break, from: 45, to: 75, room: nil),
            session("talk2", from: 75, to: 120),
            session("talk3", from: 120, to: 150)
        ])
    }

    /// Two tracks: a1/b1 at 0–45, a2/b2 at 60–105, a3 at 120–165.
    private var multiTrack: Schedule {
        schedule(rooms: ["a", "b"], [
            session("a1", from: 0, to: 45, room: "a"),
            session("b1", from: 0, to: 45, room: "b"),
            session("a2", from: 60, to: 105, room: "a"),
            session("b2", from: 60, to: 105, room: "b"),
            session("a3", from: 120, to: 165, room: "a")
        ])
    }

    private func snapshotIDs(_ snapshot: AgendaSnapshot) -> [String?] {
        [snapshot.current?.id, snapshot.next?.id, snapshot.after?.id]
    }

    // MARK: - agenda(for:favouriteTalkIDs:)

    func test_agenda_singleTrack_includesEveryTalkAndIgnoresFavourites() {
        let sut = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: ["talk2"])

        XCTAssertEqual(sut.map(\.id), ["talk1", "talk2", "talk3"])
    }

    func test_agenda_singleTrack_excludesBreaksAndSocials() {
        let schedule = schedule(rooms: ["a"], [
            session("talk", from: 0, to: 45),
            session("lunch", .break, from: 45, to: 90),
            session("party", .social, from: 90, to: 200)
        ])

        let sut = AgendaResolver.agenda(for: schedule, favouriteTalkIDs: [])

        XCTAssertEqual(sut.map(\.id), ["talk"])
    }

    func test_agenda_multiTrack_includesOnlyFavourites() {
        let sut = AgendaResolver.agenda(for: multiTrack, favouriteTalkIDs: ["b1", "a3"])

        XCTAssertEqual(sut.map(\.id), ["b1", "a3"])
    }

    func test_agenda_multiTrack_noFavourites_isEmpty() {
        let sut = AgendaResolver.agenda(for: multiTrack, favouriteTalkIDs: [])

        XCTAssertTrue(sut.isEmpty)
    }

    func test_agenda_overlappingFavourites_keepsEarlierRoomOnTie() {
        let sut = AgendaResolver.agenda(for: multiTrack, favouriteTalkIDs: ["a1", "b1", "b2"])

        XCTAssertEqual(sut.map(\.id), ["a1", "b2"])
    }

    func test_agenda_overlappingFavourites_keepsEarlierStart() {
        let schedule = schedule(rooms: ["a", "b"], [
            session("long", from: 0, to: 90, room: "b"),
            session("short", from: 30, to: 60, room: "a")
        ])

        let sut = AgendaResolver.agenda(for: schedule, favouriteTalkIDs: ["long", "short"])

        XCTAssertEqual(sut.map(\.id), ["long"])
    }

    func test_agenda_resolvesRoomName() {
        let sut = AgendaResolver.agenda(for: multiTrack, favouriteTalkIDs: ["b1"])

        XCTAssertEqual(sut.first?.roomName, "B")
    }

    // MARK: - conflictingFavourites(in:favouriteTalkIDs:)

    func test_conflictingFavourites_flagsBothSidesOfAnOverlap() {
        let sut = AgendaResolver.conflictingFavourites(in: multiTrack, favouriteTalkIDs: ["a1", "b1", "a3"])

        XCTAssertEqual(sut, ["a1", "b1"])
    }

    func test_conflictingFavourites_backToBack_isNotAConflict() {
        let schedule = schedule(rooms: ["a", "b"], [
            session("first", from: 0, to: 45, room: "a"),
            session("second", from: 45, to: 90, room: "b")
        ])

        let sut = AgendaResolver.conflictingFavourites(in: schedule, favouriteTalkIDs: ["first", "second"])

        XCTAssertTrue(sut.isEmpty)
    }

    // MARK: - snapshot(of:at:)

    func test_snapshot_beforeFirstTalk_headlinesFirstTalk() {
        let agenda = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(-30))

        XCTAssertEqual(snapshotIDs(sut), [nil, "talk1", "talk2"])
        XCTAssertEqual(sut.headline?.id, "talk1")
        XCTAssertEqual(sut.upcoming?.id, "talk2")
        XCTAssertEqual(sut.validUntil, at(0))
    }

    func test_snapshot_duringTalk_headlinesCurrentTalk() {
        let agenda = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(20))

        XCTAssertEqual(snapshotIDs(sut), ["talk1", "talk2", "talk3"])
        XCTAssertEqual(sut.headline?.id, "talk1")
        XCTAssertEqual(sut.upcoming?.id, "talk2")
        XCTAssertEqual(sut.validUntil, at(45))
    }

    func test_snapshot_duringBreak_headlinesNextTalk() {
        let agenda = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(50))

        XCTAssertEqual(snapshotIDs(sut), [nil, "talk2", "talk3"])
        XCTAssertEqual(sut.headline?.id, "talk2")
        XCTAssertEqual(sut.upcoming?.id, "talk3")
        XCTAssertEqual(sut.validUntil, at(75))
    }

    func test_snapshot_exactBoundary_switchesToTheStartingTalk() {
        let agenda = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(120))

        XCTAssertEqual(snapshotIDs(sut), ["talk3", nil, nil])
    }

    func test_snapshot_multiTrackGap_treatedAsFreeTime() {
        let agenda = AgendaResolver.agenda(for: multiTrack, favouriteTalkIDs: ["a1", "a3"])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(70))

        XCTAssertEqual(snapshotIDs(sut), [nil, "a3", nil])
        XCTAssertEqual(sut.headline?.id, "a3")
    }

    func test_snapshot_afterLastTalk_isFinished() {
        let agenda = AgendaResolver.agenda(for: singleTrack, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(150))

        XCTAssertTrue(sut.isFinished)
        XCTAssertNil(sut.headline)
        XCTAssertNil(sut.validUntil)
    }

    func test_snapshot_emptyAgenda_isFinished() {
        let sut = AgendaResolver.snapshot(of: [], at: base)

        XCTAssertTrue(sut.isFinished)
    }

    func test_snapshot_afterDaysLastTalk_headlinesTomorrowsFirstTalk() {
        let schedule = schedule(rooms: ["a"], [
            session("day1-last", from: 0, to: 45),
            session("day2-first", from: 24 * 60, to: 24 * 60 + 45)
        ])
        let agenda = AgendaResolver.agenda(for: schedule, favouriteTalkIDs: [])

        let sut = AgendaResolver.snapshot(of: agenda, at: at(300))

        XCTAssertEqual(sut.headline?.id, "day2-first")
    }
}
