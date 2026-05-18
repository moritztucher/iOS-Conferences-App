import Foundation
import EventKit
import Observation

@MainActor
@Observable
final class CalendarService {
    let eventStore: EKEventStore

    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    /// Asks for write-only access (the minimum needed to create a calendar event).
    /// Returns true if access is granted.
    @discardableResult
    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestWriteOnlyAccessToEvents()
        } catch {
            return false
        }
    }

    /// Build a draft event from a Conference. The caller hands this to
    /// `EKEventEditViewController` so the user picks the calendar and alerts.
    func makeDraftEvent(for conference: Conference) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = conference.name
        event.startDate = conference.startDate
        // Treat conferences as all-day events spanning start..endDate.
        event.endDate = conference.endDate
        event.isAllDay = true
        event.location = conference.isOnline ? "Online" : conference.locationName
        event.notes = [conference.summary, conference.websiteURLString]
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        event.url = conference.websiteURL
        return event
    }
}
