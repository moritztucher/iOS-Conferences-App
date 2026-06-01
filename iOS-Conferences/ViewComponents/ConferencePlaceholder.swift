import SwiftUI

/// Typographic fallback shown when a conference has no `logoURL` (or `AsyncImage` fails).
/// Initials + a hash-derived colour from the conference id so each one is visually distinct
/// and stable across launches.
struct ConferencePlaceholder: View {
    let conference: Conference

    var body: some View {
        GeometryReader { proxy in
            let base = Self.color(for: conference.id)
            ZStack {
                Self.gradient(for: conference.id)
                Text(Self.initials(for: conference.name))
                    .font(.system(size: proxy.size.height * 0.42, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.foreground(on: base))
                    .minimumScaleFactor(0.5)
                    .padding(proxy.size.height * 0.1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(conference.name)
    }

    static func initials(for name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let words = trimmed.split(separator: " ").filter { $0.first?.isLetter == true }
        if words.count >= 2 {
            let first = words[0].first.map { String($0) } ?? ""
            let second = words[1].first.map { String($0) } ?? ""
            return first + second
        } else if let only = words.first {
            return String(only.prefix(2))
        }
        return "?"
    }

    /// Hash-derived base RGB for a conference id, stable across launches.
    private static func rgb(for id: String) -> (r: Double, g: Double, b: Double) {
        let palette: [(Double, Double, Double)] = [
            (0.00, 0.48, 1.00),
            (0.88, 0.24, 0.18),
            (1.00, 0.44, 0.00),
            (0.18, 0.56, 0.25),
            (0.40, 0.18, 0.57),
            (0.80, 0.14, 0.34),
            (0.00, 0.61, 0.59),
            (0.51, 0.32, 0.13),
            (0.45, 0.45, 0.50)
        ]
        var hash: UInt64 = 5381
        for byte in id.utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return palette[Int(hash % UInt64(palette.count))]
    }

    static func color(for id: String) -> Color {
        let c = rgb(for: id)
        return Color(red: c.r, green: c.g, blue: c.b)
    }

    /// Subtle top-lighter → base gradient from the same hash colour. Adds depth to the
    /// large detail hero while staying imperceptible (and consistent) on small list tiles.
    static func gradient(for id: String) -> LinearGradient {
        let c = rgb(for: id)
        let lighten = 0.18
        let top = Color(
            red: c.r + (1 - c.r) * lighten,
            green: c.g + (1 - c.g) * lighten,
            blue: c.b + (1 - c.b) * lighten
        )
        return LinearGradient(
            colors: [top, Color(red: c.r, green: c.g, blue: c.b)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Picks black or white initials for the best contrast against `background`,
    /// based on the colour's relative luminance.
    static func foreground(on background: Color) -> Color {
        let resolved = background.resolve(in: EnvironmentValues())
        let r = Double(resolved.red)
        let g = Double(resolved.green)
        let b = Double(resolved.blue)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6 ? .black : .white
    }
}

#Preview {
    VStack(spacing: 12) {
        ConferencePlaceholder(conference: .sample)
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        ConferencePlaceholder(conference: Conference.bundled[0])
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        ConferencePlaceholder(conference: Conference.bundled.last!)
            .frame(height: 220)
    }
    .padding()
}
