import Foundation
import Observation

@MainActor
@Observable
final class SuggestConferenceViewModel {
    var name: String = ""
    var websiteURL: String = ""
    /// Calendar-style "When": all-day by default (the common case for conferences);
    /// toggling off reveals the time components of the start/end pickers, Watch Party /
    /// Event style. The dates carry the time of day when `isAllDay` is false.
    var isAllDay: Bool = true
    var startDate: Date = .now
    var endDate: Date = Date.now.addingTimeInterval(86_400)
    /// IANA identifier the times are anchored to — mainly relevant for online timed
    /// events. Defaults to the device zone, like the Calendar app.
    var timeZoneID: String = TimeZone.current.identifier
    var location: String = ""
    var summary: String = ""
    var contributor: String = ""

    struct Content {
        let title: String
        let body: String
    }

    var isSubmittable: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !websiteURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func buildContent() -> Content {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = "Conference: \(trimmedName)"
        let body = """
        ### Name
        \(trimmedName)

        ### Website
        \(websiteURL.trimmingCharacters(in: .whitespacesAndNewlines))

        ### Dates
        \(ConferenceDateStyle.range(from: startDate, to: endDate))

        ### Time
        \(timeText)

        ### Time zone
        \(isAllDay ? "—" : timeZoneID)

        ### Location
        \(emptyDash(location))

        ### Description
        \(emptyDash(summary))

        ### Submitted by
        \(submittedBy)
        """
        return Content(title: title, body: body)
    }

    func githubIssueURL() -> URL? {
        let content = buildContent()
        return RepoConfig.newSuggestionIssueURL(title: content.title, body: content.body)
    }

    func mailtoFallbackURL() -> URL? {
        let content = buildContent()
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = RepoConfig.developerEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: content.title),
            URLQueryItem(name: "body", value: content.body)
        ]
        return components.url
    }

    private var submittedBy: String {
        let trimmed = contributor.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "—" }
        return trimmed.hasPrefix("@") ? trimmed : "@\(trimmed)"
    }

    private func emptyDash(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }

    /// "19:00 – 22:00" (fixed 24h, the format the issue template expects) or "—" for
    /// all-day — derived from the time components the pickers wrote into the dates.
    private var timeText: String {
        guard !isAllDay else { return "—" }
        return ConferenceDateStyle.submissionTimeRange(
            start: minutesOfDay(of: startDate),
            end: minutesOfDay(of: endDate)
        )
    }

    private func minutesOfDay(of date: Date) -> Int {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }
}
