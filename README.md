# iOS Conferences

An open, community-curated list of iOS / Apple-platform developer conferences — in one place, sorted by date.

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

There is no canonical, frictionless place to see "all iOS conferences this year." Information lives across personal blogs, Twitter/Mastodon threads, and one-off lists that go stale. This app is the smallest possible bet on a different shape:

- **Open data.** The list lives as a plain JSON file in this repo at [`data/conferences.json`](./data/conferences.json). Anyone can correct or extend it.
- **No backend.** No servers, no logins, no telemetry. The app ships with the data bundled for instant first launch, then fetches the JSON file from this repo on every refresh and caches it locally for offline use.
- **One-time tip, never a subscription.** If the app saves you time, you can buy the developer a coffee. That's it — no ads, no upsells.

## Currently seeded conferences

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

## Contributing a conference

Three paths, in order of friction (full schema and conventions in [`CONTRIBUTING.md`](./CONTRIBUTING.md)):

1. **In-app (easiest):** Settings → "Suggest a conference" → fill the form → tap **Email suggestion**. The structured details land in the developer's inbox.
2. **GitHub Issue:** in the same form, tap **Submit as a GitHub Issue instead** — or open [a new conference request](https://github.com/moritztucher/iOS-Conferences-App/issues/new?template=conference-request.yml) directly.
3. **Pull Request:** edit [`data/conferences.json`](./data/conferences.json) and open a PR against `develop`. Schema documented in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

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
2. Open `iOS-Conferences.xcodeproj` in Xcode 16+.
3. Build for any iOS 26 simulator.

On launch the app instantly seeds 15 bundled conferences (offline-safe), then refreshes from [`data/conferences.json`](./data/conferences.json) via [jsDelivr](https://www.jsdelivr.com/) (with `raw.githubusercontent.com` as a fallback). Pull-to-refresh on the Conferences tab triggers the same live fetch. `RepoConfig.dataBranch` currently points at `develop` — it'll switch to `main` once the first release-merge lands.

## Roadmap

- [x] LICENSE + CONTRIBUTING.md + GitHub issue template.
- [x] Publish `data/conferences.json` and wire `LiveConferenceService` as the runtime source (bundled remains as offline-safe seed).
- [ ] Register the `com.pocketapps.conferences.tip` consumable in App Store Connect and ship to TestFlight.
- [ ] Switch `RepoConfig.dataBranch` to `"main"` on the first release-merge.
- [ ] Post-MVP system integrations: Core Spotlight, App Intents, WidgetKit, Live Activities.
- [ ] Verify WWDC 2026 dates once Apple announces (current entry is a best-guess based on Apple's 2nd-Monday-of-June tradition).

## License

MIT — see [`LICENSE`](./LICENSE).

The data contributed to `data/conferences.json` is under the same license, except for any third-party logo URLs referenced — those remain the property of their respective owners and are fetched at display time only.

## Acknowledgements

This app exists because the iOS developer community keeps putting on the most welcoming conferences in software. Most of them are run by volunteers; if you can attend one, do.
