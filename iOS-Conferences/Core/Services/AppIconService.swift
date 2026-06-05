import UIKit

/// Reads and changes the app's alternate icon. Thin wrapper over `UIApplication`
/// so the picker can be unit-tested against a mock.
@MainActor
protocol AppIconManaging {
    var current: AppIcon { get }
    var supportsAlternateIcons: Bool { get }
    func setIcon(_ icon: AppIcon) async throws
}

@MainActor
final class AppIconService: AppIconManaging {
    var current: AppIcon {
        let name = UIApplication.shared.alternateIconName
        return AppIcon.allCases.first { $0.alternateName == name } ?? .default
    }

    var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    func setIcon(_ icon: AppIcon) async throws {
        guard UIApplication.shared.alternateIconName != icon.alternateName else { return }
        try await UIApplication.shared.setAlternateIconName(icon.alternateName)
    }
}
