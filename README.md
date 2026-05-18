# iOS Conferences

An open, community-curated list of iOS / Apple-platform developer conferences — in one place, sorted by date.

Built for iOS 26+ with SwiftUI, SwiftData, and zero third-party dependencies. Designed to feel like an extension of the Apple ecosystem: stock components, system integrations, no custom design language.

> Status: pre-release. App is functional and ships with **15 confirmed 2026/2027 events** bundled in. Repo-hosted JSON feed and App Store release are pending.

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

- **Open data.** The conference list will live as a plain JSON file in this repo (once `data/conferences.json` lands; see Roadmap). Anyone can correct or extend it via PR.
- **No backend.** No servers, no logins, no telemetry. The app reads bundled data today; later it will fetch the JSON file from this repo at runtime and cache it locally for offline use.
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

Spotted a missing conference, a wrong date, or a broken link? See **Contributing** below.

## Contributing a conference

Two paths:

1. **In-app (easiest):** Settings → "Suggest a conference" → fill the form → tap **Email suggestion**. The structured details land in the developer's inbox; the next bundled-data update or PR will pick it up.
2. **GitHub Issue:** in the same form, tap **Submit as a GitHub Issue instead**. Opens a pre-filled issue you finalise on github.com (one-time sign-in required).
3. **Pull Request:** edit `data/conferences.json` directly and open a PR. *(Available once the JSON feed is published — see Roadmap.)*

Per-conference fields (will mirror the JSON schema):

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | stable kebab-case identifier (e.g. `tryswift-tokyo-2026`) |
| `name` | `String` | display name |
| `startDate` | `String` (ISO-8601 date) | inclusive |
| `endDate` | `String` (ISO-8601 date) | inclusive |
| `locationName` | `String` | display string, e.g. `"Tokyo, Japan"` or `"Online"` |
| `mapQuery` | `String?` | optional Maps query (city or venue). `null` for online events. |
| `summary` | `String` | one-sentence paraphrased description |
| `websiteURL` | `String` | conference homepage |
| `logoURL` | `String?` | the site's `og:image` URL — fetched at runtime, never bundled |
| `tags` | `[String]` | topical tags (`swift`, `ios`, `visionos`, `community`, …) |

**Legal note.** We only display each conference's name, date, location, and *its own* `og:image` URL (fetched at runtime, like iMessage / Slack link previews — never redistributed). When a logo URL is missing or fails to load, a typographic placeholder (initials + hash-derived colour) is shown instead. Descriptions are paraphrased from the site, not copied verbatim. Logos are not bundled.

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
│   │   ├── Services/                  ← ConferenceService, CalendarService, TipJarService
│   │   └── Extensions/                ← date formatting helpers
│   ├── Features/                      ← ConferenceList, ConferenceDetail, Favourites, Settings, SuggestConference
│   ├── ViewComponents/                ← ConferencePlaceholder, MailComposeView
│   └── Resources/
├── docs/decisions/                    ← Architecture Decision Records
├── data/conferences.json              ← (planned) repo-hosted JSON feed
├── VIEW-INVENTORY.md                  ← index of shared UI components
├── README.md
├── CLAUDE.md                          ← agent guidance for this repo
└── Backlog.md
```

## Building

1. Clone the repo.
2. Open `iOS-Conferences.xcodeproj` in Xcode 16+.
3. Build for any iOS 26 simulator. The app launches populated with the 15 bundled conferences.

`ConferenceServiceFactory.make()` in `Core/Services/ConferenceService.swift` currently returns `BundledConferenceService()`. Once `data/conferences.json` is published to the repo, flip that one line to `LiveConferenceService()` — fetches via jsDelivr's CDN with a `raw.githubusercontent.com` fallback.

## Roadmap

- [ ] Publish `data/conferences.json` (and `.github/ISSUE_TEMPLATE/conference-request.yml`).
- [ ] Switch `ConferenceServiceFactory.make()` to `LiveConferenceService()`.
- [ ] Configure the StoreKit consumable in App Store Connect; ship to the App Store.
- [ ] Post-MVP system integrations (Spotlight, App Intents, Widget, Live Activities).
- [ ] Add MIT `LICENSE` and `CONTRIBUTING.md`.

## License

MIT (planned — `LICENSE` file to be added; see Roadmap).

The data contributed to `data/conferences.json` is under the same license, except for any third-party logo URLs referenced — those remain the property of their respective owners and are fetched at display time only.

## Acknowledgements

This app exists because the iOS developer community keeps putting on the most welcoming conferences in software. Most of them are run by volunteers; if you can attend one, do.
