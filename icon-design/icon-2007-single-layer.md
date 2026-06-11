# 2007 "iPhone" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #5 (`layered-icons.md` · 9 Jan 2007 · Moscone Center).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched, with iPhone OS 1 folded in):** face #0A0A0C (the keynote slides
and "Hello" ad placed the phone on near-pure black), chrome #C7CBD0 (the original's
polished bezel ring), text #F5F6F7 (white-on-black of the 2007 ads), gloss arc #BFE3F2
(the Aqua "lickable" sheen of iPhone OS 1 icons), background #1C2C46 → #050810 (the
Blue Marble wallpaper's deep ocean blue falling into the black stage).

**Known fix:** in the previous generation the iPhone die-cut sat too low in the stub —
it must be exactly centered.

---

## Layer — glossy keynote ticket (complete, with print and die-cut)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of glossy near-black glass (#0A0A0C, like the face of the original iPhone): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The ticket has a thin polished chrome edge (#C7CBD0) running around its entire silhouette, about 4 pixels wide, like the steel bezel of the original iPhone. Across the ticket's upper half sweeps one glossy Aqua-style highlight arc — a soft translucent sheen tinted pale cyan-white (#BFE3F2) with a crisp lower boundary curving from the left edge to the right edge, the "lickable" gloss of iPhone OS 1 icons — brightest near the top edge and fading before the ticket's vertical middle.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a medium cool gray (#585E64): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, a die-cut silhouette is punched fully through the glass: the front outline of the original 2007 iPhone — a single vertical rounded slab, about 115 pixels tall and 56 pixels wide, with the large soft corner radius of the original — the hole showing the transparent background. The silhouette is centered exactly both horizontally in the stub's 192-pixel width and vertically in the ticket's 280-pixel height: equal space above and below it, its center on the same horizontal centerline as the large "2007" numerals — not shifted toward the bottom. Keep it one simple closed cut; the chrome edge treatment also rims this cut so it reads as machined.

The ticket's printing is in bright near-white ink (#F5F6F7) in clean Myriad-style type, each glyph carrying a faint glass-edge glint, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge: a three-line quote in Myriad-style mixed-case type, letters 30 pixels tall per line (cap height), normal letter-spacing, 12 pixels between lines, the three lines center-aligned with each other — the keynote's thesis line, written exactly:
   - "Today, Apple is"
   - "going to reinvent"
   - "the phone."
   The stack as a whole is vertically centered in the ticket's 280-pixel height, so its vertical center lines up exactly with the center of the large "2007" numerals.
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three text elements, each line center-aligned with the others, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "JAN 9" — Myriad-style capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2007" — semibold Myriad-style numerals, digits 110 pixels tall, the focal point of the entire icon.
   - The words "MOSCONE CENTER, SAN FRANCISCO" — small Myriad-style capitals, letters 20 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "Today, Apple is", "going to reinvent", "the phone.", "JAN 9", "2007", and "MOSCONE CENTER, SAN FRANCISCO". Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#1C2C46** → bottom **#050810** (Blue Marble ocean
  blue falling into the black keynote stage; solid fallback **#0E1622**)
- **Glass:** off
