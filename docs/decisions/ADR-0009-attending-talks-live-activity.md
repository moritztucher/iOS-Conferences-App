# ADR-0009: Attending, Talk Schedules & a Local-Only Conference-Day Live Activity

## Status

Proposed (2026-10-06).

## Context

The app answers "which conferences are coming up". Users also want to know what they'll be watching *at* a conference they're going to. That means flagging a conference as attended, seeing its talks, picking talks across parallel tracks, and having the phone show what's on now or next during the event. The project has no backend (ADR-0001/0002), so we have no talk data and no push server.

## Decision

1. **Attending is its own local flag** (`AttendingConference`, stored by ID only, like `FavouriteConference`). Marking a conference as Attending also favourites it.
2. **Talk schedules are curated JSON in the repo**: one `data/schedules/<conference-id>.json` file per conference, in a single normalised schema. Times are venue-local wall-clock with a required IANA `timeZone` (as in ADR-0005). Importer scripts convert Sessionize/Pretalx exports into this schema. The app never calls a provider at runtime. Only factual fields are stored (title, speakers, room, time, link), with no abstracts.
3. **Everyone can see schedules.** *Attending* unlocks the personal agenda and the Live Activity.
4. **Agenda:** on a single-track conference every talk is on the agenda. On a multi-track conference only favourited talks are (`FavouriteTalk`, stored by stable talk ID). A slot with no favourited talk counts as free time.
5. **The Live Activity is updated locally only.** It starts with iOS 26 scheduled start, and is updated on app foreground and by `BGAppRefreshTask`. Each update carries `staleDate` = the current slot's end, plus a one-step `next` lookahead that the view promotes to the title when `isStale` is true.

## Alternatives considered

- **Live fetch from Sessionize/Pretalx.** Data stays fresh, but it needs one adapter per provider, only covers conferences that use those tools, and depends on someone else's uptime. Rejected for v1. The importer reuses the same providers offline.
- **Broadcast push (APNs channels) from a cron job** (GitHub Action or Worker). This would keep the Live Activity exactly right all day, but it introduces a backend, an APNs signing key, and operations work, which goes against ADR-0002. Kept as the upgrade path if local-only accuracy turns out not to be good enough in the field.
- **Schedules only for attended conferences.** Simpler, but it hides the information people use to decide whether to go.

## Consequences

- New surface area: a widget extension target, a shared attributes type, three SwiftData models, `ScheduleService`, `AgendaResolver`, and `LiveActivityManager`.
- The scope grows from aggregator to companion. This is deliberate. The date-sorted list stays the primary job.
- Changes to a schedule on the day only reach users after a PR is merged and the app refreshes.
- Live Activity accuracy degrades gracefully: one missed transition is covered by the lookahead, and two or more show dimmed, stale content until the app runs.
- Users must keep talk IDs stable across schedule edits, or their favourites are lost. `CONTRIBUTING.md` documents this, and the validator enforces that IDs are unique.

## References

- ADR-0002 (data source), ADR-0005 (times & zones), ADR-0006/0007 (visual levers, glass)
- `docs/FEATURE-ATTENDING-TALKS.md`: full plan, Live Activity layout, phases
- `Activity.request(attributes:content:pushType:style:alertConfiguration:start:)` (iOS 26): https://developer.apple.com/documentation/activitykit/activity/request(attributes:content:pushtype:style:alertconfiguration:start:)
- Sessionize API: https://sessionize.com/playbook/api

## Date

2026-10-06
