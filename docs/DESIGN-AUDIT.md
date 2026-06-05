# Design Audit — Whole App

**Date:** 2026-06-01 · **Scope:** Conferences list, Conference detail, Favourites, Settings · **Validated against screenshots:** yes (iPhone 17 simulator, dark mode)

## Design Snapshot

The app reads as a clean, confident, ecosystem-native iOS 26 app — and that is the correct outcome given ADR-0003. Every screen is stock `List` / `Form` / `TabView` with system tint, system text styles, SF Symbols, and Liquid Glass tab/toolbar adoption. Nothing fights the platform. The one place the app gives itself a visual identity is the **hash-derived colour tiles** for conferences without logos, and they're legible, distinct, and consistent across list and detail. The overall maturity is *polished and restrained* rather than expressive — exactly the brief. The few opportunities below are about making the deliberately-small set of custom surfaces (chiefly the detail hero) feel as crafted as the stock chrome around them, without adding a single design token.

## Summary

| Category | HIGH | MEDIUM | LOW |
|----------|------|--------|-----|
| Color | 0 | 1 | 0 |
| Typography | 0 | 0 | 1 |
| Spacing | 0 | 0 | 1 |
| Motion | 0 | 0 | 0 |
| Hierarchy | 0 | 1 | 1 |
| Emotional | 0 | 0 | 0 |
| Visibility | 0 | 0 | 0 |
| Consistency | 0 | 0 | 0 |

**Lever profile:** Typography safe · Color safe (one sanctioned accent system: the hash tiles) · Vocabulary safe · Data Viz none · Status safe · Motion safe (heart `.bounce`)
**Verdict:** POLISHED — the restraint is intentional and well-executed; this is not "bare bones," it's a deliberately native app that nails the native brief.

## Strengths

- **Month-grouped list** (`ConferenceListView.swift:51-66`) with caps secondary section headers — glanceable, very iOS-Calendar-like. Reads well on screen (`audit-list.png`).
- **Hash-derived colour tiles** (`ConferencePlaceholder.swift`) are the app's signature: stable per-conference colour, auto-contrasting initials, rounded-rect with continuous corners. On `audit-list.png` the WR/AP/tS/PG/CC tiles give the list real personality while staying native. This is the right — and only — place the app spends its identity budget.
- **Native empty states** — Favourites uses `ContentUnavailableView` with the `heart` symbol (`audit-favourites.png`); textbook, zero custom code.
- **Heart `symbolEffect(.bounce)`** on the detail favourite toggle (`ConferenceDetailView.swift:166`) — one tasteful, system-blessed moment of delight.
- **Cross-screen consistency** — list, detail, settings, and favourites all feel like one app. Dark mode is clean throughout (no gray-on-gray, no invisible materials).

## Findings

### Color

#### COLOR-1: The detail hero is the largest surface and the least crafted — MEDIUM
- **Screen / Location:** `audit-detail.png` · `ConferenceDetailView.swift:183-204` (`ConferenceHeroBanner`)
- **Observation:** When a conference has no `logoURL`, the 220pt hero is a single flat fill (`Self.color(for:)`) with centred initials. It's the most prominent thing on the screen yet has the least depth — it reads as a placeholder, not a designed banner. Conferences *with* a logo get a rich photo here; the no-logo majority get a flat block, so the screen's quality swings hard on data you don't control.
- **Consider:** Derive a subtle two-stop `LinearGradient` from the same hash colour (e.g. the base colour at the bottom, a ~12% lighter variant at the top) so the flat fill gains depth while staying inside the sanctioned palette — no new token, just a lighter shade of the colour you already compute. Optionally drop a faint `.regularMaterial`-backed scrim behind the nav controls. This is the single highest-leverage visual change in the app.

### Hierarchy

#### HIER-1: Conference name is rendered twice on the detail screen — MEDIUM
- **Screen / Location:** `audit-detail.png` · `ConferenceDetailView.swift:29-30` (inline nav title) + `:77-91` (`titleSection`, `.title2.weight(.semibold)`)
- **Observation:** The name appears as the inline navigation-bar title *and* again as a large title just under the hero, with the same date·location subtitle echoed in `headerSubtitle`. On screen it's mild redundancy rather than a defect, but it spends vertical space and slightly muddies "where's the real title?"
- **Consider:** Either (a) keep the large `titleSection` and let the nav bar stay title-less until scrolled (the Calendar/Maps event pattern), or (b) keep an inline nav title and tighten `titleSection` to subtitle-only. Pick one home for the name.

#### HIER-2: Hero initials ghost behind the inline nav title while scrolling — LOW
- **Screen / Location:** `audit-detail-actions.png` (mid-scroll) · `ConferenceHeroBanner`
- **Observation:** As the hero scrolls up, the giant "WR" passes directly behind the inline nav title "WWDC Run", briefly overlapping. It's transient and minor but looks slightly unfinished.
- **Consider:** A short `.opacity`/`.blur` fade on the hero as it leaves the safe area, or reducing the hero height (180pt) so the initials clear the title sooner. Reducing height also helps COLOR-1's "placeholder-ness."

### Typography

#### TYPO-1: Row title/subtitle contrast is gentle — LOW
- **Screen / Location:** `audit-list.png` · `ConferenceRow.swift:13-27`
- **Observation:** Name is `.body`, secondary is `.subheadline`/`.secondary`. Perfectly fine and native, but the date — arguably the app's most important sort key — gets no emphasis; rows read as uniform paragraphs.
- **Consider:** Optional, stays native: render the date with `.monospacedDigit()` or give the day a touch more weight so the chronological spine of the list is scannable. Don't overdo it — `.body`/`.subheadline` is already correct.

### Spacing

#### SPACE-1: Edge-to-edge hero vs. inset content creates a small rhythm break — LOW
- **Screen / Location:** `audit-detail.png` · hero section uses `listRowInsets(EdgeInsets())` (`:71`) while following sections keep default inset-grouped margins
- **Observation:** The hero runs full-bleed and the very next title block is inset, so the left edge "jumps." It's a deliberate magazine-style choice and looks okay, just slightly unsettled.
- **Consider:** Either inset the hero to match the cards (fully grouped feel) or push the title block to align with the hero's full-bleed edge — commit to one alignment story.

## Elevation Opportunities

1. **Make the hero a designed banner, not a placeholder.** *Current:* flat hash-colour block with centred initials (`audit-detail.png`). *Prescription:* in `ConferenceHeroBanner`, replace the flat fill (no-logo path) with a `LinearGradient` of `[baseColor.lighter(0.12), baseColor]` top→bottom, keep the initials but try `.font(.system(size: …, weight: .bold, design: .rounded))` scaled to the banner and bottom-left aligned (Apple-event-poster feel) instead of dead-centre. Optionally reduce height to 180pt (also fixes HIER-2). *Effort:* Low–Med.
2. **Smarter location strings.** *Current:* every Cupertino row shows "Cupertino, California, USA" and truncates identically (`audit-list.png`), so the secondary line is visually monotonous and low-information. *Prescription:* centralise a `locationShort` (city + abbreviated region, drop redundant country) in the existing date-formatting layer — the project already mandates no inline formatting in views, so this belongs next to `ConferenceDateStyle`. *Effort:* Low.
3. **Resolve the double title** (HIER-1) so the detail screen has one unambiguous headline. *Effort:* Low.

## Signature Moment

**Current candidate:** the hash-derived colour tiles in the list — the only place the app expresses identity, and it works.
**Prescribed:** the **conference detail hero**. It's the one full-width, full-attention surface in the app and the natural home for a signature. Turning the flat no-logo block into a gradient "event poster" with a confident rounded-bold initial treatment (Elevation #1) would give the app a memorable moment that is still 100% system-native — no custom tokens, no `.glassEffect()`, just a smarter use of the colour you already derive.

## Drift from Design System

No `docs/DESIGN-SYSTEM.md` exists, so there's nothing to reconcile. Note (not a finding): `ConferencePlaceholder` hardcodes a 9-colour RGB palette, which on its face conflicts with CLAUDE.md's "no custom colours." This is the **sanctioned exception** documented under Legal & Content Notes ("hash-derived colour") — it's intentional and is the app's identity, so treat it as approved, not as drift. If you want it airtight, capture the palette decision in a short ADR.

## Quick Wins

1. **Hero gradient** — derive a 2-stop gradient from the existing hash colour in `ConferenceHeroBanner` (`ConferenceDetailView.swift:183-204`). Biggest visual payoff, lowest risk.
2. **Trim location strings** — add a `locationShort` helper near `ConferenceDateStyle`; use it in `ConferenceRow.secondaryLine` (`ConferenceRow.swift:33-36`).
3. **De-duplicate the detail title** — drop either the inline nav title or the `titleSection` headline (`ConferenceDetailView.swift:29-30` / `77-91`).
4. **Reduce hero height to ~180pt** — clears the scroll-overlap (HIER-2) and reads less placeholder-y.
