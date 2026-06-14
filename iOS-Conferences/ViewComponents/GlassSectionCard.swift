import SwiftUI

/// A floating content card on Liquid Glass — the custom replacement for a stock grouped
/// `Form` section on identity surfaces (ADR-0007). An optional uppercase eyebrow title sits
/// above arbitrary content, and the whole card is backed by `.glassEffect`, so dark mode,
/// vibrancy, and the accessibility transparency/contrast settings are handled by the system
/// rather than by us. Sits inside a `GlassEffectContainer` so adjacent cards blend correctly.
struct GlassSectionCard<Content: View>: View {
    private let title: String?
    private let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .eyebrow(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .glassEffect(in: .rect(cornerRadius: 24))
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.indigo, .black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 16) {
                GlassSectionCard(title: "About") {
                    Text("Long-running, community-driven UK iOS conference combining workshops, talks and shared accommodation in coastal Wales.")
                }
                GlassSectionCard(title: "When & Where") {
                    Text("Sep 7–10, 2026 · Aberystwyth, UK")
                }
            }
            .padding()
        }
    }
}
