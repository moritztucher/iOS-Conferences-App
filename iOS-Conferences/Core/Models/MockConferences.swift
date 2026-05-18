import Foundation
import SwiftData

extension Conference {
    static var sample: Conference {
        Conference(
            id: "wwdc-2026",
            name: "WWDC 2026",
            startDate: Self.makeDate(2026, 6, 8),
            endDate: Self.makeDate(2026, 6, 12),
            locationName: "Cupertino, USA",
            mapQuery: "Apple Park, Cupertino, California",
            summary: "Apple's annual developer conference. Keynote, sessions, and labs covering the latest platforms.",
            websiteURLString: "https://developer.apple.com/wwdc/",
            logoURLString: "https://ui-avatars.com/api/?name=WW+DC&background=007AFF&color=fff&size=512&font-size=0.33&bold=true",
            tags: ["apple", "ios", "swift"]
        )
    }

    static var samples: [Conference] {
        [
            Conference(
                id: "swift-heroes-2026",
                name: "Swift Heroes",
                startDate: makeDate(2026, 4, 16),
                endDate: makeDate(2026, 4, 17),
                locationName: "Turin, Italy",
                mapQuery: "Turin, Italy",
                summary: "Swift and iOS community conference in northern Italy.",
                websiteURLString: "https://swiftheroes.com",
                logoURLString: "https://ui-avatars.com/api/?name=SH&background=E03E2F&color=fff&size=512&font-size=0.45&bold=true",
                tags: ["swift", "ios"]
            ),
            Conference(
                id: "tryswift-nyc-2026",
                name: "try! Swift NYC",
                startDate: makeDate(2026, 5, 22),
                endDate: makeDate(2026, 5, 23),
                locationName: "New York, USA",
                mapQuery: "New York, New York",
                summary: "Two-day Swift community conference in Manhattan.",
                websiteURLString: "https://www.tryswift.co",
                logoURLString: "https://ui-avatars.com/api/?name=tS&background=FF6F00&color=fff&size=512&font-size=0.45&bold=true",
                tags: ["swift", "ios"]
            ),
            sample,
            Conference(
                id: "serverside-swift-2026",
                name: "ServerSide.swift",
                startDate: makeDate(2026, 6, 18),
                endDate: makeDate(2026, 6, 19),
                locationName: "Online",
                mapQuery: nil,
                summary: "Server-side Swift talks and workshops.",
                websiteURLString: "https://www.serversideswift.info",
                logoURLString: "https://ui-avatars.com/api/?name=SS&background=2D8E3F&color=fff&size=512&font-size=0.45&bold=true",
                tags: ["swift", "server"]
            ),
            Conference(
                id: "ndc-london-2026",
                name: "NDC London",
                startDate: makeDate(2026, 1, 26),
                endDate: makeDate(2026, 1, 30),
                locationName: "London, UK",
                mapQuery: "London, United Kingdom",
                summary: "A general software conference with strong mobile and Apple-platform tracks.",
                websiteURLString: "https://ndclondon.com",
                logoURLString: "https://ui-avatars.com/api/?name=NDC&background=662D91&color=fff&size=512&font-size=0.40&bold=true",
                tags: ["general", "ios"]
            )
        ]
    }

    fileprivate static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}

@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([Conference.self, FavouriteConference.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        for conference in Conference.samples {
            context.insert(conference)
        }
        // Pre-favourite WWDC so the Favourites tab has something in previews.
        context.insert(FavouriteConference(conferenceID: "wwdc-2026"))
        return container
    }()
}
