import Foundation

enum ConferenceDateStyle {
    /// e.g. "Jun 8 – 12, 2026" or "Jun 28 – Jul 2, 2026"
    static func range(from start: Date, to end: Date) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: start, to: end)
    }

    /// e.g. "MAY 2026" — used as List Section headers.
    static func monthHeader(for date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year()).uppercased()
    }

    /// Relative status for the detail screen's Date row: a localized countdown before the
    /// event ("In 3 months", "Tomorrow"), "Happening now" during it, and `nil` once it has
    /// ended (so the row isn't cluttered for past events). Day-granular, so the bucket is
    /// stable across the event day regardless of the time of day.
    static func countdown(from start: Date, to end: Date, now: Date = .now) -> String? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)
        let startDay = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: end)
        if today > endDay { return nil }
        if today >= startDay { return "Happening now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relative = formatter.localizedString(for: startDay, relativeTo: today)
        return relative.prefix(1).uppercased() + relative.dropFirst()
    }

    /// Stable key for grouping a date by month — used by the list view model.
    static func monthKey(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }

    /// Date broken into ticket-stub lines: a small month label over a large day (range),
    /// with an optional bottom line for the rare cross-month event.
    /// e.g. `JUN` / `8–12`, `JUN` / `9`, or `JUN` / `28` / `– JUL 2`.
    struct StubDate {
        let month: String
        let day: String
        let endLine: String?
    }

    /// Parses an event-local `"HH:mm"` (24h) string into minutes from midnight (0–1439).
    /// Returns `nil` for malformed or out-of-range input. `nonisolated` so the JSON
    /// decoder (a nonisolated context) can call it.
    nonisolated static func minutes(fromHHmm string: String) -> Int? {
        let parts = string.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0..<24).contains(hour), (0..<60).contains(minute) else { return nil }
        return hour * 60 + minute
    }

    /// Formats minutes-from-midnight as a locale-aware short time, e.g. "7:00 PM" / "19:00".
    static func timeLabel(minutes: Int) -> String {
        var comps = DateComponents()
        comps.hour = minutes / 60
        comps.minute = minutes % 60
        guard let date = Calendar.current.date(from: comps) else { return "" }
        return date.formatted(date: .omitted, time: .shortened)
    }

    /// e.g. "7:00 PM" or "7:00 – 10:00 PM" when an end time is present.
    static func timeRangeLabel(start: Int, end: Int?) -> String {
        guard let end else { return timeLabel(minutes: start) }
        return "\(timeLabel(minutes: start)) – \(timeLabel(minutes: end))"
    }

    static func stub(from start: Date, to end: Date) -> StubDate {
        let cal = Calendar.current
        let month = start.formatted(.dateTime.month(.abbreviated)).uppercased()
        let startDay = cal.component(.day, from: start)
        let endDay = cal.component(.day, from: end)

        if cal.isDate(start, inSameDayAs: end) {
            return StubDate(month: month, day: "\(startDay)", endLine: nil)
        }
        if cal.isDate(start, equalTo: end, toGranularity: .month) {
            return StubDate(month: month, day: "\(startDay)–\(endDay)", endLine: nil)
        }
        let endShort = end.formatted(.dateTime.month(.abbreviated).day()).uppercased()
        return StubDate(month: month, day: "\(startDay)", endLine: "– \(endShort)")
    }
}
