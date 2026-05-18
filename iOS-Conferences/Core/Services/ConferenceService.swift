import Foundation
import SwiftData

@MainActor
protocol ConferenceServiceProtocol {
    func fetchRemote() async throws -> [Conference]
    func refreshCache(into context: ModelContext) async throws
}

/// Single point to switch between Mock and Live data sources.
/// TODO: flip to `LiveConferenceService()` once `conferences.json` is pushed to the repo.
@MainActor
enum ConferenceServiceFactory {
    static func make() -> any ConferenceServiceProtocol {
        MockConferenceService()
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
            // Try fallback once.
            let (fallbackData, fallbackResponse) = try await URLSession.shared.data(from: RepoConfig.conferencesJSONFallbackURL)
            guard let fallbackHTTP = fallbackResponse as? HTTPURLResponse, (200..<300).contains(fallbackHTTP.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return try Self.decode(fallbackData)
        }
        return try Self.decode(data)
    }

    func refreshCache(into context: ModelContext) async throws {
        let remote = try await fetchRemote()
        let existingByID: [String: Conference]
        do {
            let descriptor = FetchDescriptor<Conference>()
            let existing = try context.fetch(descriptor)
            existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        } catch {
            existingByID = [:]
        }

        let remoteIDs = Set(remote.map(\.id))
        for conference in remote {
            if let existing = existingByID[conference.id] {
                existing.name = conference.name
                existing.startDate = conference.startDate
                existing.endDate = conference.endDate
                existing.locationName = conference.locationName
                existing.mapQuery = conference.mapQuery
                existing.summary = conference.summary
                existing.websiteURLString = conference.websiteURLString
                existing.tags = conference.tags
            } else {
                context.insert(conference)
            }
        }
        // Remove conferences that disappeared from the feed.
        for (id, existing) in existingByID where !remoteIDs.contains(id) {
            context.delete(existing)
        }
        try context.save()
    }

    private static func decode(_ data: Data) throws -> [Conference] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode([ConferenceDTO].self, from: data)
        return payload.map { $0.toModel() }
    }
}

@MainActor
struct MockConferenceService: ConferenceServiceProtocol {
    func fetchRemote() async throws -> [Conference] {
        try await Task.sleep(for: .milliseconds(300))
        return Conference.samples
    }

    func refreshCache(into context: ModelContext) async throws {
        let descriptor = FetchDescriptor<Conference>()
        let existing = (try? context.fetch(descriptor)) ?? []
        if existing.isEmpty {
            for conference in try await fetchRemote() {
                context.insert(conference)
            }
            try context.save()
        }
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
