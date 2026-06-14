import SwiftUI
import SwiftData
import EventKit
import MapKit
import CoreLocation
import UIKit
import Observation

@MainActor
@Observable
final class ConferenceDetailViewModel {
    let conference: Conference

    var isShowingSafari = false
    var isShowingEventEditor = false
    var calendarAccessIssue: CalendarAccessIssue?

    /// Resolved lazily from the conference's location for the embedded venue map.
    var venueCoordinate: CLLocationCoordinate2D?
    /// The venue's time zone, resolved alongside the coordinate. Used so an added calendar
    /// event sits at the event's *local* time, not the viewer's.
    var venueTimeZone: TimeZone?

    private let venueService: VenueLocating

    enum CalendarAccessIssue: Identifiable {
        case denied
        case restricted

        var id: String {
            switch self {
            case .denied: return "denied"
            case .restricted: return "restricted"
            }
        }

        var title: String { "Calendar Access" }
        var message: String {
            switch self {
            case .denied:
                return "To add conferences to your calendar, enable calendar access in Settings."
            case .restricted:
                return "Calendar access is restricted on this device."
            }
        }
    }

    init(conference: Conference, venueService: VenueLocating = VenueLocationService()) {
        self.conference = conference
        self.venueService = venueService
    }

    /// Geocodes the venue (once) for the embedded map and the calendar time zone.
    /// No-ops for online events or when already resolved.
    func resolveVenue() async {
        guard !conference.isOnline, venueCoordinate == nil else { return }
        let query = conference.mapQuery ?? conference.locationName
        guard let venue = await venueService.resolve(query) else { return }
        venueCoordinate = venue.coordinate
        venueTimeZone = venue.timeZone
    }

    func isFavourite(in favourites: [FavouriteConference]) -> Bool {
        favourites.contains { $0.conferenceID == conference.id }
    }

    func toggleFavourite(in favourites: [FavouriteConference], context: ModelContext) {
        if let existing = favourites.first(where: { $0.conferenceID == conference.id }) {
            context.delete(existing)
        } else {
            context.insert(FavouriteConference(conferenceID: conference.id))
        }
        try? context.save()
    }

    func openInMaps() {
        guard let query = conference.mapQuery,
              let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?q=\(encoded)") else {
            return
        }
        UIApplication.shared.open(url)
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func requestCalendarAccess(via service: CalendarService) async {
        let status = service.authorizationStatus
        switch status {
        case .denied:
            calendarAccessIssue = .denied
            return
        case .restricted:
            calendarAccessIssue = .restricted
            return
        case .notDetermined, .writeOnly, .fullAccess, .authorized:
            break
        @unknown default:
            break
        }

        let granted = await service.requestAccess()
        if granted {
            isShowingEventEditor = true
        } else {
            calendarAccessIssue = .denied
        }
    }

    var shareText: String {
        let range = ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate)
        return "\(conference.name) · \(range) · \(conference.websiteURLString)"
    }
}
