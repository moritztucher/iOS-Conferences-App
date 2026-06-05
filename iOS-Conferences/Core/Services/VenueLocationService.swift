import CoreLocation
import MapKit

/// Resolves a conference's free-text location into map coordinates and a Look Around
/// scene. Keeps geocoding / MapKit lookups out of the ViewModel (which delegates here).
protocol VenueLocating {
    func coordinate(for query: String) async -> CLLocationCoordinate2D?
    func lookAroundScene(for coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene?
}

struct VenueLocationService: VenueLocating {
    func coordinate(for query: String) async -> CLLocationCoordinate2D? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let placemarks = try? await CLGeocoder().geocodeAddressString(trimmed)
        return placemarks?.first?.location?.coordinate
    }

    func lookAroundScene(for coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        return try? await request.scene
    }
}
