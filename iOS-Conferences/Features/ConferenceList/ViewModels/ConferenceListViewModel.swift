import Foundation
import Observation

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
    let filter: Filter

    init(filter: Filter) {
        self.filter = filter
    }

    var isFilterActive: Bool {
        formatFilter != .all
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
