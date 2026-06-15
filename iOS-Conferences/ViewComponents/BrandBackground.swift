import SwiftUI

/// The app's marigold "stage-light" background wash (ADR-0007): a restrained accent
/// gradient at the very top fading into the system background. Used behind the list and the
/// stock Settings `Form`s so every scrolling surface shares the same framing without
/// touching the rows themselves. Adapts to light/dark via the asset-backed accent and
/// `Color(.systemBackground)`.
struct BrandBackground: View {
    var body: some View {
        Color(.systemBackground)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Theme.accent.opacity(0.12), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 260)
            }
            .ignoresSafeArea()
    }
}

extension View {
    /// Applies the `BrandBackground` wash. Pair with `.scrollContentBackground(.hidden)` on
    /// the scrolling container (`List` / `Form`) so the wash shows through.
    func brandBackground() -> some View {
        background(BrandBackground())
    }
}
