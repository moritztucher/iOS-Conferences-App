# ADR-0004: Premium Ticket-Based Visual Identity

## Status

Accepted (2026-06-09). Partially supersedes [ADR-0003](ADR-0003-ecosystem-native-ui.md).

## Context

ADR-0003 committed to a zero-custom, ecosystem-native visual layer: stock `List`/`Form` rows, system tint, no custom shapes, transitions, or motion. In practice the running app read as "competent but generic" — a stock grouped list of conferences with a flat banner detail. Reviewing it, the project owner chose to pursue a distinctive, premium visual identity for the browse-and-detail experience, explicitly accepting the maintenance trade-off ADR-0003 had avoided.

The chosen metaphor is the **event ticket**, which already exists in the app's identity (the collectible-ticket alternate app icons). The list shows ticket cards; tapping one expands into the full ticket.

This reverses the "Custom design system with a clear visual identity" alternative that ADR-0003 rejected — but only for the surfaces where identity matters (list + detail hero), not the whole app.

## Decision

### Custom premium visual layer (list + detail hero)

- **Ticket cards** (`ConferenceCard` + `TicketShape`): full-bleed image (or a hash-derived mesh placeholder) under a bottom scrim, with a perforation + punched notches dividing a main body (name + `kind · location` overline) from a date **stub**. Corner radius + shadow for depth.
- **Stretchy parallax hero** (`ConferenceDetailHero` + `HeroTicketEdge`): the detail screen opens with a full-bleed image hero that grows on pull-down overscroll, the name + date overlaid on a scrim, and a perforated bottom "tear line" — so the list ticket and the detail are one continuous object.
- **Zoom transition**: tapping a card morphs it into the hero via `matchedTransitionSource(id:in:)` + `.navigationTransition(.zoom(sourceID:in:))`.
- **Pinned bottom action bar** on the detail: Website + Add to Calendar promoted out of an in-list section into a `.safeAreaInset(.bottom)` bar.
- **Editorial structure**: month-primary section headers (year folded in) with kind sub-dividers + counts shown only in mixed months; bold tracked headers instead of stock secondary ones.
- **Motion & haptics**: `.sensoryFeedback` on favourite/calendar actions; a favourite-heart spring — all motion gated on `accessibilityReduceMotion`.

### Retained from ADR-0003 (unchanged)

- **System tint, system fonts.** No brand colour; no custom typeface (strong weight/tracking on system fonts carries the editorial feel). A signature typeface remains a future option, not a commitment.
- **Stock `Form`** for Settings and the detail's When/Where, About, and Map sections.
- **Deep system integrations**: `EKEventEditViewController`, Apple Maps, `ShareLink`, in-app review, `ContentUnavailableView`.
- **No onboarding.**

So the rule shifts from "stock everything" to **"stock where it carries trust (utility screens, system integrations); custom where it carries identity (the list cards and the detail hero)."**

## Consequences

### Pros
- A distinctive, screenshot-worthy identity that the stock approach couldn't give — better for the App Store and for the "this app has a point of view" feel.
- The ticket metaphor is coherent (icons → cards → detail), not decorative.

### Cons / costs (accepted)
- **We now own a design system** (`TicketShape`, `HeroTicketEdge`, scrims, card layout) and must maintain it across iOS releases — the maintenance debt ADR-0003 avoided.
- **Accessibility is now our responsibility**: motion is reduce-motion-gated and cards carry VoiceOver labels, but Dynamic Type at the largest sizes and full light-mode parity need ongoing verification.
- **Verification debt**: the custom interactions (zoom morph, parallax stretch, haptics, menu behaviour) can't be exercised in the headless build loop and require a device pass before release.

## References

- ADR-0003 — ecosystem-native UI (the stance this narrows)
- `docs/VIEW-INVENTORY.md` — the components this introduced (`TicketShape`, `ConferenceCard`, `ConferenceDetailHero`, `HeroTicketEdge`)
- Zoom transition — https://developer.apple.com/documentation/swiftui/view/navigationtransition(_:)

## Date

2026-06-09
