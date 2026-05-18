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
}
