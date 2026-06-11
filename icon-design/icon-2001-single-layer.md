# 2001 "iPod" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #4 (`layered-icons.md` · 23 Oct 2001 · Apple Campus).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched, with the era's OS folded in):** card #F6F4EF ("iBook white" —
the original iPod's warm-white polycarbonate face per Wikipedia/MoMA, not pure white),
ink #1C1C1E (near-black of the 2001 ads/keynote slides), accent #1A6DD2 (Mac OS X Aqua
blue — the OS look of 2001), background #2B2D30 → #050505 (the launch photography shot
the white iPod against a dark-gray-to-black field, pre-silhouette-campaign).

---

## Layer — glossy gift-card ticket (complete, with print and die-cut)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of glossy warm-white polycarbonate (#F6F4EF, the "iBook white" acrylic of the original iPod's face): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The card face carries one soft diagonal specular band sweeping across its upper half, carrying the faintest cool Aqua-blue tint (#1A6DD2 at very low opacity) — glossy plastic, not paper — and a faint cool highlight along its top edge so it reads slightly thick.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a cool light gray (#C6C8CA): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered exactly both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height — equal space above and below — a die-cut silhouette is punched fully through the card: a single classic white-earbud shape — the round bud with its short stem — with one graceful looping curve of cable flowing below it, the whole motif about 115 pixels tall, drawn as one connected cut about 12 pixels wide along the cable so the hole stays sturdy and reads at small sizes. The hole shows the transparent background; the cut edge shows the slight thickness of the card.

The ticket's printing is in near-black ink (#1C1C1E), crisp like screen-printed plastic, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge: a two-line stack in slender old-style serif capitals (Apple-Garamond-like), letters 34 pixels tall per line, wide letter-spacing, 14 pixels between lines, the two lines center-aligned with each other:
   - "1,000 SONGS"
   - "IN YOUR POCKET"
   The stack as a whole is vertically centered in the ticket's 280-pixel height, so its vertical center lines up exactly with the center of the large "2001" numerals.
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three text elements, each line center-aligned with the others, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "OCT 23" — clean light humanist sans-serif capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2001" — large clean humanist sans-serif numerals, semibold, digits 110 pixels tall, the focal point of the entire icon.
   - The words "APPLE CAMPUS, CUPERTINO" — small humanist sans-serif capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "1,000 SONGS", "IN YOUR POCKET", "OCT 23", "2001", and "APPLE CAMPUS, CUPERTINO". Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#2B2D30** → bottom **#050505** (the 2001 launch
  photography's dark field; solid fallback **#1A1B1D**)
- **Glass:** off
