import SwiftUI

/// Event-ticket card for a conference in the list. The conference's image (or the
/// `.card`-style `ConferencePlaceholder` mesh, used for almost every entry since no
/// logos are bundled) fills the card under a bottom scrim. A perforation with punched
/// notches (`TicketShape`) divides it into a main body — `kind · location` overline +
/// the name as the hero — and a trailing stub carrying the date as the "admit one" block.
///
/// Hosted in a `.plain` `List` with cleared row backgrounds so the tickets float — see
/// `ConferenceSectionList`.
struct ConferenceCard: View {
    let conference: Conference
    let isFavourite: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let height: CGFloat = 172
    private static let cornerRadius: CGFloat = 22
    private static let notchRadius: CGFloat = 11
    private static let stubWidth: CGFloat = 80

    private var ticket: TicketShape {
        TicketShape(cornerRadius: Self.cornerRadius,
                    notchRadius: Self.notchRadius,
                    stubWidth: Self.stubWidth)
    }

    var body: some View {
        ZStack {
            // Base floors the ZStack's size so an oversized scaledToFill image can't
            // drive layout; it also backs any image with transparency.
            Color.black
            background
            perforation
            HStack(spacing: 0) {
                mainBody
                stub
            }
            favouriteMark
        }
        .animation(reduceMotion ? nil : .snappy, value: isFavourite)
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .clipShape(ticket)
        .overlay(
            ticket.stroke(.white.opacity(0.10), lineWidth: 0.5)
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

    /// Dashed perforation line, drawn between the two notches on the stub seam.
    private var perforation: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VerticalDashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 4]))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 1.5)
                .padding(.vertical, Self.notchRadius + 3)
                .padding(.trailing, Self.stubWidth)
        }
    }

    // MARK: - Main body

    private var mainBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            overline
            Text(conference.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 1)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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

    // MARK: - Stub

    private var stub: some View {
        let date = ConferenceDateStyle.stub(from: conference.startDate, to: conference.endDate)
        return VStack(spacing: 1) {
            Text(date.month)
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.9))
            Text(date.day)
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if let endLine = date.endLine {
                Text(endLine)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
        .padding(.horizontal, 6)
        .frame(maxHeight: .infinity)
        .frame(width: Self.stubWidth)
    }

    @ViewBuilder
    private var favouriteMark: some View {
        if isFavourite {
            Image(systemName: "heart.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 4, y: 1)
                .padding(14)
                // Sit in the body, just left of the perforation.
                .padding(.trailing, Self.stubWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Text

    private var locationText: String {
        conference.isOnline ? "ONLINE" : conference.locationShort.uppercased()
    }

    /// Overline reads `TIME · LOCATION` for timed events, just `LOCATION` for conferences.
    /// Online timed events also show the zone abbreviation, since they have no location to
    /// imply it (e.g. `19:00 PDT · ONLINE`).
    private var overlineText: String {
        guard let time = conference.startTimeLabel else { return locationText }
        var timePart = time
        if conference.isOnline, let abbreviation = conference.timeZoneAbbreviation {
            timePart += " \(abbreviation)"
        }
        return "\(timePart.uppercased()) · \(locationText)"
    }

    private var accessibilityLabel: String {
        let dateRange = ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate)
        let location = conference.isOnline ? "Online" : conference.locationShort
        var parts = [conference.name, dateRange]
        if let time = conference.startTimeLabel { parts.append(time) }
        parts.append(location)
        if isFavourite { parts.append("Favourite") }
        return parts.joined(separator: ", ")
    }
}

/// A vertical line filling its bounds — stroked with a dash for the ticket perforation.
private struct VerticalDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

#Preview("Tickets") {
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
