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

    var isSubmittable: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !websiteURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func buildURL() -> URL? {
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

        if let url = RepoConfig.newSuggestionIssueURL(title: title, body: body) {
            return url
        }
        return RepoConfig.suggestionMailtoURL
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
