import ConferenceKit
import Foundation
import SwiftData

enum ScheduleServiceError: LocalizedError {
    case invalidConferenceID(String)
    case unavailable

    var errorDescription: String? {
        switch self {
        case .invalidConferenceID(let id):
            "“\(id)” isn't a valid conference ID."
        case .unavailable:
            "The schedule couldn't be loaded. Pull to refresh to try again."
        }
    }
}

@MainActor
protocol ScheduleServiceProtocol {
    func fetchSchedule(conferenceID: String) async throws -> Schedule
}

extension ScheduleServiceProtocol {
    /// Fetches the schedule and replaces the cached copy, or inserts one. Talk favourites
    /// are separate rows, so they survive.
    @discardableResult
    func refreshCache(conferenceID: String, into context: ModelContext) async throws -> Schedule {
        let schedule = try await fetchSchedule(conferenceID: conferenceID)
        let descriptor = FetchDescriptor<ConferenceSchedule>(
            predicate: #Predicate { $0.conferenceID == conferenceID }
        )
        if let cached = try context.fetch(descriptor).first {
            try cached.replace(with: schedule)
        } else {
            context.insert(try ConferenceSchedule(schedule: schedule))
        }
        try context.save()
        return schedule
    }
}

@MainActor
enum ScheduleServiceFactory {
    static func make() -> any ScheduleServiceProtocol {
        LiveScheduleService()
    }
}

/// Loads `data/schedules/<id>.json` from jsDelivr, falling back to raw GitHub, the same
/// pattern as `LiveConferenceService`.
@MainActor
struct LiveScheduleService: ScheduleServiceProtocol {
    func fetchSchedule(conferenceID: String) async throws -> Schedule {
        // IDs come from the community feed and become a URL path: allow kebab-case only.
        guard conferenceID.wholeMatch(of: /[a-z0-9]+(-[a-z0-9]+)*/) != nil else {
            throw ScheduleServiceError.invalidConferenceID(conferenceID)
        }
        #if DEBUG && targetEnvironment(simulator)
        if let data = try? Data(contentsOf: RepoConfig.localRepoDataFile("schedules/\(conferenceID).json")) {
            return try ScheduleFeed.decode(data)
        }
        #endif
        if let data = try? await Self.load(RepoConfig.scheduleJSONURL(conferenceID: conferenceID)) {
            return try ScheduleFeed.decode(data)
        }
        guard let data = try? await Self.load(RepoConfig.scheduleJSONFallbackURL(conferenceID: conferenceID)) else {
            throw ScheduleServiceError.unavailable
        }
        return try ScheduleFeed.decode(data)
    }

    private static func load(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ScheduleServiceError.unavailable
        }
        return data
    }
}
