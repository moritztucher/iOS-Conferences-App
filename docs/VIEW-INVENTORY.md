# View Inventory — iOS-Conferences

> **Read this file before implementing any new View, ViewModifier, or shared UI component.** If a component matching what you need already exists here, reuse or extend it — do not invent a parallel one. **Update this file whenever you add, rename, or remove a shared component.**

Last updated: 2026-06-10

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
| `ConferencePlaceholder` | `ViewComponents/ConferencePlaceholder.swift` | Typographic fallback shown when a conference has no `logoURL` or `AsyncImage` fails. Initials + hash-derived background colour. | `conference: Conference`, `style: .auto \| .card`, `breathes: Bool = false` | Uses `GeometryReader` to scale to the container. `.auto` (default): centred monogram on small tiles, full mesh hero (mesh + kind watermark + top-leading monogram) above 120pt. `.card`: mesh + watermark for depth but **no monogram** — used as `ConferenceCard`'s background, where the host overlays the conference name as the focal mark. Auto-contrasting ink; stable per-id colour from a **curated 9-tone jewel palette** (deep, desaturated, marigold-friendly — Track A) rendered as a deepened light→dark `MeshGradient`. A `lighten` factor (`> 1`) multiplicatively brightens the base tone *preserving hue + saturation* (vibrant, not a grey wash) — `ConferenceCard` passes a strong value for live tickets so the deep tones read alive, ~1 for past. `breathes: true` (detail hero only) drifts the mesh keypoints sub-perceptually on a 4s loop — the "you've arrived" moment — gated behind reduce-motion. `paletteTone(_:)` exposes the jewel palette for surfaces without a conference to hash (empty-state ghosts). |
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
| `.ticketEmptyStateBackdrop()` (View modifier) | `Features/ConferenceList/Views/TicketEmptyStateBackdrop.swift` | Branded backdrop for list/search empty states (design-audit EMO-1): the marigold `.brandBackground()` wash plus ghost `TicketShape` outlines in `ConferencePlaceholder.paletteTone` jewel tints, so an empty screen still reads as dubdub. | — | Apply to the stock `ContentUnavailableView` (which stays stock on top). Used by `ConferenceListView` (all three empty branches) and `ConferenceSearchView` (prompt + no-results). Ghosts are `accessibilityHidden`. |
| `ConferenceSectionList` | `Features/ConferenceList/Views/ConferenceSectionList.swift` | **Month-primary** (chronological, year folded into the header), each month split into kind groups (Conference → Event → Watch Party) sorted by day→time; **`.plain`** list of full-bleed cards with a trailing favourite swipe action. Shared by the Conferences/Favourites tabs and the Search tab. | `sections: [ConferenceMonthSection], favouriteIDs: Set<String>, namespace: Namespace.ID, onToggleFavourite: (Conference) -> Void` | Host owns the `NavigationStack` + `navigationDestination` and supplies the favourite toggle **and a `@Namespace`**. Each card gets `.matchedTransitionSource(id:in:)`; the host's destination applies `.navigationTransition(.zoom(sourceID:in:))`. Rows clear background/separator/insets so cards float; navigation via a `.background` value-based `NavigationLink` glued to the card so the disclosure indicator stays hidden. **No `.scrollTransition` on rows** — inside a `List` the phase never resolves to identity, so the edge fade applied permanently and drew every card at a flat 0.5 opacity (the "grayed ticket" bug); verify rendered pixels before re-adding any scroll effect. The list hides its own background (`.scrollContentBackground(.hidden)`) for the shared `.brandBackground()` marigold "stage-light" wash. Private `MonthSectionHeader` (serif, pinned, **on a glass capsule** so it stays legible riding over card artwork — design-audit VIS-1; past months recede to 0.55 opacity per the aliveness split, HIER-2) is the section header; private `TypeSubheader` (eyebrow + count) is an inline row shown **only in months that mix kinds** (`ConferenceMonthSection.showsTypeHeaders`). |
| `ConferenceCard` | `Features/ConferenceList/Views/ConferenceCard.swift` | Event-**ticket** card for a conference: the `.card`-style `ConferencePlaceholder` mesh is the card's **only background**; the conference's real artwork appears as a small top-leading **logo badge** (42pt rounded rect, success-only). A `TicketShape` perforation + dashed seam splits the card into a main body (`kind · location` overline + name hero) and a trailing **stub** showing the date as a stacked `JUN / 8–12` block (via `ConferenceDateStyle.stub`). | `conference: Conference, isFavourite: Bool` | Replaces the old stock `ConferenceRow`. Full-bleed artwork was removed (unpredictable og:images fought the overlay text and needed a heavy veil that read as "past"); the controlled mesh canvas means **live tickets carry no scrim at all** — text relies on its own shadows — while past tickets keep the full-card darkening veil (aliveness split, ADR-0007). Live mesh: saturation 1.2 with a **mode-aware** lift (1.2 in dark, 1.0 on the light cream where depth is the pop). **Adaptive height** (ADR-0007): the text drives the height (`.frame(minHeight: 172)`), growing for large Dynamic Type; the fixed-width date **stub** clamps its Dynamic Type (`.dynamicTypeSize(...xxLarge)`) so the numerals stay legible (full date lives in the detail + VoiceOver). Heart marker top-trailing when favourited; the logo badge mutes (desaturate + 0.75 opacity) on past tickets. Private `VerticalDashedLine` draws the perforation. Overline grammar is `[TIME or KIND] · CITY` (HIER-1): timed events lead with the wall-clock time (+ zone abbreviation when online), untimed entries lead with the kind word, location is city-only (`Conference.locationCity`). Premium card redesign, ticket metaphor (matches the collectible-ticket app icons). |

### ConferenceDetail

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceDetailHero` | `Features/ConferenceDetail/Views/ConferenceDetailHero.swift` | Full-bleed **stretchy parallax** hero for the detail screen: image (or `.card` `ConferencePlaceholder` mesh) under a scrim with the name + date overlaid, so the header *is* the title block. Grows on pull-down overscroll (reads `.scrollView` minY). **Clean rectangular bottom edge** — the old `HeroTicketEdge` tear was removed under ADR-0007 because the details below now float as separate glass cards rather than abutting the hero. | `conference: Conference` | First element in the detail `ScrollView`; the screen uses `.ignoresSafeArea(edges: .top)` so the hero bleeds under the nav bar, whose background is hidden until the hero scrolls away. `baseHeight` (300) drives the nav-title reveal threshold. The title block fades out between 80–200pt of scroll so the name never slides un-staged beneath the toolbar (VIS-3). **Aliveness mirrors `ConferenceCard`** so the zoomed hero matches the tapped ticket: live mesh heroes are saturated + mode-aware-lifted with only a slim top scrim (status-bar anchor) and `breathes: true` (MOTION-1); real artwork keeps a text-safe scrim (unpredictable brightness); past heroes desaturate under the shared `pastVeilStops` and hold still. |
| `SafariView` | `Features/ConferenceDetail/Views/SafariView.swift` | UIViewControllerRepresentable wrapping `SFSafariViewController`. | `url: URL` | **TODO: promote to `ViewComponents/`** — also used by `SettingsView` (View source on GitHub) and could be by `SuggestConferenceView` in future. |
| `EventEditorView` | `Features/ConferenceDetail/Views/EventEditorView.swift` | UIViewControllerRepresentable wrapping `EKEventEditViewController` (system event editor sheet). | `event: EKEvent, eventStore: EKEventStore` | Only used in ConferenceDetail today. |

### SuggestConference

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `TimeZonePickerView` | `Features/SuggestConference/Views/TimeZonePickerView.swift` | Calendar-app-style time-zone chooser: searchable list of IANA zones (city title, identifier + zone name subtitle), pushed from the suggest form's "Time Zone" row; selecting pops back. | `selection: Binding<String>` | `cityName(for:)` / `offsetLabel(for:)` are exposed for the form's `LabeledContent` row. |

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
| `ConferenceDetailView` | `Features/ConferenceDetail/Views/ConferenceDetailView.swift` | ConferenceDetail | `ConferenceDetailViewModel` | **ScrollView**-based detail (ADR-0007) led by the stretchy `ConferenceDetailHero`, then floating **`GlassSectionCard`s** in a `GlassEffectContainer` — **About** (blurb) → **When & Where**. The latter holds custom rows: a Date row with a relative **countdown** (`ConferenceDateStyle.countdown`), a **Time** row for timed events (zone abbr), a tappable Location row, and a rounded **MapKit map** (venue `Marker`, geocoded by `VenueLocationService`, "Open in Maps" badge, taps through to Maps). Row icons are accent-tinted; values are stock SF (Dynamic Type preserved). Primary actions are a pinned `.safeAreaInset(.bottom)` `GlassEffectContainer`: **Website** (`.buttonStyle(.glass)`) + **Calendar** (`.glassProminent`). Nav-bar title + toolbar background fade in once the hero scrolls away. Rich `ShareLink` (`SharePreview`). The tab bar is hidden on this screen (`.toolbarVisibility(.hidden, for: .tabBar)`) — the detail is an immersive leaf; the bar returns on pop. |
| `SettingsView` | `Features/Settings/Views/SettingsView.swift` | Settings | `SettingsViewModel` | Stock `Form` (Display, Support, Contribute, Acknowledgements, About) over the shared `.brandBackground()` wash (ADR-0007 Phase 3 — chrome only; rows stay stock). |
| `AppearanceView` | `Features/Settings/Views/AppearanceView.swift` | Settings | `AppIconViewModel` | Pushed from Settings → Display. Two stock `List` sections: **Color Scheme** (segmented `Picker` → System/Light/Dark, persisted via `@AppStorage("settings.colorScheme")`, applied app-wide with `.preferredColorScheme` at the root) and **App Icon** (a row per `AppIcon` case — preview image + title + date/venue subtitle + checkmark, switched via `AppIconService` / `setAlternateIconName`). Icons are collectible Apple-history milestones; default is the ticket-fan icon. |
| `AcknowledgementsView` | `Features/Settings/Views/AcknowledgementsView.swift` | Settings | — | Pushed from Settings via `NavigationLink`. List of credits; each row opens its URL in a `SafariView` sheet. |
| `SuggestConferenceView` | `Features/SuggestConference/Views/SuggestConferenceView.swift` | SuggestConference | `SuggestConferenceViewModel` | Sheet form. **When** section is Calendar-app style: All-day toggle (default on) whose off state reveals the time components on the Starts/Ends `DatePicker`s plus a pushed `TimeZonePickerView` row; **Where** holds the location field. `.safeAreaInset(.bottom)` stacks primary "Email suggestion" (`.glassProminent`) + secondary "Submit as GitHub Issue instead". The submission body keeps the fixed 24h `HH:mm` + IANA-identifier format (`ConferenceDateStyle.submissionTimeRange`). |

---

## View Modifiers & Styles

Custom `ViewModifier`, `ButtonStyle`, `LabelStyle`, etc.

| Modifier / Style | File | Apply via | Purpose |
|------------------|------|-----------|---------|
| `Theme` (brand layer) | `Core/Theme/Theme.swift` | `Theme.accent`, `Theme.serif(_:weight:)`, `Theme.ticketNumerals(_:)`, `Theme.eyebrowTracking` | The signature brand levers (ADR-0006) + the app's named type roles. `Theme.accent` mirrors the `AccentColor` asset (warm marigold, applied app-wide via `.tint` at the root; the asset carries **light/dark variants** — a deep burnt marigold on light for ~4.8:1 contrast on white, the bright marigold on dark). **Type roles:** `serif(_:)` = *display* (New York; conference names + month mastheads only); `ticketNumerals(_:)` = the rounded-heavy date-stub day (the only `design: .rounded` in the app — a deliberate "ticket numeral"); the eyebrow role is applied via the `.eyebrow()` modifier below. All other text stays stock SF. No bundled fonts; no second brand colour. |
| `.eyebrow()` (View modifier) | `Core/Theme/Theme.swift` | `.eyebrow(_:weight:)` | The **eyebrow** type role: small uppercase, tracked SF above a display title — the `kind · location` overlines (card + hero), the stub month, and the kind sub-dividers. Bundles font + `Theme.eyebrowTracking` + uppercasing so every overline matches; foreground colour is left to the caller (white over imagery, secondary in lists). Extracted per the "modifier used in 3+ places" rule. |

> Beyond the ticket system (ADR-0004) and the two `Theme` levers above, we still avoid custom styles per ADR-0003 — check for a system style first.

---

## Promotion rules

- A feature-scoped component used by **2+ features** should be promoted to `ViewComponents/`.
- A modifier applied in **3+ places** should be extracted into a named `ViewModifier`.
- When promoting, move the file, update imports, and move the row from the feature section to the shared section here.

**Pending promotion:** `SafariView` is in `Features/ConferenceDetail/Views/` but is also imported by `SettingsView`. Move to `ViewComponents/SafariView.swift` next time anyone touches either file.
