# Mock C — Black-Canvas Ticket Set (date-forward)

A redesign of the easter-egg date set that bridges the **ticket metaphor** (from
`mock-A-tickets.md`) with the **running app's look** (pure-black canvas, vibrant
saturated tiles). Built for legibility as an actual app icon at small sizes: the
**date is the hero**, clutter is stripped, and each variant carries its own accent
colour — like the app's row avatars on black.

Shared design (constant across all four):
- **Black canvas** with a soft radial glow of the variant accent behind the tickets.
- **Two overlapping event tickets** — a prominent front ticket (fully legible) and one
  peeking behind it, offset, to suggest "many conferences."
- Front ticket = a **vibrant accent-gradient card** with a vertical perforated stub +
  circular punch on the right, and a single thin barcode strip for ticket signal.
- The date is the focus: a **large bold white day numeral**, with the **month** and
  **year** stacked beside/below it in bold caps.

Per variant, change only the **date** and the **accent gradient**:

| Icon (default first) | Date           | Accent gradient            | Meaning                        |
|----------------------|----------------|----------------------------|--------------------------------|
| **Main**             | `1 APR 1976`   | red → orange `#FF5A5F→#FF8A3D` | Apple founded               |
| iPhone               | `9 JAN 2007`   | blue → indigo `#3A8DFF→#5E5CE6` | Original iPhone keynote     |
| Macintosh            | `24 JAN 1984`  | green → teal `#34C759→#0FB8A0`  | First Macintosh             |
| Launch / WWDC26      | `8 JUN 2026`   | purple → magenta `#AF52DE→#FF2D92` | WWDC26 & release day     |

**Output format:** flat **square** 1024×1024, no rounded corners (iOS masks at display
time), no shadow beyond the canvas edge. GPT Image — verify date/year render exactly.

---

## 1 — Main · 1 APR 1976 (red→orange) ★ default

A square image 1024×1024, flat square (no rounded corners). Pure-black background with a
soft radial glow of warm red-orange behind the centre. Centred: two overlapping event
tickets. The back ticket is a dim, desaturated dark card offset up and to the right
(~+8° rotation), only partly visible — a hint of "more." The front ticket is a bold
horizontal card (~720×340) filled with a vibrant red-to-orange gradient (#FF5A5F →
#FF8A3D), tilted slightly (~-6°), with a vertical perforated stub and a circular punch
hole on its right edge (perforation as a dashed line). On the front ticket, the date is
the hero: a very large bold white "1", with "APR" and "1976" stacked beside it in bold
white letter-spaced caps. A single thin barcode strip runs along the bottom edge of the
card. Subtle top sheen and a soft drop shadow grounding the tickets on the black canvas.
Modern, premium, friendly. Square image 1024×1024, full-bleed, square corners, no text
outside the artwork.

## 2 — iPhone · 9 JAN 2007 (blue→indigo)

A square image 1024×1024, flat square (no rounded corners). Pure-black background with a
soft radial glow of blue behind the centre. Centred: two overlapping event tickets. The
back ticket is a dim, desaturated dark card offset up and to the right (~+8° rotation),
only partly visible. The front ticket is a bold horizontal card (~720×340) filled with a
vibrant blue-to-indigo gradient (#3A8DFF → #5E5CE6), tilted slightly (~-6°), with a
vertical perforated stub and a circular punch hole on its right edge. On the front
ticket, the date is the hero: a very large bold white "9", with "JAN" and "2007" stacked
beside it in bold white letter-spaced caps. A single thin barcode strip runs along the
bottom edge. Subtle top sheen and a soft drop shadow on the black canvas. Modern,
premium, friendly. Square image 1024×1024, full-bleed, square corners, no text outside
the artwork.

## 3 — Macintosh · 24 JAN 1984 (green→teal)

A square image 1024×1024, flat square (no rounded corners). Pure-black background with a
soft radial glow of green behind the centre. Centred: two overlapping event tickets. The
back ticket is a dim, desaturated dark card offset up and to the right (~+8° rotation),
only partly visible. The front ticket is a bold horizontal card (~720×340) filled with a
vibrant green-to-teal gradient (#34C759 → #0FB8A0), tilted slightly (~-6°), with a
vertical perforated stub and a circular punch hole on its right edge. On the front
ticket, the date is the hero: a very large bold white "24", with "JAN" and "1984" stacked
beside it in bold white letter-spaced caps. A single thin barcode strip runs along the
bottom edge. Subtle top sheen and a soft drop shadow on the black canvas. Modern,
premium, friendly. Square image 1024×1024, full-bleed, square corners, no text outside
the artwork.

## 4 — Launch / WWDC26 · 8 JUN 2026 (purple→magenta)

A square image 1024×1024, flat square (no rounded corners). Pure-black background with a
soft radial glow of purple-magenta behind the centre. Centred: two overlapping event
tickets. The back ticket is a dim, desaturated dark card offset up and to the right
(~+8° rotation), only partly visible. The front ticket is a bold horizontal card
(~720×340) filled with a vibrant purple-to-magenta gradient (#AF52DE → #FF2D92), tilted
slightly (~-6°), with a vertical perforated stub and a circular punch hole on its right
edge. On the front ticket, the date is the hero: a very large bold white "8", with "JUN"
and "2026" stacked beside it in bold white letter-spaced caps. A single thin barcode
strip runs along the bottom edge. Subtle top sheen and a soft drop shadow on the black
canvas. Modern, premium, friendly. Square image 1024×1024, full-bleed, square corners,
no text outside the artwork.
