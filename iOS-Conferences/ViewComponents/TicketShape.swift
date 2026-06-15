import SwiftUI

/// An event-ticket outline: a rounded rectangle with two semicircular notches punched
/// into the top and bottom edges at a vertical perforation line, dividing the card into
/// a main body and a trailing stub. Used to clip `ConferenceCard` so the notches are
/// truly cut out and the list background shows through.
///
/// A single continuous, non-self-intersecting outline so it clips correctly with the
/// default winding rule (no even-odd subtraction needed).
struct TicketShape: Shape {
    var cornerRadius: CGFloat = 22
    var notchRadius: CGFloat = 11
    /// Distance from the trailing edge to the perforation line — i.e. the stub width.
    var stubWidth: CGFloat = 78

    /// The perforation's x position for a given card width, so the host can align the
    /// dashed line and stub content to the same line the notches sit on.
    func perforationX(for width: CGFloat) -> CGFloat { width - stubWidth }

    func path(in rect: CGRect) -> Path {
        let r = min(cornerRadius, min(rect.width, rect.height) / 2)
        let nr = notchRadius
        let px = rect.maxX - stubWidth

        var p = Path()
        // Top edge: left corner → top notch → right corner.
        p.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        p.addLine(to: CGPoint(x: px - nr, y: rect.minY))
        p.addArc(center: CGPoint(x: px, y: rect.minY), radius: nr,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r), radius: r,
                 startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        // Right edge → bottom-right corner.
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r), radius: r,
                 startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        // Bottom edge: right corner → bottom notch → left corner.
        p.addLine(to: CGPoint(x: px + nr, y: rect.maxY))
        p.addArc(center: CGPoint(x: px, y: rect.maxY), radius: nr,
                 startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r), radius: r,
                 startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        // Left edge → top-left corner.
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r), radius: r,
                 startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}

#Preview {
    TicketShape()
        .fill(.blue.gradient)
        .frame(height: 172)
        .padding()
}
