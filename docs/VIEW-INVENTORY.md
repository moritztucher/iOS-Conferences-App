# View Inventory — iOS-Conferences

> **Read this file before implementing any new View, ViewModifier, or shared UI component.** If a component matching what you need already exists here, reuse or extend it — do not invent a parallel one. **Update this file whenever you add, rename, or remove a shared component.**

Last updated: 2026-06-09

---

## How to use this file

1. **Before building a new screen or component:** scan the relevant section below. If something close exists, reuse/extend it.
2. **When adding a new shared component:** add an entry here in the same turn that introduces the file. Treat it as part of the diff.
3. **When renaming or deleting:** update or remove the entry. Stale entries are worse than no entry.
4. **One row per file.** If a file exports multiple subcomponents that are independently reusable, list each.

---

## Shared Components (`ViewComponents/`)

Cross-feature reusable UI. Pure, stateless or self-contained, no feature-specific dependencies.

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferencePlaceholder` | `ViewComponents/ConferencePlaceholder.swift` | Typographic fallback shown when a conference has no `logoURL` or `AsyncImage` fails. Initials + hash-derived background colour. | `conference: Conference`, `style: .auto \| .card` | Uses `GeometryReader` to scale to the container. `.auto` (default): centred monogram on small tiles, full mesh hero (mesh + kind watermark + top-leading monogram) above 120pt. `.card`: mesh + watermark for depth but **no monogram** — used as `ConferenceCard`'s background, where the host overlays the conference name as the focal mark. Auto-contrasting ink; stable per-id colour (9-colour hash palette). |
| `TicketShape` | `ViewComponents/TicketShape.swift` | Event-ticket outline: a rounded rectangle with two punched semicircle notches at a vertical perforation, splitting a card into body + trailing stub. Used to clip `ConferenceCard`. | `cornerRadius`, `notchRadius`, `stubWidth` | Single continuous, non-self-intersecting path → clips correctly with the default winding rule (no even-odd). `perforationX(for:)` exposes the seam x so callers can align a dashed line/stub content. Notches are truly cut, so the list background shows through (theme-robust). |
| `MailComposeView` | `ViewComponents/MailComposeView.swift` | UIViewControllerRepresentable wrapping `MFMailComposeViewController` (in-app mail compose sheet). | `recipient: String, subject: String = "", body: String = ""` | Callers should check `MFMailComposeViewController.canSendMail()` before presenting and fall back to a `mailto:` URL if false. |

---

## Feature Components

Components scoped to a single feature, in `Features/[Feature]/Views/...`. Listed here so they can be promoted to shared when reused elsewhere.

### ConferenceList

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceSectionList` | `Features/ConferenceList/Views/ConferenceSectionList.swift` | Month-sectioned, **`.plain`** list of conferences rendered as floating full-bleed cards with a trailing favourite swipe action. Shared by the Conferences/Favourites tabs and the Search tab so every entry point renders identically. | `sections: [ConferenceMonthSection], favouriteIDs: Set<String>, namespace: Namespace.ID, onToggleFavourite: (Conference) -> Void` | Host owns the `NavigationStack` + `navigationDestination` and supplies the favourite toggle **and a `@Namespace`**. Each card gets `.matchedTransitionSource(id:in:)`; the host's destination applies `.navigationTransition(.zoom(sourceID:in:))`, so tapping a card zooms into the detail hero. Rows clear their background/separator/insets so `ConferenceCard` floats; navigation uses a `.background` value-based `NavigationLink` (full-card tap target, no List chevron). `swipeActions` live here. Month headers use a private editorial `MonthSectionHeader` (bold, tracked, primary, card-aligned) instead of the stock secondary header. |
| `ConferenceCard` | `Features/ConferenceList/Views/ConferenceCard.swift` | Event-**ticket** card for a conference: image (or `.card`-style `ConferencePlaceholder` mesh) fills the card under a bottom scrim; a `TicketShape` perforation + dashed seam splits it into a main body (`kind · location` overline + name hero) and a trailing **stub** showing the date as a stacked `JUN / 8–12` block (via `ConferenceDateStyle.stub`). | `conference: Conference, isFavourite: Bool` | Replaces the old stock `ConferenceRow`. Background built as `Color.clear.overlay { AsyncImage }.clipped().overlay(scrim)` so any source aspect ratio (square icon vs landscape og:image) is pinned to the card bounds. Heart marker top-trailing of the body when favourited. Private `VerticalDashedLine` shape draws the perforation. Premium card redesign, ticket metaphor (matches the collectible-ticket app icons). |

### ConferenceDetail

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceDetailHero` | `Features/ConferenceDetail/Views/ConferenceDetailHero.swift` | Full-bleed **stretchy parallax** hero for the detail screen: image (or `.card` `ConferencePlaceholder` mesh) under a scrim with the name + date overlaid, so the header *is* the title block. Grows on pull-down overscroll (reads `.scrollView` minY). Perforated bottom edge (`HeroTicketEdge` + dashed seam) reads as the torn top of a ticket. | `conference: Conference` | Hosted as the first List row (zeroed insets, clear bg); the list uses `.ignoresSafeArea(edges: .top)` so the hero bleeds under the nav bar, whose background is hidden until the hero scrolls away. `baseHeight` (300) drives the nav-title reveal threshold. Replaced the old flat 180pt `ConferenceHeroBanner`. |
| `HeroTicketEdge` | `Features/ConferenceDetail/Views/ConferenceDetailHero.swift` | Rectangle with two semicircle notches punched into the left/right edges near the bottom — the horizontal ticket "tear line." Clips `ConferenceDetailHero`. | `notchRadius` | Square top corners (full-bleed to screen edges); perforation sits `notchRadius` up from the bottom. Counterpart to the vertical `TicketShape` used by the list cards. |
| `SafariView` | `Features/ConferenceDetail/Views/SafariView.swift` | UIViewControllerRepresentable wrapping `SFSafariViewController`. | `url: URL` | **TODO: promote to `ViewComponents/`** — also used by `SettingsView` (View source on GitHub) and could be by `SuggestConferenceView` in future. |
| `EventEditorView` | `Features/ConferenceDetail/Views/EventEditorView.swift` | UIViewControllerRepresentable wrapping `EKEventEditViewController` (system event editor sheet). | `event: EKEvent, eventStore: EKEventStore` | Only used in ConferenceDetail today. |

### SuggestConference

No feature-scoped reusable components yet.

### Settings

No feature-scoped reusable components yet.

---

## Screens (top-level Views)

Top-level Views that represent a tab root or pushed destination.

| Screen | File | Feature | ViewModel | Notes |
|--------|------|---------|-----------|-------|
| `RootTabView` | `Features/RootTabView.swift` | (root) | — | `TabView`: Conferences / Favourites / Settings + a `Tab(role: .search)` (iOS 26 search affordance in the tab bar) hosting `ConferenceSearchView`. |
| `ConferenceListView` | `Features/ConferenceList/Views/ConferenceListView.swift` | ConferenceList | `ConferenceListViewModel` | Used by both Conferences and Favourites tabs via `init(filter:)`. Renders via `ConferenceSectionList`; hosts `.refreshable`, filter `Menu`, and the `navigationDestination(for: Route.self)`. Search is no longer per-tab — it lives in the global Search tab. |
| `ConferenceSearchView` | `Features/ConferenceList/Views/ConferenceSearchView.swift` | ConferenceList | `ConferenceListViewModel` | Content for `Tab(role: .search)`. Owns its `.searchable` field (iOS 26 renders it bottom-anchored), filters all conferences by name/location/tag, and renders via `ConferenceSectionList`. Prompt + no-results use `ContentUnavailableView`. |
| `ConferenceDetailView` | `Features/ConferenceDetail/Views/ConferenceDetailView.swift` | ConferenceDetail | `ConferenceDetailViewModel` | List-based detail led by the stretchy `ConferenceDetailHero` (name + date overlaid, so there's no separate title section). Below: an embedded MapKit map card (venue `Marker`, geocoded by `VenueLocationService`, taps through to Maps), When/Where and About sections. The primary actions live in a pinned `.safeAreaInset(.bottom)` bar (`.bar` material): **Website** (bordered) + **Calendar** (bordered-prominent) — no longer an in-list Actions section. Nav-bar title + toolbar background fade in once the hero scrolls away. Rich `ShareLink` (`SharePreview`). |
| `SettingsView` | `Features/Settings/Views/SettingsView.swift` | Settings | `SettingsViewModel` | `Form` with sections: prominent tip CTA (no header), Support, Contribute, Display (past-conferences toggle + `Appearance` `NavigationLink`), About. |
| `AppearanceView` | `Features/Settings/Views/AppearanceView.swift` | Settings | `AppIconViewModel` | Pushed from Settings → Display. Two stock `List` sections: **Color Scheme** (segmented `Picker` → System/Light/Dark, persisted via `@AppStorage("settings.colorScheme")`, applied app-wide with `.preferredColorScheme` at the root) and **App Icon** (a row per `AppIcon` case — preview image + title + date/venue subtitle + checkmark, switched via `AppIconService` / `setAlternateIconName`). Icons are collectible Apple-history milestones; default is the ticket-fan icon. |
| `AcknowledgementsView` | `Features/Settings/Views/AcknowledgementsView.swift` | Settings | — | Pushed from Settings via `NavigationLink`. List of credits; each row opens its URL in a `SafariView` sheet. |
| `SuggestConferenceView` | `Features/SuggestConference/Views/SuggestConferenceView.swift` | SuggestConference | `SuggestConferenceViewModel` | Sheet form. `.safeAreaInset(.bottom)` stacks primary "Email suggestion" + secondary "Submit as GitHub Issue instead". |

---

## View Modifiers & Styles

Custom `ViewModifier`, `ButtonStyle`, `LabelStyle`, etc.

| Modifier / Style | File | Apply via | Purpose |
|------------------|------|-----------|---------|
| _(none)_ | — | — | Per ADR-0003 (ecosystem-native), we deliberately have no custom styles. If you find yourself needing one, first check whether a system style covers it. |

---

## Promotion rules

- A feature-scoped component used by **2+ features** should be promoted to `ViewComponents/`.
- A modifier applied in **3+ places** should be extracted into a named `ViewModifier`.
- When promoting, move the file, update imports, and move the row from the feature section to the shared section here.

**Pending promotion:** `SafariView` is in `Features/ConferenceDetail/Views/` but is also imported by `SettingsView`. Move to `ViewComponents/SafariView.swift` next time anyone touches either file.
