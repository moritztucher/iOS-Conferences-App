# ADR-0006: Signature Typeface & Accent Colour

## Status

Accepted (2026-06-09). Amends [ADR-0004](ADR-0004-premium-ticket-identity.md) (and, through it, [ADR-0003](ADR-0003-ecosystem-native-ui.md)).

## Context

ADR-0004 introduced a custom ticket identity for the list cards and detail hero but deliberately **retained system tint and system fonts** — it called a signature typeface "a future option, not a commitment." With the ticket system in place, the two remaining identity levers are the two ADR-0004 left on the table: a distinctive type voice and a brand accent. Both are the highest-leverage moves for separating "premium template" from "this app has a point of view," and both are now wanted.

The constraint we keep: do this **without** bundling a custom font (licensing review, file weight, Dynamic Type / optical-sizing regressions) or hand-rolling a colour system that fights the OS in light/dark and accessibility settings.

## Decision

### Signature typeface — system serif (New York), display-only

- Editorial **display** text uses Apple's system serif (New York) via `Font.system(_:design: .serif)`, exposed as `Theme.serif(_:weight:)`.
- Applied to **conference names** (list card + detail hero) and **month mastheads** (the section headers, e.g. `JUNE 2026`) — the moments that carry voice.
- **Everything else stays SF**: overlines, the date stub, kind sub-dividers, all body/secondary/control labels, and the stock `Form` section headers.
- Because it's the *system* serif, it keeps full Dynamic Type scaling and optical sizing — no bundled file, no licensing, no accessibility regression.

### Signature accent — warm marigold, replacing system blue

- A warm marigold/amber accent replaces the system blue tint. It lives in the **`AccentColor` asset** (light + dark variants) so it flows into every *default* SwiftUI control tint automatically, and is applied explicitly at the root via `.tint(Theme.accent)`.
- `Theme.accent` mirrors the asset (`Color.accentColor`) for the few views that need the colour directly rather than via the environment tint.
- Light variant is deepened (sRGB ≈ `0.80, 0.47, 0.06`) for text/link contrast on white; dark variant is lightened (≈ `1.0, 0.70, 0.27`) for contrast on black.
- The favourite *swipe* action keeps its conventional pink (it reads as "heart," not "brand") — an explicit, intentional override of the global tint.

### What this does **not** change

- The ticket system, scrims, parallax, zoom transition, and motion/haptics from ADR-0004 are untouched.
- Stock `Form` for Settings and the detail's When/Where, About, Map sections remains stock.
- No onboarding; no custom empty states (`ContentUnavailableView`).

The ADR-0004 rule sharpens from "system tint, system fonts" to: **one signature accent (asset-backed) and the system serif for display moments only; SF and stock everywhere else.**

## Consequences

### Pros
- A genuine type voice and brand colour — the single biggest identity lift available — at near-zero cost and zero accessibility regression (system serif scales; asset accent adapts to light/dark).
- The accent unifies the bespoke surfaces (heart, buttons, links, selection) and is the foundation for a future unified image treatment.

### Cons / costs (accepted)
- A serif-vs-SF discipline must be maintained: serif is for *display* only. Drift (serif on a body label, SF on a hero name) would read as a bug. The rule lives in `Theme` docs + VIEW-INVENTORY.
- Marigold-on-white contrast for small text/links is borderline; the light variant is deepened to compensate and must be re-checked if the hue is tuned.
- Light-mode + Dynamic Type parity for the new accent/serif needs the same device-pass verification as the rest of ADR-0004.

## References

- ADR-0004 — premium ticket identity (the stance this amends)
- `iOS-Conferences/Core/Theme/Theme.swift` — the accent + serif helpers
- `iOS-Conferences/Assets.xcassets/AccentColor.colorset` — the marigold (light/dark)
- New York / system serif — `Font.system(_:design:)`

## Date

2026-06-09
