# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Premium ticket redesign** of the list and detail (ADR-0004): full-bleed `ConferenceCard`s shaped as event tickets (`TicketShape` — perforation, notches, date stub), and a stretchy parallax detail hero (`ConferenceDetailHero` / `HeroTicketEdge`) that the card zooms into via a `.navigationTransition(.zoom)` morph.
- Detail screen pinned bottom action bar (Website + Add to Calendar) replacing the in-list Actions section.
- Haptics on favourite / add-to-calendar (`.sensoryFeedback`) and a reduce-motion-gated favourite-heart spring.
- Region filter (Global + five world regions, multi-select), derived from each event's location.
- Optional event times & time zone (ADR-0005): `startTime` / `endTime` / `timeZone` in the feed; timed Watch Parties / Events show the time on the card, sort by it, and create *timed* calendar events anchored to the event's time zone.
- "Watch Party" as a distinct kind (alongside Conference and Event) with its own filter chip in the toolbar menu.
- Kind picker in the filter menu (All / Conferences / Watch Parties / Events) — complements the existing format filter.
- Acknowledgements section in Settings, opening a dedicated `AcknowledgementsView` that lists credited sources (currently twostraws/wwdc).
- "Next" keyboard chain across the Suggest-a-conference form fields.
- ~80 community entries seeded for WWDC 2026 week (Cupertino-area meetups + global keynote watch parties).
- Swift Craft 2026 (Folkestone), NSSpain XIV (Logroño, dates TBA), swiftCon Berlin 2026, and Swift Bharat 2026 (Mumbai) added to the live feed.

### Changed
- List now groups **month-first, then by type** (Conferences → Events → Watch Parties), with type sub-dividers only in mixed months; the kind filter is multi-select.
- Filter menu now stays open while toggling options (`.menuActionDismissBehavior(.disabled)`).
- Home-screen / App Store name finalised as **dubdub** (App Store listing: "dubdub - Conferences & Events").
- Support email pre-fills a descriptive subject line ("Support Request: Dubdub - Conferences & Events").

### Removed
- Tip-jar feature and all associated copy. The app is fully free with no in-app monetization.

## [0.1.0] - 2026-05-18

### Added
- Initial release planning
- Conference list (chronologically sorted)
- Conference detail view
- Add-to-calendar via EventKit
- Open conference website via SFSafariViewController
