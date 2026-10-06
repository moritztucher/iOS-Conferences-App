import ActivityKit
import ConferenceKit
import SwiftUI
import WidgetKit

/// The conference-day Live Activity (ADR-0009). Every presentation reads the same
/// `LiveAgendaDisplay`, so the Lock Screen and the Dynamic Island always agree, including
/// when the state has gone stale and the next talk has been promoted.
struct ConferenceDayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConferenceDayAttributes.self) { context in
            ConferenceDayLockScreenView(
                attributes: context.attributes,
                display: LiveAgendaDisplay(state: context.state, isStale: context.isStale),
                asOf: context.state.asOf
            )
            .activitySystemActionForegroundColor(Color.marigold)
        } dynamicIsland: { context in
            let display = LiveAgendaDisplay(state: context.state, isStale: context.isStale)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PhaseSymbol(phase: display.phase)
                        .font(.title2)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Countdown(display: display, asOf: context.state.asOf)
                        .font(.title3.weight(.semibold))
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(display.headline?.title ?? wrapLine(context.attributes))
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 2) {
                        if let room = display.headline?.roomName {
                            Text(room)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let upcoming = display.upcoming {
                            NextLine(item: upcoming, timeZone: context.attributes.timeZone)
                                .minimumScaleFactor(0.85)
                        }
                    }
                    .lineLimit(1)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(LiveAgendaSpeech.summary(display: display, attributes: context.attributes))
                }
            } compactLeading: {
                PhaseSymbol(phase: display.phase)
            } compactTrailing: {
                Countdown(display: display, asOf: context.state.asOf)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: 52)
            } minimal: {
                PhaseSymbol(phase: display.phase)
            }
            .keylineTint(Color.marigold)
        }
    }

    private func wrapLine(_ attributes: ConferenceDayAttributes) -> String {
        "That's a wrap for Day \(attributes.dayNumber)"
    }
}

// MARK: - Previews

private extension ConferenceDayAttributes {
    static let preview = ConferenceDayAttributes(
        conferenceID: "swiftleeds-2026", conferenceName: "SwiftLeeds", dayNumber: 1,
        dayStart: .now, timeZoneIdentifier: "Europe/London"
    )
}

private extension ConferenceDayAttributes.ContentState {
    static var talk: Self {
        let now = Date.now
        return Self(
            current: AgendaItem(id: "1", title: "Bringing back the love of Swift", roomName: "The Playhouse",
                                startsAt: now.addingTimeInterval(-600), endsAt: now.addingTimeInterval(1_800)),
            next: AgendaItem(id: "2", title: "Unleash the power of Swift Charts", roomName: "The Playhouse",
                             startsAt: now.addingTimeInterval(2_700), endsAt: now.addingTimeInterval(5_400)),
            after: nil,
            asOf: now
        )
    }

    static var coffee: Self {
        let now = Date.now
        return Self(
            current: nil,
            next: AgendaItem(id: "2", title: "Unleash the power of Swift Charts", roomName: "The Playhouse",
                             startsAt: now.addingTimeInterval(720), endsAt: now.addingTimeInterval(3_420)),
            after: AgendaItem(id: "3", title: "CarPlay from Zero", roomName: "The Playhouse",
                              startsAt: now.addingTimeInterval(3_600), endsAt: now.addingTimeInterval(5_400)),
            asOf: now
        )
    }
}

#Preview("Lock Screen", as: .content, using: ConferenceDayAttributes.preview) {
    ConferenceDayLiveActivity()
} contentStates: {
    ConferenceDayAttributes.ContentState.talk
    ConferenceDayAttributes.ContentState.coffee
}

#Preview("Island expanded", as: .dynamicIsland(.expanded), using: ConferenceDayAttributes.preview) {
    ConferenceDayLiveActivity()
} contentStates: {
    ConferenceDayAttributes.ContentState.talk
}

#Preview("Island compact", as: .dynamicIsland(.compact), using: ConferenceDayAttributes.preview) {
    ConferenceDayLiveActivity()
} contentStates: {
    ConferenceDayAttributes.ContentState.coffee
}
