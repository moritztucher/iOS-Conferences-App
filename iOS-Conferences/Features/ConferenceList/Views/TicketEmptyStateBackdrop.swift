import SwiftUI

/// Branded backdrop for the list/search empty states (EMO-1): keeps the marigold
/// stage-light wash and sketches ghost ticket outlines in the mesh-palette jewel tones,
/// so an empty screen still reads as dubdub — the *shape* of what will appear here —
/// instead of a generic void. The `ContentUnavailableView` stays stock on top.
struct TicketEmptyStateBackdrop: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ghosts
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .brandBackground()
    }

    private var ghosts: some View {
        ZStack {
            ghost(tone: ConferencePlaceholder.paletteTone(1), rotation: -7, x: -48, y: -170, width: 235)
            ghost(tone: ConferencePlaceholder.paletteTone(0), rotation: 5, x: 56, y: 170, width: 215)
            ghost(tone: ConferencePlaceholder.paletteTone(2), rotation: -3, x: 84, y: -40, width: 180)
        }
        .accessibilityHidden(true)
    }

    /// One phantom ticket: a faint tonal fill plus a slightly stronger outline, so the
    /// `TicketShape` silhouette reads in both modes without competing with the message.
    private func ghost(tone: Color, rotation: Double, x: CGFloat, y: CGFloat, width: CGFloat) -> some View {
        let shape = TicketShape(cornerRadius: 16, notchRadius: 8, stubWidth: width * 0.27)
        return shape
            .fill(tone.opacity(0.14))
            .overlay(shape.stroke(tone.opacity(0.45), lineWidth: 1.5))
            .frame(width: width, height: width * 0.52)
            .rotationEffect(.degrees(rotation))
            .offset(x: x, y: y)
    }
}

extension View {
    /// Applies the branded empty-state backdrop (marigold wash + ghost tickets). Use on
    /// the `ContentUnavailableView`s of the conference list and search tabs.
    func ticketEmptyStateBackdrop() -> some View {
        modifier(TicketEmptyStateBackdrop())
    }
}

#Preview("Dark") {
    ContentUnavailableView(
        "No Favourites",
        systemImage: "heart",
        description: Text("Heart any conference to hold your spot.")
    )
    .ticketEmptyStateBackdrop()
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    ContentUnavailableView(
        "Search Conferences",
        systemImage: "magnifyingglass",
        description: Text("Find a conference by name, location, or tag.")
    )
    .ticketEmptyStateBackdrop()
    .preferredColorScheme(.light)
}
