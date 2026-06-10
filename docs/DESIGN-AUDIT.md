# Design Audit — Whole App

**Date:** 2026-06-10 · **Scope:** Conferences list, Conference detail, Search, Favourites, Settings, Appearance, Suggest a Conference · **Validated against screenshots:** yes (iPhone 17 simulator, iOS 26.4, dark **and** light mode, past-conferences state included)

> Supersedes the 2026-06-01 audit, which predates the premium ticket redesign (ADR-0004 → 0007). All three of that audit's elevation opportunities have been delivered and exceeded.

## Design Snapshot

The app has moved from "polished and restrained" to a genuine bespoke identity: the ticket system (`TicketShape` perforation + notches, date stub, mesh-jewel placeholders, serif display names) reads as a coherent, ownable design language that no other app in the conference/calendar category has. The marigold accent is spent with real discipline — date stubs, one prominent CTA per screen, functional icons — and the aliveness split (vivid upcoming vs desaturated past tickets) is elegant information design that needs no label. Light- and dark-mode parity is real: the deep mesh cards work against both the cream and black washes. What separates this from award-ready is a small set of legibility failures on the most-seen screen (the pinned month header and artwork-with-baked-in-text collisions) and the empty states, which drop out of the brand entirely.

## Summary

| Category | HIGH | MEDIUM | LOW |
|----------|------|--------|-----|
| Color | 0 | 0 | 0 |
| Typography | 0 | 0 | 1 |
| Spacing | 0 | 0 | 1 |
| Motion | 0 | 0 | 1 |
| Hierarchy | 0 | 1 | 1 |
| Emotional | 1 | 1 | 0 |
| Visibility | 2 | 0 | 1 |
| Consistency | 0 | 1 | 1 |

**Lever profile:** Typography **bold** · Color **moderate→bold** · Vocabulary **safe–moderate** · Data Viz **safe** · Status **bold** (aliveness split) · Motion **moderate** (zoom transition, scroll transitions, gated haptics — invisible in stills but real in code)
**Verdict:** **POLISHED — one fix-pass from AWARD-READY.** The identity is already award-calibre; the three HIGH findings are execution gaps, not direction gaps.

## Strengths

- **The ticket system is the identity, and it works.** `TicketShape` notches + dashed perforation + the `JUN / 7–12` rounded-heavy date stub (`ConferenceCard.swift`, `audit-list.png`) form the most physically distinctive card in this category. Do not simplify.
- **Mesh placeholder palette** (`ConferencePlaceholder.swift`) — the curated jewel tones (violet, teal, indigo, mauve, rose) make logo-less conferences look art-directed, not broken (`audit-list-scrolled2.png`). Adjacent cards vary tonally even when the data is repetitive.
- **Aliveness split** — past tickets desaturate and recede, upcoming tickets are lifted vibrant (`audit-list-past.png`). Status communicated entirely through colour treatment, no badge. The app's most elegant information design.
- **Marigold restraint** — accent appears only on stubs, the active tab, one prominent CTA per screen, and functional row icons (`audit-detail.png`, `audit-settings.png`). Textbook 60-30-10; never a fill, never two CTAs.
- **Detail screen composition** — stretchy mesh hero with serif display name, floating glass cards, embedded map with "Open in Maps" badge, glass + glassProminent action bar (`audit-detail-scrolled.png`, `ConferenceDetailView.swift`). The scroll-driven nav-title reveal (`ConferenceDetailView.swift:39-45`) resolves the old double-title finding cleanly.
- **Collectible ticket app icons** (`audit-appearance.png`) — Apple-history milestones with date + venue sub-labels. Ownable personality; nothing like it in the category.
- **Cross-mode parity** — the dark cards float on cream in light mode and on black in dark mode without any treatment change (`audit-list-light-top.png`); the brand wash adapts. No invisible materials, no gray-on-gray.

## Findings

### Visibility

#### VIS-1: Pinned month masthead scrolls over card artwork with no backing — HIGH
- **Screen / Location:** `audit-list-scrolled.png` (dark), `audit-list-light.png` (light, worse) · `ConferenceSectionList.swift:92-107` (`MonthSectionHeader`)
- **Observation:** The serif "JUNE 2026" header is pinned (`.plain` list section header) but has no background, scrim, or material. Mid-scroll it renders directly over card artwork and card text — in light mode the white-on-cream serif lands on a purple mesh card with the card's own overline visible through it. Legibility currently depends on the card under it happening to be dark. This is the most visually broken state in the app, on its most-seen screen, in both modes.
- **Consider:** Back the masthead with system glass or a material so it rides over cards the way the toolbar buttons already do — e.g. `.background(.ultraThinMaterial)` on the header row, or a capsule `.glassEffect()` behind the text only (keeps the full-bleed card edge visible). The mesh cards are dark enough for materials to render correctly in both modes. Trade-off: a full-width material bar slightly heavies the list; the text-only capsule keeps the editorial feel.

#### VIS-2: Artwork with baked-in text collides with the card's own overline + name — HIGH
- **Screen / Location:** CommunityKit on `audit-list.png`; worst case LET'S VISION 2026 on `audit-list-past.png` · `ConferenceCard.swift:121-136` (scrim)
- **Observation:** Cards whose real `og:image` carries large typographic content produce a three-layer text sandwich: artwork text + "CUPERTINO, CALIFORNIA" eyebrow + serif name. On CommunityKit the name wins but the eyebrow is lost; on LET'S VISION (past + desaturated) the artwork's "Born to Create / LET'S VISION 2026" competes with the overlay at near-equal contrast — no clear winner. The live scrim's mid-stops (`opacity(0.06)` at 0.64) are tuned for photographic artwork and are too light when the artwork is itself typography. try! Swift Tokyo on the same screen shows the target: artwork contained, overlay clearly on top.
- **Consider:** Raise the scrim floor in the text anchor zone — e.g. bottom stop toward `0.84` and the 0.64-location stop toward `0.25-0.35` for the live branch — so the name region is reliably dark regardless of artwork. Trade-off: vibrancy of well-behaved artwork dims slightly; tune against try! Swift Tokyo as the reference card. (A heavier hammer — text-region detection — isn't worth the complexity at this catalogue size.)

#### VIS-3: Hero name slides un-staged beneath the toolbar — LOW
- **Screen / Location:** `audit-detail-scrolled.png` · `ConferenceDetailHero.swift:48-59`
- **Observation:** Mid-scroll the serif hero name passes behind the back/heart/share glass buttons before the nav-bar title fades in. Transient and softened by the hero's top scrim, but the handoff moment reads slightly unfinished.
- **Consider:** Fade the title overlay's opacity as `minY` goes negative (the hero already reads `.scrollView` geometry), so the name dissolves as it approaches the toolbar instead of sliding under it.

### Emotional

#### EMO-1: Empty states drop out of the brand entirely — HIGH
- **Screen / Location:** `audit-favourites.png`, `audit-search.png` · `ConferenceListView.swift:65-86`, `ConferenceSearchView.swift:48-56`
- **Observation:** Favourites-empty and the Search prompt are pure black with a gray system `ContentUnavailableView` — no marigold wash, no ticket motif, no serif. Every other screen is immersed in the identity; these two communicate "generic app." Favourites-empty is many users' second screen ever. Note: the `.brandBackground()` wash is only applied inside `ConferenceSectionList`, so any empty-state branch loses it structurally.
- **Consider:** Two tiers. Floor: apply `.brandBackground()` to the empty-state branches so the wash persists (one modifier). Elevation: keep `ContentUnavailableView` (stock stays stock) but set it on a backdrop of 2–3 ghost `TicketShape` outlines at ~0.08–0.12 opacity in mesh-palette tones — the *shape* of what will live here — and let the description text carry ticket vocabulary ("Heart a conference to hold your spot").

#### EMO-2: The collectible icons are undersold by a stock row — MEDIUM
- **Screen / Location:** `audit-appearance.png` · `AppearanceView.swift` (App Icon section)
- **Observation:** The app's best easter-egg craft (ticket icons with milestone date + venue) renders as ~50pt thumbnails in default list rows. The presentation reads as a settings chore, not a collection.
- **Consider:** Scale the leading artwork to ~72pt with a 12pt corner radius and give rows a touch more vertical padding — still a stock `List`, but the collectibles get the weight they deserve. Trade-off: taller list; with ~8 icons that's fine.

### Hierarchy

#### HIER-1: Overline monotony — every card reads "CUPERTINO, CALIFORNIA" — MEDIUM
- **Screen / Location:** `audit-list.png`, `audit-list-scrolled2.png` · `ConferenceCard.swift:236-243` (`overlineText`)
- **Observation:** During WWDC week the eyebrow column repeats the same location string down the entire viewport, so the card's only differentiators are name and artwork; the eyebrow reads as an unpopulated data column. Timed events already lead with time (`10:00 · CUPERTINO…`), which helps — untimed events have no differentiator.
- **Consider:** When several adjacent cards share a location, the *kind* is the higher-information lead for untimed entries (`CONFERENCE · CUPERTINO…`). The kind symbol already sits in the eyebrow, so alternatively lean on the existing type sub-dividers and shorten repeated locations to city only. Trade-off: any rule-based variation must stay predictable — don't let the eyebrow change meaning row to row.

#### HIER-2: Past month mastheads don't participate in the aliveness split — LOW
- **Screen / Location:** `audit-list-past.png` · `ConferenceSectionList.swift:92-107`
- **Observation:** "MARCH 2026" renders at identical weight/colour to the live "JUNE 2026" while every ticket under it is veiled — the cards recede but their headers don't.
- **Consider:** Pass the section's past-ness into `MonthSectionHeader` and render past mastheads at `.secondary` (or ~0.55 opacity). One-line change once the header has a backing (VIS-1).

### Consistency

#### CONS-1: Suggest sheet's primary CTA is the only non-glass prominent button — MEDIUM
- **Screen / Location:** `audit-suggest.png` · `SuggestConferenceView.swift:88-99`
- **Observation:** "Email suggestion" is correctly pinned in a `.safeAreaInset(.bottom)` but uses `.borderedProminent`, while the detail screen's equivalent bar established `.glass`/`.glassProminent` as the app's action-bar language (ADR-0007). Disabled on an empty form, it reads as an inert gray slab overlapping the last field.
- **Consider:** Switch to `.glassProminent` inside a `GlassEffectContainer` to match the detail bar exactly.

#### CONS-2: Top-of-screen framing differs per tab — LOW
- **Screen / Location:** `audit-list.png` vs `audit-favourites.png`/`audit-search.png` · `ConferenceListView.swift:37-40`
- **Observation:** Conferences deliberately drops its large title so the serif masthead leads (good call — the title was redundant with the tab label), but Favourites and Search keep SF large titles, so the three tabs open with three different headers. Defensible — the masthead only exists where months do — noting it as a deliberate-asymmetry check, not a defect.
- **Consider:** If Favourites adopts the ghost-ticket empty state (EMO-1), its large title earns its place as the only header; no change needed. Revisit only if the inconsistency starts to bother in daily use.

### Typography / Spacing / Motion (LOW)

#### TYPO-1: About card over-padded for one-line summaries — LOW
- **Screen / Location:** `audit-detail.png` · `GlassSectionCard.swift`
- **Observation:** A single-sentence About occupies near-equal visual weight to the map-bearing When & Where card.
- **Consider:** Slightly tighter vertical padding when content is a single text line — or fold a short summary under the When & Where card's header instead of giving it its own card.

#### MOTION-1: The hero is static after the zoom lands — LOW (opportunity, not defect)
- **Screen / Location:** `audit-detail.png` · `ConferenceDetailHero.swift:30-46`
- **Observation:** The zoom transition into the mesh hero is the app's best motion, but the destination is inert on arrival.
- **Consider:** A barely-perceptible mesh "breathe" — animate one or two `MeshGradient` keypoints ±0.015 over ~4s, `repeatForever(autoreverses:)`, gated behind `accessibilityReduceMotion` — only in the detail hero. See Signature Moment.

#### SPACE-1: Appearance list bottom row crops without a scroll cue — LOW
- **Screen / Location:** `audit-appearance.png`
- **Observation:** "Vision Pro" cuts at the viewport edge; with a collection this good, a cropped row reads as truncation rather than affordance. Minor.

## Elevation Opportunities

1. **Stage the masthead (VIS-1).** *Current:* serif month header collides with cards mid-scroll, both modes. *Prescription:* material/glass backing on `MonthSectionHeader` (`ConferenceSectionList.swift:92-107`) — capsule `.glassEffect()` behind the text, or `.background(.ultraThinMaterial)` on the row; add past-masthead recession (HIER-2) in the same touch. *Effort:* Low.
2. **Raise the scrim floor for typographic artwork (VIS-2).** *Current:* baked-in artwork text fights the overlay on CommunityKit / LET'S VISION. *Prescription:* deepen the live-branch scrim's lower stops in `ConferenceCard.swift:121-136` (bottom → ~0.84, mid → ~0.3), tuning against try! Swift Tokyo as the well-behaved reference. *Effort:* Low.
3. **Bring the empty states into the brand (EMO-1).** *Current:* pure-black generic `ContentUnavailableView`s. *Prescription:* `.brandBackground()` on the empty branches + ghost `TicketShape` backdrop at 0.08–0.12 opacity in mesh tones + ticket vocabulary in the description. *Effort:* Low–Med.
4. **Let the hero breathe (MOTION-1).** *Current:* static mesh after the zoom. *Prescription:* reduce-motion-gated `MeshGradient` keypoint drift in `ConferenceDetailHero`. *Effort:* Med.
5. **Give the collectibles a vitrine (EMO-2).** *Current:* 50pt thumbnails in stock rows. *Prescription:* 72pt artwork, 12pt radius, roomier rows in `AppearanceView`. *Effort:* Low.

## Signature Moment

**Current candidate:** tapping a ticket — the card zooms into the full-bleed mesh hero (`matchedTransitionSource` → `.navigationTransition(.zoom)`). Already the best moment in the app.
**Prescribed:** complete the sequence — *tap → ticket expands → the mesh breathes once on arrival* (MOTION-1). A slow, sub-perceptual gradient drift that exists only in the detail hero turns the landing from "image loaded" into "you've arrived." That three-beat sequence is the thing a user shows a colleague. Everything needed already exists: the mesh is custom-drawn, reduce-motion gating is house style, and the zoom is wired.

## Drift from Design System

No `docs/DESIGN-SYSTEM.md` exists; the operative spec is CLAUDE.md + ADR-0003→0007, and the rendered app matches it: two levers only (marigold + serif display), stock controls stay stock (Settings, Suggest form, map, event editor, share sheet all verified stock on screen), custom chrome composed on Liquid Glass. One reconciliation question: `Theme.ticketNumerals` adds `design: .rounded` as a de-facto third type voice — it's documented as a deliberate "ticket numeral" in `Theme.swift:38-40` and reads as part of the stub's identity on screen (it looks right), but ADR-0006 says serif + SF only. Worth one line in an ADR amendment confirming it's sanctioned. Also: `docs/VIEW-INVENTORY.md:48` still describes `ConferenceDetailHero` as having a `HeroTicketEdge` tear in its title, while the entry text says it was removed — the doc needs the one-word update, the screen is correct.

## Quick Wins

1. **Material backing on the pinned month header** — `ConferenceSectionList.swift:92-107`. Kills the app's worst rendered state in both modes.
2. **`.brandBackground()` on the empty-state branches** — `ConferenceListView.swift:65-86`, `ConferenceSearchView.swift:48-56`. One modifier each; the ghost-ticket backdrop can follow later.
3. **Deepen the live scrim's lower stops** — `ConferenceCard.swift:129-134`. Fixes CommunityKit/LET'S VISION text collisions.
4. **`.glassProminent` on the Suggest sheet CTA** — `SuggestConferenceView.swift:94`. One-line consistency fix.
5. **Recede past month mastheads** — `ConferenceSectionList.swift:96-100`, alongside Quick Win 1.
