import SwiftUI

/// The full-takeover moment when a collectible ticket is earned: the artwork reveals with a
/// shine, its lore, and two ways out — wear it now, or keep collecting. Presented app-wide
/// from `RootTabView` whenever `AchievementService` queues an unlock.
///
/// Reveal motion and shine are reduce-motion-gated; the success haptic fires once on appear.
/// Dynamic Type is honoured by scrolling the content, and the artwork carries the same serif
/// display + marigold accent levers as the rest of the wallet.
struct IconUnlockCelebrationView: View {
    let icon: AppIcon

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var iconViewModel = AppIconViewModel()
    @State private var revealed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                ticket
                lore
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .brandBackground()
        .safeAreaInset(edge: .bottom) { actions }
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.success, trigger: revealed) { _, didReveal in didReveal }
        .task {
            // Defer one tick so the spring plays *into* the presented sheet, not under it.
            withAnimation(reduceMotion ? nil : .spring(duration: 0.7, bounce: 0.45)) {
                revealed = true
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Label("Ticket Unlocked", systemImage: "sparkles")
                .labelStyle(.titleAndIcon)
                .eyebrow(.footnote)
                .foregroundStyle(Theme.accent)
            Text(icon.title)
                .font(Theme.serif(.largeTitle, weight: .bold))
                .multilineTextAlignment(.center)
            Text(icon.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ticket unlocked. \(icon.title), \(icon.subtitle).")
    }

    // MARK: - Ticket

    private var ticket: some View {
        Image(icon.previewAsset)
            .resizable()
            .scaledToFit()
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 280)
            .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
            .overlay(shine)
            .overlay(
                RoundedRectangle(cornerRadius: 44, style: .continuous)
                    .strokeBorder(Theme.accent, lineWidth: 3)
            )
            .background(glow)
            .shadow(color: .black.opacity(0.3), radius: 22, y: 10)
            .scaleEffect(revealed || reduceMotion ? 1 : 0.7)
            .opacity(revealed || reduceMotion ? 1 : 0)
            .rotation3DEffect(
                .degrees(revealed || reduceMotion ? 0 : -22),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.6
            )
            .accessibilityHidden(true)
    }

    /// A diagonal highlight that sweeps once across the ticket as it lands (static when
    /// reduce-motion is on — the gradient simply sits off-screen).
    private var shine: some View {
        GeometryReader { geo in
            let span = geo.size.width
            LinearGradient(
                colors: [.clear, .white.opacity(0.55), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: span * 0.4)
            .rotationEffect(.degrees(20))
            .offset(x: revealed && !reduceMotion ? span * 1.2 : -span)
            .animation(reduceMotion ? nil : .easeIn(duration: 0.8).delay(0.25), value: revealed)
            .blendMode(.screen)
        }
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
    }

    private var glow: some View {
        RoundedRectangle(cornerRadius: 44, style: .continuous)
            .fill(Theme.accent)
            .blur(radius: 44)
            .opacity(revealed || reduceMotion ? 0.45 : 0)
            .scaleEffect(1.05)
    }

    private var lore: some View {
        Text(icon.lore)
            .font(.callout)
            .italic()
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .accessibilityLabel(icon.lore)
    }

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    await iconViewModel.select(icon)
                    dismiss()
                }
            } label: {
                Label("Use this icon", systemImage: "checkmark.seal.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 26)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .disabled(!iconViewModel.isSupported)

            Button("Keep collecting") { dismiss() }
                .font(.subheadline.weight(.medium))
                .padding(.vertical, 4)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            IconUnlockCelebrationView(icon: .iPod)
        }
}
