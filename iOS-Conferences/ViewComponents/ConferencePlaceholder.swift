import SwiftUI

/// Typographic fallback shown when a conference has no `logoURL` (or `AsyncImage` fails).
/// Initials + a hash-derived colour from the conference id so each one is visually distinct
/// and stable across launches.
struct ConferencePlaceholder: View {
    let conference: Conference

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Self.color(for: conference.id)
                Text(Self.initials(for: conference.name))
                    .font(.system(size: proxy.size.height * 0.42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .padding(proxy.size.height * 0.1)
            }
        }
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

    static func color(for id: String) -> Color {
        let palette: [Color] = [
            Color(red: 0.00, green: 0.48, blue: 1.00),
            Color(red: 0.88, green: 0.24, blue: 0.18),
            Color(red: 1.00, green: 0.44, blue: 0.00),
            Color(red: 0.18, green: 0.56, blue: 0.25),
            Color(red: 0.40, green: 0.18, blue: 0.57),
            Color(red: 0.80, green: 0.14, blue: 0.34),
            Color(red: 0.00, green: 0.61, blue: 0.59),
            Color(red: 0.51, green: 0.32, blue: 0.13),
            Color(red: 0.45, green: 0.45, blue: 0.50)
        ]
        var hash: UInt64 = 5381
        for byte in id.utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return palette[Int(hash % UInt64(palette.count))]
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
