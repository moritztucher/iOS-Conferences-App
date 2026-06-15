import SwiftUI

/// Backdrop shown when a conference has no `logoURL` (or `AsyncImage` fails).
///
/// In practice no logos are bundled, so this *is* the detail hero for almost every
/// entry. It is therefore designed to read as an intentional, branded banner — not a
/// missing-image fallback. Size-aware: a clean centred monogram on small list tiles,
/// and at hero size a richer mesh-gradient field with the conference's *kind* as an
/// oversized SF Symbol watermark, the monogram promoted to a designed top-leading mark.
///
/// Colour and initials are hash-derived from the conference id/name, so each entry is
/// visually distinct and stable across launches.
struct ConferencePlaceholder: View {
    /// How the placeholder presents itself.
    /// - `auto`: size-based — a centred monogram on small tiles, a full hero (mesh +
    ///   watermark + top-leading monogram) above `heroThreshold`.
    /// - `card`: list-card background — mesh + kind watermark for depth, but **no
    ///   monogram**, since the host card overlays the conference name as the focal mark.
    enum Style {
        case auto
        case card
    }

    let conference: Conference
    var style: Style = .auto
    /// Multiplicative lift on the base tone before the mesh is built. `> 1` brightens while
    /// preserving hue *and* saturation (scaling RGB keeps their ratios) — i.e. a genuinely
    /// vibrant lift, not the grey wash a `.brightness()` overlay would add. Host cards pass a
    /// strong value for live tickets, ~1 for past.
    var lighten: Double = 1.0
    /// Sub-perceptual idle drift of the mesh keypoints — the detail hero's "you've arrived"
    /// moment (MOTION-1). Off by default so the scrolling list stays static; gated behind
    /// reduce-motion.
    var breathes: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var meshPhase: Float = 0

    /// Above this height the view is acting as the detail hero rather than a list tile.
    private static let heroThreshold: CGFloat = 120

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let w = proxy.size.width
            let isHero = style == .card || h >= Self.heroThreshold
            let base = Self.lit(Self.rgb(for: conference.id), by: lighten)
            let baseColor = Color(red: base.r, green: base.g, blue: base.b)
            let ink = Self.foreground(on: baseColor)

            ZStack {
                if isHero {
                    Self.mesh(for: base, phase: meshPhase)
                } else {
                    Self.gradient(for: conference.id)
                }

                // Kind watermark — oversized SF Symbol, low opacity, anchored toward the
                // bottom-trailing corner. Hero/card only; on a small tile it would just be noise.
                if isHero {
                    Image(systemName: conference.kind.symbolName)
                        .font(.system(size: h * 0.78))
                        .foregroundStyle(ink.opacity(0.14))
                        .rotationEffect(.degrees(-12))
                        .offset(x: w * 0.30, y: h * 0.32)
                        .accessibilityHidden(true)
                }

                // Monogram — the focal mark. Suppressed for `.card`, where the host card's
                // overlaid conference name is the focal mark instead.
                if style != .card {
                    Text(Self.initials(for: conference.name))
                        .font(.system(size: h * (isHero ? 0.34 : 0.42),
                                      weight: .bold, design: .rounded))
                        .foregroundStyle(ink)
                        .shadow(color: .black.opacity(isHero ? 0.18 : 0),
                                radius: isHero ? 6 : 0, y: isHero ? 2 : 0)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity,
                               alignment: isHero ? .topLeading : .center)
                        .padding(isHero ? h * 0.11 : h * 0.1)
                }
            }
            .clipped()
        }
        .onAppear {
            guard breathes, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                meshPhase = 1
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
    ///
    /// A curated set of deep, slightly-desaturated jewel tones (not pure saturated hues) so
    /// the no-image majority reads as one premium, intentional palette rather than a random
    /// assortment — and so warm members sit naturally beside the marigold brand accent.
    private static let palette: [(Double, Double, Double)] = [
        (0.10, 0.42, 0.45),   // deep teal
        (0.24, 0.28, 0.55),   // indigo
        (0.40, 0.24, 0.50),   // plum
        (0.16, 0.40, 0.30),   // forest
        (0.52, 0.20, 0.30),   // burgundy
        (0.22, 0.36, 0.52),   // slate blue
        (0.60, 0.42, 0.18),   // bronze (brand-adjacent)
        (0.56, 0.28, 0.34),   // deep rose
        (0.12, 0.34, 0.48)    // ocean
    ]

    private static func rgb(for id: String) -> (r: Double, g: Double, b: Double) {
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

    /// Multiplicatively brightens a base tone, clamped to [0, 1]. Scaling all channels by the
    /// same factor preserves their ratios → same hue & saturation, just brighter (vibrant),
    /// unlike `shade`/`.brightness` which blend toward white and desaturate.
    static func lit(_ c: (r: Double, g: Double, b: Double), by factor: Double) -> (r: Double, g: Double, b: Double) {
        (min(c.r * factor, 1), min(c.g * factor, 1), min(c.b * factor, 1))
    }

    /// Lightens (`amount > 0`) or darkens (`amount < 0`) a base colour, clamped to [0, 1].
    private static func shade(_ c: (r: Double, g: Double, b: Double), by amount: Double) -> Color {
        func adjust(_ v: Double) -> Double {
            let x = amount >= 0 ? v + (1 - v) * amount : v * (1 + amount)
            return min(max(x, 0), 1)
        }
        return Color(red: adjust(c.r), green: adjust(c.g), blue: adjust(c.b))
    }

    /// Subtle top-lighter → base gradient for small list tiles. Cheap to render in a
    /// scrolling list and imperceptible at tile size, but adds a touch of depth.
    static func gradient(for id: String) -> LinearGradient {
        let c = rgb(for: id)
        return LinearGradient(
            colors: [shade(c, by: 0.18), Color(red: c.r, green: c.g, blue: c.b)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Richer 3×3 mesh gradient for the detail hero: a diagonal light → dark sweep
    /// (light top-leading, dark bottom-trailing) that pairs with the top-leading monogram
    /// and bottom-trailing watermark to give the banner real depth.
    ///
    /// `phase` (0…1) drifts the interior + mid-edge keypoints a few points — the breathe.
    /// At 0 the mesh is the static layout used everywhere else.
    static func mesh(for c: (r: Double, g: Double, b: Double), phase: Float = 0) -> some View {
        let light = shade(c, by: 0.22)
        let base = Color(red: c.r, green: c.g, blue: c.b)
        let dark = shade(c, by: -0.34)
        return MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5 - 0.02 * phase, 0.0], [1.0, 0.0],
                [0.0, 0.5 + 0.02 * phase], [0.5 + 0.03 * phase, 0.5 - 0.025 * phase], [1.0, 0.5 - 0.02 * phase],
                [0.0, 1.0], [0.5 + 0.02 * phase, 1.0], [1.0, 1.0]
            ],
            colors: [
                light, light, base,
                light, base, dark,
                base, dark, dark
            ]
        )
    }

    /// The curated jewel palette as `Color`s, for surfaces that echo the ticket world
    /// without a conference to hash (e.g. the empty-state ghost tickets).
    static func paletteTone(_ index: Int) -> Color {
        let c = palette[index % palette.count]
        return Color(red: c.0, green: c.1, blue: c.2)
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

extension View {
    /// Unifies arbitrary conference artwork (square logos, busy og:images, photos) into one
    /// tonal family so disparate sources read as a single designed system (Track A): gently
    /// desaturated, with a soft top-down darkening so even bright/white logos gain tonal
    /// weight and sit beside the deep mesh placeholders. Each surface's own scrim still rides
    /// on top for text legibility. Apply to the *success* image only — the mesh placeholder
    /// is already in this tonal world.
    /// A light tonal baseline so disparate real artwork (square logos, busy og:images,
    /// photos) reads in the same family without going dark — the per-ticket aliveness
    /// (saturation/brightness for past vs live) is applied on top by the host card.
    func unifiedConferenceArtwork() -> some View {
        self
            .saturation(0.95)
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.16), .black.opacity(0.04), .black.opacity(0.14)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.multiply)
            }
    }
}

#Preview("Hero") {
    VStack(spacing: 16) {
        ConferencePlaceholder(conference: .sample)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        ConferencePlaceholder(conference: Conference.bundled[0])
            .frame(height: 180)
        ConferencePlaceholder(conference: Conference.bundled.last!)
            .frame(height: 180)
    }
    .padding()
}

#Preview("Tiles") {
    HStack(spacing: 12) {
        ConferencePlaceholder(conference: .sample)
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        ConferencePlaceholder(conference: Conference.bundled[0])
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        ConferencePlaceholder(conference: Conference.bundled.last!)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    .padding()
}
