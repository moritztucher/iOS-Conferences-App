@~/.claude/docs/ios/ios-guide.md

## Role

You are a senior iOS engineer. Apply the judgment of someone who has shipped production apps for years — question requirements that conflict with platform conventions, prefer Apple-native APIs, and call out work that would not pass a senior code review. **Project-specific reinforcement:** ADR-0003 mandates ecosystem-native design — push back on any suggestion that would add custom design tokens, custom `.glassEffect()` usage, custom empty states, or an onboarding flow.

## View Inventory

Read `VIEW-INVENTORY.md` before implementing any new View, ViewModifier, or shared UI component. If a matching component already exists, reuse or extend it. When you add, rename, or delete a shared component, update `VIEW-INVENTORY.md` in the same diff. Given this project's ecosystem-native stance, the inventory should stay small — prefer stock SwiftUI components over custom ones.

# iOS-Conferences

A conference aggregator app for iOS. Browse upcoming developer/tech conferences sorted chronologically, view detail pages with date/location/description/link, mark favourites, add events to the system calendar, and open the conference website in an in-app Safari view.

## Scope & Philosophy

- **One job, done well:** "all the conferences in one place, sorted by date." Resist scope creep.
- **No backend, no accounts.** Data source is a JSON file in the public GitHub repo; favourites live locally.
- **Open source.** Repo is (or will be) public under MIT. The conference list is community-curated via PRs.
- **Community contributions:** in-app "Suggest a conference" form pre-fills a GitHub Issue and opens it in Safari — no backend needed.
- **Monetization:** a repeatable €1.49 "buy me a coffee" tip via StoreKit 2 (consumable). No subscriptions, no ads, no upsell nags.
- **Design direction (ADR-0003):** ecosystem-native. Zero custom design tokens — system tint, system fonts, SF Symbols, stock `List` / `Form` / `TabView`. **No `.glassEffect()` on custom views** (system applies Liquid Glass to tabs/toolbars/sheets automatically). Deep system integrations (EventKit, Maps, ShareLink, Spotlight, App Intents) carry the "feels like Apple built it" weight. **No onboarding flow.**

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
| Monetization | StoreKit 2 **consumable** IAP (~€1.49 tip, repeatable) | User can tip multiple times. Apple requires IAP for developer tips (Guideline 3.1.1). No RevenueCat — overkill for one product. See ADR-0002. |
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
| StoreKit 2 | Consumable €1.49 "Buy me a coffee" tip (repeatable) |
| SwiftUI Liquid Glass APIs (iOS 26+) | `.glassEffect()`, `GlassEffectContainer`, system toolbar/tab Liquid Glass adoption |

## Legal & Content Notes

- **Conference data:** store only objective facts (name, date, location, URL). Avoid copying long verbatim descriptions from conference sites; paraphrase or display only short factual blurbs.
- **Trademarks/logos:** do not bundle conference logos. MVP uses a typographic header (large name + hash-derived colour) — zero risk. A later polish pass may fetch the site's `og:image` at runtime (same pattern as iMessage/Slack link previews); cached short-term, never redistributed.
- **Linking out to sites that sell tickets:** safe. We are not the seller, do not take commission, and the in-app Safari view shows the true URL bar so users can see they're on the organiser's site. Avoid framing CTAs as "Buy" with our branding — use "Visit website" / "Official site". If affiliate links are ever added, label them ("Sponsored" / "Affiliate") and re-check Apple Guideline 3.1.1.
- **Linking:** opening URLs in `SFSafariViewController` is the chosen pattern. Do not wrap external sites in our chrome or frame them as our own content.
- **Data source:** prefer official APIs/feeds (Sessionize, Pretalx, conference RSS) over scraping. If scraping, respect `robots.txt` and the site's ToS.
- **Privacy:** no user accounts and no personal data collected initially → low-risk for GDPR. Add a `PrivacyInfo.xcprivacy` file before App Store submission. If calendar permission is requested, include a clear `NSCalendarsUsageDescription`.

## UI Shape (per ADR-0003)

**Root navigation: 3-tab `TabView`** (Liquid Glass auto-adopted)
- **Conferences** — list of all upcoming conferences
- **Favourites** — same list view, filtered
- **Settings** — `Form` with Support / Contribute / About sections

**Conference list:**
- Large nav title.
- `.searchable` (name + location).
- `Section` per month (`MAY 2026`, etc.).
- Row: `Label` style — primary = name, secondary = "Jun 8–12 · Cupertino".
- Sort ascending by `startDate`. Past hidden by default (toggle in Settings).
- `.refreshable` pull-to-refresh.
- `ContentUnavailableView` for empty states.

**Conference detail** (Calendar-event-detail pattern):
1. `.navigationTitle(.large)` = conference name.
2. Toolbar: favourite toggle (`heart` / `heart.fill`), `ShareLink`.
3. `Form`:
   - Section "When & Where": date row, location row (tap → Apple Maps).
   - Section "About": description text.
   - Section "Actions": row "Visit website" → `SFSafariViewController`; row "Add to calendar" → `EKEventEditViewController` (system event editor sheet).

**Settings:** stock `Form`. Tip-jar row opens the system StoreKit purchase sheet. Suggest-a-conference row opens an in-app form (sheet) that ultimately opens a pre-filled GitHub Issue in Safari.

**Forbidden in code:**
- No custom colours / brand tint
- No custom fonts
- No `.glassEffect()` modifiers on custom views
- No onboarding flow
- No custom empty states (use `ContentUnavailableView`)
- No custom list row backgrounds / cards

## Suggest a Conference

- **Entry point:** a row in Settings labelled "Suggest a conference" + a small button in the empty state of the list.
- **Form fields:** name, website URL, start date, end date, city/country (or "Online"), one-line description, your name (optional, credits the contributor in the PR).
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
- **IAP product IDs** live in a single `IAPProductID.swift` enum; the App Store Connect product is configured separately and is not committed.
- Favourites are stored by **conference ID only** in a separate SwiftData model — never mutate the cached `Conference` to track favourite state.
