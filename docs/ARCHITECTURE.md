# Architecture Overview

> This document provides a high-level overview of the project architecture.
> Update when significant architectural changes occur.

## Project Summary

**App Name:** iOS-Conferences
**Bundle ID:** `com.pocketapps.conferences`
**Target iOS:** iOS 26+
**Design Language:** Liquid Glass (iOS 26 native material)
**Database:** SwiftData

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        App Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Views     │  │ ViewModels  │  │   Models    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                      Core Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Services   │  │  Managers   │  │   Helpers   │     │
│  │ Network /   │  │  Calendar / │  │  Date fmt / │     │
│  │ Conference  │  │  Navigation │  │  URL helper │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                   External Services                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  REST API   │  │  SwiftData  │  │  EventKit   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## Key Components

### Navigation
- **Pattern:** Simple `NavigationStack` driven by a `NavigationCoordinator` that owns a `NavigationPath`.
- **NavigationCoordinator:** Centralised navigation; pushes typed `Route` values onto the path so detail screens resolve via `.navigationDestination(for:)`.
- Deep linking support: Planned (URL → conference detail), not in MVP.

### Networking
- **Approach:** REST.
- **Offline strategy:** Offline-first with sync. The cached SwiftData store is the source of truth for the UI; the network refresh updates it in the background.
- All API calls go through `NetworkService` — Views and ViewModels never call URLSession directly.
- `ConferenceService` wraps `NetworkService` to expose `func fetchConferences() async throws -> [Conference]` and persistence into SwiftData.

### Auth
- **Provider:** None.
- **Biometrics:** No.
- **Keychain:** No.

### Sync Strategy
- **Approach:** Local-only. SwiftData stores the most recently fetched list; no CloudKit / cross-device sync.

### Data Flow
1. View appears → ViewModel's `.task` triggers `ConferenceService.load()`.
2. `ConferenceService` reads cached conferences from SwiftData immediately (instant render) and concurrently fires a REST refresh.
3. On refresh success, SwiftData is updated; the `@Observable` ViewModel publishes the new list.
4. User taps a row → `NavigationCoordinator` pushes `.detail(Conference.ID)`; the detail View reads from the same SwiftData store.
5. From detail, user taps **Add to Calendar** → `CalendarManager` (EventKit) creates an `EKEvent`. **Open Website** → `SFSafariViewController`.

### Dependencies
| Dependency | Purpose | ADR |
|------------|---------|-----|
| SwiftData (system) | Local cache of conferences | ADR-0001 |
| EventKit (system) | Add events to user's calendar | ADR-0001 |
| SafariServices (system) | Show conference website in-app | ADR-0001 |

No third-party SPM dependencies at MVP.

## Feature Modules

| Feature | Location | Description |
|---------|----------|-------------|
| ConferenceList | `Features/ConferenceList/` | Ticket-card list (`ConferenceCard` + `TicketShape`), month-primary with kind sub-groups + counts. Region + multi-select kind/format filters. `.refreshable`; global Search tab. Shared by Conferences + Favourites (filter at the ViewModel level). See ADR-0004. |
| ConferenceDetail | `Features/ConferenceDetail/` | Stretchy parallax ticket hero (`ConferenceDetailHero` + `HeroTicketEdge`) → stock `Form` (Map, When/Where, About) → pinned bottom CTA bar (Website + Add to Calendar). Card→hero zoom transition. Favourite toggle + `ShareLink` in toolbar. |
| SuggestConference | `Features/SuggestConference/` | Form sheet that pre-fills a GitHub Issue URL and opens it in `SFSafariViewController` |
| Settings | `Features/Settings/` | `Form` with Display (show-past toggle) / Support (rate, contact) / Contribute (suggest, view source) / About (version, license) |

## Architecture Decisions

See `docs/decisions/` for detailed ADRs.

| Decision | Summary | Date |
|----------|---------|------|
| ADR-0001 | Initial architecture: SwiftData + REST + simple NavigationStack, no auth, EventKit + SafariServices | 2026-05-18 |
| ADR-0002 | Data source (`conferences.json` in public GitHub repo), open source under MIT. *Original monetization decision (StoreKit 2 tip) reversed — the app no longer ships any in-app purchase.* | 2026-05-18 |
| ADR-0003 | Ecosystem-native UI direction: stock components only, system integrations carry the "feels like Apple" weight. *Visual layer partially superseded by ADR-0004.* | 2026-05-18 |
| ADR-0004 | Premium ticket-based visual identity for the list + detail hero (custom shapes, scrims, parallax, zoom transition); stock everywhere else | 2026-06-09 |
| ADR-0005 | Optional event-local times + IANA time zone in the feed; timed calendar events anchored to the event zone | 2026-06-09 |

## Data Storage

| Data Type | Storage | Encryption |
|-----------|---------|------------|
| User credentials | N/A — no auth | N/A |
| User preferences (last-refresh timestamp, filters) | UserDefaults | No |
| Conference cache | SwiftData | No (public data) |

## Third-Party Integrations

| Service | Purpose | Documentation |
|---------|---------|---------------|
| EventKit / EventKitUI (system) | Add a conference to the user's calendar via `EKEventEditViewController` (system event editor sheet) | `~/.claude/docs/ios/system/eventkit.md` |
| SafariServices (system) | In-app web view for conference URLs + GitHub Issue submission | Apple docs: `SFSafariViewController` |
| StoreKit (system) | In-app review prompt via `RequestReviewAction` | Apple docs: StoreKit |
| MapKit (system) | `MKMapItem.openInMaps` from the detail Location row | Apple docs: `MKMapItem` |
| Core Spotlight (system, post-MVP) | Index favourited conferences for system-wide search | Apple docs: Core Spotlight |
| App Intents (system, post-MVP) | `Conference` as `AppEntity`; "What's the next conference?" intent | Apple docs: App Intents |
| GitHub Issues (URL-based) | Receive "suggest a conference" submissions via pre-filled issue URL | https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository |
| GitHub (raw / jsDelivr CDN) | Hosts `conferences.json` data file | https://www.jsdelivr.com/?docs=gh |

## Legal & Compliance Notes

- Only objective conference metadata (name, date, location, URL) is stored. Long descriptive text is paraphrased to avoid copyright issues.
- No bundled conference logos; rendered text-only badges where needed.
- `NSCalendarsUsageDescription` required in Info.plist before the first EventKit call.
- `PrivacyInfo.xcprivacy` to be added before App Store submission.
