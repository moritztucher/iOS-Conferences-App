import Foundation

/// Broad world regions used by the list's region filter.
enum ConferenceRegion: String, CaseIterable, Identifiable {
    case northAmerica = "North America"
    case southAmerica = "South America"
    case europe = "Europe"
    case asiaPacific = "Asia Pacific"
    case africaMiddleEastIndia = "Africa, Middle East, and India"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .northAmerica: return "globe.americas.fill"
        case .southAmerica: return "globe.americas"
        case .europe: return "globe.europe.africa.fill"
        case .asiaPacific: return "globe.asia.australia.fill"
        case .africaMiddleEastIndia: return "globe.central.south.asia.fill"
        }
    }

    /// Country / territory keywords mapped to this region, matched against the country
    /// component of a conference's `locationName`.
    fileprivate var keywords: [String] {
        switch self {
        case .northAmerica:
            return ["usa", "u.s.a", "united states", "america", "canada", "mexico"]
        case .southAmerica:
            return ["brazil", "brasil", "argentina", "chile", "colombia", "peru",
                    "uruguay", "ecuador", "bolivia", "paraguay", "venezuela"]
        case .europe:
            return ["uk", "u.k", "united kingdom", "england", "scotland", "wales",
                    "ireland", "germany", "france", "spain", "italy", "netherlands",
                    "belgium", "switzerland", "austria", "portugal", "poland", "sweden",
                    "norway", "denmark", "finland", "czech", "macedonia", "greece",
                    "hungary", "romania", "croatia", "serbia", "slovenia", "slovakia",
                    "estonia", "lithuania", "latvia", "iceland", "luxembourg"]
        case .asiaPacific:
            return ["japan", "china", "korea", "singapore", "australia", "new zealand",
                    "philippines", "indonesia", "malaysia", "thailand", "vietnam",
                    "taiwan", "hong kong"]
        case .africaMiddleEastIndia:
            return ["india", "uae", "united arab emirates", "dubai", "abu dhabi",
                    "saudi", "qatar", "kuwait", "bahrain", "oman", "israel", "turkey",
                    "egypt", "nigeria", "kenya", "south africa", "morocco", "ghana"]
        }
    }
}

extension Conference {
    /// Best-effort region derived from the country component of `locationName`. `nil` for
    /// online or unrecognised locations.
    ///
    /// Heuristic by design — the feed carries no region field. Matching only the trailing
    /// country token (not the whole string) avoids false hits like "Milwaukee" → "uk".
    /// If the feed grows, a stored region field would be more robust.
    var region: ConferenceRegion? {
        if isOnline { return nil }
        let country = locationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .last
        guard let country, !country.isEmpty else { return nil }
        return ConferenceRegion.allCases.first { region in
            region.keywords.contains { country.contains($0) }
        }
    }
}
