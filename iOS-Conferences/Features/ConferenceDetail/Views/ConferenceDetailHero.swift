import SwiftUI

/// Full-bleed, stretchy parallax hero for the conference detail screen. The image (or
/// the `.card`-style `ConferencePlaceholder` mesh) fills the header and grows on pull-down
/// overscroll. The conference name + date are overlaid under a scrim, so the header *is*
/// the title block. The bottom edge is clean: under ADR-0007 the details below float as
/// separate Liquid Glass cards, so the old ticket "tear" no longer connects to anything.
struct ConferenceDetailHero: View {
    let conference: Conference

    static let baseHeight: CGFloat = 300

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            let stretch = max(0, minY)
            ZStack(alignment: .bottomLeading) {
                background
                titleOverlay
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
                        image.resizable().scaledToFill().unifiedConferenceArtwork()
                    case .empty, .failure:
                        ConferencePlaceholder(conference: conference, style: .card)
                    @unknown default:
                        ConferencePlaceholder(conference: conference, style: .card)
                    }
                }
            }
            .clipped()
            .overlay(scrim)
    }

    private var scrim: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.35), location: 0.0),
                .init(color: .clear, location: 0.30),
                .init(color: .black.opacity(0.35), location: 0.55),
                .init(color: .black.opacity(0.85), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

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
