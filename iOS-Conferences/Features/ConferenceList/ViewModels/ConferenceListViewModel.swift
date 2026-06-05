import Foundation
import Observation
import SwiftData

struct ConferenceMonthSection: Identifiable {
    let id: String
    let title: String
    let conferences: [Conference]
}

enum ConferenceFormatFilter: String, CaseIterable, Identifiable {
    case all
    case inPerson
    case online

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All formats"
        case .inPerson: return "In person"
        case .online: return "Online"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "globe.americas"
        case .inPerson: return "person.2.fill"
        case .online: return "video.fill"
        }
    }
}

enum ConferenceKindFilter: String, CaseIterable, Identifiable {
    case all
    case conferences
    case watchParties
    case events

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All kinds"
        case .conferences: return "Conferences"
        case .watchParties: return "Watch Parties"
        case .events: return "Events"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "rectangle.stack"
        case .conferences: return "building.columns.fill"
        case .watchParties: return "tv"
        case .events: return "calendar.badge.plus"
        }
    }
}

@MainActor
@Observable
final class ConferenceListViewModel {
    enum Filter {
        case all
        case favourites

        var title: String {
            switch self {
            case .all: return "Conferences"
            case .favourites: return "Favourites"
            }
        }
    }

    var searchText: String = ""
    var formatFilter: ConferenceFormatFilter = .all
    var kindFilter: ConferenceKindFilter = .all
    let filter: Filter

    init(filter: Filter) {
        self.filter = filter
    }

    var isFilterActive: Bool {
        formatFilter != .all || kindFilter != .all
    }

    /// Toggles a conference's favourite state from a swipe action.
    /// Mirrors the detail screen's toggle so both entry points behave identically.
    func toggleFavourite(
        _ conference: Conference,
        in favourites: [FavouriteConference],
        context: ModelContext
    ) {
        if let existing = favourites.first(where: { $0.conferenceID == conference.id }) {
            context.delete(existing)
        } else {
            context.insert(FavouriteConference(conferenceID: conference.id))
        }
        try? context.save()
    }

    func sections(
        from conferences: [Conference],
        favouriteIDs: Set<String>,
        showPast: Bool
    ) -> [ConferenceMonthSection] {
        var filtered = conferences

        if !showPast {
            filtered = filtered.filter { !$0.isPast }
        }

        if filter == .favourites {
            filtered = filtered.filter { favouriteIDs.contains($0.id) }
        }

        switch kindFilter {
        case .all:
            break
        case .conferences:
            filtered = filtered.filter { $0.kind == .conference }
        case .watchParties:
            filtered = filtered.filter { $0.kind == .watchParty }
        case .events:
            filtered = filtered.filter { $0.kind == .event }
        }

        switch formatFilter {
        case .all:
            break
        case .inPerson:
            filtered = filtered.filter { !$0.isOnline }
        case .online:
            filtered = filtered.filter { $0.isOnline }
        }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            filtered = filtered.filter { conference in
                conference.name.localizedCaseInsensitiveContains(trimmedQuery) ||
                conference.locationName.localizedCaseInsensitiveContains(trimmedQuery) ||
                conference.tags.contains { $0.localizedCaseInsensitiveContains(trimmedQuery) }
            }
        }

        let sorted = filtered.sorted { $0.startDate < $1.startDate }
        let grouped = Dictionary(grouping: sorted) { ConferenceDateStyle.monthKey(for: $0.startDate) }

        return grouped.keys.sorted().map { key in
            let confs = grouped[key] ?? []
            let title = confs.first.map { ConferenceDateStyle.monthHeader(for: $0.startDate) } ?? key
            return ConferenceMonthSection(id: key, title: title, conferences: confs)
        }
    }
}
