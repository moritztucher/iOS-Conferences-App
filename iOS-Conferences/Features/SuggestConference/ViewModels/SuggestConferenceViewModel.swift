import Foundation
import Observation

@MainActor
@Observable
final class SuggestConferenceViewModel {
    var name: String = ""
    var websiteURL: String = ""
    var startDate: Date = .now
    var endDate: Date = Date.now.addingTimeInterval(86_400)
    /// Optional event-local times (`HH:mm`) for Watch Parties / Events; left blank for conferences.
    var startTime: String = ""
    var endTime: String = ""
    /// Optional IANA time-zone identifier — mainly for online timed events.
    var timeZone: String = ""
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
        \(emptyDash(timeZone))

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

    /// "19:00 – 22:00", "19:00", or "—" — for the submission body.
    private var timeText: String {
        let start = startTime.trimmingCharacters(in: .whitespacesAndNewlines)
        let end = endTime.trimmingCharacters(in: .whitespacesAndNewlines)
        if start.isEmpty { return "—" }
        return end.isEmpty ? start : "\(start) – \(end)"
    }
}
