import SwiftUI

/// Brand theme layer (ADR-0006). Two signature levers sit on top of the otherwise
/// system palette + fonts — the only deliberate departures from "system tint, system
/// fonts" (see ADR-0004):
///
/// - **Accent** — a warm marigold replacing the system blue tint. It lives in the
///   `AccentColor` asset (so it flows into every *default* control tint automatically)
///   and is mirrored here as `Theme.accent` for the handful of views that need the
///   colour directly (custom strokes, the favourite heart) rather than via the
///   environment tint.
/// - **Serif display** — Apple's system serif (New York), reserved for editorial
///   *display* moments only: conference names and month mastheads. Body, controls, and
///   secondary labels stay SF. Because it's the *system* serif, it keeps full Dynamic
///   Type scaling and optical sizing for free — no bundled font, no licensing, no
///   accessibility regressions.
enum Theme {
    /// Signature accent — mirrors the `AccentColor` asset so non-tint uses match the
    /// app-wide tint exactly (single source of truth is the asset).
    static let accent = Color.accentColor

    // MARK: - Type roles

    /// **Display** — the serif voice (New York) at a semantic text style, so it scales with
    /// Dynamic Type. Use for display moments only — conference names, month mastheads —
    /// never body or UI labels.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .serif).weight(weight)
    }

    /// Tracking for the **eyebrow** role — applied via `.eyebrow()`. One value app-wide so
    /// every overline reads as the same role.
    static let eyebrowTracking: CGFloat = 0.8

    /// **Ticket numerals** — the big day number on a card's date stub. Rounded + heavy as a
    /// deliberate "admission ticket" numeral, intentionally distinct from the serif display
    /// and the SF body. The only place `design: .rounded` is used.
    static func ticketNumerals(_ style: Font.TextStyle) -> Font {
        .system(style, design: .rounded).weight(.heavy)
    }
}

extension View {
    /// **Eyebrow** — the small uppercase, tracked SF label that sits above a display title:
    /// the `kind · location` overlines, the stub month, the kind sub-dividers. Bundles font
    /// + tracking + uppercasing so every eyebrow matches; foreground colour is left to the
    /// caller (white over imagery, secondary in lists).
    func eyebrow(_ style: Font.TextStyle = .caption, weight: Font.Weight = .bold) -> some View {
        self
            .font(.system(style).weight(weight))
            .tracking(Theme.eyebrowTracking)
            .textCase(.uppercase)
    }
}
