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

        if let startMinutes = conference.startTimeMinutes {
            // Timed event (Watch Party / Event): a same-day event at its wall-clock time.
            // Falls back to a 2-hour duration when no end time is provided.
            let calendar = Calendar.current
            let day = calendar.startOfDay(for: conference.startDate)
            let start = calendar.date(byAdding: .minute, value: startMinutes, to: day) ?? conference.startDate
            let end: Date
            if let endMinutes = conference.endTimeMinutes, endMinutes > startMinutes {
                end = calendar.date(byAdding: .minute, value: endMinutes, to: day) ?? start
            } else {
                end = calendar.date(byAdding: .hour, value: 2, to: start) ?? start
            }
            event.startDate = start
            event.endDate = end
            event.isAllDay = false
        } else {
            // Multi-day conference: all-day event spanning start..endDate.
            event.startDate = conference.startDate
            event.endDate = conference.endDate
            event.isAllDay = true
        }

        event.location = conference.isOnline ? "Online" : conference.locationName
        event.notes = [conference.summary, conference.websiteURLString]
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        event.url = conference.websiteURL
        return event
    }
}
