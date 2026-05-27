# dubdub — Conferences & Events

An open, community-curated list of iOS / Apple-platform developer conferences and the events around them — in one place, sorted by date.

Home-screen name: **dubdub**. App Store listing: **dubdub - Conferences & Events**.

Built for iOS 26+ with SwiftUI, SwiftData, and zero third-party dependencies. Designed to feel like an extension of the Apple ecosystem: stock components, system integrations, no custom design language.

> Status: pre-release. 15 confirmed 2026/2027 conferences are bundled into the app for offline-safe first launch, and a live JSON feed in this repo keeps the list fresh. App Store submission is the next gate.

## What it does

- **Browse** every upcoming Apple-platform conference, grouped by month.
- **Filter** by format (All / In person / Online) or include past events.
- **Search** by name, location, or tag (`swift`, `visionos`, `community`, …).
- **Favourite** conferences you're considering — stored locally, no account needed.
- **Add to calendar** with the system event editor (`EKEventEditViewController`) — you pick the calendar, alerts, notes.
- **Open the website** in an in-app Safari view.
- **Tap a location** to open Apple Maps with a pin on the venue.
- **Share a conference** via the system share sheet.
- **Suggest a conference** — primary path emails the developer a structured form; secondary path opens a pre-filled GitHub Issue.
- **Buy me a coffee** — repeatable €1.49 consumable tip via StoreKit 2.
- **Rate the app** and **contact the developer** from Settings.

## Why this exists

There is no canonical, frictionless place to see what's happening across the iOS / Apple-platform calendar — the official conferences, but also the adjacent events that orbit them: Core Coffee at WWDC, community meetups, watch parties, hack days. Information lives across personal blogs, Twitter/Mastodon threads, and one-off lists that go stale.

This app is the smallest possible bet on a different shape: a single, community-maintained list that lives where you'll actually look at it — on your phone.

- **Open data.** The list lives as a plain JSON file in this repo at [`data/conferences.json`](./data/conferences.json). Anyone can correct or extend it.
- **No backend.** No servers, no logins, no telemetry. The app ships with the data bundled for instant first launch, then fetches the JSON file from this repo on every refresh and caches it locally for offline use.
- **One-time tip, never a subscription.** If the app saves you time, you can buy the developer a coffee. That's it — no ads, no upsells.

If you run a conference, organise a meetup, or just spotted something missing — please contribute. No conference is too small, no PR too short. First time submitting to an open-source project? Even better — we'll help.

## Conferences listed for 2026/27

| Conference | Dates | Location |
|---|---|---|
| LET'S VISION 2026 | Mar 28–29, 2026 | Shanghai, China |
| try! Swift Tokyo | Apr 12–14, 2026 | Tokyo, Japan |
| Deep Dish Swift 2026 | Apr 12–14, 2026 | Rosemont, IL, USA |
| iOSKonf26 | May 4–6, 2026 | Skopje, North Macedonia |
| CommunityKit | Jun 7–12, 2026 | Cupertino, CA, USA |
| WWDC 2026 | Jun 8–12, 2026 | Cupertino, CA, USA |
| Swift Rockies | Jul 22–23, 2026 | Calgary, Canada |
| iOSDevUK | Sep 7–10, 2026 | Aberystwyth, UK |
| Swift Island | Sep 7–11, 2026 | Texel, Netherlands |
| SwiftLeeds | Oct 13–14, 2026 | Leeds, UK |
| Swift Connection X | Nov 2–3, 2026 | Paris, France |
| Do iOS 2026 | Nov 10–12, 2026 | Amsterdam, Netherlands |
| Swiftsonic '26 | Nov 20–22, 2026 | Nashville, TN, USA |
| iOS Conf SG 2027 | Jan 21–23, 2027 | Singapore |
| Arctic Conference 2027 | Feb 16–18, 2027 | Oulu, Finland |

Spotted a missing conference, a wrong date, or a broken link? See [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Contributing

Got a conference to add? A meetup we missed? A wrong date or a broken link? Three paths, easiest first:

1. **In-app:** Settings → "Suggest a conference" → fill the form → tap **Email suggestion**. The structured details land in the developer's inbox and are added to `data/conferences.json` from there.
2. **GitHub Issue:** in the same form, tap **Submit as a GitHub Issue instead** — or open [a new conference request](https://github.com/moritztucher/iOS-Conferences-App/issues/new?template=conference-request.yml) directly.
3. **Pull Request:** edit [`data/conferences.json`](./data/conferences.json) and open a PR against `develop`. Schema documented in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

Be kind. This is a community project — see [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md).

## Tech stack

- **iOS 26+** · SwiftUI · SwiftData · MVVM with a `NavigationCoordinator`
- **Zero third-party Swift packages.** Every dependency is a system framework:
  - `EventKit` / `EventKitUI` — adds events via `EKEventEditViewController` (system event editor sheet).
  - `MapKit` — opens locations in Apple Maps.
  - `StoreKit 2` — repeatable consumable tip IAP + `RequestReviewAction` for the in-app review prompt.
  - `SafariServices` — in-app web view for conference websites and the GitHub Issue suggestion path.
  - `MessageUI` — `MFMailComposeViewController` for the Suggest-by-email and Contact-me flows.
- **Post-MVP system integrations** (planned): Core Spotlight (favourites in iOS system search), App Intents (`Conference` as `AppEntity`, "What's the next conference?" Siri intent), WidgetKit, Live Activities.

The app feels like an extension of the Apple ecosystem rather than a third-party utility — that's an intentional design direction documented in [`docs/decisions/ADR-0003-ecosystem-native-ui.md`](./docs/decisions/ADR-0003-ecosystem-native-ui.md).

## Project layout

```
.
├── iOS-Conferences/                   ← the Xcode project sources
│   ├── App/                           ← entry point, RepoConfig
│   ├── Core/
│   │   ├── Models/                    ← Conference, FavouriteConference, Route, BundledConferences
│   │   ├── Managers/                  ← NavigationCoordinator
│   │   ├── Services/                  ← ConferenceService (Live + Bundled), CalendarService, TipJarService
│   │   └── Extensions/                ← date formatting helpers
│   ├── Features/                      ← ConferenceList, ConferenceDetail, Favourites, Settings, SuggestConference
│   ├── ViewComponents/                ← ConferencePlaceholder, MailComposeView
│   └── Resources/
├── data/conferences.json              ← the canonical 15-conference feed
├── .github/ISSUE_TEMPLATE/            ← conference-request issue form
├── docs/decisions/                    ← Architecture Decision Records (ADR-0001 / 0002 / 0003)
├── VIEW-INVENTORY.md                  ← index of shared UI components
├── CONTRIBUTING.md                    ← contribution paths + JSON schema
├── README.md
├── CLAUDE.md                          ← agent guidance for this repo
├── Backlog.md
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
