#!/usr/bin/env python3
"""Import a talk schedule from Sessionize or Pretalx into data/schedules/<conference-id>.json.

Writes the normalised schema from CONTRIBUTING.md › "Talk schedules" (ADR-0009). Session ids
are derived from the provider's ids, so re-running the import after the organiser edits
their schedule keeps the ids (and users' talk favourites) stable. Abstracts are never copied.
Standard library only. Review the output — the `kind` mapping is a heuristic.

    python3 scripts/import_schedule.py sessionize <event-id> --conference swiftleeds-2026 \\
        --time-zone Europe/London
    python3 scripts/import_schedule.py sessionize yak5yl8m --conference swiftcon-berlin-2026 \\
        --time-zone Europe/Berlin --room "swiftCon 1" --room "swiftCon 2" --room "swiftCon 3" --room Schedule \\
        --session 1348320
    python3 scripts/import_schedule.py swiftleeds - --conference swiftleeds-2026
    python3 scripts/import_schedule.py pretalx https://pretalx.com/<event>/schedule/export/schedule.json \\
        --conference nsspain-2026
"""

import argparse
import json
import re
import sys
import unicodedata
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parent.parent
CONFERENCES = ROOT / "data" / "conferences.json"
SCHEDULES = ROOT / "data" / "schedules"
USER_AGENT = "iOS-Conferences-schedule-import (+https://github.com/moritztucher/iOS-Conferences-App)"


# MARK: - Helpers

def fetch_json(url):
    if not url.startswith("https://"):
        sys.exit(f"Refusing non-HTTPS URL: {url}")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def slugify(value):
    ascii_value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", ascii_value.lower()).strip("-") or "room"


def session_kind(title, labels, is_break):
    """Heuristic mapping onto keynote | talk | workshop | break | social.

    Breaks come only from the provider's own flag (Sessionize service sessions, SwiftLeeds
    activities), never from title words: "When Emojis Break" is a talk.
    """
    if is_break:
        return "break"
    text = " ".join([title, *labels]).lower()
    if "workshop" in text:
        return "workshop"
    if "keynote" in text:
        return "keynote"
    if any(word in text for word in ("party", "dinner", "drinks", "social", "reception")):
        return "social"
    return "talk"


def make_session(conference_id, provider_id, kind, start, end, title, speakers, room_id, url):
    session = {
        "id": f"{conference_id}-{slugify(str(provider_id))}",
        "kind": kind,
        "day": start.date().isoformat(),
        "start": start.strftime("%H:%M"),
        "end": end.strftime("%H:%M"),
        "title": " ".join(title.split()),
    }
    if speakers:
        session["speakers"] = speakers
    if room_id:
        session["roomId"] = room_id
    if url and url.startswith("https://"):
        session["url"] = url
    return session


# MARK: - Sessionize (https://sessionize.com/api/v2/<event-id>/view/All)

def from_sessionize(event_id, conference_id, zone_name, room_filter, category_filter, session_filter):
    data = fetch_json(f"https://sessionize.com/api/v2/{event_id}/view/All")
    speakers = {s["id"]: s["fullName"] for s in data.get("speakers", [])}
    all_rooms = sorted(data.get("rooms", []), key=lambda r: r.get("sort", 0))
    categories = {
        item["id"]: item["name"]
        for category in data.get("categories", [])
        for item in category.get("items", [])
    }

    # Shared Sessionize events (e.g. a multi-conference umbrella) carry other conferences'
    # sessions. Keep a session if its room is in --room, it's tagged with a --category, or
    # its id is in --session (for one-offs in shared rooms, e.g. a community meetup).
    def is_kept(raw):
        if not room_filter and not category_filter and not session_filter:
            return True
        if str(raw["id"]) in session_filter:
            return True
        room_name = next((r["name"] for r in all_rooms if r["id"] == raw.get("roomId")), None)
        labels = {categories.get(item_id) for item_id in raw.get("categoryItems", [])}
        return room_name in room_filter or bool(labels & category_filter)

    kept_room_ids = {raw.get("roomId") for raw in data.get("sessions", []) if is_kept(raw)}
    # --room rooms lead, in the order given; rooms only reached via --category/--session follow.
    room_rank = {name: index for index, name in enumerate(room_filter)}
    rooms = sorted(
        (r for r in all_rooms if r["id"] in kept_room_ids),
        key=lambda r: room_rank.get(r["name"], len(room_rank)),
    )
    room_ids = {r["id"]: slugify(r["name"]) for r in rooms}

    sessions = []
    for raw in data.get("sessions", []):
        if not raw.get("startsAt") or not raw.get("endsAt") or not is_kept(raw):
            continue  # Not yet scheduled, or outside --room / --category.
        # Sessionize times are already event-local wall-clock, without an offset.
        start = datetime.fromisoformat(raw["startsAt"])
        end = datetime.fromisoformat(raw["endsAt"])
        labels = [categories.get(item_id, "") for item_id in raw.get("categoryItems", [])]
        sessions.append(make_session(
            conference_id,
            raw["id"],
            session_kind(raw["title"], labels, raw.get("isServiceSession", False)),
            start,
            end,
            raw["title"],
            [speakers[s] for s in raw.get("speakers", []) if s in speakers],
            room_ids.get(raw.get("roomId")),
            None,
        ))
    room_list = [{"id": room_ids[r["id"]], "name": r["name"]} for r in rooms]
    return zone_name, room_list, sessions


# MARK: - SwiftLeeds (https://swiftleeds.co.uk/api/v2/schedule, single track)

def from_swiftleeds(conference_id, zone_name):
    data = fetch_json("https://swiftleeds.co.uk/api/v2/schedule")["data"]
    room = {"id": slugify(data["event"]["location"].split(",")[0]), "name": data["event"]["location"].split(",")[0]}
    sessions = []
    for day in data.get("days", []):
        for slot in day.get("slots", []):
            day_start = datetime.fromisoformat(slot["date"]).date()
            hours, minutes = (int(part) for part in slot["startTime"].split(":"))
            start = datetime(day_start.year, day_start.month, day_start.day, hours, minutes)
            end = start + timedelta(minutes=slot["duration"])
            if "presentation" in slot:
                presentation = slot["presentation"]
                title = presentation["title"]
                kind = session_kind(title, [], False)
                speakers = [s["name"] for s in presentation.get("speakers", []) if s.get("name")]
            else:
                title = slot["activity"]["title"]
                kind = session_kind(title, [], False)
                kind = "break" if kind == "talk" else kind  # Host intros, registration, etc.
                speakers = []
            sessions.append(make_session(conference_id, slot["id"], kind, start, end, title, speakers, room["id"], None))
    return zone_name or "Europe/London", [room], sessions


# MARK: - Pretalx (https://<host>/<event>/schedule/export/schedule.json, frab format)

def from_pretalx(export_url, conference_id, zone_name):
    data = fetch_json(export_url)["schedule"]["conference"]
    zone_name = zone_name or data.get("time_zone_name")
    if not zone_name:
        sys.exit("The export has no time_zone_name; pass --time-zone.")
    zone = ZoneInfo(zone_name)

    room_names = [room["name"] for room in data.get("rooms", [])]
    sessions = []
    for day in data.get("days", []):
        for room_name, talks in day.get("rooms", {}).items():
            if room_name not in room_names:
                room_names.append(room_name)
            for talk in talks:
                start = datetime.fromisoformat(talk["date"]).astimezone(zone).replace(tzinfo=None)
                hours, minutes = (int(part) for part in talk["duration"].split(":")[:2])
                end = start + timedelta(hours=hours, minutes=minutes)
                sessions.append(make_session(
                    conference_id,
                    talk.get("id") or talk["guid"],
                    session_kind(talk["title"], [talk.get("type") or "", talk.get("track") or ""], False),
                    start,
                    end,
                    talk["title"],
                    [p["public_name"] for p in talk.get("persons", []) if p.get("public_name")],
                    slugify(room_name),
                    talk.get("url"),
                ))
    room_list = [{"id": slugify(name), "name": name} for name in room_names]
    return zone_name, room_list, sessions


# MARK: - Main

def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", choices=["sessionize", "pretalx", "swiftleeds"])
    parser.add_argument("event", help="Sessionize event id, Pretalx schedule.json export URL, or - for swiftleeds")
    parser.add_argument("--conference", required=True, help="Conference id from data/conferences.json")
    parser.add_argument("--time-zone", help="Venue IANA zone (required for Sessionize)")
    parser.add_argument("--room", action="append", default=[], help="Sessionize: keep this room (repeatable)")
    parser.add_argument("--category", action="append", default=[],
                        help="Sessionize: also keep sessions tagged with this category, in any room (repeatable)")
    parser.add_argument("--session", action="append", default=[],
                        help="Sessionize: also keep this session id, in any room (repeatable)")
    args = parser.parse_args()

    if args.source == "sessionize":
        if not args.time_zone:
            parser.error("--time-zone is required for Sessionize")
        zone_name, rooms, sessions = from_sessionize(
            args.event, args.conference, args.time_zone, list(dict.fromkeys(args.room)), set(args.category), set(args.session)
        )
    elif args.source == "swiftleeds":
        zone_name, rooms, sessions = from_swiftleeds(args.conference, args.time_zone)
    else:
        zone_name, rooms, sessions = from_pretalx(args.event, args.conference, args.time_zone)

    conference = next((c for c in json.loads(CONFERENCES.read_text(encoding="utf-8")) if c["id"] == args.conference), None)
    if conference is None:
        sys.exit(f"No conference `{args.conference}` in data/conferences.json.")
    in_range = [s for s in sessions if conference["startDate"] <= s["day"] <= conference["endDate"]]
    if len(in_range) < len(sessions):
        print(f"Skipped {len(sessions) - len(in_range)} session(s) outside {conference['startDate']}–{conference['endDate']}.")
    sessions = in_range

    # A room that only holds breaks/socials (e.g. a "Schedule" lane) isn't a stage: drop it.
    stage_rooms = {s.get("roomId") for s in sessions if s["kind"] not in ("break", "social")}
    for session in sessions:
        if session.get("roomId") not in stage_rooms:
            session.pop("roomId", None)

    room_order = {room["id"]: index for index, room in enumerate(rooms)}
    sessions.sort(key=lambda s: (s["day"], s["start"], room_order.get(s.get("roomId"), -1), s["title"]))
    used_rooms = {s.get("roomId") for s in sessions}
    rooms = [room for room in rooms if room["id"] in used_rooms]

    schedule = {
        "conferenceId": args.conference,
        "timeZone": zone_name,
        "updatedAt": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "rooms": rooms,
        "sessions": sessions,
    }
    SCHEDULES.mkdir(parents=True, exist_ok=True)
    out = SCHEDULES / f"{args.conference}.json"
    out.write_text(json.dumps(schedule, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote {out.relative_to(ROOT)}: {len(rooms)} room(s), {len(sessions)} session(s).")
    print("Next: review `kind` values, set \"hasSchedule\": true in conferences.json, "
          "run scripts/validate_schedules.py.")


if __name__ == "__main__":
    main()
