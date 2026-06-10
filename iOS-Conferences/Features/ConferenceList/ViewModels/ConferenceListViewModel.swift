import Foundation
import Observation
import SwiftData

/// A month group in the list (e.g. "JUNE 2026"), split into kind groups.
struct ConferenceMonthSection: Identifiable {
    let id: String          // month key, e.g. "2026-06"
    let title: String       // e.g. "JUNE 2026" (year folded into the header)
    let groups: [ConferenceTypeGroup]
    /// Show per-type sub-dividers only when the month actually mixes kinds.
    let showsTypeHeaders: Bool
    /// Display-only: true when every conference in the month has ended, so the month
    /// masthead can recede with the same aliveness treatment as its tickets.
    let isPast: Bool
}

/// A kind group within a month, sorted by day then time.
struct ConferenceTypeGroup: Identifiable {
    let id: String          // e.g. "2026-06-Conference"
    let kind: ConferenceKind
    let title: String       // e.g. "CONFERENCES"
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
    /// Multi-select region filter. Empty means Global (all regions).
    var selectedRegions: Set<ConferenceRegion> = []
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

    var isRegionFilterActive: Bool { !selectedRegions.isEmpty }

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

    /// Month-primary sections (chronological, year folded into the title), each split into
    /// kind groups in display order (Conferences → Events → Watch Parties) and sorted by
    /// day then time within. Type sub-dividers only surface in months that mix kinds, so
    /// dense months (WWDC week) get organised while quiet months stay clean.
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

        if !selectedRegions.isEmpty {
            filtered = filtered.filter { $0.region.map(selectedRegions.contains) ?? false }
        }

        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            filtered = filtered.filter { conference in
                conference.name.localizedCaseInsensitiveContains(trimmedQuery) ||
                conference.locationName.localizedCaseInsensitiveContains(trimmedQuery) ||
                conference.tags.contains { $0.localizedCaseInsensitiveContains(trimmedQuery) }
            }
        }

        // Month-primary, chronological. Each event groups by its start month.
        let byMonth = Dictionary(grouping: filtered) { ConferenceDateStyle.monthKey(for: $0.startDate) }

        return byMonth.keys.sorted().map { monthKey in
            let monthConferences = byMonth[monthKey] ?? []
            let title = monthConferences.first
                .map { ConferenceDateStyle.monthHeader(for: $0.startDate) } ?? monthKey

            // Within the month: kind groups in display order, each sorted by day then time.
            let groups: [ConferenceTypeGroup] = ConferenceKind.displayOrder.compactMap { kind in
                let confs = monthConferences
                    .filter { $0.kind == kind }
                    .sorted { lhs, rhs in
                        // Day first, then time of day (untimed events sort before timed).
                        if lhs.startDate != rhs.startDate { return lhs.startDate < rhs.startDate }
                        return (lhs.startTimeMinutes ?? -1) < (rhs.startTimeMinutes ?? -1)
                    }
                guard !confs.isEmpty else { return nil }
                return ConferenceTypeGroup(
                    id: "\(monthKey)-\(kind.rawValue)",
                    kind: kind,
                    title: kind.pluralLabel.uppercased(),
                    conferences: confs
                )
            }

            return ConferenceMonthSection(
                id: monthKey,
                title: title,
                groups: groups,
                showsTypeHeaders: groups.count > 1,
                isPast: monthConferences.allSatisfy(\.isPast)
            )
        }
    }
}
