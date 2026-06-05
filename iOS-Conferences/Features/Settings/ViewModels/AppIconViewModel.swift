import SwiftUI

@MainActor
@Observable
final class AppIconViewModel {
    private let service: AppIconManaging
    private(set) var selected: AppIcon
    var errorMessage: String?

    var isSupported: Bool { service.supportsAlternateIcons }

    init(service: AppIconManaging? = nil) {
        let service = service ?? AppIconService()
        self.service = service
        self.selected = service.current
    }

    func select(_ icon: AppIcon) async {
        guard icon != selected else { return }
        do {
            try await service.setIcon(icon)
            selected = icon
        } catch {
            errorMessage = error.localizedDescription
            selected = service.current
        }
    }
}
