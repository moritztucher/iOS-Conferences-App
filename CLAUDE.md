@~/.claude/docs/ios/ios-guide.md

## Role

You are a senior iOS engineer. Apply the judgment of someone who has shipped production apps for years — question requirements that conflict with platform conventions, prefer Apple-native APIs, and call out work that would not pass a senior code review. **Project-specific reinforcement (ADR-0003 → 0004 → 0006 → 0007):** push custom **as far as possible by composing Liquid Glass** (ADR-0007), never by reinventing system controls. The Conferences list (ticket cards) and the detail hero are a bespoke premium "ticket" design (`TicketShape`, `HeroTicketEdge`, scrims, zoom transition); custom chrome elsewhere is built from `.glassEffect(in:)` / `GlassEffectContainer` / `.buttonStyle(.glass|.glassProminent)` — extend those systems rather than reinventing (check `docs/VIEW-INVENTORY.md` first). Identity is carried by exactly **two** brand levers (ADR-0006): a warm **marigold accent** (`Theme.accent`) and the **system serif** (`Theme.serif`) for *display* moments only (conference names, month mastheads); SF for all other text. **Accessibility, Dynamic Type, and dark-mode parity are hard acceptance criteria** — they survive because the custom layer rides on system glass + semantic styles. **Stay stock** for text input, pickers, toggles, the Settings `Form` rows, `EKEventEditViewController`, `ShareLink`, `Map`, and `ContentUnavailableView` — reinventing those loses accessibility for no identity gain. No onboarding flow; push back on *new* custom colours/fonts or bundled typefaces beyond the two levers.

## View Inventory

Read `docs/VIEW-INVENTORY.md` before implementing any new View, ViewModifier, or shared UI component. If a matching component already exists, reuse or extend it. When you add, rename, or delete a shared component, update `docs/VIEW-INVENTORY.md` in the same diff. The inventory now includes the bespoke ticket system (`TicketShape`, `ConferenceCard`, `ConferenceDetailHero`, `HeroTicketEdge`) — extend those for list/detail visuals; outside that, still prefer stock SwiftUI over new custom components.

# iOS-Conferences

A conference aggregator app for iOS. Browse upcoming developer/tech conferences sorted chronologically, view detail pages with date/location/description/link, mark favourites, add events to the system calendar, and open the conference website in an in-app Safari view.

## Scope & Philosophy

- **One job, done well:** "all the conferences in one place, sorted by date." Resist scope creep.
- **No backend, no accounts.** Data source is a JSON file in the public GitHub repo; favourites live locally.
- **Open source.** Repo is (or will be) public under MIT. The conference list is community-curated via PRs.
- **Community contributions:** in-app "Suggest a conference" form pre-fills a GitHub Issue and opens it in Safari — no backend needed.
- **No in-app monetization.** No subscriptions, no ads, no tips, no upsells. The app is fully free.
- **Design direction (ADR-0003 → 0004 → 0006 → 0007):** push custom **as far as possible by composing Liquid Glass**, never by reinventing system controls (ADR-0007). The list + detail use a bespoke **ticket** identity (`TicketShape`/`HeroTicketEdge`, full-bleed imagery + scrims, parallax hero, zoom transition, gated motion/haptics); custom chrome elsewhere uses `.glassEffect(in:)` / `GlassEffectContainer` and the system glass button styles (`.glass` / `.glassProminent`). Two brand levers carry voice (ADR-0006): a **marigold accent** (`Theme.accent`) and the **system serif** (`Theme.serif`) for display moments only. **Hard constraints (ADR-0007):** accessibility, Dynamic Type, and dark-mode parity are preserved *because* the custom layer rides on system glass + semantic styles. **Stay stock** for text input, pickers, toggles, the Settings `Form` rows, and deep system integrations (EventKit, Maps, ShareLink, `ContentUnavailableView`) — that's where a custom rebuild would *lose* accessibility for no identity gain. **No onboarding flow.**

## Project Config

| Setting | Value |
|---------|-------|
| Bundle ID | `com.pocketapps.conferences` |
| iOS Target | iOS 26+ |
| Design Language | Liquid Glass (iOS 26 default — `.glassEffect()`, `GlassEffectContainer`, system toolbar/tab adoption) |
| Database | SwiftData |
| Git Prefix | CONF |

## Commit Convention

`CONF-<area>: <imperative summary>` — e.g. `CONF-list: sort conferences by start date`.

## Technical Decisions

| Area | Choice | Rationale |
|------|--------|-----------|
| Networking | REST | Fetch conference data from a JSON feed/API. Wrapped in `NetworkService`. |
| Auth | None | Browse-only app, no user accounts. |
| Navigation | Simple `NavigationStack` | List → Detail flow. Coordinator with `NavigationPath` so it scales if tabs are added later. |
| Data Source | `conferences.json` in the public GitHub repo (or `cdn.jsdelivr.net` mirror) | Zero backend cost; community-curated via PRs. See ADR-0002. |
| Sync Strategy | Local-only | SwiftData caches the fetched conference list; refresh-on-pull. No multi-device sync. |
| Offline Support | Offline-first with sync | Users can browse cached conferences without a network. Refresh updates the cache. |
| Favourites | Local-only SwiftData, separate `FavouriteConference` model | Survives cache refresh; no accounts needed. |
| Monetization | None | No IAP, no subscriptions, no ads. |
| Community contributions | In-app "Suggest a conference" form → opens a pre-filled GitHub Issue in `SFSafariViewController` | No backend; fits the open-source contribution flywheel. `mailto:` fallback if GitHub is unavailable. |
| Biometrics | No | No authenticated state to gate. |
| Keychain | No | No credentials to store. |
| Heavy background work | No | Lightweight JSON fetch + SwiftData writes. |
| Accessibility | Standard | VoiceOver labels on all interactive elements, Dynamic Type support. |

## Third-Party / System Frameworks

| Framework | Purpose |
|-----------|---------|
| SwiftData | Local cache of conference list + favourites |
| EventKit | Add a conference to the user's calendar |
| SafariServices (`SFSafariViewController`) | Open the conference website + GitHub Issue suggestion link |
| StoreKit | In-app review prompt via `RequestReviewAction` |
| SwiftUI Liquid Glass APIs (iOS 26+) | `.glassEffect()`, `GlassEffectContainer`, system toolbar/tab Liquid Glass adoption |

## Legal & Content Notes

- **Conference data:** store only objective facts (name, date, location, URL). Avoid copying long verbatim descriptions from conference sites; paraphrase or display only short factual blurbs.
- **Trademarks/logos:** do not bundle conference logos. MVP uses a typographic header (large name + hash-derived colour) — zero risk. A later polish pass may fetch the site's `og:image` at runtime (same pattern as iMessage/Slack link previews); cached short-term, never redistributed.
- **Linking out to sites that sell tickets:** safe. We are not the seller, do not take commission, and the in-app Safari view shows the true URL bar so users can see they're on the organiser's site. Avoid framing CTAs as "Buy" with our branding — use "Visit website" / "Official site". If affiliate links are ever added, label them ("Sponsored" / "Affiliate") and re-check Apple Guideline 3.1.1.
- **Linking:** opening URLs in `SFSafariViewController` is the chosen pattern. Do not wrap external sites in our chrome or frame them as our own content.
- **Data source:** prefer official APIs/feeds (Sessionize, Pretalx, conference RSS) over scraping. If scraping, respect `robots.txt` and the site's ToS.
- **Privacy:** no user accounts and no personal data collected initially → low-risk for GDPR. Add a `PrivacyInfo.xcprivacy` file before App Store submission. If calendar permission is requested, include a clear `NSCalendarsUsageDescription`.

## UI Shape (per ADR-0003 + ADR-0004)

**Root navigation: 3-tab `TabView`** (+ a `Tab(role: .search)`) — Liquid Glass auto-adopted
- **Conferences** — list of all upcoming conferences
- **Favourites** — same list view, filtered
- **Settings** — `Form` with Display / Support / Contribute / About sections
- **Search** — global search tab hosting `ConferenceSearchView`

**Conference list** (bespoke ticket cards — `ConferenceSectionList`):
- Large nav title; region + filter menus in the toolbar (both multi-select, stay open while toggling).
- Grouped **month-primary** (`JUNE 2026`, year folded in), then by kind (Conference → Event → Watch Party) with editorial sub-dividers + counts shown only in mixed months. Sorted day → time within.
- Rows are `ConferenceCard`: full-bleed image / mesh placeholder, `TicketShape` perforation + notches, date stub, `kind · location` (+ time for timed events) overline, name as hero. Swipe-to-favourite. Tapping zooms into the detail hero (`matchedTransitionSource` + `.navigationTransition(.zoom)`).
- Past hidden by default (Settings toggle). `.refreshable` pull-to-refresh. `ContentUnavailableView` for empty states.

**Conference detail:**
1. `ConferenceDetailHero` — full-bleed stretchy parallax hero (`HeroTicketEdge` tear line); name + date overlaid; nav-bar title fades in on scroll.
2. Toolbar: favourite toggle (`heart`/`heart.fill`, springs), `ShareLink`.
3. Stock `Form` sections below the hero: embedded **Map** card, **When & Where**, **About**.
4. Pinned `.safeAreaInset(.bottom)` action bar: **Website** + **Add to Calendar** (`EKEventEditViewController`; timed events anchored to the venue/feed time zone).

**Settings:** stock `Form` with Display / Support (rate, contact) / Contribute (suggest, view source) / About sections. Suggest-a-conference opens an in-app form (sheet) → pre-filled GitHub Issue in Safari.

**Custom is broad now (ADR-0007): compose custom chrome on Liquid Glass.** Use `.glassEffect(in:)` / `GlassEffectContainer` / `.buttonStyle(.glass|.glassProminent)` for bespoke containers and floating actions. Still forbidden / required:
- No custom colours beyond the marigold accent (`Theme.accent` / `AccentColor` asset — ADR-0006); no second brand colour
- No custom/bundled fonts; the system serif (`Theme.serif`) is for display moments only (names + month mastheads), SF everywhere else
- **Don't reinvent system controls** — text input, pickers, toggles, the Settings `Form` rows, `EKEventEditViewController`, `ShareLink`, `SFSafariViewController`, `Map`, `ContentUnavailableView` stay stock (that's where a custom rebuild loses accessibility/Dynamic Type for no gain)
- Accessibility, Dynamic Type, and dark-mode parity are hard acceptance criteria — semantic fonts, no fixed-height text containers, VoiceOver labels on custom controls, reduce-motion-gated motion
- No onboarding flow

## Suggest a Conference

- **Entry point:** a row in Settings labelled "Suggest a conference" + a small button in the empty state of the list.
- **Form fields:** name, website URL, start date, end date, optional start/end time (24h `HH:mm`, for watch parties/events), optional IANA time zone (for online timed events), city/country (or "Online"), one-line description, your name (optional, credits the contributor in the PR).
- **On submit:** construct a URL of the form
  `https://github.com/<owner>/<repo>/issues/new?template=conference-request.yml&title=...&body=...`
  populated with the form data, and open it in `SFSafariViewController`. The user finishes the submission on GitHub (signs in if not already).
- **Fallback:** if `canOpenURL` fails for the GitHub URL, fall back to a `mailto:` with the same body.
- **Footer escape hatch:** a small "Already discussed? Comment on the running thread →" link pointing at a single pinned `Suggestions` issue in the repo, for users who'd rather drop a one-liner than fill the form.

## Project-Specific Rules

- Keep the `Conference` model in `Core/Models/` (shared across the list and detail features).
- Conference list data lives in `Features/ConferenceList/`; detail in `Features/ConferenceDetail/`.
- Date formatting is centralised — never inline `DateFormatter` in a View.
- **No secrets in the repo.** The repo is (or will be) public. No API keys, no private endpoints. The conference data URL is allowed to be public.
- Favourites are stored by **conference ID only** in a separate SwiftData model — never mutate the cached `Conference` to track favourite state.
