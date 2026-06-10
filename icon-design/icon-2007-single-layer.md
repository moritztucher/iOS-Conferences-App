# 2007 "iPhone" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #5 (`layered-icons.md` · 9 Jan 2007 · Moscone Center),
same recipe as the other flat versions: one transparent ticket PNG, background as a
fill in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Background note:** unlike 1976/1984/2001, the spec's L1 (keynote stage: near-black
with a deep aqua reflection floor) *is* expressible as a linear fill — near-black at the
top falling into deep aqua at the bottom edge. The catch is inverted here: the ticket is
glossy black on a dark stage, so separation comes from the Aqua highlight arc and the
chrome edge, not paper luminance. Keep the fill very near black so the gloss does the
work; check tinted-mono extra carefully on this one.

---

## Layer — glossy keynote ticket (complete, with print and die-cut)

A 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of glossy piano-black plastic (#202428, like the face of the original iPhone): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The ticket has a thin polished chrome edge running around its entire silhouette, about 4 pixels wide, like the steel band of the original iPhone. Across the ticket's upper half sweeps one glossy Aqua-style highlight arc — a soft translucent white-blue sheen with a crisp lower boundary curving from the left edge to the right edge, the skeuomorphic glass look of 2007 — brightest near the top edge and fading before the ticket's vertical middle.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a medium cool gray (#5A6066): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height, a die-cut silhouette is punched fully through the plastic: the front outline of the original 2007 iPhone — a single vertical rounded slab, about 115 pixels tall and 56 pixels wide, with the large soft corner radius of the original — the hole showing the transparent background. Keep it one simple closed cut; the chrome edge treatment also rims this cut so it reads as machined.

The ticket's printing is in a bright cool silver-white ink (#E8EAEC) in clean Myriad-style type, each glyph carrying a faint glass-edge glint, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge and vertically centered: a two-line stack in Myriad-style capitals, letters 32 pixels tall per line, wide letter-spacing, 14 pixels between lines:
   - "APPLE REINVENTS"
   - "THE PHONE"
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "JAN 9" — Myriad-style capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2007" — semibold Myriad-style numerals, digits 110 pixels tall, the focal point of the entire icon.
   - The words "MOSCONE CENTER, SAN FRANCISCO" — small Myriad-style capitals, letters 20 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "APPLE REINVENTS", "THE PHONE", "JAN 9", "2007", and "MOSCONE CENTER, SAN FRANCISCO". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom (keynote stage falling into the aqua reflection floor):
- Top: **#0C0E10** (near-black)
- Bottom: **#17444F** (deep aqua-blue)

Orientation: start (0.5, 0) → stop (0.5, 1) — let the aqua live only in the bottom
third by keeping the top color dominant. If only a solid color is wanted: **#11181C**.

Layer settings, same recipe as the rest of the set: glass off, neutral shadow ~0.5,
translucency ~0.5. The iPhone die-cut and the two notches read as holes because the
stage fill shows through them. **Tinted-mono check matters most on this icon** — the
black ticket must separate via its Aqua arc and chrome rim; if it melts, brighten the
arc rather than lightening the plastic.
