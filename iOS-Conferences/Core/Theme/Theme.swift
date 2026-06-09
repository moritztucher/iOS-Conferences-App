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

    // MARK: - Serif display

    /// System serif (New York) at a semantic text style, so it scales with Dynamic Type.
    /// Use for display moments only — conference names, month mastheads — never body or
    /// UI labels.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .serif).weight(weight)
    }
}
