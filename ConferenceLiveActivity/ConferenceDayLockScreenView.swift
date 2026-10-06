import ConferenceKit
import SwiftUI

/// Lock Screen (and StandBy / banner) presentation of the conference-day Live Activity.
struct ConferenceDayLockScreenView: View {
    let attributes: ConferenceDayAttributes
    let display: LiveAgendaDisplay
    let asOf: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(attributes.conferenceName) · Day \(attributes.dayNumber)")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                PhaseSymbol(phase: display.phase)
                    .font(.caption)
            }

            if let headline = display.headline {
                // Title: the running talk, or the next one during a break.
                Text(headline.title)
                    .font(.headline)
                    .lineLimit(2)
                // Below: where, and how long until it ends / starts.
                whereAndWhen(headline)
                    .font(.subheadline)
                    .lineLimit(1)
                // If there's room: what comes after.
                if let upcoming = display.upcoming {
                    NextLine(item: upcoming, timeZone: attributes.timeZone)
                }
            } else {
                Text("That's a wrap for Day \(attributes.dayNumber)")
                    .font(.headline)
            }
        }
        .padding(16)
    }

    /// "swiftCon 1 · ends in 23:10" as one text run, so the timer sits inline.
    private func whereAndWhen(_ headline: AgendaItem) -> Text {
        let lead = [headline.roomName, display.phase == .inSession ? "ends in" : "starts in"]
            .compactMap(\.self)
            .joined(separator: " · ")
        guard let countdown = Countdown.text(display: display, asOf: asOf) else {
            return Text(lead)
        }
        return Text("\(lead) \(countdown.foregroundStyle(Color.marigold).monospacedDigit())")
    }

}
