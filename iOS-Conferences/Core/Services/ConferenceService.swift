import Foundation
import SwiftData

@MainActor
protocol ConferenceServiceProtocol {
    func fetchRemote() async throws -> [Conference]
    func refreshCache(into context: ModelContext) async throws
}

/// Default upsert: update existing conferences by id, insert new ones,
/// delete any in the store that are no longer in the fresh list.
extension ConferenceServiceProtocol {
    func refreshCache(into context: ModelContext) async throws {
        let fresh = try await fetchRemote()
        let descriptor = FetchDescriptor<Conference>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        let freshIDs = Set(fresh.map(\.id))

        for conference in fresh {
            if let target = existingByID[conference.id] {
                target.name = conference.name
                target.startDate = conference.startDate
                target.endDate = conference.endDate
                target.locationName = conference.locationName
                target.mapQuery = conference.mapQuery
                target.summary = conference.summary
                target.websiteURLString = conference.websiteURLString
                target.logoURLString = conference.logoURLString
                target.tags = conference.tags
            } else {
                context.insert(conference)
            }
        }
        for (id, target) in existingByID where !freshIDs.contains(id) {
            context.delete(target)
        }
        try context.save()
    }
}

/// Single point to vary the active refresh source. The factory is what
/// pull-to-refresh and background updates use; first-launch seeding still
/// uses `BundledConferenceService` directly in `iOS_ConferencesApp` so the
/// list is populated instantly even when offline.
@MainActor
enum ConferenceServiceFactory {
    static func make() -> any ConferenceServiceProtocol {
        LiveConferenceService()
    }
}

@MainActor
struct LiveConferenceService: ConferenceServiceProtocol {
    func fetchRemote() async throws -> [Conference] {
        let url = RepoConfig.conferencesJSONURL
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let (fallbackData, fallbackResponse) = try await URLSession.shared.data(from: RepoConfig.conferencesJSONFallbackURL)
            guard let fallbackHTTP = fallbackResponse as? HTTPURLResponse, (200..<300).contains(fallbackHTTP.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return try Self.decode(fallbackData)
        }
        return try Self.decode(data)
    }

    private static func decode(_ data: Data) throws -> [Conference] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = Self.dateFormatter.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date '\(string)' does not match expected format yyyy-MM-dd"
            )
        }
        let payload = try decoder.decode([ConferenceDTO].self, from: data)
        return payload.map { $0.toModel() }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

/// Seeds and keeps the SwiftData store in sync with the bundled `Conference.bundled` list.
/// Replaced by `LiveConferenceService` once `data/conferences.json` is pushed to the repo.
@MainActor
struct BundledConferenceService: ConferenceServiceProtocol {
    func fetchRemote() async throws -> [Conference] {
        Conference.bundled
    }
}

private struct ConferenceDTO: Decodable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let locationName: String
    let mapQuery: String?
    let summary: String
    let websiteURL: String
    let logoURL: String?
    let tags: [String]

    func toModel() -> Conference {
        Conference(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            locationName: locationName,
            mapQuery: mapQuery,
            summary: summary,
            websiteURLString: websiteURL,
            logoURLString: logoURL,
            tags: tags
        )
    }
}
