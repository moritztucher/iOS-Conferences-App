# iOS Conferences

An open, community-curated list of iOS / Apple-platform developer conferences — in one place, sorted by date.

Built for iOS 26+ with SwiftUI, SwiftData, and zero third-party dependencies. The conference data lives in this repo as a single JSON file — anyone can add a conference via a Pull Request or by tapping **Suggest a conference** in the app.

> Status: pre-release. App in active development; data file is seeded with confirmed 2026/2027 events.

## What it does

- **Browse** every upcoming iOS conference, grouped by month.
- **Filter** by format (in-person / online) or include past events.
- **Search** by name, location, or tag (`swift`, `visionos`, `community`, …).
- **Favourite** conferences you're considering — stored locally, no account needed.
- **Add to calendar** with the system event editor (you pick the calendar, alerts, notes).
- **Open the website** in an in-app Safari view.
- **Suggest a conference** — fills a pre-populated GitHub Issue you submit with one tap.

## Why this exists

There is no canonical, frictionless place to see "all iOS conferences this year." Information lives across personal blogs, Twitter/Mastodon threads, and one-off lists that go stale. This app is the smallest possible bet on a different shape:

- **Open data.** The list is a plain JSON file in this repo. Anyone can correct or extend it.
- **No backend.** No servers, no logins, no telemetry. The app fetches `data/conferences.json` from this repo at runtime and caches it locally for offline use.
- **One-time tip, never a subscription.** If the app saves you time, you can buy the developer a coffee (€1.49). That's it.

## Contributing a conference

The data lives in `data/conferences.json`. To add or update an event:

1. **Easy mode:** open the app → Settings → "Suggest a conference" → fill the form → submit (creates a pre-filled GitHub Issue you finalise on github.com).
2. **PR mode:** edit `data/conferences.json` directly and open a Pull Request. The schema is documented in [`CONTRIBUTING.md`](./CONTRIBUTING.md) (todo).

Per-conference fields:

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String` | stable kebab-case identifier (e.g. `tryswift-tokyo-2026`) |
| `name` | `String` | display name |
| `startDate` | `String` (ISO-8601) | inclusive |
| `endDate` | `String` (ISO-8601) | inclusive |
| `locationName` | `String` | display string, e.g. `"Tokyo, Japan"` or `"Online"` |
| `mapQuery` | `String?` | optional Maps query (city or venue). `null` for online events. |
| `summary` | `String` | one-sentence paraphrased description |
| `websiteURL` | `String` | conference homepage |
| `logoURL` | `String?` | the site's `og:image` URL — displayed at runtime, never bundled |
| `tags` | `[String]` | topical tags |

**Legal note.** We only display each conference's name, date, location, and *its own* `og:image` URL (fetched at runtime, like iMessage / Slack link previews — never redistributed). Descriptions are paraphrased from the site, not copied verbatim. Logos are not bundled.

## Tech stack

- **iOS 26+** · SwiftUI · SwiftData
- **No third-party Swift packages.** Every dependency is a system framework:
  - `EventKit` / `EventKitUI` — adds events via `EKEventEditViewController`
  - `MapKit` — opens locations in Apple Maps
  - `StoreKit 2` — the tip-jar consumable IAP
  - `SafariServices` — in-app web view
  - `Core Spotlight` & `App Intents` (post-MVP) — make favourited conferences searchable system-wide and queryable from Siri

The app feels like an extension of the Apple ecosystem rather than a third-party utility — that's an intentional design direction documented in [`docs/decisions/ADR-0003-ecosystem-native-ui.md`](./docs/decisions/ADR-0003-ecosystem-native-ui.md).

## Project layout

```
.
├── data/conferences.json       ← the data this app shows
├── iOS-Conferences/            ← the Xcode project sources
│   ├── App/                    ← entry point & repo config
│   ├── Core/                   ← models, services, helpers
│   └── Features/               ← ConferenceList, ConferenceDetail, Settings, …
├── docs/decisions/             ← Architecture Decision Records
└── README.md
```

## Building

1. Clone the repo.
2. Open `iOS-Conferences.xcodeproj` in Xcode 16+.
3. Build for any iOS 26 simulator.

The app currently uses bundled mock data (see `MockConferenceService`) so it runs without a network connection. Flip `ConferenceServiceFactory.make()` in `Core/Services/ConferenceService.swift` to `LiveConferenceService()` to fetch the real list from this repo's `data/conferences.json` via jsDelivr's CDN, with a `raw.githubusercontent.com` fallback.

## License

MIT — see [`LICENSE`](./LICENSE) (todo).

The data in `data/conferences.json` is contributed under the same license, except for any third-party logo URLs referenced (those remain the property of their respective owners and are fetched at display time only).

## Acknowledgements

This app exists because the iOS developer community keeps putting on the most welcoming conferences in software. Most of them are run by volunteers; if you can attend one, do.
