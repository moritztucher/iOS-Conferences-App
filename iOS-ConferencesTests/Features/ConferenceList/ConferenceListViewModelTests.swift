import XCTest
@testable import iOS_Conferences

@MainActor
final class ConferenceListViewModelTests: XCTestCase {
    // MARK: - Fixtures

    private func conference(_ id: String, month: Int, day: Int) -> Conference {
        var components = DateComponents(year: 2099, month: month, day: day)
        components.timeZone = TimeZone(identifier: "UTC")
        let date = Calendar(identifier: .gregorian).date(from: components)!
        return Conference(
            id: id, name: id, startDate: date, endDate: date,
            locationName: "Leeds, UK", mapQuery: "Leeds, UK",
            summary: "", websiteURLString: "https://example.com", tags: []
        )
    }

    private var conferences: [Conference] {
        [
            conference("oct-a", month: 10, day: 13),
            conference("oct-b", month: 10, day: 20),
            conference("nov-a", month: 11, day: 2)
        ]
    }

    private func ids(_ section: ConferenceMonthSection) -> [String] {
        section.groups.flatMap(\.conferences).map(\.id)
    }

    // MARK: - Attending section (ADR-0009)

    func test_sections_favourites_pinsAttendingFirst() {
        let sut = ConferenceListViewModel(filter: .favourites)

        let sections = sut.sections(
            from: conferences, favouriteIDs: ["oct-a", "nov-a"], attendingIDs: ["nov-a"], showPast: false
        )

        XCTAssertEqual(sections.first?.id, "attending")
        XCTAssertEqual(sections.first.map(ids), ["nov-a"])
        XCTAssertFalse(sections.first?.showsTypeHeaders ?? true)
    }

    func test_sections_favourites_attendingIsNotRepeatedInMonths() {
        let sut = ConferenceListViewModel(filter: .favourites)

        let sections = sut.sections(
            from: conferences, favouriteIDs: ["oct-a", "nov-a"], attendingIDs: ["nov-a"], showPast: false
        )

        XCTAssertEqual(sections.dropFirst().flatMap(ids), ["oct-a"])
    }

    func test_sections_favourites_showsAttendingEvenIfUnfavourited() {
        let sut = ConferenceListViewModel(filter: .favourites)

        let sections = sut.sections(from: conferences, favouriteIDs: [], attendingIDs: ["oct-b"], showPast: false)

        XCTAssertEqual(sections.map(\.id), ["attending"])
        XCTAssertEqual(sections.first.map(ids), ["oct-b"])
    }

    func test_sections_favourites_attendingSortedChronologically() {
        let sut = ConferenceListViewModel(filter: .favourites)

        let sections = sut.sections(
            from: conferences.reversed(), favouriteIDs: [], attendingIDs: ["nov-a", "oct-a"], showPast: false
        )

        XCTAssertEqual(sections.first.map(ids), ["oct-a", "nov-a"])
    }

    func test_sections_favourites_noAttending_hasNoPinnedSection() {
        let sut = ConferenceListViewModel(filter: .favourites)

        let sections = sut.sections(from: conferences, favouriteIDs: ["oct-a"], attendingIDs: [], showPast: false)

        XCTAssertFalse(sections.contains { $0.id == "attending" })
    }

    func test_sections_allConferences_neverPinsAttending() {
        let sut = ConferenceListViewModel(filter: .all)

        let sections = sut.sections(from: conferences, favouriteIDs: [], attendingIDs: ["oct-a"], showPast: false)

        XCTAssertFalse(sections.contains { $0.id == "attending" })
        XCTAssertEqual(sections.flatMap(ids), ["oct-a", "oct-b", "nov-a"])
    }
}
