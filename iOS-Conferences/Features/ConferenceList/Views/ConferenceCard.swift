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

    /// Floor height at default type sizes. The card grows beyond this when the name +
    /// overline need more room (large Dynamic Type), so text never clips — an ADR-0007
    /// hard criterion. The image fills whatever height results.
    private static let minHeight: CGFloat = 172
    private static let cornerRadius: CGFloat = 22
    private static let notchRadius: CGFloat = 11
    private static let stubWidth: CGFloat = 80

    // Aliveness levers (see `artwork` + `scrim`). Live = upcoming/ongoing; past = ended.
    // Live tickets are pushed bright + saturated so they read alive. Past tickets sit at a
    // normal mid brightness but desaturated, so they read "done" without going pitch-dark.
    // The deep mesh placeholders need a much bigger lift than real photos (which already
    // carry their own colour), so the two branches are tuned separately.
    private static let liveMeshLighten: Double = 1.85   // vibrant lift of the deep base tone
    private static let liveMeshSaturation: Double = 1.20
    private static let pastMeshLighten: Double = 1.0
    private static let pastMeshSaturation: Double = 0.70
    private static let liveImageSaturation: Double = 1.22
    private static let liveImageBrightness: Double = 0.07
    private static let pastImageSaturation: Double = 0.82
    private static let pastImageBrightness: Double = 0.02

    private var ticket: TicketShape {
        TicketShape(cornerRadius: Self.cornerRadius,
                    notchRadius: Self.notchRadius,
                    stubWidth: Self.stubWidth)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            mainBody
            stub
        }
        // The content (text) drives the height; `minHeight` floors it at default sizes and
        // it grows for large Dynamic Type. The image rides behind as a `.background` so it
        // fills the resulting bounds instead of driving layout.
        .frame(maxWidth: .infinity, minHeight: Self.minHeight)
        .background { imageBackground }
        .overlay { perforation }
        .overlay { favouriteMark }
        .animation(reduceMotion ? nil : .snappy, value: isFavourite)
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

    private var imageBackground: some View {
        // Color.black floors the size and backs any image with transparency; the image is
        // overlaid *into* it and clipped, so a scaledToFill image can never drive layout —
        // regardless of the source aspect ratio (a square apple-touch-icon vs a landscape
        // og:image). The scrim then rides on top of the clipped image so text always reads.
        Color.black
            .overlay { artwork }
            .clipped()
            .overlay(scrim)
    }

    // Aliveness treatment applied to the artwork *under* the scrim, so text contrast is
    // untouched. The mesh placeholder gets a far bigger lift than a real photo, because the
    // deep jewel tones are what read as "already done"; photos carry their own colour.
    @ViewBuilder
    private var artwork: some View {
        AsyncImage(url: conference.logoURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .unifiedConferenceArtwork()
                    .saturation(conference.isPast ? Self.pastImageSaturation : Self.liveImageSaturation)
                    .brightness(conference.isPast ? Self.pastImageBrightness : Self.liveImageBrightness)
            case .empty, .failure:
                meshPlaceholder
            @unknown default:
                meshPlaceholder
            }
        }
    }

    private var meshPlaceholder: some View {
        // `lighten` brightens the tone vibrantly (hue/saturation preserved); the small
        // saturation nudge on top just sharpens it. Past tones stay near their base and
        // desaturate so they read "done".
        ConferencePlaceholder(
            conference: conference,
            style: .card,
            lighten: conference.isPast ? Self.pastMeshLighten : Self.liveMeshLighten
        )
        .saturation(conference.isPast ? Self.pastMeshSaturation : Self.liveMeshSaturation)
    }

    /// Bottom-weighted darkening so the overline + name read on *any* image — including
    /// light og:images like the WWDC logo card — plus a faint top darken to keep the
    /// favourite mark legible. Live tickets use a lighter mid/upper scrim so the artwork's
    /// colour shows through and the card reads vibrant; past tickets keep the heavier
    /// darkening (and are veiled on top) so they recede. The bottom stays dark in both so
    /// the name + overline always clear the legibility bar (ADR-0007).
    private var scrim: some View {
        let stops: [Gradient.Stop] = conference.isPast
            ? [
                .init(color: .black.opacity(0.16), location: 0.0),
                .init(color: .clear, location: 0.32),
                .init(color: .black.opacity(0.20), location: 0.56),
                .init(color: .black.opacity(0.84), location: 1.0)
            ]
            : [
                .init(color: .black.opacity(0.04), location: 0.0),
                .init(color: .clear, location: 0.42),
                // The lower stops are the legibility floor for artwork with baked-in
                // typography (og:images that are mostly text): strong only in the
                // text-anchor zone, so the body of a live ticket keeps its colour and
                // doesn't read as a veiled "past" card.
                .init(color: .black.opacity(0.22), location: 0.68),
                .init(color: .black.opacity(0.82), location: 1.0)
            ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
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
                .font(Theme.serif(.title2, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 1)
        }
        .padding(18)
        // Width fills; height is natural so the text drives the card's height. Vertical
        // placement (bottom) comes from the enclosing `HStack(alignment: .bottom)`.
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var overline: some View {
        HStack(spacing: 6) {
            Image(systemName: conference.kind.symbolName)
                .imageScale(.small)
            Text(overlineText)
                .lineLimit(1)
        }
        .eyebrow()
        .foregroundStyle(.white.opacity(0.95))
        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
    }

    // MARK: - Stub

    private var stub: some View {
        let date = ConferenceDateStyle.stub(from: conference.startDate, to: conference.endDate)
        return VStack(spacing: 1) {
            Text(date.month)
                .eyebrow()
                .lineLimit(1)
                .foregroundStyle(.white.opacity(0.9))
            Text(date.day)
                .font(Theme.ticketNumerals(.title))
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
        // The stub is a compact, fixed-width "ticket number" badge: clamp its Dynamic Type
        // so the numerals stay legible instead of ballooning/truncating at accessibility
        // sizes. The full date still scales in the detail's When & Where row + VoiceOver.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
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
        conference.isOnline ? "ONLINE" : conference.locationCity.uppercased()
    }

    /// Overline grammar: `[TIME or KIND] · LOCATION` — the lead slot always carries the
    /// card's differentiator. Timed events lead with the wall-clock time; untimed entries
    /// lead with the kind word, so a run of same-city cards doesn't read as one repeated
    /// location column. Online timed events also show the zone abbreviation, since they
    /// have no location to imply it (e.g. `19:00 PDT · ONLINE`).
    private var overlineText: String {
        guard let time = conference.startTimeLabel else {
            return "\(conference.kind.rawValue.uppercased()) · \(locationText)"
        }
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
