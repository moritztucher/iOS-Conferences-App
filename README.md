# dubdub — Conferences & Events

An open, community-curated list of iOS / Apple-platform developer conferences and the events around them — in one place, sorted by date.

Home-screen name: **dubdub**. App Store listing: **dubdub - Conferences & Events**.

Built for iOS 26+ with SwiftUI, SwiftData, and zero third-party dependencies. The browse experience has a bespoke **ticket** identity — full-bleed ticket cards that zoom into a stretchy ticket hero — while everything else stays Apple-native (stock `Form` settings, deep EventKit / Maps / ShareLink integrations, system tint and fonts). See [ADR-0004](docs/decisions/ADR-0004-premium-ticket-identity.md).

## What it does

- **Browse** every upcoming Apple-platform conference, watch party, and community event as ticket cards — grouped by month, then by type (Conferences → Events → Watch Parties).
- **Filter** by kind and world region (both multi-select), by format (In person / Online), and toggle past entries on or off.
- **Search** by name, location, or tag (`swift`, `wwdc`, `visionos`, `community`, …).
- **Favourite** entries you're considering — stored locally, no account needed.
- **Add to calendar** with the system event editor (`EKEventEditViewController`) — you pick the calendar, alerts, notes.
- **Open the website** in an in-app Safari view.
- **Tap a location** to open Apple Maps with a pin on the venue.
- **Share** any entry via the system share sheet.
- **Suggest a conference** — primary path emails the developer a structured form; secondary path opens a pre-filled GitHub Issue.
- **Contact the developer** straight from Settings.

## Why this exists

Finding out what's happening across the Apple-platform calendar is harder than it should be. The big conferences are easy enough to track, but the events that orbit them — Core Coffee at WWDC, community meetups, keynote watch parties, hack days — are scattered across blogs, Mastodon and Twitter threads, and one-off lists that quietly go stale.

dubdub started from one simple idea: keep all of it in a single, community-maintained list that lives on your phone, where you'll actually look.

- **Open data.** The list — conferences, watch parties, and the events around them — lives as a plain JSON file in this repo at [`data/conferences.json`](./data/conferences.json). Anyone can correct or extend it.
- **No backend.** No servers, no logins, no telemetry. The app ships with the data bundled for instant first launch, then fetches the JSON file from this repo on every refresh and caches it locally for offline use.
- **Free, forever.** No ads, no subscriptions, no in-app purchases.

If you run a conference, organise a meetup, or just spotted something missing — please contribute. No conference is too small, no PR too short. First time submitting to an open-source project? Even better — we'll help.

## Conferences listed for 2026/27

| Conference | Dates | Location |
|---|---|---|
| LET'S VISION 2026 | Mar 28–29, 2026 | Shanghai, China |
| try! Swift Tokyo | Apr 12–14, 2026 | Tokyo, Japan |
| Deep Dish Swift 2026 | Apr 12–14, 2026 | Rosemont, IL, USA |
| iOSKonf26 | May 4–6, 2026 | Skopje, North Macedonia |
| Swift Craft 2026 | May 18–20, 2026 | Folkestone, UK |
| CommunityKit | Jun 7–12, 2026 | Cupertino, CA, USA |
| WWDC 2026 | Jun 8–12, 2026 | Cupertino, CA, USA |
| Swift Rockies | Jul 22–23, 2026 | Calgary, Canada |
| iOSDevUK | Sep 7–10, 2026 | Aberystwyth, UK |
| Swift Island | Sep 7–11, 2026 | Texel, Netherlands |
| NSSpain XIV | Sep 16–18, 2026* | Logroño, Spain |
| swiftCon Berlin 2026 | Oct 7–9, 2026 | Berlin, Germany |
| SwiftLeeds | Oct 13–14, 2026 | Leeds, UK |
| Swift Connection X | Nov 2–3, 2026 | Paris, France |
| Do iOS 2026 | Nov 10–12, 2026 | Amsterdam, Netherlands |
| Swift Bharat 2026 | Nov 19–20, 2026 | Mumbai, India |
| Swiftsonic '26 | Nov 20–22, 2026 | Nashville, TN, USA |
| iOS Conf SG 2027 | Jan 21–23, 2027 | Singapore |
| Arctic Conference 2027 | Feb 16–18, 2027 | Oulu, Finland |

\* Exact NSSpain XIV dates TBA; mid-September placeholder based on historical schedule.

Alongside these, the app tracks **70+ WWDC-week community events** (Core Coffee, the Tim Cookout, indie meetups, etc.) and **30+ keynote watch parties** worldwide. Spotted a missing entry, a wrong date, or a broken link? See [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Contributing

Contributions of every kind are welcome — not just new conferences, but bug fixes and feature ideas too.

**Adding or correcting an event?** Three paths, easiest first:

1. **In-app:** Settings → "Suggest a conference" → fill the form → tap **Email suggestion**. The structured details land in the developer's inbox and are added to `data/conferences.json` from there.
2. **GitHub Issue:** in the same form, tap **Submit as a GitHub Issue instead** — or open [a new conference request](https://github.com/moritztucher/iOS-Conferences-App/issues/new?template=conference-request.yml) directly.
3. **Pull Request:** edit [`data/conferences.json`](./data/conferences.json) and open a PR against `develop`. Schema documented in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

**Found a bug or have a feature idea?** [Open an issue](https://github.com/moritztucher/iOS-Conferences-App/issues/new) or send a PR against `develop` — the dev setup and conventions live in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

Be kind. This is a community project — see [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md).

## Tech stack

- **iOS 26+** · SwiftUI · SwiftData · MVVM with a `NavigationCoordinator`
- **Zero third-party Swift packages.** Every dependency is a system framework:
  - `EventKit` / `EventKitUI` — adds events via `EKEventEditViewController` (system event editor sheet).
  - `MapKit` — opens locations in Apple Maps.
  - `SafariServices` — in-app web view for conference websites and the GitHub Issue suggestion path.
  - `MessageUI` — `MFMailComposeViewController` for the Suggest-by-email and Contact-me flows.
- **Post-MVP system integrations** (planned): Core Spotlight (favourites in iOS system search), App Intents (`Conference` as `AppEntity`, "What's the next conference?" Siri intent), WidgetKit, Live Activities.

The app feels like an extension of the Apple ecosystem rather than a third-party utility — that's an intentional design direction documented in [`docs/decisions/ADR-0003-ecosystem-native-ui.md`](./docs/decisions/ADR-0003-ecosystem-native-ui.md).

## Project layout

```
.
├── iOS-Conferences/                    ← the Xcode project sources
│   ├── App/                            ← entry point, app configuration
│   │   └── RepoConfig.swift
│   ├── Core/
│   │   ├── Extensions/                 ← shared helpers (date formatting, etc.)
│   │   │   └── Date+ConferenceFormatting.swift
│   │   ├── Managers/                   ← NavigationCoordinator
│   │   │   └── NavigationCoordinator.swift
│   │   ├── Models/                     ← data models
│   │   │   ├── BundledConferences.swift
│   │   │   ├── Conference.swift
│   │   │   ├── FavouriteConference.swift
│   │   │   └── Route.swift
│   │   └── Services/                   ← networking + system-service wrappers
│   │       ├── CalendarService.swift
│   │       └── ConferenceService.swift
│   ├── Features/
│   │   ├── ConferenceDetail/           ← detail screen, hero, Safari + event-editor sheets
│   │   │   ├── ViewModels/
│   │   │   │   └── ConferenceDetailViewModel.swift
│   │   │   └── Views/
│   │   │       ├── ConferenceDetailView.swift
│   │   │       ├── EventEditorView.swift
│   │   │       └── SafariView.swift
│   │   ├── ConferenceList/             ← list, filter menu, search (Conferences + Favourites tabs)
│   │   │   ├── ViewModels/
│   │   │   │   └── ConferenceListViewModel.swift
│   │   │   └── Views/
│   │   │       ├── ConferenceListView.swift
│   │   │       └── ConferenceRow.swift
│   │   ├── Settings/                   ← Display, Support, Contribute, Acknowledgements, About
│   │   │   ├── ViewModels/
│   │   │   │   └── SettingsViewModel.swift
│   │   │   └── Views/
│   │   │       ├── AcknowledgementsView.swift
│   │   │       └── SettingsView.swift
│   │   ├── SuggestConference/          ← in-app form: email primary, GitHub Issue secondary
│   │   │   ├── ViewModels/
│   │   │   │   └── SuggestConferenceViewModel.swift
│   │   │   └── Views/
│   │   │       └── SuggestConferenceView.swift
│   │   └── RootTabView.swift
│   ├── ViewComponents/                 ← shared reusable views
│   │   ├── ConferencePlaceholder.swift
│   │   └── MailComposeView.swift
│   └── iOS_ConferencesApp.swift
├── data/conferences.json               ← the canonical feed (conferences + watch parties + events)
├── .github/ISSUE_TEMPLATE/             ← conference-request issue form
├── docs/                               ← project documentation
│   ├── ARCHITECTURE.md                 ← architecture overview
│   ├── VIEW-INVENTORY.md               ← index of shared UI components
│   └── decisions/                      ← Architecture Decision Records (ADR-0001 / 0002 / 0003)
├── CONTRIBUTING.md                     ← contribution paths + JSON schema
├── CODE_OF_CONDUCT.md
├── CHANGELOG.md
├── README.md
├── CLAUDE.md                           ← agent guidance for this repo
└── LICENSE
```

## Building

1. Clone the repo.
2. Open `iOS-Conferences.xcodeproj` in Xcode 26+.
3. Build for any iOS 26 simulator.

On launch the app instantly seeds the bundled conferences (offline-safe), then refreshes from [`data/conferences.json`](./data/conferences.json) via [jsDelivr](https://www.jsdelivr.com/) (with `raw.githubusercontent.com` as a fallback). Pull-to-refresh on the Conferences tab triggers the same live fetch.

## License

MIT — see [`LICENSE`](./LICENSE).

The data contributed to `data/conferences.json` is released under the same license.

**Logos.** Conference logos are only displayed with the organiser's explicit permission. If you run a conference and would like your logo to appear next to your listing, either email the developer or open a PR with the image file. Logos remain the property of their respective owners and are used by permission only.

## Legal bits

This is a community project. It is not an Apple initiative and is not endorsed by, affiliated with, or sponsored by Apple Inc.

Apple, the Apple logo, App Store, iPhone, iPad, iOS, iPadOS, macOS, watchOS, tvOS, visionOS, Swift, the Swift logo, Xcode, and SF Symbols are trademarks of Apple Inc., registered in the U.S. and other countries.

Conference and event names, brands, and content link to their respective organisers. They appear in this list as factual references — we don't endorse, sponsor, sell, or take a cut of ticket sales, and the in-app web view shows the real URL so you can see whose site you're on. If you spot something that shouldn't be here (wrong info, takedown request, anything else), [open an issue](https://github.com/moritztucher/iOS-Conferences-App/issues/new) or email **moritztucher@gmail.com**.

## Acknowledgements

This app exists because the iOS developer community keeps putting on the most welcoming conferences in software. Most of them are run by volunteers; if you can attend one, do.

A particular nod to [**twostraws/wwdc**](https://github.com/twostraws/wwdc) by Paul Hudson and contributors — the source of much of Dubdub's WWDC-week event data. The in-app **Settings → Acknowledgements** screen mirrors this list.
