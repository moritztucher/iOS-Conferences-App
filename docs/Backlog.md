# Backlog

> Task backlog organized by category and priority.
> Claude will ask before modifying this file.

## Features

### High Priority
- [ ] Set up project folder structure and `NavigationCoordinator` (NavigationPath-based)
- [ ] Define `Conference` SwiftData model (id, name, startDate, endDate, location, summary, websiteURL, tags)
- [ ] Define `FavouriteConference` SwiftData model (conferenceID, favouritedAt) — separate from `Conference`
- [ ] Create `data/conferences.json` schema and a starter file with 5–10 real conferences
- [ ] Write `CONTRIBUTING.md` documenting the JSON schema for PRs
- [ ] Implement `NetworkService` with base URL configured to the jsDelivr-mirrored `conferences.json` (fallback to raw GitHub URL)
- [ ] Implement `ConferenceService` that reads from SwiftData, refreshes via the JSON URL, and writes back to the cache
- [ ] Build `ConferenceListView` + `ConferenceListViewModel` — sorted by `startDate`, pull-to-refresh, favourite toggle from row
- [ ] Build `ConferenceDetailView` + `ConferenceDetailViewModel` — typographic header (no logo), location, date(s), description, "Visit website" button, "Save to calendar" button, favourite toggle
- [ ] Build `FavouritesView` — filtered list of favourited conferences (reuse the list row)
- [ ] Implement `CalendarManager` that presents `EKEventEditViewController` (UIKit-bridged) — system event editor sheet, NOT programmatic `EKEvent.save()`
- [ ] Wire location row → opens Apple Maps via `MKMapItem.openInMaps` with the city as the pin
- [ ] Add `ShareLink` to the detail view toolbar
- [ ] Use `ContentUnavailableView` for all empty states (no data, no favourites, no search results)
- [ ] Add `.searchable` to the conference list (filter by name + location)
- [ ] Add `.refreshable` to the conference list
- [ ] Build `SettingsView` with "Suggest a conference" link and about / license attribution
- [ ] Build `SuggestConferenceView` — form fields (name, URL, dates, location, description, optional contributor name) → constructs a pre-filled GitHub Issue URL → opens in `SFSafariViewController`; `mailto:` fallback
- [ ] Add `.github/ISSUE_TEMPLATE/conference-request.yml` with structured fields matching the in-app form
- [ ] Pin a `Suggestions` issue in the repo to receive low-friction comment-based submissions (linked from the form footer)
- [ ] Liquid Glass: rely entirely on system adoption (TabView, toolbar, sheets). **Do not** add `.glassEffect()` to custom views.
- [ ] Root: 3-tab `TabView` (Conferences / Favourites / Settings). Favourites tab reuses the list view with the favourites filter applied at ViewModel level.
- [ ] Wire `SFSafariViewController` for the "Open Website" button
- [ ] Add `NSCalendarsUsageDescription` to Info.plist
- [ ] Implement offline-first cache: first paint from SwiftData, refresh in background, update store

### Medium Priority
- [ ] Section the list by month using `Section` (header = "MAY 2026", etc.)
- [ ] Add basic filters (region, topic, in-person/online) — only if needed; `.searchable` may cover most use cases
- [ ] Date formatting helper (centralised — no inline `DateFormatter` in Views)
- [ ] Hide past conferences by default + "Show past conferences" toggle in Settings
- [ ] Add `PrivacyInfo.xcprivacy` ahead of App Store submission
- [ ] Write `README.md` (what / why / how to run / how to contribute / license)
- [ ] Add `LICENSE` (MIT)
- [ ] Decide repo name and push to GitHub (public)

### Immediately Post-MVP (ecosystem integrations)
- [ ] Spotlight: index favourited conferences with `CSSearchableItem`. Tap from system search deep-links to the detail view.
- [ ] App Intents: `Conference` as `AppEntity` + intent "What's the next conference?" (Siri / Shortcuts).
- [ ] Deep-link handler so Spotlight/App-Intent results open the right detail view.

### Conferences to add (research pending)
- [ ] **NextAppCon** (`https://www.nextappcon.com`) — site is a JS-only SPA, dates/location couldn't be auto-extracted. Manual entry needed.
- [ ] **NSSpain** — 2026 not announced yet (last edition Sep 2025, Logroño). Add when dates land.
- [ ] **try! Swift x AI** — only the Sept 2025 online workshop ran. Add if/when a future edition is announced.
- [ ] **Pre-WWDC Bashcade** — RevenueCat luma event (June 2025). Add if a 2026 edition is scheduled.
- [ ] **One More Thing** — June 2025 was the last edition; 2026 hinted via sponsorship CTA. Add when dates confirmed.

### Low Priority (post-MVP, deferred)
- [ ] WidgetKit widget showing the next 1–3 conferences (small + medium)
- [ ] Live Activity for conferences happening today/this week (Dynamic Island countdown)
- [ ] Universal Links: `https://<domain>/conf/<id>` opens detail
- [ ] Settings screen advanced options (region default, refresh frequency)

## Bugs

### High Priority
- [ ]

### Medium Priority
- [ ] Optional icon polish: 2026 stub omits the silver "WWDC26" wordmark under the metallic Apple (looks great without it — decide if the lockup is wanted); 1984 rainbow runs red-top rather than canonical green-top (full six bands, edge to edge — cosmetic).

### Low Priority
- [ ]

## Tech Debt

### High Priority
- [ ]

### Medium Priority
- [ ] Centralise theme / spacing tokens once `/ios-design-brief` runs

### Low Priority
- [ ]

## Ideas

> Future considerations, not committed to implementation.

- [ ] Favourites / watch-list (would require either local-only persistence or eventually accounts)
- [ ] Notifications for conferences I'm watching ("CFP closes in 7 days")
- [ ] Submit-a-conference flow (community-curated)
- [ ] Apple Sign-In + CloudKit sync if favourites become a thing
- [ ] WidgetKit widget showing the next 3 conferences
- [ ] Single-favourite countdown widget (small) — see `feature-ideas-2026-06-07.md`
- [ ] Local "I'm attending" flag → drives Live Activity — see `feature-ideas-2026-06-07.md`
- [ ] visionOS / iPad layout

> 2026-06-07 brainstorm (Live Activity, attendance, schedule-pull, countdown widget) documented with trade-offs in `feature-ideas-2026-06-07.md`.
