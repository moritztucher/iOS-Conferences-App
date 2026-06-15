# ADR-0003: Ecosystem-Native UI Direction

## Status

**Partially superseded by [ADR-0004](ADR-0004-premium-ticket-identity.md) (2026-06-09).**

The *visual layer* decision here (zero custom design tokens, stock `List`/`Form` rows, no custom shapes/transitions) was reversed for the Conferences list and the detail hero — see ADR-0004 for the premium ticket-based identity that replaced it. **Still in force:** the deep system integrations (EventKit, Maps, ShareLink, in-app review), the stock `Form`-based Settings and the detail's When/Where/About/Map sections, `ContentUnavailableView` empty states, system tint (no brand colour), and **no onboarding**. In other words, ADR-0004 narrows the "stock everything" stance to "stock where it carries trust, custom where it carries identity."

## Context

After ADR-0001 (initial architecture) and ADR-0002 (monetization, data source, open source), the visual and interaction design direction was still open. The user's stated goal evolved across the discussion:

1. First: "as native as possible, as little custom design as possible."
2. Then: "it should feel like an extension to the Apple ecosystem."

These two framings imply different design strategies. "Native" means using system components and avoiding visual decoration. "Ecosystem extension" goes further — the app should *behave* like a first-party Apple app: deep system integrations, no onboarding, no brand identity beyond the icon, and zero design tokens that compete with Apple's. The user explicitly accepted the ecosystem-extension framing.

## Decision

### Visual layer: zero custom design tokens

- **Accent colour:** inherit the system accent (`.tint`); no brand colour.
- **Typography:** system text styles only (`.headline`, `.body`, etc.). No custom fonts, no manual sizing.
- **Iconography:** SF Symbols only, monochrome, no recoloured glyphs.
- **Materials:** Liquid Glass (iOS 26) applied by the system to tab bar, toolbar, and sheets. **No `.glassEffect()` on custom views.**
- **Spacing/layout:** native list/form spacing — no custom padding tokens.
- **Animations:** all defaults. No spring tuning, no custom transitions.
- **Onboarding:** none. Apple's first-party apps don't have welcome flows.
- **Launch screen:** static — icon + background, no animation.

### Component palette: stock SwiftUI only

| Need | Component |
|------|-----------|
| Root navigation | `TabView` (3 tabs: Conferences / Favourites / Settings) |
| Per-tab stack | `NavigationStack` with `NavigationPath` coordinator |
| List | `List` with `Section` per month |
| Detail | `Form` (Calendar event detail pattern) |
| Search | `.searchable` |
| Refresh | `.refreshable` |
| Empty states | `ContentUnavailableView` (no custom empty states) |
| Sharing | `ShareLink` in the detail toolbar |
| Favourite toggle | Toolbar `Image(systemName: "heart"/"heart.fill")` |
| Settings rows | `Form` rows with `NavigationLink` |

### Navigation shape

```
TabView (Liquid Glass auto-adopted)
├── Conferences         NavigationStack → ConferenceListView → ConferenceDetailView
├── Favourites          NavigationStack → ConferenceListView (filtered) → ConferenceDetailView
└── Settings            Form (display, support, contribute, about)
```

The Favourites tab reuses the list and detail views; only the data source differs (favourites filter applied at the ViewModel level).

### System integrations (MVP)

These move from "feature ideas" to "required for the ecosystem-extension feel":

| Touchpoint | Implementation |
|------------|----------------|
| Add to Calendar | **`EKEventEditViewController`** — the system event editor sheet (calendar picker, alerts, notes). Not programmatic `EKEvent.save()`. |
| Location row | Tap opens Apple Maps (`MKMapItem.openInMaps`) with a pin on the city. |
| Share a conference | `ShareLink` in the detail toolbar — system share sheet with URL + dates. |
| Search a conference | `.searchable` on the list. |
| Refresh data | `.refreshable` pull-to-refresh. |
| Empty states | `ContentUnavailableView` everywhere. |
| Permissions | Asked at point of use, not upfront. Denied → inline link to system Settings via `UIApplication.openSettingsURLString`. |

### System integrations (immediately post-MVP)

| Touchpoint | Implementation |
|------------|----------------|
| Spotlight | `CSSearchableItem` for favourited conferences — they appear in iOS system search and deep-link into the app. |
| App Intents | `Conference` as `AppEntity` + one intent: "What's the next conference?" — usable from Siri and Shortcuts. |

### System integrations (post-MVP, deferred)

- **WidgetKit:** home/lock screen widget showing the next conference (with configuration to select all vs favourites).
- **Live Activities:** Dynamic Island countdown when a favourited conference is happening today/this week.
- **Universal Links:** `https://<domain>/conf/<id>` opens the detail view directly.

### Detail screen (revised)

The earlier "typographic name on hash-derived colour band" header is **dropped**. Detail view is the *Calendar event detail* shape:

1. Standard `.navigationTitle(.large)` showing the conference name.
2. Toolbar items: favourite toggle (`heart`/`heart.fill`), `ShareLink`.
3. `Form` with:
   - **Section 1 (When/Where):** Date row, Location row (tap → Maps).
   - **Section 2 (About):** description text.
   - **Section 3 (Actions):** row-as-button "Visit website", row-as-button "Add to calendar".

### List screen

- Large nav title "Conferences" (or "Favourites" on the second tab).
- `.searchable` (filters by name + location).
- `Section` per month (`MAY 2026`, `JUNE 2026`, ...).
- Row: `Label`-style — primary text = conference name, secondary = "Jun 8–12 · Cupertino".
- Sort ascending by `startDate`. Past conferences hidden by default; a Settings toggle exposes them.
- `.refreshable` pull-to-refresh.
- Empty state via `ContentUnavailableView` (different copy for the empty Favourites tab vs. no data on the All tab).

### Settings screen

`Form` with four sections:
- **Display** — "Show past conferences" toggle.
- **Support** — "Rate the app" (in-app review prompt via `RequestReviewAction`), "Contact me" (`MFMailComposeViewController`).
- **Contribute** — "Suggest a conference" (opens a sheet with the in-app form → GitHub Issue URL), "View source on GitHub" (opens repo in `SFSafariViewController`).
- **About** — Version (with build number), License (MIT).

## Consequences

### Pros
- **Lowest possible UI maintenance cost.** When Apple changes the look of `List` / `Form` / `TabView` in a future iOS release, our app updates for free. No design debt.
- **Maximum trust.** Users with system-level familiarity (every iPhone user) feel immediately at home — no learning curve.
- **Accessibility for free.** System components ship with VoiceOver, Dynamic Type, reduce-motion, and high-contrast support already wired in.
- **Future-proof against design trend shifts.** We're not betting on a specific aesthetic that ages.
- **Cheaper to build.** No design system to maintain; no `.swatch`/`.spacing`/`.radius` tokens.
- **Deep system integrations make it feel "first-party"** in a way pure UI choices alone can't.

### Cons
- **No visual identity.** Two iOS-Conferences-style apps would look identical. Differentiation must come from data quality and integration depth, not visual flair.
- **Harder to screenshot / market.** App Store screenshots of stock `List` views aren't visually arresting — we'll need to lean on annotations or feature callouts.
- **Pressure to add system integrations.** "Looks like an Apple app" sets an expectation that *behaves* like one — pushing Spotlight + App Intents from "nice" to "expected" early.
- **No room for delight via design.** Whatever delight the app provides has to come from copy, content, or integration moments — not visual surprise.
- **Locked into Apple's pace.** If Apple changes List/Form spacing or behaviour in a way we dislike, we have nowhere to hide.

## Alternatives Considered

### Custom design system with a clear visual identity
- **Pros:** memorable, differentiated, gives the app a personality.
- **Cons:** every custom decision (colours, typography, row layout, transitions) is a maintenance liability and a deviation from system behaviour the user has internalised. Loses the "trusted utility" frame for a "stylish indie app" frame — wrong fit for a factual conference list.

### Light visual customisation (accent colour + typography, stock components otherwise)
- **Pros:** small differentiation without much cost.
- **Cons:** half-measure — once we have a brand colour, we have to defend it across every screen, and the ecosystem-extension framing breaks down. The user explicitly said "as little custom design as possible." Drop entirely.

### Native UI without deep system integrations
- **Pros:** less to build.
- **Cons:** loses the "ecosystem extension" frame the user asked for. A stock-component app that doesn't talk to Maps / Calendar / Spotlight / Shortcuts is just plain native, not ecosystem-native. The integrations are what differentiate this approach.

## References

- ADR-0001 — initial architecture
- ADR-0002 — data source, open source (monetization decision later reversed)
- Apple HIG: Components → Lists, Forms, Tab bars
- `ContentUnavailableView` — https://developer.apple.com/documentation/swiftui/contentunavailableview
- `EKEventEditViewController` — https://developer.apple.com/documentation/eventkitui/ekeventeditviewcontroller
- App Intents framework — https://developer.apple.com/documentation/appintents
- Core Spotlight — https://developer.apple.com/documentation/corespotlight

## Date

2026-05-18
