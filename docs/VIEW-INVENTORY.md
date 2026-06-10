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
| `ConferencePlaceholder` | `ViewComponents/ConferencePlaceholder.swift` | Typographic fallback shown when a conference has no `logoURL` or `AsyncImage` fails. Initials + hash-derived background colour. | `conference: Conference`, `style: .auto \| .card` | Uses `GeometryReader` to scale to the container. `.auto` (default): centred monogram on small tiles, full mesh hero (mesh + kind watermark + top-leading monogram) above 120pt. `.card`: mesh + watermark for depth but **no monogram** — used as `ConferenceCard`'s background, where the host overlays the conference name as the focal mark. Auto-contrasting ink; stable per-id colour from a **curated 9-tone jewel palette** (deep, desaturated, marigold-friendly — Track A) rendered as a deepened light→dark `MeshGradient`. A `lighten` factor (`> 1`) multiplicatively brightens the base tone *preserving hue + saturation* (vibrant, not a grey wash) — `ConferenceCard` passes a strong value for live tickets so the deep tones read alive, ~1 for past. |
| `.unifiedConferenceArtwork()` (View modifier) | `ViewComponents/ConferencePlaceholder.swift` | Tonal-unify treatment for *real* conference artwork (logos, og:images, photos) — gentle desaturation + a multiplied top/bottom darkening — so disparate sources read in the same family as the mesh placeholders (Track A). | — | Applied to the **success** image only, in both `ConferenceCard` and `ConferenceDetailHero`; each surface's own scrim still rides on top for text legibility. |
| `TicketShape` | `ViewComponents/TicketShape.swift` | Event-ticket outline: a rounded rectangle with two punched semicircle notches at a vertical perforation, splitting a card into body + trailing stub. Used to clip `ConferenceCard`. | `cornerRadius`, `notchRadius`, `stubWidth` | Single continuous, non-self-intersecting path → clips correctly with the default winding rule (no even-odd). `perforationX(for:)` exposes the seam x so callers can align a dashed line/stub content. Notches are truly cut, so the list background shows through (theme-robust). |
| `MailComposeView` | `ViewComponents/MailComposeView.swift` | UIViewControllerRepresentable wrapping `MFMailComposeViewController` (in-app mail compose sheet). | `recipient: String, subject: String = "", body: String = ""` | Callers should check `MFMailComposeViewController.canSendMail()` before presenting and fall back to a `mailto:` URL if false. |
| `BrandBackground` | `ViewComponents/BrandBackground.swift` | The app's marigold "stage-light" wash (ADR-0007) — an accent gradient at the top fading into `Color(.systemBackground)`. Applied via the `.brandBackground()` `View` extension. | — | Pair with `.scrollContentBackground(.hidden)` on the `List`/`Form`. Shared by the conference list and the stock Settings `Form`s so every scrolling surface shares the same framing without touching rows. Adapts to light/dark. |
| `GlassSectionCard` | `ViewComponents/GlassSectionCard.swift` | Floating **Liquid Glass** content card (ADR-0007) — the custom replacement for a stock grouped `Form` section on identity surfaces. Optional uppercase eyebrow title over arbitrary content, backed by `.glassEffect(in: .rect(cornerRadius: 24))`. | `title: String? = nil, @ViewBuilder content` | Place inside a `GlassEffectContainer` so adjacent cards blend. Dark mode, vibrancy, and the accessibility transparency/contrast settings are handled by the system because the card rides on system glass. Used by `ConferenceDetailView`. |

---

## Feature Components

Components scoped to a single feature, in `Features/[Feature]/Views/...`. Listed here so they can be promoted to shared when reused elsewhere.

### ConferenceList

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceSectionList` | `Features/ConferenceList/Views/ConferenceSectionList.swift` | **Month-primary** (chronological, year folded into the header), each month split into kind groups (Conference → Event → Watch Party) sorted by day→time; **`.plain`** list of full-bleed cards with a trailing favourite swipe action. Shared by the Conferences/Favourites tabs and the Search tab. | `sections: [ConferenceMonthSection], favouriteIDs: Set<String>, namespace: Namespace.ID, onToggleFavourite: (Conference) -> Void` | Host owns the `NavigationStack` + `navigationDestination` and supplies the favourite toggle **and a `@Namespace`**. Each card gets `.matchedTransitionSource(id:in:)`; the host's destination applies `.navigationTransition(.zoom(sourceID:in:))`. Rows clear background/separator/insets so cards float; navigation via a `.background` value-based `NavigationLink` (glued to the card *before* the scroll transition so the disclosure indicator stays hidden). Cards get a reduce-motion-gated `.scrollTransition` (fade + slight shrink on the viewport edges). The list hides its own background (`.scrollContentBackground(.hidden)`) for the shared `.brandBackground()` marigold "stage-light" wash. Private `MonthSectionHeader` (serif, pinned) is the section header; private `TypeSubheader` (eyebrow + count) is an inline row shown **only in months that mix kinds** (`ConferenceMonthSection.showsTypeHeaders`). |
| `ConferenceCard` | `Features/ConferenceList/Views/ConferenceCard.swift` | Event-**ticket** card for a conference: image (or `.card`-style `ConferencePlaceholder` mesh) fills the card under a bottom scrim; a `TicketShape` perforation + dashed seam splits it into a main body (`kind · location` overline + name hero) and a trailing **stub** showing the date as a stacked `JUN / 8–12` block (via `ConferenceDateStyle.stub`). | `conference: Conference, isFavourite: Bool` | Replaces the old stock `ConferenceRow`. **Adaptive height** (ADR-0007): the text drives the height (`.frame(minHeight: 172)`), so the card grows for large Dynamic Type instead of clipping; the image rides behind as a `.background` (`Color.black.overlay { AsyncImage }.clipped().overlay(scrim)`) pinning any source aspect ratio (square icon vs landscape og:image) to the card bounds. The fixed-width date **stub** clamps its Dynamic Type (`.dynamicTypeSize(...xxLarge)`) so the numerals stay legible (full date lives in the detail + VoiceOver). Heart marker top-trailing of the body when favourited. Private `VerticalDashedLine` shape draws the perforation. Overline shows the local time for timed events (and the zone abbreviation for online ones, e.g. `19:00 PDT · ONLINE`). **Aliveness state**: the artwork carries a `conference.isPast`-driven treatment (applied *under* the scrim, so text contrast is untouched) — upcoming/ongoing tickets are saturated + lifted to read vibrant, past tickets are desaturated, darkened, and veiled so they recede as "already done". Premium card redesign, ticket metaphor (matches the collectible-ticket app icons). |

### ConferenceDetail

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceDetailHero` | `Features/ConferenceDetail/Views/ConferenceDetailHero.swift` | Full-bleed **stretchy parallax** hero for the detail screen: image (or `.card` `ConferencePlaceholder` mesh) under a scrim with the name + date overlaid, so the header *is* the title block. Grows on pull-down overscroll (reads `.scrollView` minY). **Clean rectangular bottom edge** — the old `HeroTicketEdge` tear was removed under ADR-0007 because the details below now float as separate glass cards rather than abutting the hero. | `conference: Conference` | First element in the detail `ScrollView`; the screen uses `.ignoresSafeArea(edges: .top)` so the hero bleeds under the nav bar, whose background is hidden until the hero scrolls away. `baseHeight` (300) drives the nav-title reveal threshold. |
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
| `ConferenceListView` | `Features/ConferenceList/Views/ConferenceListView.swift` | ConferenceList | `ConferenceListViewModel` | Used by both Conferences and Favourites tabs via `init(filter:)`. Renders via `ConferenceSectionList` (month-grouped, type sub-dividers); hosts `.refreshable`, a filter `Menu` (multi-select Kind toggles + Format + past toggle), a separate **region** `Menu` (Global + multi-select `ConferenceRegion` toggles), and the `navigationDestination(for: Route.self)`. Search is no longer per-tab — it lives in the global Search tab. |
| `ConferenceSearchView` | `Features/ConferenceList/Views/ConferenceSearchView.swift` | ConferenceList | `ConferenceListViewModel` | Content for `Tab(role: .search)`. Owns its `.searchable` field (iOS 26 renders it bottom-anchored), filters all conferences by name/location/tag, and renders via `ConferenceSectionList`. Prompt + no-results use `ContentUnavailableView`. |
| `ConferenceDetailView` | `Features/ConferenceDetail/Views/ConferenceDetailView.swift` | ConferenceDetail | `ConferenceDetailViewModel` | **ScrollView**-based detail (ADR-0007) led by the stretchy `ConferenceDetailHero`, then floating **`GlassSectionCard`s** in a `GlassEffectContainer` — **About** (blurb) → **When & Where**. The latter holds custom rows: a Date row with a relative **countdown** (`ConferenceDateStyle.countdown`), a **Time** row for timed events (zone abbr), a tappable Location row, and a rounded **MapKit map** (venue `Marker`, geocoded by `VenueLocationService`, "Open in Maps" badge, taps through to Maps). Row icons are accent-tinted; values are stock SF (Dynamic Type preserved). Primary actions are a pinned `.safeAreaInset(.bottom)` `GlassEffectContainer`: **Website** (`.buttonStyle(.glass)`) + **Calendar** (`.glassProminent`). Nav-bar title + toolbar background fade in once the hero scrolls away. Rich `ShareLink` (`SharePreview`). |
| `SettingsView` | `Features/Settings/Views/SettingsView.swift` | Settings | `SettingsViewModel` | Stock `Form` (Display, Support, Contribute, Acknowledgements, About) over the shared `.brandBackground()` wash (ADR-0007 Phase 3 — chrome only; rows stay stock). |
| `AppearanceView` | `Features/Settings/Views/AppearanceView.swift` | Settings | `AppIconViewModel` | Pushed from Settings → Display. Two stock `List` sections: **Color Scheme** (segmented `Picker` → System/Light/Dark, persisted via `@AppStorage("settings.colorScheme")`, applied app-wide with `.preferredColorScheme` at the root) and **App Icon** (a row per `AppIcon` case — preview image + title + date/venue subtitle + checkmark, switched via `AppIconService` / `setAlternateIconName`). Icons are collectible Apple-history milestones; default is the ticket-fan icon. |
| `AcknowledgementsView` | `Features/Settings/Views/AcknowledgementsView.swift` | Settings | — | Pushed from Settings via `NavigationLink`. List of credits; each row opens its URL in a `SafariView` sheet. |
| `SuggestConferenceView` | `Features/SuggestConference/Views/SuggestConferenceView.swift` | SuggestConference | `SuggestConferenceViewModel` | Sheet form. `.safeAreaInset(.bottom)` stacks primary "Email suggestion" + secondary "Submit as GitHub Issue instead". |

---

## View Modifiers & Styles

Custom `ViewModifier`, `ButtonStyle`, `LabelStyle`, etc.

| Modifier / Style | File | Apply via | Purpose |
|------------------|------|-----------|---------|
| `Theme` (brand layer) | `Core/Theme/Theme.swift` | `Theme.accent`, `Theme.serif(_:weight:)`, `Theme.ticketNumerals(_:)`, `Theme.eyebrowTracking` | The signature brand levers (ADR-0006) + the app's named type roles. `Theme.accent` mirrors the `AccentColor` asset (warm marigold, applied app-wide via `.tint` at the root). **Type roles:** `serif(_:)` = *display* (New York; conference names + month mastheads only); `ticketNumerals(_:)` = the rounded-heavy date-stub day (the only `design: .rounded` in the app — a deliberate "ticket numeral"); the eyebrow role is applied via the `.eyebrow()` modifier below. All other text stays stock SF. No bundled fonts; no second brand colour. |
| `.eyebrow()` (View modifier) | `Core/Theme/Theme.swift` | `.eyebrow(_:weight:)` | The **eyebrow** type role: small uppercase, tracked SF above a display title — the `kind · location` overlines (card + hero), the stub month, and the kind sub-dividers. Bundles font + `Theme.eyebrowTracking` + uppercasing so every overline matches; foreground colour is left to the caller (white over imagery, secondary in lists). Extracted per the "modifier used in 3+ places" rule. |

> Beyond the ticket system (ADR-0004) and the two `Theme` levers above, we still avoid custom styles per ADR-0003 — check for a system style first.

---

## Promotion rules

- A feature-scoped component used by **2+ features** should be promoted to `ViewComponents/`.
- A modifier applied in **3+ places** should be extracted into a named `ViewModifier`.
- When promoting, move the file, update imports, and move the row from the feature section to the shared section here.

**Pending promotion:** `SafariView` is in `Features/ConferenceDetail/Views/` but is also imported by `SettingsView`. Move to `ViewComponents/SafariView.swift` next time anyone touches either file.
