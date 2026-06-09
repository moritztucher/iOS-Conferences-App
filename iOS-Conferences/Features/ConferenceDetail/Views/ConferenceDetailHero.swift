import SwiftUI

/// Full-bleed, stretchy parallax hero for the conference detail screen. The image (or
/// the `.card`-style `ConferencePlaceholder` mesh) fills the header and grows on pull-down
/// overscroll. The conference name + date are overlaid under a scrim, so the header *is*
/// the title block — echoing the list's ticket cards. A perforated bottom edge (notches +
/// dashed seam) reads as the top half of a ticket torn from the details below.
struct ConferenceDetailHero: View {
    let conference: Conference

    static let baseHeight: CGFloat = 300
    private static let notchRadius: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            let stretch = max(0, minY)
            ZStack(alignment: .bottomLeading) {
                background
                titleOverlay
            }
            .frame(width: geo.size.width, height: Self.baseHeight + stretch)
            .clipShape(HeroTicketEdge(notchRadius: Self.notchRadius))
            .overlay(alignment: .bottom) { perforation(width: geo.size.width) }
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
                        image.resizable().scaledToFill()
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
            .font(.caption.weight(.bold))
            .tracking(0.9)
            .foregroundStyle(.white.opacity(0.95))

            Text(conference.name)
                .font(.largeTitle.weight(.bold))
                .lineLimit(3)
                .foregroundStyle(.white)

            Text(ConferenceDateStyle.range(from: conference.startDate, to: conference.endDate))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))
        }
        .shadow(color: .black.opacity(0.45), radius: 5, y: 1)
        .padding(20)
        .padding(.bottom, Self.notchRadius)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private func perforation(width: CGFloat) -> some View {
        HorizontalDashedLine()
            .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 4]))
            .foregroundStyle(.white.opacity(0.55))
            .frame(height: 1.5)
            .padding(.horizontal, Self.notchRadius + 4)
            .padding(.bottom, Self.notchRadius)
    }

    private var locationText: String {
        conference.isOnline ? "ONLINE" : conference.locationShort.uppercased()
    }
}

/// Rectangle with two semicircle notches punched into the left and right edges near the
/// bottom — the horizontal "tear line" of a ticket. Top corners are square (full-bleed to
/// the screen edges); the perforation sits `notchRadius` up from the bottom.
struct HeroTicketEdge: Shape {
    var notchRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let nr = notchRadius
        let py = rect.maxY - nr   // perforation y

        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Right edge down to the right notch.
        p.addLine(to: CGPoint(x: rect.maxX, y: py - nr))
        p.addArc(center: CGPoint(x: rect.maxX, y: py), radius: nr,
                 startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom edge.
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Left edge up to the left notch.
        p.addLine(to: CGPoint(x: rect.minX, y: py + nr))
        p.addArc(center: CGPoint(x: rect.minX, y: py), radius: nr,
                 startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)
        p.closeSubpath()
        return p
    }
}

/// A horizontal line filling its bounds — stroked with a dash for the ticket perforation.
private struct HorizontalDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}
