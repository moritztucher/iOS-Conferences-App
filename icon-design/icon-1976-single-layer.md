# 1976 "Apple Computer Co." icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #2 (`layered-icons.md` · 1 Apr 1976 · Los Altos).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched):** paper #F2E8D5 (uncoated ivory letterpress stock, matching the
Apple-1 manual's buff cover), ink #1E1A15 (India ink — Ron Wayne's Newton crest was
drawn in it), sepia accent #8B5A2B (aged 1970s secondary ink), background a tungsten-lit
Los Altos garage: #2A1F16 → #140D08.

---

## Layer — letterpress ticket (complete, with print and die-cut)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of aged ivory letterpress paper (#F2E8D5, like the cover stock of the 1976 Apple-1 manual): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The paper has subtle grain, a few very faint foxing specks, and a faint warm-white highlight along its top edge so it reads slightly thick; the edges are a touch soft and uneven like deckled handmade paper, but the overall rounded-rectangle silhouette stays clean.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in aged sepia ink (#8B5A2B): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered exactly both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height — equal space above and below — a die-cut apple silhouette is punched fully through the paper: the classic outline of an apple with a single leaf on top, about 110 pixels tall, the hole showing the transparent background. The cut edge shows the slight thickness of the paper.

The ticket's printing is letterpress in India-ink near-black (#1E1A15), pressed slightly into the paper with subtly uneven ink coverage, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge: a woodcut-style engraving of Isaac Newton sitting and reading under an apple tree, about 180 pixels tall and 150 pixels wide, drawn in fine engraved line work like an old book plate. The engraving is vertically centered in the ticket's 280-pixel height so its vertical center lines up exactly with the center of the large "1976" numerals.
2. To the right of the engraving, horizontally centered in the remaining body width, a vertical stack of three text elements, each line center-aligned with the others, the stack as a whole vertically centered in the ticket's 280-pixel height, with 16 pixels of space between elements:
   - The words "APRIL 1" — letterpress serif capitals, letters 44 pixels tall, wide letter-spacing.
   - The number "1976" — very heavy serif numerals, digits 120 pixels tall, the focal point of the entire icon.
   - The words "LOS ALTOS, CALIFORNIA" — small letterpress serif capitals, letters 24 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "APRIL 1", "1976", and "LOS ALTOS, CALIFORNIA". Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#2A1F16** → bottom **#140D08** (tungsten-lit garage
  sepia; solid fallback **#1F1710**)
- **Glass:** off
