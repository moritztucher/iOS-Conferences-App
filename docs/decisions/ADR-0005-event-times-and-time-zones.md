# ADR-0005: Event Times & Time Zones

## Status

Accepted (2026-06-09).

## Context

Conferences are multi-day and treated as all-day. But Watch Parties and Events are single-occasion and have a meaningful start (and often end) *time of day* — which the data model (day-granularity `startDate`/`endDate` only) couldn't express. We wanted to show the time on the card, sort same-day events by it, and create an accurate (timed, not all-day) calendar event. Times are inherently local to the event, and online events have no venue to derive a zone from.

## Decision

### Optional, local times in the feed

Three optional fields, omitted for multi-day conferences:

- `startTime` / `endTime` — event-**local** wall-clock, 24-hour `"HH:mm"`.
- `timeZone` — IANA identifier (e.g. `"Asia/Tokyo"`). Mainly for **online** events (no venue to geocode); overrides the geocoded zone for in-person events.

Stored on the model as `startTimeMinutes` / `endTimeMinutes` (`Int?`, minutes from midnight — clean to sort and format) and `timeZoneIdentifier` (`String?`). All optional → existing entries and conferences are unaffected (SwiftData lightweight migration).

### Behaviour

- **Display**: the card overline shows the local time for timed events; online timed events also show the zone abbreviation (e.g. `19:00 PDT · ONLINE`), since they have no location to imply it.
- **Sort**: within a kind group, by day then `startTime`.
- **Calendar**: timed events become *timed* `EKEvent`s (not all-day). The event's zone is resolved as `conference.timeZone` (feed) → geocoded venue zone (`CLPlacemark.timeZone`) → current zone. So a Tokyo 19:00 party saves as 19:00 Tokyo regardless of the viewer's zone.

### Why local wall-clock + optional zone (not absolute instants)

Storing absolute UTC instants would force every entry to carry a zone and would display a Tokyo party at the viewer's converted clock time. Local wall-clock matches how organizers publish times and how people browse ("the 7 PM party"); the optional `timeZone` disambiguates the cases (online) where location can't.

## Consequences

- **No accurate times until the feed is populated** — this shipped as plumbing; `conferences.json` carries no times yet. They're added per-event over time (documented in `CONTRIBUTING.md`).
- **Online events without a `timeZone`** fall back to the viewer's current zone for the calendar event — best-effort, since the intended zone is unknowable without the field.
- A pre-tap geocode race exists: if "Add to Calendar" is tapped before the on-appear geocode finishes (and no feed `timeZone` is set), the current zone is used.

## References

- ADR-0002 — JSON feed data source
- `CONTRIBUTING.md` — `startTime` / `endTime` / `timeZone` schema + examples
- `CLPlacemark.timeZone` — https://developer.apple.com/documentation/corelocation/clplacemark/timezone

## Date

2026-06-09
