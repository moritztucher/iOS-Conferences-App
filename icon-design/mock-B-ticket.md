# Mock B — Single Ticket, Date-Stamped

iOS app icon for **iOS-Conferences** — an indie aggregator app that lists upcoming
developer/tech conferences sorted by date.

Direction: a **single** event ticket, glowing against a **pure-black** canvas, with
a perforated stub stamped with a developer-history date. The hero date is
**1. April 1976** (Apple's founding day). The other dates are the alternate-icon
easter egg (see below). Visually rooted in the running app's look: black background,
vibrant saturated accent colours (the row-avatar hash palette — red, purple, teal,
blue, green), bold SF Pro typography.

**Output format:** flat **square** 1024×1024 image (no rounded corners — iOS applies
the corner radius at display time). No drop shadow extending beyond the canvas edge.
Generated via GPT Image (ChatGPT) — text rendering is decent but verify the date reads
exactly `1. April 1976`; regenerate or instruct "fix the text to read exactly:
1. April 1976" if garbled.

## Prompt (1 — Hero: glowing ticket on black) ★ primary

A square image 1024×1024 for a developer-conference app. A single event ticket viewed
straight-on, centered, with a vertical perforated tear-line down one side. The ticket
face is a deep saturated gradient (magenta-red into violet into teal) glowing softly
against a pure-black background. Stamped on the ticket in bold modern sans-serif
(SF Pro style), the date "1. April 1976". Minimal, high-contrast, neon-like edge glow,
flat vector aesthetic. Square image 1024×1024, full-bleed, square corners, no text
outside the artwork.

## Prompt (2 — Minimal mono-colour ticket)

A square image 1024×1024: one flat conference ticket centered on a pure-black canvas,
perforated edge on the left, single vibrant accent color (electric red) with a subtle
inner glow. The date "1. April 1976" printed in clean bold white sans-serif, plus a
small admit-one circle punch. Confident, simple, premium, flat design. Square image
1024×1024, full-bleed, square corners, no text outside the artwork.

## Prompt (3 — Ticket as the colored tile, matches the app's row avatars)

A square image 1024×1024 shaped like a rounded-square tile fully filling the frame,
using a saturated diagonal gradient (purple to teal). Embossed/cut into the tile is the
silhouette of an event ticket with a perforated edge, and the stamped date
"1. April 1976" in bold white SF Pro typography. Soft top-light, subtle depth, glassy
premium finish on black. Square image 1024×1024, full-bleed, no text outside the
artwork.

## Prompt (4 — Tilted ticket with depth)

A square image 1024×1024, 3D-rendered: a single glossy event ticket floating at a
slight 15° tilt, perforated stub on one end, casting a soft glow onto a pure-black
backdrop. The ticket surface is a vivid red-to-violet gradient with the date
"1. April 1976" debossed in bold sans-serif. Cinematic studio lighting, premium
product-render style, subtle reflection. Square image 1024×1024, centered, full-bleed,
no text outside the artwork.

## Alternate-icon easter egg

Same prompt, swap the stamped date and shift the accent colour so each reads
distinctly in the Settings icon picker:

| Icon (default first) | Date stamp     | Suggested accent | Meaning                          |
|----------------------|----------------|------------------|----------------------------------|
| **Main**             | `1. April 1976`| red → violet     | Apple founded                    |
| iPhone               | `9. Jan 2007`  | blue             | Original iPhone keynote          |
| Macintosh            | `24. Jan 1984` | green            | First Macintosh                  |
| Launch / WWDC26      | `08. Jun 2026` | teal             | WWDC26 & the app's release day   |

## Notes

- Test order: **Prompt 1** (truest to the glow-on-black app look), then **Prompt 3**
  if you want the icon to read as "extracted from the UI" tile.
- April 1 doubles as April Fools' Day — intended as a quiet nerd easter egg, not a gag.
- Sibling direction: `mock-A-tickets.md` (fanned tickets, blueprint-blue, `JUN 26`).
