# ADR-0008: Collectible App Icons as Achievements

## Status

Accepted (2026-06-15). Extends the alternate-app-icon easter egg shipped under [ADR-0004](ADR-0004-premium-ticket-identity.md) / [ADR-0006](ADR-0006-signature-typeface-and-accent.md); builds chrome on [ADR-0007](ADR-0007-custom-on-liquid-glass.md).

## Context

The app already ships seven collectible "ticket" app icons (a default plus six Apple-history milestones), all freely selectable in **Settings → Appearance**. The owner wanted them to feel **earned** — small achievements unlocked through real use — rather than a flat list, turning the icon picker into a light collection loop without adding monetization, accounts, or a backend (all out of scope per the project charter).

The constraint: this is a one-job utility app. Achievements must stay a *quiet delight* — no points, no streak pressure, no onboarding tutorial — and must not regress the accessibility / Dynamic Type / dark-mode parity that the rest of the app guarantees.

## Decision

**Gate the six alternate icons behind permanent, use-driven unlocks; the default ticket stays free. Surface them inline in the existing Appearance grid, and celebrate each unlock with a full-takeover sheet.**

### Unlock rules (hybrid: usage milestones + one seasonal easter egg)

| Icon | Rule |
|------|------|
| Tickets (default) | Always unlocked |
| iPhone (2007) | Favourite your first conference |
| iPod (2001) | Favourite 5 conferences |
| Macintosh (1984) | Add a conference to your calendar |
| Vision Pro (2023) | Open a conference's website |
| Apple Computer Co. (1976) | Suggest a conference |
| WWDC26 (2026) | Open the app during June 2026 (seasonal) |

Rules live on `AppIcon.unlockRule` (`.always` / `.favourites(Int)` / `.event(AchievementEvent)` / `.dateWindow(ClosedRange<Date>)`) with a matching `unlockHint` shown on locked tickets.

### Permanence & persistence
- An unlock is **forever**. Earned tickets never re-lock — un-favouriting below a threshold does not take iPod away.
- Stored in a dedicated SwiftData `@Model UnlockedIcon` (ID + timestamp), mirroring the `FavouriteConference` pattern: separate from the conference cache so unlocks survive a refresh, and never recomputed away.

### Evaluation
- `AchievementService` (`@MainActor @Observable`, injected app-wide via `.environment`) is the single brain. It caches unlocked IDs for synchronous reads, evaluates rules as the user acts, and queues freshly-earned icons for celebration.
- One-shot actions call `record(_:)` at the action site (website button, `EventEditorView.onSaved` == `.saved`, suggest submit). Favourite-count tickets call `reevaluateFavourites()` after a toggle (idempotent). The seasonal window and any already-met threshold are **replayed on launch** from `RootTabView.task`, so unlocks land even if the action predates this feature.
- **Earning vs. discovering — only live earnings celebrate.** The launch replay persists its unlocks *silently* (an `isReplaying` flag suppresses the celebration queue). A date-window ticket like WWDC26, or a threshold an updating user already passed, therefore appears quietly as collected in Settings rather than slamming a full-takeover sheet over the first screen on cold launch. The celebration sheet fires only for an unlock earned in response to an action *this session*. The WWDC26 ticket's surprise is finding it already in your wallet during WWDC week — not a forced sheet you "earned" by opening the app.

### Surface & celebration
- **Inline** in the Appearance grid (no separate Achievements screen — fits the existing "vitrine" and the one-job ethos): an "N of 7 collected" header; locked tickets desaturate behind a `lock.fill` with the hint shown as a goal and a live `ProgressView` + `n / target` for the count-based ones.
- **Full celebration sheet** (`IconUnlockCelebrationView`) presented app-wide from `RootTabView` whenever the service queues an unlock — wherever the user is when they earn it.

## Consequences

- **Hard acceptance criteria (ADR-0007) carry over.** Locked/celebration UI rides on semantic fonts + system glass; reveal motion + shine are `accessibilityReduceMotion`-gated; locked tickets carry full VoiceOver labels (state + hint + progress); content scrolls for Dynamic Type. No new colours beyond `Theme.accent`, no bundled fonts.
- **No new brand levers, no onboarding, no monetization** — the loop is invisible until the user stumbles into it.
- **Double-sheet timing:** an event-based unlock (website/calendar/suggest) can present the celebration over a just-opened Safari/editor sheet on the *first* time only. Accepted as a one-time delight; the celebration sits at the root level (separate hierarchy) so it never collides as a same-view double presentation.
- **Discoverability cost:** gating hides icons that were previously free. Mitigated by showing hints + progress (chosen over "??? mystery") so every locked ticket reads as an inviting, reachable goal.
- The WWDC26 ticket is only earnable during June 2026; after the window closes it can no longer be unlocked. This is intentional — it is a seasonal collectible tied to the app's ship date.
