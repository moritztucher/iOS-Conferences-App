import ConferenceKit
import SwiftUI

// Small views shared by the Lock Screen and Dynamic Island presentations.

/// Mic while a talk runs, coffee cup during a break, checkmark when the day is done.
struct PhaseSymbol: View {
    let phase: LiveAgendaDisplay.Phase

    var body: some View {
        Image(systemName: symbolName)
            .foregroundStyle(Color.marigold)
            .accessibilityHidden(true)
    }

    private var symbolName: String {
        switch phase {
        case .inSession: "mic.fill"
        case .upNext: "cup.and.saucer.fill"
        case .finished: "checkmark.circle.fill"
        }
    }
}

/// Ticks on its own (no update budget spent) and stops at zero instead of counting up.
/// A bare timer `Text` claims the full available width, so callers that need it inline
/// use `Countdown.text(...)` inside a single `Text` run instead.
struct Countdown: View {
    let display: LiveAgendaDisplay
    let asOf: Date

    var body: some View {
        if let text = Self.text(display: display, asOf: asOf) {
            text
                .monospacedDigit()
                .foregroundStyle(Color.marigold)
                .multilineTextAlignment(.trailing)
        }
    }

    static func text(display: LiveAgendaDisplay, asOf: Date) -> Text? {
        guard let target = display.countdownTarget, target > asOf else { return nil }
        return Text(timerInterval: asOf...target, countsDown: true, showsHours: false)
    }
}

extension Color {
    /// The brand accent (ADR-0006), from this extension's own `AccentColor` asset: Live
    /// Activity views don't inherit the app's tint.
    static let marigold = Color("AccentColor")
}

/// "Next · SwiftData at Scale · 10:45 · Hall B"
struct NextLine: View {
    let item: AgendaItem
    let timeZone: TimeZone

    var body: some View {
        Text(
            ["Next", item.title, ScheduleTimeFormat.time(item.startsAt, in: timeZone), item.roomName]
                .compactMap(\.self)
                .joined(separator: " · ")
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}
