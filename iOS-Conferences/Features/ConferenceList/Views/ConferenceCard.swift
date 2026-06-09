import SwiftUI

/// Full-bleed image card for a conference in the list. The conference's image
/// (or the hash-derived `ConferencePlaceholder` mesh, used for almost every entry
/// since no logos are bundled) fills the card; a bottom scrim keeps the overlaid
/// text legible against any image. The name is the hero, sat under an editorial
/// uppercase date · location overline.
///
/// Replaces the old stock `ConferenceRow` cell as part of the premium card redesign.
/// Designed to be hosted in a `.plain` `List` with cleared row backgrounds so the
/// cards float — see `ConferenceSectionList`.
struct ConferenceCard: View {
    let conference: Conference
    let isFavourite: Bool

    private static let height: CGFloat = 172
    private static let cornerRadius: CGFloat = 22

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Base floors the ZStack's size so an oversized scaledToFill image can't
            // drive layout; it also backs any image with transparency.
            Color.black
            background
            favouriteMark
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay(
            // Hairline keeps the card defined against light images / light mode.
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isFavourite ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Background

    private var background: some View {
        // Color.clear defines the card-sized container; the image is overlaid *into* it
        // and clipped, so a scaledToFill image can never drive layout — regardless of the
        // source aspect ratio (a square apple-touch-icon vs a landscape og:image). The
        // scrim then rides on top of the clipped image so text always reads.
        Color.clear
            .overlay {
                AsyncImage(url: conference.logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
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

    /// Bottom-weighted darkening so the overline + name read on *any* image — including
    /// light og:images like the WWDC logo card — plus a faint top darken to keep the
    /// favourite mark legible.
    private var scrim: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.30), location: 0.0),
                .init(color: .clear, location: 0.28),
                .init(color: .black.opacity(0.45), location: 0.52),
                .init(color: .black.opacity(0.92), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Overlaid content

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            overline
            Text(conference.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 1)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var overline: some View {
        HStack(spacing: 6) {
            Image(systemName: conference.kind.symbolName)
                .imageScale(.small)
            Text(overlineText)
                .lineLimit(1)
        }
        .font(.caption.weight(.bold))
        .tracking(0.8)
        .foregroundStyle(.white.opacity(0.95))
        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
    }

    @ViewBuilder
    private var favouriteMark: some View {
        if isFavourite {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 4, y: 1)
                }
                Spacer()
            }
            .padding(16)
        }
    }

    // MARK: - Text

    private var dateRange: String {
        ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate)
    }

    private var locationText: String {
        conference.isOnline ? "Online" : conference.locationShort
    }

    private var overlineText: String {
        "\(dateRange) · \(locationText)".uppercased()
    }

    private var accessibilityLabel: String {
        var parts = [conference.name, dateRange, locationText]
        if isFavourite { parts.append("Favourite") }
        return parts.joined(separator: ", ")
    }
}

#Preview("Cards") {
    ScrollView {
        VStack(spacing: 12) {
            ConferenceCard(conference: .sample, isFavourite: true)
            ConferenceCard(conference: Conference.bundled[0], isFavourite: false)
            ConferenceCard(conference: Conference.bundled.last!, isFavourite: false)
        }
        .padding(16)
    }
    .preferredColorScheme(.dark)
}
