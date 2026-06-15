import SwiftUI

struct AppearanceView: View {
    @AppStorage("settings.colorScheme") private var colorSchemeRaw = AppColorScheme.system.rawValue
    @State private var viewModel = AppIconViewModel()

    var body: some View {
        List {
            colorSchemeSection
            appIconSection
        }
        .scrollContentBackground(.hidden)
        .brandBackground()
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.selected)
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't change the icon", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var colorSchemeSection: some View {
        Section {
            Picker("Color Scheme", selection: $colorSchemeRaw) {
                ForEach(AppColorScheme.allCases) { scheme in
                    Text(scheme.title).tag(scheme.rawValue)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Color Scheme")
        } footer: {
            Text("Choose how the app looks. System follows your device setting.")
        }
    }

    /// The collection's vitrine: a two-column grid of tickets (artwork + date · venue +
    /// lore), all visible by scrolling the screen itself — no horizontal scrolling.
    /// Selecting flips the ticket and punches a haptic (both reduce-motion-gated).
    @ViewBuilder
    private var appIconSection: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16, alignment: .top),
                          GridItem(.flexible(), alignment: .top)],
                spacing: 24
            ) {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    AppIconTicketPage(icon: icon, isSelected: viewModel.selected == icon) {
                        Task { await viewModel.select(icon) }
                    }
                }
            }
            .padding(.vertical, 8)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } header: {
            Text("App Icon")
        } footer: {
            Text("Collectible tickets marking milestones in Apple history. iOS shows a brief alert when the icon changes.")
        }
    }
}

/// One ticket in the wallet: large artwork, title, date · venue, lore. The selected
/// ticket wears a marigold ring + a `checkmark.seal` stamp and spins once when newly
/// chosen (reduce-motion collapses the spin; the stamp still appears).
private struct AppIconTicketPage: View {
    let icon: AppIcon
    let isSelected: Bool
    let onSelect: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spin: Double = 0

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                artwork
                VStack(spacing: 3) {
                    Text(icon.title)
                        .font(.subheadline.weight(.semibold))
                    Text(icon.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(icon.lore)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .snappy, value: isSelected)
        .onChange(of: isSelected) { _, selected in
            guard selected, !reduceMotion else { return }
            withAnimation(.spring(duration: 0.7, bounce: 0.25)) { spin += 360 }
        }
        .accessibilityLabel("\(icon.title), \(icon.subtitle). \(icon.lore)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Sets this as the app icon")
    }

    private var artwork: some View {
        Image(icon.previewAsset)
            .resizable()
            .scaledToFit()
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .strokeBorder(
                        isSelected ? Theme.accent : Color(.separator),
                        lineWidth: isSelected ? 3 : 0.5
                    )
            )
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    // Inset inside the artwork corner — an outward offset clips at the
                    // grid's trailing edge on right-column cards.
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Theme.accent)
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                        .padding(10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .shadow(color: .black.opacity(isSelected ? 0.25 : 0.12),
                    radius: isSelected ? 14 : 8, y: 6)
    }
}

#Preview {
    NavigationStack { AppearanceView() }
}
