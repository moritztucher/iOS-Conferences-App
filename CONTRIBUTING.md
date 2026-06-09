# Contributing

Thanks for helping keep this list current. Every conference in the app comes from `data/conferences.json` in this repo — a plain JSON file anyone can edit.

There are three ways to contribute, in order of friction:

1. **In-app email form** *(easiest, no GitHub account needed)*
   Open the app → **Settings** → **Suggest a conference** → fill the form → **Email suggestion**. The structured details land in the developer's inbox and get added in the next data update.

2. **GitHub Issue**
   From the same in-app form, tap **Submit as a GitHub Issue instead** — or open one directly: [New conference request](https://github.com/moritztucher/iOS-Conferences-App/issues/new?template=conference-request.yml). A maintainer turns approved issues into PRs against `data/conferences.json`.

3. **Pull Request** *(fastest if you know git)*
   Edit `data/conferences.json` directly and open a PR. Schema below.

---

## JSON schema

`data/conferences.json` is an array of conference objects.

```json
{
  "id": "iosdevuk-2026",
  "kind": "Conference",
  "name": "iOSDevUK",
  "startDate": "2026-09-07",
  "endDate": "2026-09-10",
  "locationName": "Aberystwyth, UK",
  "mapQuery": "Aberystwyth University, Aberystwyth, Wales, UK",
  "summary": "Long-running, community-driven UK iOS conference combining workshops, talks and shared accommodation in coastal Wales.",
  "websiteURL": "https://www.iosdevuk.com",
  "logoURL": "https://...",
  "tags": ["ios", "swift", "community"]
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | yes | Stable kebab-case identifier, typically `<short-name>-<year>` (e.g. `tryswift-tokyo-2026`). Must be unique. Don't change this once published — favourites in users' apps are keyed on it. |
| `kind` | `String` | no (default `"Conference"`) | One of `"Conference"` (multi-day developer conference), `"Watch Party"` (a group gathering to stream the WWDC keynote, SOTU, or similar Apple event), or `"Event"` (everything else — meetups, hack days, dinners, runs, satellite gatherings around a conference). When in doubt between Watch Party and Event: if the primary purpose is watching an Apple stream together, it's a `"Watch Party"`. |
| `name` | `String` | yes | Display name as it appears in the app. |
| `startDate` | `String` | yes | First day, `YYYY-MM-DD`. Inclusive. |
| `endDate` | `String` | yes | Last day, `YYYY-MM-DD`. Inclusive. Same as `startDate` for one-day events. |
| `startTime` | `String?` | no | Event-local start time, 24-hour `HH:mm` (e.g. `"19:00"`). Set it for timed **Watch Parties** and **Events**; omit it for multi-day conferences (they show as all-day). When present, the time appears on the card and the "Add to Calendar" action creates a timed event. |
| `endTime` | `String?` | no | Event-local end time, 24-hour `HH:mm`. Optional even when `startTime` is set — the calendar event falls back to a 2-hour duration if it's missing. |
| `timeZone` | `String?` | no | IANA time-zone identifier, e.g. `"Asia/Tokyo"`, `"America/Los_Angeles"`, `"Europe/Berlin"`. Set it for **online** timed events (which have no venue to derive a zone from); for in-person events it's optional and overrides the geocoded zone. Drives the zone shown on the card and used by "Add to Calendar". |
| `locationName` | `String` | yes | Display string, e.g. `"Tokyo, Japan"` or `"Online"`. |
| `mapQuery` | `String?` | no | Apple-Maps-friendly query (city, venue, or full address). `null` for online events. The Location row in the detail view becomes tappable when this is set. |
| `summary` | `String` | yes | One-sentence factual description. **In your own words** — don't copy the site's marketing copy verbatim (see [Legal](#legal) below). Aim for ~100–160 characters. |
| `websiteURL` | `String` | yes | Conference homepage. Must be HTTPS. |
| `logoURL` | `String?` | no | Direct link to the conference's logo or `og:image`. Fetched and displayed at runtime — never bundled or redistributed. If absent, the app shows a typographic placeholder. |
| `tags` | `[String]` | yes | One or more topical tags. Current vocabulary (most used first): `community`, `wwdc`, `swift`, `ios`, `ai`, `indie`, `visionos`, `accessibility`, `swiftui`, `macos`, `apple`, `design`, `general`. Use `wwdc` for any WWDC-week entry. Propose new tags in your PR if you need one. |

### Timed events (watch parties & events)

Multi-day conferences are all-day, so they omit `startTime`/`endTime`. A single-evening watch party or event can add an event-local time:

```json
{
  "id": "keynote-watch-party-berlin-2026",
  "kind": "Watch Party",
  "name": "Berlin WWDC Keynote Watch Party",
  "startDate": "2026-06-08",
  "endDate": "2026-06-08",
  "startTime": "18:30",
  "endTime": "22:00",
  "locationName": "Berlin, Germany",
  "mapQuery": "Berlin, Germany",
  "summary": "Community keynote viewing with talks and drinks afterwards.",
  "websiteURL": "https://...",
  "logoURL": null,
  "tags": ["wwdc", "community"]
}
```

Times are the event's **local** wall-clock (no timezone offset) — `"18:30"` shows as `6:30 PM` / `18:30` per the viewer's locale.

For an **online** timed event, add a `timeZone` so the time is unambiguous (there's no venue to derive it from):

```json
{
  "id": "online-keynote-watch-2026",
  "kind": "Watch Party",
  "name": "Global Online Keynote Watch",
  "startDate": "2026-06-08",
  "endDate": "2026-06-08",
  "startTime": "10:00",
  "timeZone": "America/Los_Angeles",
  "locationName": "Online",
  "mapQuery": null,
  "summary": "Streamed keynote watch-along for the global community.",
  "websiteURL": "https://...",
  "logoURL": null,
  "tags": ["wwdc", "community"]
}
```

### Ordering

The file is sorted by `startDate` ascending. Keep it sorted when you add a row — it makes diffs reviewable. Within a day, timed events sort by `startTime`.

### Validating your edit

The JSON is parsed by `LiveConferenceService` in the iOS app. To validate locally:

- `python3 -m json.tool data/conferences.json` confirms the JSON is well-formed.
- Build and run the app, then pull-to-refresh on the Conferences tab — your additions should appear.

---

## What gets accepted

**Yes:**
- Conferences focused on Apple platforms (iOS / macOS / visionOS / watchOS / tvOS), Swift, or SwiftUI.
- General software/dev conferences with a strong, established Apple-platform track.
- Events around those conferences — meetups, watch parties, hack days, social gatherings (set `"kind": "Event"`).
- Both in-person and online listings.

**No:**
- Single-edition events with no announced future date.
- Vendor sales events.
- Anything that doesn't have a public website with date and location.

**Pending dates are OK:** if a conference has announced "we're back in 2027" but no day-precise date yet, open an Issue and we'll add it when the dates land.

---

## Legal

A reminder of how this project treats third-party material — relevant to anything you submit:

- **Descriptions are paraphrased.** Don't paste the site's marketing text verbatim. One factual sentence in your own words is the goal.
- **Logos are never bundled.** `logoURL` points at the conference's own image, and the app fetches it at runtime (same pattern as iMessage / Slack link previews). If a site doesn't have a usable image, leave `logoURL` as `null` — the app falls back to a typographic placeholder.
- **Trademarks remain with their owners.** Listing a conference doesn't imply endorsement of it by us, or of us by it.

See [ADR-0002](./docs/decisions/ADR-0002-monetization-and-data-source.md) for the full reasoning.

---

## Code contributions

Bug fix or feature for the app itself? Standard flow:

1. Fork → branch off `develop` (not `main` — `main` is release-only).
2. Match existing patterns. The project is intentionally minimalist; see [`CLAUDE.md`](./CLAUDE.md) and [`docs/VIEW-INVENTORY.md`](./docs/VIEW-INVENTORY.md) before adding any new shared components.
3. Build green: `xcodebuild -project iOS-Conferences.xcodeproj -scheme iOS-Conferences -destination 'generic/platform=iOS Simulator' build`.
4. PR against `develop` with a description of what changed and why.

### Branch target

**All PRs go into `develop`.** `main` is release-only and protected — the maintainer opens `develop → main` release PRs. If you open a PR from the GitHub website, double-check the base branch dropdown reads `develop`, not `main`.

### Commit messages

Use `CONF-<area>: <imperative summary>` — a short area slug, then what the commit does, in the imperative mood.

```
CONF-list: sort conferences by start date
CONF-detail: add tap-to-Maps on the location row
CONF-data: add iOSDevUK 2026
CONF-docs: document the JSON schema
```

- `<area>` is the feature or part of the app touched (`list`, `detail`, `settings`, `data`, `docs`, `a11y`, `marketing`, …).
- Summary is imperative and lower-case ("add", not "added"/"Adds"), no trailing period.
- One logical change per commit; keep data edits (`data/conferences.json`) separate from code changes.

### Pull requests

- **Title:** same `CONF-<area>: <summary>` form as commits.
- **Body:** what changed and *why*; link any related issue (`Closes #12`).
- Keep the PR focused — one feature or fix. Build green before opening.
- Update docs in the same PR when behaviour changes: [`docs/VIEW-INVENTORY.md`](./docs/VIEW-INVENTORY.md) for new/renamed shared components, and add an ADR under `docs/decisions/` for significant design decisions.

The architecture is documented in [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md). Significant design decisions live as ADRs under `docs/decisions/`.
