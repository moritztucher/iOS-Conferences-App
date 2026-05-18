import Foundation
import Observation

@MainActor
@Observable
final class SuggestConferenceViewModel {
    var name: String = ""
    var websiteURL: String = ""
    var startDate: Date = .now
    var endDate: Date = Date.now.addingTimeInterval(86_400)
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
}
