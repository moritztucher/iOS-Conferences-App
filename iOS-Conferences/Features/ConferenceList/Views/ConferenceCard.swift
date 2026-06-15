import SwiftUI

/// Event-ticket card for a conference in the list. The `.card`-style
/// `ConferencePlaceholder` mesh is the card's *only* background — real artwork is
/// unpredictable (washed photos, baked-in typography) and fought the overlay text, so it
/// appears as a small top-leading `logoBadge` instead. A perforation with punched
/// notches (`TicketShape`) divides the card into a main body — `kind · location` overline +
/// the name as the hero — and a trailing stub carrying the date as the "admit one" block.
///
/// Hosted in a `.plain` `List` with cleared row backgrounds so the tickets float — see
/// `ConferenceSectionList`.
struct ConferenceCard: View {
    let conference: Conference
    let isFavourite: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    /// Floor height at default type sizes. The card grows beyond this when the name +
    /// overline need more room (large Dynamic Type), so text never clips — an ADR-0007
    /// hard criterion. The image fills whatever height results.
    private static let minHeight: CGFloat = 172
    private static let cornerRadius: CGFloat = 22
    private static let notchRadius: CGFloat = 11
    private static let stubWidth: CGFloat = 80

    // Aliveness levers (see `meshBackground` + `scrim`). Live = upcoming/ongoing; past =
    // ended. Live tickets are *strongly saturated* — a rich jewel, not a washed pastel
    // (saturation is what reads "alive"; excess lightness is what read as muted). The
    // brightness lift is mode-aware: against the dark wash the deep tones need a real lift
    // to glow, but on the light cream the same lift turns them pastel and costs the white
    // text its contrast — there the near-base depth is what pops. Past tickets sit at
    // their deep base and desaturate, so they read "done" without going pitch-dark.
    // Tuned against full-opacity rendering (the old values compensated for a scroll-
    // transition bug that drew every card at 0.5 alpha — see ConferenceSectionList).
    private static let liveMeshLightenDark: Double = 1.2
    private static let liveMeshLightenLight: Double = 1.0   // true jewel base — depth is the pop on cream
    private static let liveMeshSaturation: Double = 1.2
    private static let pastMeshLighten: Double = 1.0
    private static let pastMeshSaturation: Double = 0.70

    private var liveMeshLighten: Double {
        colorScheme == .dark ? Self.liveMeshLightenDark : Self.liveMeshLightenLight
    }

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
        .background { meshBackground }
        .overlay { perforation }
        .overlay { logoBadge }
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

    /// The mesh is the card's only background — a controlled canvas, so the jewel tones
    /// stay saturated and the scrim stays a thin anchor: vibrancy and legibility no longer
    /// compete (the old full-bleed artwork needed a heavy veil that read as "past").
    private var meshBackground: some View {
        ConferencePlaceholder(
            conference: conference,
            style: .card,
            lighten: conference.isPast ? Self.pastMeshLighten : liveMeshLighten
        )
        .saturation(conference.isPast ? Self.pastMeshSaturation : Self.liveMeshSaturation)
        .overlay(scrim)
    }

    /// Past tickets only: the full-card darkening that makes ended tickets recede (the
    /// aliveness split, ADR-0007). Live tickets get *no* scrim at all — the mesh is a
    /// controlled canvas and the text carries its own shadows, so any veil just reads as
    /// gray and drags a live card toward "past".
    @ViewBuilder
    private var scrim: some View {
        if conference.isPast {
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.16), location: 0.0),
                    .init(color: .clear, location: 0.32),
                    .init(color: .black.opacity(0.20), location: 0.56),
                    .init(color: .black.opacity(0.84), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    /// The conference's real artwork, demoted from card background to a small brand badge
    /// in the top-leading corner — the only quiet corner (heart top-trailing, text bottom,
    /// watermark bottom-trailing). Shown only once it loads; the mesh card is complete
    /// without it. Past tickets mute the badge along with everything else.
    @ViewBuilder
    private var logoBadge: some View {
        if let url = conference.logoURL {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        .saturation(conference.isPast ? 0.6 : 1)
                        .opacity(conference.isPast ? 0.75 : 1)
                        .transition(.opacity)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityHidden(true)
        }
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
