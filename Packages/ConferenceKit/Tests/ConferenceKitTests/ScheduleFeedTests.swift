import XCTest
@testable import ConferenceKit

final class ScheduleFeedTests: XCTestCase {
    private func feed(timeZone: String = "Europe/London", rooms: String = #"[{"id":"a","name":"A"}]"#, sessions: String) -> Data {
        Data("""
        {"conferenceId":"test-2026","timeZone":"\(timeZone)","updatedAt":"2026-10-01T12:00:00Z",
         "rooms":\(rooms),"sessions":\(sessions)}
        """.utf8)
    }

    private func utc(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    // MARK: - Times & zones

    func test_decode_anchorsWallClockInVenueZone() throws {
        let data = feed(timeZone: "Asia/Tokyo", sessions: """
        [{"id":"test-2026-1","kind":"talk","day":"2026-10-13","start":"09:00","end":"09:45","title":"T","roomId":"a"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertEqual(sut.sessions.first?.startsAt, utc("2026-10-13T00:00:00Z"))
        XCTAssertEqual(sut.sessions.first?.endsAt, utc("2026-10-13T00:45:00Z"))
    }

    func test_decode_acrossDaylightSavingChange_usesEachDaysOffset() throws {
        // Europe/London leaves BST (UTC+1) on 2026-10-25.
        let data = feed(sessions: """
        [{"id":"test-2026-1","kind":"talk","day":"2026-10-24","start":"09:00","end":"09:45","title":"Sat"},
         {"id":"test-2026-2","kind":"talk","day":"2026-10-25","start":"09:00","end":"09:45","title":"Sun"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertEqual(sut.sessions.map(\.startsAt), [utc("2026-10-24T08:00:00Z"), utc("2026-10-25T09:00:00Z")])
    }

    func test_decode_invalidTimeZone_throws() {
        let data = feed(timeZone: "Mars/Olympus_Mons", sessions: "[]")

        XCTAssertThrowsError(try ScheduleFeed.decode(data)) { error in
            XCTAssertEqual(error as? ScheduleFeed.DecodingError, .invalidTimeZone("Mars/Olympus_Mons"))
        }
    }

    // MARK: - Leniency

    func test_decode_malformedSessions_areDroppedNotFatal() throws {
        let data = feed(sessions: """
        [{"id":"test-2026-ok","kind":"talk","day":"2026-10-13","start":"09:00","end":"09:45","title":"OK"},
         {"id":"test-2026-bad-time","kind":"talk","day":"2026-10-13","start":"9am","end":"09:45","title":"X"},
         {"id":"test-2026-backwards","kind":"talk","day":"2026-10-13","start":"10:00","end":"09:00","title":"X"},
         {"id":"test-2026-no-title","kind":"talk","day":"2026-10-13","start":"10:00","end":"11:00"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertEqual(sut.sessions.map(\.id), ["test-2026-ok"])
    }

    func test_decode_unknownKind_readsAsTalk() throws {
        let data = feed(sessions: """
        [{"id":"test-2026-1","kind":"panel","day":"2026-10-13","start":"09:00","end":"09:45","title":"Panel"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertEqual(sut.sessions.first?.kind, .talk)
    }

    func test_decode_nonHTTPSURL_isDropped() throws {
        let data = feed(sessions: """
        [{"id":"test-2026-1","kind":"talk","day":"2026-10-13","start":"09:00","end":"09:45","title":"T",
          "url":"http://example.com/talk"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertNil(sut.sessions.first?.url)
    }

    func test_decode_sortsByStartThenRoomOrder() throws {
        let data = feed(rooms: #"[{"id":"a","name":"A"},{"id":"b","name":"B"}]"#, sessions: """
        [{"id":"test-2026-late","kind":"talk","day":"2026-10-13","start":"10:00","end":"10:45","title":"L","roomId":"a"},
         {"id":"test-2026-b","kind":"talk","day":"2026-10-13","start":"09:00","end":"09:45","title":"B","roomId":"b"},
         {"id":"test-2026-a","kind":"talk","day":"2026-10-13","start":"09:00","end":"09:45","title":"A","roomId":"a"}]
        """)

        let sut = try ScheduleFeed.decode(data)

        XCTAssertEqual(sut.sessions.map(\.id), ["test-2026-a", "test-2026-b", "test-2026-late"])
        XCTAssertFalse(sut.isSingleTrack)
    }

    // MARK: - Seeded repo data

    /// The schedules in `data/schedules/` must decode without dropping a single session:
    /// a drop here means the app and `validate_schedules.py` disagree about the schema.
    func test_decode_seededSchedules_decodeCompletely() throws {
        let schedules = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // ConferenceKitTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // ConferenceKit
            .deletingLastPathComponent()  // Packages
            .deletingLastPathComponent()  // repo root
            .appending(path: "data/schedules")
        let files = try FileManager.default.contentsOfDirectory(at: schedules, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
        XCTAssertFalse(files.isEmpty)

        for file in files {
            let data = try Data(contentsOf: file)
            let rawCount = try XCTUnwrap(
                (try JSONSerialization.jsonObject(with: data) as? [String: Any])?["sessions"] as? [Any]
            ).count

            let sut = try ScheduleFeed.decode(data)

            XCTAssertEqual(sut.sessions.count, rawCount, file.lastPathComponent)
            XCTAssertEqual(sut.conferenceID, file.deletingPathExtension().lastPathComponent)
        }
    }
}
