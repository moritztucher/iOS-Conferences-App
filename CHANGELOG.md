# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Image + mesh cohesion** (Track A): real conference artwork (logos, og:images, photos) is now tonally unified (desaturated + darkened) so it reads in the same family as the placeholders, and the hash-derived placeholder palette was recurated into a deeper, desaturated jewel-tone set that harmonises with the marigold accent — the list now reads as one designed system instead of a grab-bag of sources.
- **Settings framing** (ADR-0007 Phase 3): the Settings screens now share the same marigold background wash as the list (`.brandBackground()`) — chrome only; the `Form` rows stay stock.
- **List elevation** (ADR-0007 Phase 2): conference cards now grow with Dynamic Type instead of clipping (verified at the largest accessibility sizes), gained a reduce-motion-gated scroll-in animation (fade + slight shrink), and sit over a restrained marigold "stage-light" background wash.
- **Custom UI on Liquid Glass** (ADR-0007): the detail screen's content is now floating `GlassSectionCard`s (About, When & Where with an embedded map) in a `GlassEffectContainer`, and the action bar uses the system glass button styles (`.glass` / `.glassProminent`) — replacing the stock grouped `Form`. Accessibility, Dynamic Type, and dark-mode parity are kept because the custom layer rides on system glass.
- **Signature brand identity** (ADR-0006): a warm marigold accent replacing the system blue tint (app-wide, light + dark), and the system serif (New York) for display moments — conference names and month mastheads. Body, controls, and stock `Form` sections stay SF.
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
- **Typographic rhythm** unified into named type roles in `Theme`: display (serif), an `.eyebrow()` modifier for every uppercase overline (one tracking value app-wide), and a documented "ticket numeral" for the date stub — replacing scattered per-view font/tracking values.
- **Detail screen layout** reflowed: About now leads, followed by a "When & Where" card that folds the venue map in under the location (with an "Open in Maps" badge). The Date row gained a relative countdown ("In 3 months" / "Happening now"), and timed events show a dedicated Time row. The detail hero's ticket "tear" edge was dropped (clean bottom) since the content now floats as separate cards.
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
