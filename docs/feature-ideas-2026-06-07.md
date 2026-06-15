# Feature Ideas — 2026-06-07

> Captured from a brainstorm. Documentation only — none committed to a milestone yet.
> Cross-refs existing `Backlog.md` entries where they overlap.

## Context

App is currently static-JSON, offline-first, no backend, no accounts (`data/conferences.json` → SwiftData cache). Any idea that requires shared/server state is a structural leap and should be flagged as such.

---

## 1. Live Activity — "conference happening now" ✅ cheap, recommended v1

Show a Live Activity (lock screen + Dynamic Island) while a favourited conference is live, driven by `startDate`/`endDate`.

- **Cost:** Low. Purely local — ActivityKit + existing date fields. No backend.
- **Content:** conference name, current day (Day 2 of 3), countdown to end / next day.
- **Trigger:** user opts in per conference (or auto for favourites), gated by a Settings toggle.
- **Why it's good:** iOS-26-native, screenshot/share-friendly, zero server cost.
- Backlog already lists this under *Low Priority* — this note promotes the rationale.

## 2. Local "I'm attending" flag — cheap

A private, local-only attendance flag (distinct from favourite). Drives the Live Activity and could surface a personal "my schedule" view.

- **Cost:** Low. Local SwiftData, no accounts.
- **Note:** This is the cheap half of the original "people select they attend" idea.

## 3. Attendee list / social "who's going" — ⛔ deferred

Seeing *other* people who marked attendance.

- **Cost:** High. Requires backend, user accounts, moderation, privacy/abuse handling.
- **Verdict:** Different product. Park until/unless the app justifies a backend (overlaps Backlog *Ideas*: "Apple Sign-In + CloudKit sync").

## 4. Schedule pull → show as live event — ⚠️ maintenance tax

Pull each conference's session schedule and surface the current/next talk.

- **Problem:** No `sessions` field in the data model; every conference site formats its schedule differently. Scraping is brittle and a recurring maintenance cost.
- **Better shape:** optional hand-curated `sessions: []` array on the few large conferences that publish clean schedules. Feed the Live Activity ("On now: <talk>") only where data exists.

## 5. Countdown widget for favourite conference — ✅ small, recommended

WidgetKit widget showing a countdown to your favourite / next conference.

- **Cost:** Small. Local, reuses date logic from the Live Activity.
- **Size:** small (single conference countdown); medium could show next 1–3.
- Backlog already lists "WidgetKit widget showing the next 1–3 conferences" under *Low Priority* and *Ideas* — this adds the single-favourite countdown variant.

---

## 6. Multi-select — small/medium

Allow selecting multiple conferences at once (e.g. for batch favourite, batch "add to calendar", batch share/export).

- **Cost:** Small–medium. SwiftUI `EditMode` + selection set on the list; actions operate on the set.
- **Open question:** which batch actions matter most — favourite, calendar, share? (assumed favourite + calendar.)

## 7. Finer list ordering & separators — small

Within a month, order additionally by **time of day**, and add **day-level separators** when multiple events fall on different days — especially clustered weeks (e.g. WWDC week, where several events run across adjacent days).

- **Cost:** Small. Extends the existing month `Section` logic to sub-group by day; sort key becomes `(startDate, startTime)`.
- **Note:** needs a start-time field in the data model — currently only `startDate`/`endDate` (date granularity). Add optional `startTime` or keep date-only and just add day separators.

## 8. Information & notes about conferences — small/medium

Two things bundled: (a) richer **information** surfaced on the detail view, and (b) personal **notes** a user can write about a conference.

- **(a) Info:** more structured fields (CFP deadline, ticket price, format in-person/online, social links). Local data-model + JSON schema additions.
- **(b) Notes:** user-authored free-text note per conference, local-only (SwiftData), no backend.
- **Cost:** Small for notes (local); medium for info (depends how many curated fields and who maintains them).

## Suggested v1 slice (if/when prioritised)

Live Activity (1) + local attendance flag (2) + countdown widget (5) + Settings toggles.
All local, no backend, share-friendly. Defer (3) hard; treat (4) as curated-data, not scraping.
