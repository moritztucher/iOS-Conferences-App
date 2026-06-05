# View Inventory — iOS-Conferences

> **Read this file before implementing any new View, ViewModifier, or shared UI component.** If a component matching what you need already exists here, reuse or extend it — do not invent a parallel one. **Update this file whenever you add, rename, or remove a shared component.**

Last updated: 2026-05-18

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
| `ConferencePlaceholder` | `ViewComponents/ConferencePlaceholder.swift` | Typographic fallback shown when a conference has no `logoURL` or `AsyncImage` fails. Initials + hash-derived background colour. | `conference: Conference` | Uses `GeometryReader` to scale text to the container — works at 44pt thumbnail or 180pt hero. Auto-contrasting initials on a subtle top-lighter→base **gradient** derived from a stable per-id colour (9-colour hash palette via `gradient(for:)`). |
| `MailComposeView` | `ViewComponents/MailComposeView.swift` | UIViewControllerRepresentable wrapping `MFMailComposeViewController` (in-app mail compose sheet). | `recipient: String, subject: String = "", body: String = ""` | Callers should check `MFMailComposeViewController.canSendMail()` before presenting and fall back to a `mailto:` URL if false. |

---

## Feature Components

Components scoped to a single feature, in `Features/[Feature]/Views/...`. Listed here so they can be promoted to shared when reused elsewhere.

### ConferenceList

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceSectionList` | `Features/ConferenceList/Views/ConferenceSectionList.swift` | Month-sectioned, inset-grouped list of conferences with a trailing favourite swipe action. Shared by the Conferences/Favourites tabs and the Search tab so every entry point renders rows identically. | `sections: [ConferenceMonthSection], favouriteIDs: Set<String>, onToggleFavourite: (Conference) -> Void` | Host owns the `NavigationStack` + `navigationDestination` and supplies the favourite toggle. The `swipeActions` (favourite/unfavourite, pink/gray) live here. |
| `ConferenceRow` | `Features/ConferenceList/Views/ConferenceRow.swift` | Row cell for a conference in the list (logo + name + favourite marker + secondary line: kind glyph · date · location, with a `globe` glyph for online events). | `conference: Conference, isFavourite: Bool` | Used by both list tabs and the Search tab via `ConferenceSectionList`. |
| `ConferenceLogo` | `Features/ConferenceList/Views/ConferenceRow.swift` | 44pt rounded `AsyncImage` thumbnail with `ConferencePlaceholder` fallback. | `conference: Conference, size: CGFloat` | Lives next to `ConferenceRow` (same file) since it's only used by the row. Promote to `ViewComponents/` if another feature needs it. |

### ConferenceDetail

| Component | File | Purpose | Key Inputs | Notes |
|-----------|------|---------|------------|-------|
| `ConferenceHeroBanner` | `Features/ConferenceDetail/Views/ConferenceDetailView.swift` | Full-bleed 180pt `AsyncImage` banner for the detail hero, with gradient `ConferencePlaceholder` fallback. | `conference: Conference` | Lives in the same file as `ConferenceDetailView` since it's only used there. |
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
| `RootTabView` | `Features/RootTabView.swift` | (root) | — | `TabView`: Conferences / Favourites / Settings + a `Tab(role: .search)` (iOS 26 search affordance in the tab bar) hosting `ConferenceSearchView`. Favourites tab shows a numeric `.badge` of saved conferences. |
| `ConferenceListView` | `Features/ConferenceList/Views/ConferenceListView.swift` | ConferenceList | `ConferenceListViewModel` | Used by both Conferences and Favourites tabs via `init(filter:)`. Renders via `ConferenceSectionList`; hosts `.refreshable`, filter `Menu`, and the `navigationDestination(for: Route.self)`. Search is no longer per-tab — it lives in the global Search tab. |
| `ConferenceSearchView` | `Features/ConferenceList/Views/ConferenceSearchView.swift` | ConferenceList | `ConferenceListViewModel` | Content for `Tab(role: .search)`. Owns its `.searchable` field (iOS 26 renders it bottom-anchored), filters all conferences by name/location/tag, and renders via `ConferenceSectionList`. Prompt + no-results use `ContentUnavailableView`. |
| `ConferenceDetailView` | `Features/ConferenceDetail/Views/ConferenceDetailView.swift` | ConferenceDetail | `ConferenceDetailViewModel` | List-based detail with full-bleed hero, title block, an embedded MapKit map card (venue `Marker` + Look Around via `lookAroundViewer`, geocoded by `VenueLocationService`), When/Where, About, Actions sections. Rich `ShareLink` (`SharePreview`). |
| `SettingsView` | `Features/Settings/Views/SettingsView.swift` | Settings | `SettingsViewModel` | `Form` with sections: prominent tip CTA (no header), Support, Contribute, Display, About. |
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
