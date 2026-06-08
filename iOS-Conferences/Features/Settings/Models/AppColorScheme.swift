import SwiftUI

/// User-facing override for the app's colour scheme. `system` defers to the
/// device setting; `light`/`dark` force a scheme via `preferredColorScheme`.
enum AppColorScheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    /// Value for `.preferredColorScheme` — `nil` follows the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}
