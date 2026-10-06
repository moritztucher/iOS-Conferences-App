# Feature Plan — Attending, Talk Schedules & Conference-Day Live Activity

Status: **Planned** (2026-10-06) · Decision record: [ADR-0009](decisions/ADR-0009-attending-talks-live-activity.md)

## 1. What we're building

1. **Attending flag.** Any conference can be flagged *Attending*, independently of *Favourite*.
2. **Talk schedules.** Conferences with schedule data show every talk: when it is, where it is, and who is speaking. Everyone can browse them, whether or not they're attending.
3. **Talk favourites → personal agenda.**
   - **Multi-track** (2+ rooms): the user hearts the talks they want to see, and those make up the agenda.
   - **Single-track** (one stage): every talk is automatically on the agenda, and the hearts are hidden.
4. **Live Activity** on the days of an *attending* conference shows on the Lock Screen and in the Dynamic Island what's on now or next, where it is, and when it starts or ends.

### Decisions locked (2026-10-06)

| Question | Decision |
|---|---|
| Talk data source | Curated per-conference JSON in the repo (`data/schedules/<conference-id>.json`), filled by PR or by an importer script for Sessionize/Pretalx |
| Live Activity updates | Local only, no backend. iOS 26 scheduled start, app foreground and background refresh, `staleDate` with a one-step lookahead |
| Schedule visibility | Everyone. *Attending* unlocks the personal agenda and the Live Activity |
| Multi-track slot with no favourite | Treated as free time, like a break. The title shows the next favourited talk |

## 2. Live Activity design

### Content rule (pure function, `AgendaResolver`)

Given `now` and the agenda (all talks for single-track, favourited talks for multi-track, both in schedule order):

| Situation | Title (headline) | Line 2 (body) | Line 3 (if space) |
|---|---|---|---|
| A talk is running | **current talk** | room · `ends in 23:10` | Next: *talk* · 10:45 · room |
| Break / free slot / before first talk | **next talk** | room · `starts in 12:03` | Then: *talk after* · 11:30 · room |
| After the last talk of the day | "That's a wrap for Day 2" | Tomorrow's first talk, or nothing on the final day | — |

The countdowns use `Text(timerInterval:countsDown:)`, so they tick without spending update budget. The accent colour (`Theme.accent`) is used only on the countdown. Talk titles use SF semibold, not the serif, because a talk title isn't a display moment under ADR-0006.

### Presentations

```
Lock Screen                                    Dynamic Island (expanded)
┌──────────────────────────────────────────┐   ┌──────────────────────────────────┐
│ DEINIT 2026 · DAY 2              🎤       │   │ 🎤 Hall A              ends 23:10 │
│ Swift Concurrency in Practice             │   │ Swift Concurrency in Practice     │
│ Hall A · ends in 23:10                    │   │ Next · SwiftData at Scale · 10:45 │
│ Next · SwiftData at Scale · 10:45 · Hall B│   └──────────────────────────────────┘
└──────────────────────────────────────────┘
Compact:  leading = 🎤 / ☕ (talk vs break) + room short   trailing = countdown
Minimal:  countdown (to the end of the current talk or the start of the next one)
```

- The overline (conference name · day) goes on the static `ActivityAttributes`.
- `context.isStale` == true means the current item has ended and no update arrived. The view then promotes **next** to the title (and shows "Then" on line 3). This is the **one-step lookahead**: a single missed update still shows the right content.
- VoiceOver: one combined label per region ("Now: Swift Concurrency in Practice, Hall A, ends in 23 minutes").

### Lifecycle (local only)

| Trigger | Action |
|---|---|
| Mark Attending, or change talk favourites | Recompute the day's agenda. Schedule the next conference day's activity with iOS 26 `Activity.request(…, start:)` at *first agenda item − 15 min* (this requires an `alertConfiguration`: "Day 2 starts soon") |
| App becomes active during a conference day | Start the activity if it's missing (because of the 8h cap or a dismissal), otherwise `update` |
| `BGAppRefreshTask` (opportunistic) | `update` with the recomputed state |
| Every update | `staleDate` = end of the current item, or start of the next item during a break |
| Last agenda item ends | `end(…, dismissalPolicy: .after(lastEnd + 15 min))` |
| Settings toggle off / `areActivitiesEnabled` false | Don't schedule anything, and end any running activity |

`ContentState` holds `current?`, `next?`, and `after?` (title, room, start, end): a few hundred bytes. It never holds the whole schedule.

## 3. Data

### Feed schema — `data/schedules/<conference-id>.json`

```json
{
  "conferenceId": "deinit-2026",
  "timeZone": "Europe/Berlin",
  "updatedAt": "2026-10-01T12:00:00Z",
  "rooms": [{ "id": "hall-a", "name": "Hall A" }, { "id": "hall-b", "name": "Hall B" }],
  "sessions": [
    {
      "id": "deinit-2026-s-48213",
      "kind": "talk",
      "day": "2026-10-13",
      "start": "09:00",
      "end": "09:45",
      "title": "Swift Concurrency in Practice",
      "speakers": ["Jane Doe"],
      "roomId": "hall-a",
      "url": "https://…/sessions/48213"
    },
    { "id": "deinit-2026-b-1", "kind": "break", "day": "2026-10-13", "start": "09:45", "end": "10:15", "title": "Coffee" }
  ]
}
```

- `kind`: `keynote | talk | workshop | break | social`. The agenda only includes `keynote | talk | workshop`. Breaks show in the full schedule but never take the Live Activity title.
- Times are **venue-local wall-clock plus a required `timeZone`**, which is ADR-0005 applied to sessions. The resolver converts them to absolute `Date`s once.
- **`id` must stay stable** across edits, because favourites are keyed on it. The importer derives it from the provider's session ID.
- **Legal:** store only the title, speakers, room, time, and link. No abstracts, in line with the CLAUDE.md content notes.
- `conferences.json` gets an optional `"hasSchedule": true` so the app never has to probe for 404s.

### App models (SwiftData)

| Model | Purpose |
|---|---|
| `ConferenceSchedule` @Model | Cache: `conferenceID` (unique), `timeZoneIdentifier`, `fetchedAt`, `rooms: [ScheduleRoom]`, `sessions: [ScheduleSession]` (Codable structs). Each refresh replaces the whole thing |
| `AttendingConference` @Model | `conferenceID` (unique), `markedAt`. Same pattern as `FavouriteConference` |
| `FavouriteTalk` @Model | `talkID` (unique), `conferenceID`, `favouritedAt`. Survives schedule refreshes, and is never stored on the cached session |

### Services

- `ScheduleService` (protocol + live + bundled/mock) does a fetch via `RepoConfig`, using the same primary/fallback pattern as `ConferenceService`. It refreshes when a schedule is opened, on pull-to-refresh, and on foreground during an attended conference.
- `AgendaResolver` is a pure value type that turns (sessions, favourites, isSingleTrack, now) into a `LiveAgendaState`. It holds all the business logic and is fully unit-tested.
- `LiveActivityManager` (`@MainActor`) handles scheduling, starting, updating, and ending, the enablement gate, and observing `activityStateUpdates`.

## 4. UI

| Surface | Change |
|---|---|
| Detail toolbar | New **Attending** toggle using `ticket` / `ticket.fill`, which matches the ticket identity. It sits next to the heart and springs the same way. Marking Attending also favourites the conference; un-attending leaves the favourite alone |
| Detail cards | New **Schedule** `GlassSectionCard` (only when `hasSchedule`): "Up next" preview of 2–3 sessions, then a "Full schedule" row that pushes `Route.conferenceSchedule(conferenceID:)` |
| `ConferenceScheduleView` (new) | Stock `Picker(.segmented)` for the day. "All / My agenda" filter (attending + multi-track only). `List` grouped by time slot. Rows show kind symbol, title, speakers, room, and a heart button (multi-track only). Overlapping favourites get a conflict badge. During the event there's a "Now" marker and it scrolls to now. If the device time zone differs from the venue, times are shown in venue time with the zone abbreviation |
| Conference card | "ATTENDING" stamp on the ticket stub (extends `ConferenceCard`) |
| Favourites tab | An **Attending** section above the favourites |
| Settings › Display | Toggle "Live Activity during conferences" (default on) |
| Single-track note | Under the schedule header: "One stage — every talk is on your agenda." |

All of this is stock `List`/`Form`/`Picker`, with glass only on toolbar and floating chrome (ADR-0007). It must support Dynamic Type at AX sizes (no fixed-height rows), and reduce motion gates the heart/ticket springs.

## 5. Phases

| # | Scope | Notes |
|---|---|---|
| 0 ✅ | ADR-0009, feed schema, `CONTRIBUTING.md` section, `scripts/validate_schedules.py`, `scripts/import_schedule.py` (Sessionize, Pretalx, SwiftLeeds), seeded `swiftcon-berlin-2026` (3 tracks, Sessionize umbrella event filtered with `--room`) and `swiftleeds-2026` (single track) | Done 2026-10-06. No app code |
| 1 | `AttendingConference`, toolbar toggle, card stamp, Favourites section | Ships on its own |
| 2 | `ConferenceSchedule` / `FavouriteTalk` models, `ScheduleService`, `AgendaResolver` + XCTest matrix | Logic first, tests gate it |
| 3 | Schedule section + `ConferenceScheduleView`, talk hearts, conflict badge, Now marker | UI-first inside the phase |
| 4 | Widget extension target, shared `ConferenceDayAttributes`, Lock Screen + all Dynamic Island regions, `LiveActivityManager`, `NSSupportsLiveActivities`, BG refresh task, Settings toggle | Run the scheduled-start spike first (see risks) |
| 5 | `/ios-design-audit`, VoiceOver pass, `VIEW-INVENTORY.md`, `ARCHITECTURE.md`, App Store screenshot of the Live Activity | |

### `AgendaResolver` test matrix

Before the first talk · during a talk · exact boundary (end == next start) · coffee break · multi-track gap · overlapping favourites (the earlier start wins, with a tie-break on favourite order) · after the last talk · single-track ignores favourites · day with no agenda items · venue zone ≠ device zone · DST change during the conference.

## 6. Risks & open items

1. **iOS 26 scheduled start limits.** We don't yet know how far ahead it works, how many pending activities are allowed, or whether a pending one survives an app update. *Spike before phase 4.* Fallback: start the activity on the first foreground of the day.
2. **8-hour active cap.** A 9:00–18:30 day is longer than the cap. Mitigation: re-start on foreground, or schedule a second activity around midday (covered by the same spike).
3. **Accuracy without push.** Between app opens, correctness depends on the one-step lookahead. Two or more missed transitions in a row will show stale content, dimmed by the system. If that matters in practice, the upgrade path is ADR-0009's "broadcast push" alternative.
4. **Schedule churn on the day** (room swaps, cancellations) only reaches users after a PR is merged and they refresh. This is accepted for v1.
5. **Coverage.** The feature is only as good as the number of schedule files. The importer script is what makes curation cheap.
6. **Scope.** This turns the app from an aggregator into a conference companion. ADR-0009 records that this is a deliberate expansion. The browse-first list stays the primary job.
7. `docs/iOS26-OPPORTUNITIES.md` §1.2 says "we have no session-level data". Update it once this ships.
