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
