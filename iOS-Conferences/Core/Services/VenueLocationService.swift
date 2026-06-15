import CoreLocation
import MapKit

/// A geocoded venue: map coordinate plus the location's time zone (from the placemark),
/// used to anchor calendar events to the event's local time.
struct ResolvedVenue {
    let coordinate: CLLocationCoordinate2D
    let timeZone: TimeZone?
}

/// Resolves a conference's free-text location into a coordinate + time zone.
/// Keeps geocoding / MapKit lookups out of the ViewModel (which delegates here).
protocol VenueLocating {
    func resolve(_ query: String) async -> ResolvedVenue?
}

struct VenueLocationService: VenueLocating {
    func resolve(_ query: String) async -> ResolvedVenue? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let placemark = try? await CLGeocoder().geocodeAddressString(trimmed).first,
              let coordinate = placemark.location?.coordinate else { return nil }
        return ResolvedVenue(coordinate: coordinate, timeZone: placemark.timeZone)
    }
}
