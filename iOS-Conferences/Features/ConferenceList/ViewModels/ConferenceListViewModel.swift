import Foundation
import Observation
import SwiftData

struct ConferenceListSection: Identifiable {
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
    /// Multi-select kind filter. Empty is treated as "all" (see `effectiveKinds`).
    var selectedKinds: Set<ConferenceKind> = Set(ConferenceKind.allCases)
    let filter: Filter

    init(filter: Filter) {
        self.filter = filter
    }

    /// Empty selection falls back to all kinds, so the list is never unexpectedly empty.
    var effectiveKinds: Set<ConferenceKind> {
        selectedKinds.isEmpty ? Set(ConferenceKind.allCases) : selectedKinds
    }

    var isFilterActive: Bool {
        formatFilter != .all || effectiveKinds != Set(ConferenceKind.allCases)
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

    /// Sections grouped by kind (Conferences → Events → Watch Parties), each sorted by
    /// date & time. Grouping by kind keeps dense months (e.g. WWDC week) organised: the
    /// marquee conferences sit apart from the pile of watch parties.
    func sections(
        from conferences: [Conference],
        favouriteIDs: Set<String>,
        showPast: Bool
    ) -> [ConferenceListSection] {
        var filtered = conferences

        if !showPast {
            filtered = filtered.filter { !$0.isPast }
        }

        if filter == .favourites {
            filtered = filtered.filter { favouriteIDs.contains($0.id) }
        }

        let kinds = effectiveKinds
        if kinds != Set(ConferenceKind.allCases) {
            filtered = filtered.filter { kinds.contains($0.kind) }
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

        return ConferenceKind.displayOrder.compactMap { kind in
            let confs = filtered
                .filter { $0.kind == kind }
                .sorted { $0.startDate < $1.startDate }
            guard !confs.isEmpty else { return nil }
            return ConferenceListSection(
                id: kind.rawValue,
                title: kind.pluralLabel.uppercased(),
                conferences: confs
            )
        }
    }
}
