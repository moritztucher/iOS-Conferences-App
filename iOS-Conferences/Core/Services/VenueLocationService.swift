import CoreLocation
import MapKit

/// Resolves a conference's free-text location into map coordinates.
/// Keeps geocoding / MapKit lookups out of the ViewModel (which delegates here).
protocol VenueLocating {
    func coordinate(for query: String) async -> CLLocationCoordinate2D?
}

struct VenueLocationService: VenueLocating {
    func coordinate(for query: String) async -> CLLocationCoordinate2D? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let placemarks = try? await CLGeocoder().geocodeAddressString(trimmed)
        return placemarks?.first?.location?.coordinate
    }
}
