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
    ///
    /// `timeZone` (the geocoded venue's zone) anchors a timed event to its *local* time, so
    /// e.g. a Tokyo 19:00 party is saved as 19:00 Tokyo regardless of the viewer's zone.
    /// The conference's own `timeZone` (from the feed) wins when set — important for online
    /// events that can't be geocoded. Falls back to the current zone when neither is known.
    func makeDraftEvent(for conference: Conference, timeZone: TimeZone? = nil) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = conference.name

        if let startMinutes = conference.startTimeMinutes {
            // Timed event (Watch Party / Event): a same-day event at its wall-clock time in
            // the event's zone. Falls back to a 2-hour duration when no end time is provided.
            let zone = conference.timeZone ?? timeZone ?? .current
            let start = date(forDayOf: conference.startDate, minutes: startMinutes, in: zone)
            let end: Date
            if let endMinutes = conference.endTimeMinutes, endMinutes > startMinutes {
                end = date(forDayOf: conference.startDate, minutes: endMinutes, in: zone)
            } else {
                end = start.addingTimeInterval(2 * 3600)
            }
            event.timeZone = zone
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

    /// Combines the calendar day of `dayDate` (the day shown on the card, read in the
    /// current calendar) with `minutes` from midnight interpreted in `zone`, yielding the
    /// correct absolute instant for a timed event in that time zone.
    private func date(forDayOf dayDate: Date, minutes: Int, in zone: TimeZone) -> Date {
        let ymd = Calendar.current.dateComponents([.year, .month, .day], from: dayDate)
        var target = Calendar(identifier: .gregorian)
        target.timeZone = zone
        var comps = DateComponents()
        comps.year = ymd.year
        comps.month = ymd.month
        comps.day = ymd.day
        comps.hour = minutes / 60
        comps.minute = minutes % 60
        return target.date(from: comps) ?? dayDate
    }
}
