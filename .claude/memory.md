# Project Memory

> This file persists context across Claude Code sessions.
> Location: `.claude/memory.md` in project root.

## Decisions

- [2026-05-18] Database: SwiftData — chosen as the local cache for conference data. iOS 18+ target, no need for Realm or CoreData baggage.
- [2026-05-18] iOS target: **iOS 26+** — chosen to adopt Liquid Glass natively and use the latest SwiftUI APIs. Trade-off: smaller addressable market today, but app is non-essential and target audience (devs) updates fast.
- [2026-05-18] Design language: **Liquid Glass** — Apple's iOS 26 translucent material system. Use `.glassEffect()` and `GlassEffectContainer` for emphasised controls; let system toolbar/tab bar adopt it automatically. Guide: `~/.claude/docs/ios/swiftui/LiquidGlass.md`. Full design system to be locked in by `/ios-design-brief`.
- [2026-05-18] Networking: REST — fetch conference list from a JSON feed/API. Wrapped in `NetworkService`; Views/ViewModels never call URLSession directly.
- [2026-05-18] Auth: None — browse-only app, no user accounts. Removes Keychain/biometrics complexity.
- [2026-05-18] Navigation: Simple NavigationStack with NavigationPath coordinator — list → detail today, scalable to tabs later without rewrite.
- [2026-05-18] Sync strategy: Local-only — SwiftData caches the latest fetched list. No CloudKit / multi-device sync needed at MVP.
- [2026-05-18] Offline support: Offline-first with sync — last-fetched list is browsable without network; manual or automatic refresh updates the cache.
- [2026-05-18] Biometrics: No — nothing sensitive to gate.
- [2026-05-18] Heavy background work: No — lightweight JSON + SwiftData writes only.
- [2026-05-18] Accessibility: Standard — VoiceOver labels on interactive elements, Dynamic Type, `accessibilityReduceMotion` check before animations.
- [2026-05-18] Calendar integration: EventKit — add a conference to the system calendar from the detail view. Requires `NSCalendarsUsageDescription`.
- [2026-05-18] External links: `SFSafariViewController` — opens conference websites in-app to preserve domain visibility (avoids passing-off concerns).
- [2026-05-18] Content sourcing: factual data only (name, date, location, URL). Paraphrased descriptions, no verbatim copying of copyrighted blurbs. No bundled trademarked logos.
- [2026-05-18] Scope: deliberately small — "all conferences sorted by date" + favourites. Resist feature creep (no notifications, no submissions UI, no social features at MVP).
- [2026-05-18] Open source: repo will be public under MIT. Implication: no secrets in code; data source must also be public.
- [2026-05-18] Data source: `conferences.json` checked into the public GitHub repo. Fetched at runtime from raw.githubusercontent.com or a jsdelivr CDN mirror. Contributors add conferences via PRs — zero hosting cost, version-controlled, community-curated.
- [2026-05-18] Favourites: local-only via a separate SwiftData `FavouriteConference` model that stores just `conferenceID`. Decoupled from the cached Conference so cache refresh never wipes favourites.
- [2026-05-18] Monetization: **consumable** StoreKit 2 IAP at ~€1.49, repeatable, branded "Buy me a coffee ☕". Consumable (not non-consumable) so users can tip multiple times. No "Restore Purchases" needed (consumables can't be restored). Tip count tracked locally in UserDefaults for the "thanks 💛" UX. Apple requires IAP for developer tips (Guideline 3.1.1). RevenueCat skipped — overkill for one product.
- [2026-05-18] No subscriptions, no ads, no upsells.
- [2026-05-18] "Suggest a conference" feature: in-app form that pre-fills a GitHub Issue and opens it in `SFSafariViewController`. Uses the `issues/new?template=...&title=...&body=...` URL format. Falls back to `mailto:` if the GitHub URL can't be opened. No backend — fits the open-source contribution flywheel.
- [2026-05-18] UI direction (ADR-0003): **ecosystem-native, zero custom design tokens**. Stock `List` / `Form` / `TabView`, system tint, system fonts, SF Symbols, `ContentUnavailableView`, `.searchable`, `.refreshable`, `ShareLink`. No `.glassEffect()` on custom views — system applies Liquid Glass automatically. No onboarding, no launch animation, no brand colour. Differentiation comes from deep system integrations (EventKit, Maps, Spotlight, App Intents), not visual identity.
- [2026-05-18] Navigation: **3-tab TabView** (Conferences / Favourites / Settings). Earlier "filter chip for favourites" idea dropped — tabs are more native (Music/Podcasts/App Store pattern).
- [2026-05-18] Detail view: **Calendar event detail pattern** — large nav title + `Form` with sections for When/Where, About, Actions. Earlier "typographic header on hash-derived colour band" dropped — too custom.
- [2026-05-18] Calendar integration: use **`EKEventEditViewController`** (system event editor sheet), not programmatic `EKEvent.save()`. User picks calendar, sets alerts, edits details. This is what Mail uses when creating an event from a date in an email.
- [2026-05-18] Location row: taps open Apple Maps via `MKMapItem.openInMaps`.
- [2026-05-18] Sharing: `ShareLink` in detail toolbar.
- [2026-05-18] Immediately post-MVP integrations: Spotlight (`CSSearchableItem` for favourites) and App Intents (`Conference` as `AppEntity`, intent "What's the next conference?"). Deferred post-MVP: WidgetKit, Live Activities, Universal Links.
- [2026-05-18] Permissions asked at point of use, never upfront. If denied → inline link to system Settings via `UIApplication.openSettingsURLString`.

## Preferences

- User prefers terse output and reasonable defaults over clarifying questions.

## Common Issues

<!-- Add as encountered -->

## Notes

- User email: tucher@pocketapps.studio
- Legal questions answered at init:
  1. Listing conferences is legal — factual data only, paraphrased descriptions, no bundled trademarked logos, respect ToS/robots.txt.
  2. Linking out via `SFSafariViewController` is legal and the safer pattern than embedding/framing.
  3. Linking to ticket-selling sites is legal — we're not the seller. Use neutral CTA labels ("Visit website" not "Buy"). If affiliate links are added later, disclose them and re-check Apple Guideline 3.1.1.
