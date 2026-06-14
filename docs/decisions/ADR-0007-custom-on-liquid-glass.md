# ADR-0007: Custom UI Composed on Liquid Glass

## Status

Accepted (2026-06-09). Supersedes the "stock-first" stance of [ADR-0003](ADR-0003-ecosystem-native-ui.md) and reverses the "no `.glassEffect()` on custom views" rule of [ADR-0004](ADR-0004-premium-ticket-identity.md). Extends ADR-0004 / [ADR-0006](ADR-0006-signature-typeface-and-accent.md).

## Context

ADR-0003 → ADR-0004 → ADR-0006 walked the app from "stock everything" to "custom on the identity surfaces (ticket cards + hero), stock everywhere else, two brand levers." The remaining weak spot is everything *between* the bespoke surfaces — most visibly the detail screen, which opens with a custom hero and then drops onto generic grouped `Form` sections (the "cliff").

The project owner chose to push the custom/premium treatment **as far as possible** — but explicitly conditioned on keeping what stock gave us for free: **accessibility, Dynamic Type, and dark-mode parity**, and on staying native to **iOS 26/27 Liquid Glass** rather than fighting it.

That condition is the whole design of this decision. Liquid Glass is the vehicle: by *composing* custom layouts out of system Liquid Glass materials and controls, we get a bespoke look while the system continues to handle vibrancy, dark mode, and the accessibility settings (Reduce Transparency, Increase Contrast) automatically. Custom becomes a composition problem, not a "reimplement the platform" problem.

## Decision

**Build custom UI by composing Liquid Glass + system primitives — not by reinventing controls.**

### The vehicle
- Custom containers use `.glassEffect(_:in:)` (with explicit shapes, e.g. `.rect(cornerRadius:)`), grouped in `GlassEffectContainer` so effects blend/morph correctly; `.glassEffectID(_:in:)` for transitions.
- Floating actions use the system glass button styles `.glass` / `.glassProminent` (tinted by our marigold accent), not hand-rolled buttons.
- Tint/interactivity via `.glassEffect(.regular.tint(Theme.accent).interactive())` where a control is interactive.

### Hard acceptance criteria (non-negotiable — a change that breaks one is not done)
1. **Accessibility is preserved.** Glass is used *because* it auto-responds to Reduce Transparency / Increase Contrast. Every custom control carries a VoiceOver label + traits; motion stays `accessibilityReduceMotion`-gated.
2. **Dynamic Type scales.** Semantic font styles only (via `Theme` roles); containers size to their content. No fixed-height views that contain text. Verified at the largest accessibility sizes.
3. **Dark-mode parity.** No hardcoded colours except scrims (black/white opacity) and the asset-backed `Theme.accent`. Glass + semantic styles carry the rest.

### The senior caveat — "as custom as possible" ≠ reinvent the platform
Where the system control already nails it **and** a custom version would add no identity, **stay stock** — because that is exactly where reimplementation *loses* accessibility/Dynamic Type for zero gain:
- Text input, pickers, toggles, steppers → stock.
- `EKEventEditViewController`, `ShareLink`, `SFSafariViewController`, `Map`, `ContentUnavailableView` → stock.
- Settings remains a stock `Form` (it is the trust surface; a no-account utility app earns trust by feeling system-native there).

So custom means **custom composition and chrome** (containers, layout, motion, the ticket language) built on stock materials and controls — not bespoke re-creations of UIKit/SwiftUI primitives.

### Rollout (phased, each verified before the next)
1. **Detail content** — replace the grouped `Form` sections with floating glass section cards + glass CTA buttons (bridges the hero→content cliff). *(this turn)*
2. **List + Search surfaces** — backgrounds, spacing, and any floating chrome on the glass vocabulary.
3. **Settings** — only the framing/chrome; the `Form` rows stay stock per the caveat.

## Consequences

### Pros
- A cohesive, premium, unmistakably-iOS-26 look that extends the ticket identity across the app.
- The accessibility / Dynamic Type / dark-mode guarantees are *kept* precisely because the custom layer rides on system glass rather than replacing it.

### Cons / costs (accepted)
- We own more layout + composition (and its verification) than under ADR-0004's narrow scope.
- Liquid Glass is iOS 26+ only; that already matches the deployment target, but it ties the look to the platform generation.
- Over-using glass on large static backgrounds can look heavy — glass is for floating/grouped chrome, not every surface; apply with restraint (HIG).

## References

- ADR-0004 — premium ticket identity (the "no glassEffect" rule this reverses)
- ADR-0006 — signature accent + serif (the type/colour roles this composes with)
- Apple — "Applying Liquid Glass to custom views" (`glassEffect`, `GlassEffectContainer`, `glassEffectID`, `.buttonStyle(.glass)`)

## Date

2026-06-09
