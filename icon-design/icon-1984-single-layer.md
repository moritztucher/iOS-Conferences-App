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

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of matte Apple-Beige card stock (#C4C0AA, the exact warm gray-beige of the original Macintosh ABS plastic): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The card has a very subtle matte paper texture and a faint warm-white highlight along its top edge so it reads slightly thick.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a deeper warm gray-beige (#8F8B77): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered exactly horizontally in its 192-pixel width and vertically centered in the space above the rainbow stripe (described below), a die-cut silhouette is punched fully through the card: the front-face outline of the classic 1984 Macintosh computer — a vertical, slightly tapered boxy shape with its wide "chin" below the screen area — about 110 pixels tall, the hole showing the transparent background, well clear of the stripe. Keep the cut a single simple closed silhouette so it reads at small sizes. The cut edge shows the slight thickness of the card.

A rainbow stripe is printed along the ticket's lower edge, rotated together with the ticket. The stripe is made of EXACTLY SIX horizontal color bands — not three, not four, not five: six — stacked tightly with no gaps, each band exactly 4 pixels tall, every band a clearly different color, none merged and none omitted, in the canonical Apple-logo order from top to bottom:
1. green #61BB46
2. yellow #FDB827
3. orange #F5821F
4. red #E03A3E
5. purple #963D97
6. blue #009DDC
Together the six bands are 24 pixels tall. The stripe spans the ticket's entire 640-pixel width, running uninterrupted from the ticket's left edge all the way to its right edge — crossing the perforation seam and continuing through the stub — with its top edge 56 pixels up from the ticket's bottom edge. (The Macintosh die-cut sits above the stripe and is not touched by it.) Count the bands before finishing: there must be six distinct colors, with purple and blue both present below the red.

The ticket's printing is in warm near-black ink (#2B2B29) with a subtle dot-matrix print texture, rotated together with the ticket. All printing is on the body, in the area above the rainbow stripe:

1. In the body's left area, inset 48 pixels from the ticket's left edge: the word "hello." written in a single flowing handwritten script line, like the script from the Macintosh introduction, 110 pixels tall including the descender — the SAME height as the large "1984" numerals. Its vertical center sits exactly on the same horizontal line as the center of the "1984" numerals, so "hello." and "1984" read as one row, with "JAN 24" in the row above and "FLINT CENTER, CUPERTINO" in the row below.
2. To the right of the script, horizontally centered in the remaining body width, a vertical stack of three text elements, each line center-aligned with the others, the stack as a whole vertically centered in the space above the stripe, with 14 pixels of space between elements:
   - The words "JAN 24" — blocky bitmap serif capitals in the style of the Chicago typeface, letters 42 pixels tall, wide letter-spacing. The middle letter is an N, not an H: its diagonal must run from the top of the left stem to the bottom of the right stem.
   - The number "1984" — very heavy blocky bitmap numerals in the same Chicago style, digits 110 pixels tall, the focal point of the entire icon.
   - The words "FLINT CENTER, CUPERTINO" — small bitmap capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "hello.", "JAN 24" (with the letter N, never "JAH"), "1984", and "FLINT CENTER, CUPERTINO" — and verify the rainbow stripe has exactly six distinct color bands (green, yellow, orange, red, purple, blue). Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#1A1C24** → bottom **#050608** (Flint Center
  dark / CRT-in-a-dark-room; solid fallback **#101218**)
- **Glass:** off
