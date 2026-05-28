# Build Log — iOS-Conferences

> Build-in-public trail. One entry per **postable step** — see `CLAUDE.md` → Build in Public.
> Format: `### YYYY-MM-DD — <step>` then: what changed · screenshot file(s) in `bip/screenshots/` · one line on the *why* / what was hard (the post angle).
> Capture on heavy days, post spread thin across quiet ones.

---

### 2026-05-18 — UI shell stands up on mock data

What changed: Project scaffolded — 3-tab `TabView` (Conferences / Favourites / Settings), `NavigationCoordinator`, the `Conference` / `FavouriteConference` SwiftData models, and the list → detail flow. First runnable build: the conference list renders month-sectioned with search, and tapping a row opens a detail screen. All on mock data, but it walks.

Screenshots: none (mock-data scaffold; not representative of the shipped look).

Post angle: Day one and it already runs end to end — 3 tabs, list, detail, search. Going stock-SwiftUI from the start (no custom design system) is why the shell came together in an afternoon.

---

### 2026-05-18 — Detail screen gets a face: hero banner + filter menu

What changed: Conference detail picked up a typographic hero banner (no bundled logos — name on a hash-derived colour, zero trademark risk), and the list got a format filter menu (All / In person / Online). Tagged the app `v1.0.0` internally.

Screenshots: `screenshots/02-conference-detail.png`

Post angle: Decided against shipping conference logos — legal grey area and someone has to maintain them. A typographic header from a hashed colour looks intentional and never goes stale. Constraint as a feature.

---

### 2026-05-18 — Real conferences bundled in, refresh upsert fixed

What changed: Swapped mock data for 15 real, hand-checked 2026/2027 conferences (WWDC, try! Swift Tokyo, SwiftLeeds, iOSDevUK, …) bundled into the app so first launch is instant and offline-safe. Fixed the cache refresh so a re-fetch upserts instead of duplicating rows.

Screenshots: `screenshots/01-conference-list.png`

Post angle: An aggregator app is only as good as its data — so the 15 conferences are bundled, not fetched. The app is useful the second it opens, even on a plane. Refresh just keeps it fresh.

---

### 2026-05-18 — Suggest-a-conference flow: community contributions, no backend

What changed: Built the Suggest-a-Conference form (name, URL, dates, location, description, optional credit). Primary path emails the developer a structured submission; secondary path opens a pre-filled GitHub Issue. Settings restructured around it — Support / Contribute sections, "Rate the app", "Contact me", "View source on GitHub".

Screenshots: `screenshots/03-settings.png`

Post angle: How do you crowd-source a conference list with no servers and no accounts? A form that hands off to email or a pre-filled GitHub Issue. The contribution flywheel costs €0/month to run.

---

### 2026-05-18 — "Buy me a coffee" tip jar

What changed: Added the StoreKit 2 consumable tip — a repeatable €1.49 "Buy me a coffee" button, given a prominent slot at the top of Settings. No subscriptions, no ads, no upsell nags.

Screenshots: `screenshots/03-settings.png`

Post angle: One IAP, one price, repeatable. If the app saved you time you can tip; if not, nothing nags you. Picking a consumable over a subscription was a deliberate "don't be greedy" call.

---

### 2026-05-18 — Live JSON feed goes live, bundled data becomes the seed

What changed: Published `data/conferences.json` as the canonical open feed in the public repo, added a forgiving date decoder, and flipped the service factory to `LiveConferenceService` — the app now seeds from bundled data on launch, then refreshes from the JSON feed (jsDelivr, with raw GitHub as fallback). Shipped MIT `LICENSE`, `CONTRIBUTING.md`, and the GitHub conference-request issue template.

Screenshots: `screenshots/01-conference-list.png`

Post angle: The conference list is now a plain JSON file in a public repo — anyone can open a PR to fix a date or add an event. Open data, no backend, the app stays current on its own.

---

### 2026-05-19 — App Store submission-ready

What changed: README updated to reflect the landed Phase 4 + 5 work. The app is feature-complete: browse, search, filter, favourite, add-to-calendar via the system event editor, open website in an in-app Safari view, tap-to-Maps, share sheet, suggest-a-conference, and the tip jar. 15 conferences bundled, live feed wired, zero third-party Swift packages. App Store submission is the next gate.

Screenshots: `screenshots/01-conference-list.png`, `screenshots/02-conference-detail.png`, `screenshots/03-settings.png`

Post angle: From empty repo to App-Store-ready in two days — a single-purpose app ("every iOS conference, sorted by date"), built entirely on stock SwiftUI and system frameworks, no dependencies. Submission next.
