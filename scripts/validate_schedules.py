#!/usr/bin/env python3
"""Validate talk schedules in data/schedules/ against data/conferences.json.

Schema and rules: CONTRIBUTING.md › "Talk schedules" and ADR-0009.
Standard library only. Exits non-zero and prints one line per problem.

    python3 scripts/validate_schedules.py
"""

import json
import re
import sys
from datetime import date, datetime, time
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

ROOT = Path(__file__).resolve().parent.parent
CONFERENCES = ROOT / "data" / "conferences.json"
SCHEDULES = ROOT / "data" / "schedules"

SESSION_KINDS = {"keynote", "talk", "workshop", "break", "social"}
TOP_KEYS = {"conferenceId", "timeZone", "updatedAt", "rooms", "sessions"}
ROOM_KEYS = {"id", "name"}
SESSION_REQUIRED = {"id", "kind", "day", "start", "end", "title"}
SESSION_OPTIONAL = {"speakers", "roomId", "url"}
SLUG = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
HHMM = re.compile(r"^([01]\d|2[0-3]):[0-5]\d$")


class Report:
    def __init__(self):
        self.errors = []

    def error(self, where, message):
        self.errors.append(f"{where}: {message}")


def parse_hhmm(value):
    if not isinstance(value, str) or not HHMM.match(value):
        return None
    hours, minutes = value.split(":")
    return time(int(hours), int(minutes))


def parse_day(value):
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError):
        return None


def exists_in_zone(day, wall_time, zone):
    """False when the wall-clock time falls in a DST gap (it doesn't exist locally)."""
    local = datetime.combine(day, wall_time, tzinfo=zone)
    round_trip = local.astimezone(ZoneInfo("UTC")).astimezone(zone)
    return round_trip.replace(tzinfo=None) == local.replace(tzinfo=None)


def validate_rooms(rooms, where, report):
    if not isinstance(rooms, list):
        report.error(where, "`rooms` must be an array")
        return set()
    ids = set()
    for index, room in enumerate(rooms):
        room_where = f"{where} rooms[{index}]"
        if not isinstance(room, dict):
            report.error(room_where, "must be an object")
            continue
        for key in room.keys() - ROOM_KEYS:
            report.error(room_where, f"unknown key `{key}`")
        room_id = room.get("id")
        if not isinstance(room_id, str) or not SLUG.match(room_id):
            report.error(room_where, "`id` must be a kebab-case string")
        elif room_id in ids:
            report.error(room_where, f"duplicate room id `{room_id}`")
        else:
            ids.add(room_id)
        if not isinstance(room.get("name"), str) or not room["name"].strip():
            report.error(room_where, "`name` must be a non-empty string")
    return ids


def validate_session(session, where, context, report):
    if not isinstance(session, dict):
        report.error(where, "must be an object")
        return
    for key in SESSION_REQUIRED - session.keys():
        report.error(where, f"missing `{key}`")
    for key in session.keys() - SESSION_REQUIRED - SESSION_OPTIONAL:
        report.error(where, f"unknown key `{key}`")

    session_id = session.get("id")
    prefix = f"{context['conference_id']}-"
    if not isinstance(session_id, str) or not session_id.startswith(prefix) or not SLUG.match(session_id):
        report.error(where, f"`id` must be kebab-case and start with `{prefix}`")
    elif session_id in context["seen_ids"]:
        report.error(where, f"duplicate session id `{session_id}`")
    else:
        context["seen_ids"].add(session_id)

    kind = session.get("kind")
    if kind not in SESSION_KINDS:
        report.error(where, f"`kind` must be one of {sorted(SESSION_KINDS)}")

    day = parse_day(session.get("day"))
    if day is None:
        report.error(where, "`day` must be YYYY-MM-DD")
    elif not context["first_day"] <= day <= context["last_day"]:
        report.error(where, f"`day` {day} is outside the conference dates")

    start, end = parse_hhmm(session.get("start")), parse_hhmm(session.get("end"))
    if start is None or end is None:
        report.error(where, "`start` and `end` must be 24-hour HH:mm")
    elif end <= start:
        report.error(where, "`end` must be after `start` on the same day")
    elif day is not None and context["zone"] is not None:
        for label, wall_time in (("start", start), ("end", end)):
            if not exists_in_zone(day, wall_time, context["zone"]):
                report.error(where, f"`{label}` falls in a daylight-saving gap")

    title = session.get("title")
    if not isinstance(title, str) or not title.strip():
        report.error(where, "`title` must be a non-empty string")

    speakers = session.get("speakers", [])
    if not isinstance(speakers, list) or not all(isinstance(name, str) and name.strip() for name in speakers):
        report.error(where, "`speakers` must be an array of non-empty strings")

    room_id = session.get("roomId")
    if room_id is None:
        if kind not in ("break", "social") and len(context["room_ids"]) > 1:
            report.error(where, "`roomId` is required on talks when there is more than one room")
    elif room_id not in context["room_ids"]:
        report.error(where, f"`roomId` `{room_id}` is not in `rooms`")

    url = session.get("url")
    if url is not None and (not isinstance(url, str) or not url.startswith("https://")):
        report.error(where, "`url` must be an HTTPS URL")


def validate_schedule(path, conference, report, global_ids):
    where = str(path.relative_to(ROOT))
    try:
        schedule = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        report.error(where, f"invalid JSON ({error})")
        return
    if not isinstance(schedule, dict):
        report.error(where, "top level must be an object")
        return

    for key in TOP_KEYS - schedule.keys():
        report.error(where, f"missing `{key}`")
    for key in schedule.keys() - TOP_KEYS:
        report.error(where, f"unknown key `{key}`")

    conference_id = schedule.get("conferenceId")
    if conference_id != path.stem:
        report.error(where, f"`conferenceId` must match the file name (`{path.stem}`)")

    zone = None
    try:
        zone = ZoneInfo(schedule.get("timeZone") or "")
    except (ZoneInfoNotFoundError, ValueError):
        report.error(where, "`timeZone` must be a valid IANA identifier")

    try:
        datetime.fromisoformat(schedule.get("updatedAt", ""))
    except (TypeError, ValueError):
        report.error(where, "`updatedAt` must be an ISO 8601 timestamp")

    room_ids = validate_rooms(schedule.get("rooms", []), where, report)
    sessions = schedule.get("sessions", [])
    if not isinstance(sessions, list) or not sessions:
        report.error(where, "`sessions` must be a non-empty array")
        return

    context = {
        "conference_id": path.stem,
        "zone": zone,
        "room_ids": room_ids,
        "seen_ids": set(),
        "first_day": date.fromisoformat(conference["startDate"]),
        "last_day": date.fromisoformat(conference["endDate"]),
    }
    for index, session in enumerate(sessions):
        validate_session(session, f"{where} sessions[{index}]", context, report)

    for session_id in context["seen_ids"] & global_ids:
        report.error(where, f"session id `{session_id}` is also used in another schedule")
    global_ids |= context["seen_ids"]

    order = [(s.get("day", ""), s.get("start", "")) for s in sessions if isinstance(s, dict)]
    if order != sorted(order):
        report.error(where, "`sessions` must be sorted by `day`, then `start`")


def main():
    report = Report()
    conferences = {c["id"]: c for c in json.loads(CONFERENCES.read_text(encoding="utf-8"))}

    for conference_id, conference in conferences.items():
        flag = conference.get("hasSchedule")
        if flag is not None and not isinstance(flag, bool):
            report.error(f"conferences.json `{conference_id}`", "`hasSchedule` must be true or false")
        if flag is True and not (SCHEDULES / f"{conference_id}.json").exists():
            report.error(f"conferences.json `{conference_id}`", "`hasSchedule` is true but no schedule file exists")

    global_ids = set()
    paths = sorted(SCHEDULES.glob("*.json")) if SCHEDULES.exists() else []
    for path in paths:
        conference = conferences.get(path.stem)
        if conference is None:
            report.error(str(path.relative_to(ROOT)), "no conference with this id in conferences.json")
            continue
        if conference.get("hasSchedule") is not True:
            report.error(str(path.relative_to(ROOT)), "set `\"hasSchedule\": true` on the conference")
        validate_schedule(path, conference, report, global_ids)

    for line in report.errors:
        print(line)
    if report.errors:
        print(f"\n{len(report.errors)} problem(s) in {len(paths)} schedule file(s).")
        return 1
    print(f"OK: {len(paths)} schedule file(s), {len(global_ids)} session(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
