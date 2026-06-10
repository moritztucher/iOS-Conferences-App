import SwiftUI

/// Full-bleed, stretchy parallax hero for the conference detail screen. The image (or
/// the `.card`-style `ConferencePlaceholder` mesh) fills the header and grows on pull-down
/// overscroll. The conference name + date are overlaid under a scrim, so the header *is*
/// the title block. The bottom edge is clean: under ADR-0007 the details below float as
/// separate Liquid Glass cards, so the old ticket "tear" no longer connects to anything.
struct ConferenceDetailHero: View {
    let conference: Conference

    @Environment(\.colorScheme) private var colorScheme

    static let baseHeight: CGFloat = 300

    // Aliveness — mirrors `ConferenceCard` so the zoomed hero matches the ticket the user
    // tapped: live heroes are saturated + lifted (and breathe), past heroes desaturate
    // under a heavier veil (and hold still — they're done).
    private static let liveMeshLightenDark: Double = 1.2
    private static let liveMeshLightenLight: Double = 1.0
    private static let liveMeshSaturation: Double = 1.2
    private static let pastMeshSaturation: Double = 0.70
    private static let liveImageSaturation: Double = 1.05
    private static let pastImageSaturation: Double = 0.70

    private var meshLighten: Double {
        guard !conference.isPast else { return 1.0 }
        return colorScheme == .dark ? Self.liveMeshLightenDark : Self.liveMeshLightenLight
    }

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            let stretch = max(0, minY)
            ZStack(alignment: .bottomLeading) {
                background
                titleOverlay
                    // Dissolve the title block as the hero scrolls away (starting 80pt up,
                    // gone by 200pt) so the name never slides un-staged beneath the toolbar
                    // buttons — the nav-bar title takes over right after (reveals at 220pt).
                    .opacity(1 - min(max((-minY - 80) / 120, 0), 1))
            }
            .frame(width: geo.size.width, height: Self.baseHeight + stretch)
            .clipShape(Rectangle())
            .offset(y: -stretch)
        }
        .frame(height: Self.baseHeight)
    }

    // MARK: - Background

    private var background: some View {
        Color.clear
            .overlay {
                AsyncImage(url: conference.logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .unifiedConferenceArtwork()
                            .saturation(conference.isPast ? Self.pastImageSaturation : Self.liveImageSaturation)
                            .overlay(artworkScrim)
                    case .empty, .failure:
                        meshBackground
                    @unknown default:
                        meshBackground
                    }
                }
            }
            .clipped()
    }

    /// Mirrors the list card exactly: a live mesh hero is the same unveiled, saturated
    /// jewel the user just tapped — only a slim top anchor keeps the status bar readable
    /// (the title carries its own shadows, as on the card). Past heroes take the same
    /// muting veil as past tickets. Live heroes breathe; past ones hold still.
    private var meshBackground: some View {
        ConferencePlaceholder(
            conference: conference,
            style: .card,
            lighten: meshLighten,
            breathes: !conference.isPast
        )
        .saturation(conference.isPast ? Self.pastMeshSaturation : Self.liveMeshSaturation)
        .overlay(meshScrim)
    }

    private var meshScrim: some View {
        let stops: [Gradient.Stop] = conference.isPast
            ? Self.pastVeilStops
            : [
                .init(color: .black.opacity(0.18), location: 0.0),
                .init(color: .clear, location: 0.25)
            ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    /// Real artwork is unpredictable (washed photos, baked-in typography), so unlike the
    /// mesh it always needs a text-safe scrim under the title block.
    private var artworkScrim: some View {
        let stops: [Gradient.Stop] = conference.isPast
            ? Self.pastVeilStops
            : [
                .init(color: .black.opacity(0.25), location: 0.0),
                .init(color: .clear, location: 0.30),
                .init(color: .black.opacity(0.16), location: 0.60),
                .init(color: .black.opacity(0.62), location: 1.0)
            ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    /// The "already done" veil — same role as the past treatment on `ConferenceCard`.
    private static let pastVeilStops: [Gradient.Stop] = [
        .init(color: .black.opacity(0.35), location: 0.0),
        .init(color: .black.opacity(0.18), location: 0.30),
        .init(color: .black.opacity(0.38), location: 0.55),
        .init(color: .black.opacity(0.85), location: 1.0)
    ]

    // MARK: - Title overlay

    private var titleOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: conference.kind.symbolName)
                    .imageScale(.small)
                Text(locationText)
                    .lineLimit(1)
            }
            .eyebrow()
            .foregroundStyle(.white.opacity(0.95))

            Text(conference.name)
                .font(Theme.serif(.largeTitle, weight: .bold))
                .lineLimit(3)
                .foregroundStyle(.white)

            Text(ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))
        }
        .shadow(color: .black.opacity(0.45), radius: 5, y: 1)
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private var locationText: String {
        conference.isOnline ? "ONLINE" : conference.locationShort.uppercased()
    }
}
