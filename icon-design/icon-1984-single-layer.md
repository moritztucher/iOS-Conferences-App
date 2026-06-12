# 1984 "Macintosh" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #3 (`layered-icons.md` · 24 Jan 1984 · Flint Center).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched):** card #C4C0AA (true "Apple Beige" — Pantone 14-0105 TPG per
Ben Zotto's analysis of original dealer touch-up paint; the often-cited Pantone 453
reads too yellow), ink #2B2B29 (period print used warm near-black), canonical rainbow
stripe hexes below, background #1A1C24 → #050608 (Flint Center auditorium / CRT glow
in a dark room — cool charcoal, not warm).

**Known failure mode:** a previous generation rendered "JAN 24" as "JAH 24" — the
bitmap N must be verified.

---

## Layer — Macintosh card ticket (complete, with print and die-cut)

A square 1024×1024 PNG with a fully transparent background.

One event ticket of matte Apple-Beige card stock (#C4C0AA, the original Macintosh plastic tone): a horizontal rounded rectangle, 640×280 pixels, 36-pixel corner radius, centered at (512, 512), rotated 8 degrees with the right end raised. Subtle matte texture; faint highlight along the top edge so the card reads slightly thick.

The right 192 pixels are a tear-off stub, separated by a vertical perforation seam: a dashed line (#8F8B77, 3 pixels thick) running between two semicircular notches of 22-pixel radius punched into the top and bottom edges at the seam — the notches are cut through, showing the transparent background.

Punched fully through the stub, horizontally centered, in the area above the rainbow stripe: the front-face silhouette of the classic 1984 Macintosh — a boxy shape with its wide "chin" — about 110 pixels tall, one simple closed cut showing the transparent background.

A rainbow stripe runs along the ticket's lower edge, spanning its entire width edge to edge — continuing uninterrupted through the seam and stub — its top edge 56 pixels above the ticket's bottom edge. It has EXACTLY SIX bands, each 4 pixels tall, no gaps, top to bottom: green #61BB46, yellow #FDB827, orange #F5821F, red #E03A3E, purple #963D97, blue #009DDC. Six distinct colors — purple AND blue must both appear below the red.

All printing is warm near-black ink (#2B2B29) with light dot-matrix texture, on the body above the stripe, rotated with the ticket:
1. Left, inset 48 pixels: "hello." in the flowing Macintosh-introduction script, 110 pixels tall — the SAME height as the "1984" numerals, its center on the same horizontal line, so "hello." and "1984" form one row.
2. To its right, centered in the remaining width, a center-aligned stack: "JAN 24" in Chicago-style bitmap capitals, 42 pixels tall (the middle letter is an N, never an H); "1984" in very heavy bitmap numerals, 110 pixels tall, the focal point; "FLINT CENTER, CUPERTINO" in small bitmap capitals, 22 pixels tall.

Nothing else — no barcode, no shadows onto the background, nothing touching the canvas edges. Verify: "hello.", "JAN 24" (never "JAH"), "1984", "FLINT CENTER, CUPERTINO", and exactly six rainbow bands.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#1A1C24** → bottom **#050608** (Flint Center
  dark / CRT-in-a-dark-room; solid fallback **#101218**)
- **Glass:** off
