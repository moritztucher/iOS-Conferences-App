import Foundation
import SwiftData

extension Conference {
    /// Representative conference used by SwiftUI previews.
    static var sample: Conference {
        bundled.first(where: { $0.id == "iosdevuk-2026" }) ?? bundled[0]
    }

    /// Real conferences shipped with the app. Seeds the SwiftData store on first launch.
    /// Source: project owner + per-site og:image fetches.
    ///
    /// Pending (see docs/Backlog.md): NextAppCon, NSSpain (2026 not announced), try! Swift x AI
    /// (single-edition past workshop), Pre-WWDC Bashcade (past), One More Thing (past).
    static var bundled: [Conference] {
        [
            Conference(
                id: "lets-vision-2026",
                kind: .conference,
                name: "LET'S VISION 2026",
                startDate: makeDate(2026, 3, 28),
                endDate: makeDate(2026, 3, 29),
                locationName: "Shanghai, China",
                mapQuery: "Caohejing Conference Center, Shanghai, China",
                summary: "Shanghai-based spatial computing and AI conference for Vision Pro, XR and Apple-platform developers and creators.",
                websiteURLString: "https://letsvision.swiftgg.team",
                logoURLString: "https://framerusercontent.com/images/djs5wcxx7xM76k9bupA6Tmfvc.png",
                tags: ["visionos", "ai", "swift"]
            ),
            Conference(
                id: "tryswift-tokyo-2026",
                kind: .conference,
                name: "try! Swift Tokyo",
                startDate: makeDate(2026, 4, 12),
                endDate: makeDate(2026, 4, 14),
                locationName: "Tokyo, Japan",
                mapQuery: "Tachikawa, Tokyo, Japan",
                summary: "Three-day Swift conference in Tokyo covering SwiftUI, concurrency, embedded Swift, server-side Swift and AI integration.",
                websiteURLString: "https://tryswift.jp",
                logoURLString: "https://tryswift.jp/images/ogp.jpg",
                tags: ["swift", "ios", "ai"]
            ),
            Conference(
                id: "deep-dish-swift-2026",
                kind: .conference,
                name: "Deep Dish Swift 2026",
                startDate: makeDate(2026, 4, 12),
                endDate: makeDate(2026, 4, 14),
                locationName: "Rosemont, Illinois, USA",
                mapQuery: "Loews Chicago O'Hare Hotel, Rosemont, Illinois",
                summary: "Chicago-area Swift developer conference featuring technical talks, indie dev sessions, and a live podcast recording across three days.",
                websiteURLString: "https://deepdishswift.com",
                logoURLString: "https://deepdishswift.com/assets/images/2026/deep-dish-logo.png",
                tags: ["swift", "ios", "community"]
            ),
            Conference(
                id: "ioskonf-2026",
                kind: .conference,
                name: "iOSKonf26",
                startDate: makeDate(2026, 5, 4),
                endDate: makeDate(2026, 5, 6),
                locationName: "Skopje, North Macedonia",
                mapQuery: "Philharmonic of the Republic of Macedonia, Skopje, North Macedonia",
                summary: "Premium iOS developer conference held at the Macedonian Philharmonic, drawing attendees from 18+ countries.",
                websiteURLString: "https://ioskonf.mk",
                logoURLString: "https://ioskonf.mk/assets/share-ticket.png",
                tags: ["ios", "swift", "community"]
            ),
            Conference(
                id: "wwdc-2026",
                kind: .conference,
                name: "WWDC 2026",
                startDate: makeDate(2026, 6, 8),
                endDate: makeDate(2026, 6, 12),
                locationName: "Cupertino, California, USA",
                mapQuery: "Apple Park, Cupertino, California",
                summary: "Apple's annual Worldwide Developers Conference. Keynote, Platforms State of the Union, sessions and labs covering all Apple platforms.",
                websiteURLString: "https://developer.apple.com/wwdc/",
                logoURLString: "https://developer.apple.com/apple-touch-icon.png",
                tags: ["apple", "ios", "swift"]
            ),
            Conference(
                id: "communitykit-2026",
                kind: .conference,
                name: "CommunityKit",
                startDate: makeDate(2026, 6, 7),
                endDate: makeDate(2026, 6, 12),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California, USA",
                summary: "Six days of community meetups, podcasts, workshops, an indie fair and WWDC watch parties held alongside WWDC.",
                websiteURLString: "https://communitykit.social",
                logoURLString: "https://raw.githubusercontent.com/community-kit/CommunityKitSite/refs/heads/main/img/og-image.png",
                tags: ["ios", "swift", "community"]
            ),
            Conference(
                id: "wwdc-run-2026",
                kind: .event,
                name: "WWDC Run",
                startDate: makeDate(2026, 6, 6),
                endDate: makeDate(2026, 6, 6),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "Saturday morning community run kicking off WWDC week for developers gathering in Cupertino.",
                websiteURLString: "https://luma.com/wwdc26-run",
                logoURLString: nil,
                tags: ["wwdc", "community"]
            ),
            Conference(
                id: "apple-park-happy-hour-2026",
                kind: .event,
                name: "Apple Park Happy Hour",
                startDate: makeDate(2026, 6, 6),
                endDate: makeDate(2026, 6, 6),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "Pre-WWDC evening gathering near Apple Park for developers arriving for the week.",
                websiteURLString: "https://www.eventbrite.com/e/apple-park-happy-hour-tickets-1986822959957",
                logoURLString: nil,
                tags: ["wwdc", "community"]
            ),
            Conference(
                id: "core-coffee-wwdc-sunday-2026",
                kind: .event,
                name: "Core Coffee — WWDC Sunday",
                startDate: makeDate(2026, 6, 7),
                endDate: makeDate(2026, 6, 7),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "Sunday-morning coffee meetup for Apple-platform developers on the eve of the WWDC keynote.",
                websiteURLString: "https://luma.com/gs91csm9",
                logoURLString: nil,
                tags: ["wwdc", "community", "swift"]
            ),
            Conference(
                id: "revenuecat-pre-wwdc-bashcade-2026",
                kind: .event,
                name: "RevenueCat Pre-WWDC Bashcade",
                startDate: makeDate(2026, 6, 7),
                endDate: makeDate(2026, 6, 7),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "Pre-WWDC arcade and developer social hosted by RevenueCat on keynote eve.",
                websiteURLString: "https://luma.com/jhm03vgs",
                logoURLString: nil,
                tags: ["wwdc", "community", "ios"]
            ),
            Conference(
                id: "communitykit-keynote-watch-2026",
                kind: .event,
                name: "Keynote Watch Party at CommunityKit",
                startDate: makeDate(2026, 6, 8),
                endDate: makeDate(2026, 6, 8),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "Watch the WWDC keynote together with iOSDevHappyHour and the CommunityKit crowd.",
                websiteURLString: "https://communitykit.social",
                logoURLString: nil,
                tags: ["wwdc", "community"]
            ),
            Conference(
                id: "wwdc-watch-cologne-2026",
                kind: .event,
                name: "WWDC 2026 Watch Party Cologne",
                startDate: makeDate(2026, 6, 8),
                endDate: makeDate(2026, 6, 8),
                locationName: "Cologne, Germany",
                mapQuery: "Cologne, Germany",
                summary: "CocoaHeads Cologne keynote watch party — stream the WWDC opener with local devs.",
                websiteURLString: "https://www.meetup.com/de-DE/cocoaheads-cologne/events/314303588/",
                logoURLString: nil,
                tags: ["wwdc", "community"]
            ),
            Conference(
                id: "wwdc-watch-london-2026",
                kind: .event,
                name: "NSLondon WWDC26 Keynote Viewing Party",
                startDate: makeDate(2026, 6, 8),
                endDate: makeDate(2026, 6, 8),
                locationName: "London, UK",
                mapQuery: "London, United Kingdom",
                summary: "NSLondon hosts a community keynote viewing for the WWDC 2026 opener.",
                websiteURLString: "https://www.meetup.com/nslondon/events/314110467",
                logoURLString: nil,
                tags: ["wwdc", "community"]
            ),
            Conference(
                id: "wwdc-watch-barcelona-2026",
                kind: .event,
                name: "Swift Barcelona WWDC 2026 Keynote Party",
                startDate: makeDate(2026, 6, 8),
                endDate: makeDate(2026, 6, 8),
                locationName: "Barcelona, Spain",
                mapQuery: "Barcelona, Spain",
                summary: "Swift Barcelona keynote watch party for local developers gathering in person.",
                websiteURLString: "https://www.meetup.com/swiftbarcelona/events/314816865/",
                logoURLString: nil,
                tags: ["wwdc", "community", "swift"]
            ),
            Conference(
                id: "iosdevhappyhour-wwdc-irl-2026",
                kind: .event,
                name: "iOSDevHappyHour @ WWDC26 IRL",
                startDate: makeDate(2026, 6, 9),
                endDate: makeDate(2026, 6, 9),
                locationName: "Cupertino, California, USA",
                mapQuery: "Cupertino, California",
                summary: "In-person edition of the long-running iOSDevHappyHour during WWDC week.",
                websiteURLString: "https://idhhwwdc26irl.eventbrite.com",
                logoURLString: nil,
                tags: ["wwdc", "community", "ios"]
            ),
            Conference(
                id: "apple-dev-community-meetup-2026",
                kind: .event,
                name: "Apple Developer Community Meetup",
                startDate: makeDate(2026, 6, 10),
                endDate: makeDate(2026, 6, 10),
                locationName: "Cupertino, California, USA",
                mapQuery: "Apple Developer Center, Cupertino, California",
                summary: "Evening community gathering at the Apple Developer Center in Cupertino during WWDC.",
                websiteURLString: "https://developer.apple.com/events/view/8D4G7DD8LR/dashboard",
                logoURLString: nil,
                tags: ["wwdc", "apple", "community"]
            ),
            Conference(
                id: "swift-rockies-2026",
                kind: .conference,
                name: "Swift Rockies",
                startDate: makeDate(2026, 7, 22),
                endDate: makeDate(2026, 7, 23),
                locationName: "Calgary, Alberta, Canada",
                mapQuery: "Calgary, Alberta, Canada",
                summary: "Retreat-style iOS conference in the Canadian Rockies with single-track talks, round-tables and hands-on sessions.",
                websiteURLString: "https://swiftrockies.com",
                logoURLString: "https://swiftrockies.com/assets/social-share-card.png",
                tags: ["ios", "swift", "swiftui"]
            ),
            Conference(
                id: "iosdevuk-2026",
                kind: .conference,
                name: "iOSDevUK",
                startDate: makeDate(2026, 9, 7),
                endDate: makeDate(2026, 9, 10),
                locationName: "Aberystwyth, UK",
                mapQuery: "Aberystwyth University, Aberystwyth, Wales, UK",
                summary: "Long-running, community-driven UK iOS conference combining workshops, talks and shared accommodation in coastal Wales.",
                websiteURLString: "https://www.iosdevuk.com",
                logoURLString: "https://static1.squarespace.com/static/59ccb76390badefdc24cee2e/t/6954faf23f4b3e6c55defb03/1767176946378/SiteBanner-GoldBackground-DeviceImage.png?format=1500w",
                tags: ["ios", "swift", "community"]
            ),
            Conference(
                id: "swift-island-2026",
                kind: .conference,
                name: "Swift Island",
                startDate: makeDate(2026, 9, 7),
                endDate: makeDate(2026, 9, 11),
                locationName: "Texel, Netherlands",
                mapQuery: "Texel, Netherlands",
                summary: "Exclusive island-based Swift conference on Texel built around small, hands-on WWDC workshops with expert mentors.",
                websiteURLString: "https://swiftisland.nl",
                logoURLString: "https://framerusercontent.com/images/qVsXCRdVU8lIeMVkkmGqTdSOwZU.jpg",
                tags: ["swift", "ios", "community"]
            ),
            Conference(
                id: "swiftleeds-2026",
                kind: .conference,
                name: "SwiftLeeds",
                startDate: makeDate(2026, 10, 13),
                endDate: makeDate(2026, 10, 14),
                locationName: "Leeds, UK",
                mapQuery: "Leeds Playhouse, Leeds, UK",
                summary: "Community-run, non-profit Swift conference at Leeds Playhouse with talks, drop-in expert sessions and an evening talkshow.",
                websiteURLString: "https://swiftleeds.co.uk",
                logoURLString: "https://swiftleeds.co.uk/img/logo.png",
                tags: ["swift", "ios", "community"]
            ),
            Conference(
                id: "swift-connection-2026",
                kind: .conference,
                name: "Swift Connection X",
                startDate: makeDate(2026, 11, 2),
                endDate: makeDate(2026, 11, 3),
                locationName: "Paris, France",
                mapQuery: "Paris, France",
                summary: "Tenth-edition Paris conference for the Swift and Apple platforms community, focused on practical talks and conversations.",
                websiteURLString: "https://swiftconnection.io",
                logoURLString: "https://swiftconnection.io/static/c7d63e77c83a2e3734e24fda2934cdb3/badge.png",
                tags: ["swift", "ios", "community"]
            ),
            Conference(
                id: "do-ios-2026",
                kind: .conference,
                name: "Do iOS 2026",
                startDate: makeDate(2026, 11, 10),
                endDate: makeDate(2026, 11, 12),
                locationName: "Amsterdam, Netherlands",
                mapQuery: "Nemo Science Museum, Oosterdok 2, Amsterdam, Netherlands",
                summary: "Eighth edition of Amsterdam's iOS conference: a day of workshops followed by two days of talks at the Nemo Science Museum.",
                websiteURLString: "https://do-ios.com",
                logoURLString: "https://do-ios.com/images/card.png?v=2026",
                tags: ["ios", "swift", "community"]
            ),
            Conference(
                id: "swiftsonic-2026",
                kind: .conference,
                name: "Swiftsonic '26",
                startDate: makeDate(2026, 11, 20),
                endDate: makeDate(2026, 11, 22),
                locationName: "Nashville, Tennessee, USA",
                mapQuery: "Nashville, Tennessee, USA",
                summary: "Community-driven Swift and iOS conference in Nashville blending technical sessions with music-festival energy.",
                websiteURLString: "https://swiftsonicconf.com",
                logoURLString: "https://swiftsonicconf.com/swiftsonic.png",
                tags: ["swift", "ios", "swiftui"]
            ),
            Conference(
                id: "iosconf-sg-2027",
                kind: .conference,
                name: "iOS Conf SG 2027",
                startDate: makeDate(2027, 1, 21),
                endDate: makeDate(2027, 1, 23),
                locationName: "Singapore",
                mapQuery: "NUS University Cultural Centre, Singapore",
                summary: "Singapore's flagship iOS developer conference featuring international speakers across Apple platform topics.",
                websiteURLString: "https://www.iosconf.sg",
                logoURLString: "https://iosconf.sg/feature.png",
                tags: ["ios", "swift", "general"]
            ),
            Conference(
                id: "arctic-conference-2027",
                kind: .conference,
                name: "Arctic Conference 2027",
                startDate: makeDate(2027, 2, 16),
                endDate: makeDate(2027, 2, 18),
                locationName: "Oulu, Finland",
                mapQuery: "Theatre Rio, Oulu, Finland",
                summary: "The world's northernmost Apple developers' conference, covering iOS, macOS, visionOS, watchOS, iPadOS and tvOS.",
                websiteURLString: "https://arcticonference.com",
                logoURLString: nil,
                tags: ["ios", "macos", "visionos"]
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
        for conference in Conference.bundled {
            context.insert(conference)
        }
        // Pre-favourite iOSDevUK so the Favourites tab has something in previews.
        context.insert(FavouriteConference(conferenceID: "iosdevuk-2026"))
        return container
    }()
}
