import Foundation

enum RepoConfig {
    static let owner = "moritztucher"
    static let repo = "iOS-Conferences-App"
    static let dataBranch = "main"
    static let developerEmail = "moritztucher@gmail.com"

    /// Consumable IAP — must match the product configured in App Store Connect.
    static let tipProductID = "com.pocketapps.conferences.tip"

    static var conferencesJSONURL: URL {
        URL(string: "https://cdn.jsdelivr.net/gh/\(owner)/\(repo)@\(dataBranch)/data/conferences.json")!
    }

    static var conferencesJSONFallbackURL: URL {
        URL(string: "https://raw.githubusercontent.com/\(owner)/\(repo)/\(dataBranch)/data/conferences.json")!
    }

    static var repoWebURL: URL {
        URL(string: "https://github.com/\(owner)/\(repo)")!
    }

    static var suggestionsThreadURL: URL {
        URL(string: "https://github.com/\(owner)/\(repo)/issues?q=is%3Aissue+label%3Aconference-suggestion")!
    }

    static func newSuggestionIssueURL(title: String, body: String) -> URL? {
        var components = URLComponents(string: "https://github.com/\(owner)/\(repo)/issues/new")
        components?.queryItems = [
            URLQueryItem(name: "template", value: "conference-request.yml"),
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "body", value: body)
        ]
        return components?.url
    }

    static var suggestionMailtoURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = developerEmail
        components.queryItems = [URLQueryItem(name: "subject", value: "Suggest a conference")]
        return components.url
    }
}
