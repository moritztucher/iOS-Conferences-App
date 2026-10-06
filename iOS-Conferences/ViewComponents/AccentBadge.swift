import SwiftUI

/// Small solid-marigold capsule with a heavy, tracked label: the "GOING" stamp on an
/// attended ticket and the "NOW" marker on the schedule. One treatment for every
/// "this is live / this is yours" state, in the brand accent (ADR-0006).
struct AccentBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.weight(.heavy))
            .tracking(Theme.eyebrowTracking)
            .lineLimit(1)
            .foregroundStyle(Theme.onAccent)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Theme.accent, in: .capsule)
    }
}

#Preview {
    HStack {
        AccentBadge(title: "NOW")
        AccentBadge(title: "GOING")
    }
    .padding()
}
