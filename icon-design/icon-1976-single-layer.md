# 1976 "Apple Computer Co." icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #2 (`layered-icons.md` · 1 Apr 1976 · Los Altos), built
the same way as the default icon's flat version: one transparent ticket PNG, background
as a fill in Icon Composer.

Geometry matches the default icon's lead ticket (640×280, 36 px corners, 8° tilt, stub on
the right, seam at 448, 22 px notches) so the set keeps its unifying silhouette — only
the position differs: this lone ticket sits at canvas center instead of low-left.

**Background note:** the layered spec's L1 is light parchment with foxing — texture a
Composer fill can't carry, and a flat light-parchment fill behind cream paper would melt
together (and fail the tinted-mono check). The fill below uses the spec's *dark note*
(tungsten-lit sepia) instead, so the ticket separates by luminance in every appearance.

---

## Layer — letterpress ticket (complete, with print and die-cut)

A 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of aged warm cream letterpress paper (#F2EAD9): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The paper has subtle grain, a few very faint foxing specks, and a faint warm-white highlight along its top edge so it reads slightly thick; the edges are a touch soft and uneven like deckled handmade paper, but the overall rounded-rectangle silhouette stays clean.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a soft warm gray-brown (#B9A684): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height, a die-cut apple silhouette is punched fully through the paper: the classic outline of an apple with a single leaf on top, about 110 pixels tall, the hole showing the transparent background. The cut edge shows the slight thickness of the paper.

The ticket's printing is letterpress in a deep warm black-brown ink (#33271A), pressed slightly into the paper with subtly uneven ink coverage, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge and vertically centered: a woodcut-style engraving of Isaac Newton sitting and reading under an apple tree, about 180 pixels tall and 150 pixels wide, drawn in fine engraved line work like an old book plate.
2. To the right of the engraving, horizontally centered in the remaining body width, a vertical stack of three text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 16 pixels of space between elements:
   - The words "APRIL 1" — letterpress serif capitals, letters 44 pixels tall, wide letter-spacing.
   - The number "1976" — very heavy serif numerals, digits 120 pixels tall, the focal point of the entire icon.
   - The words "LOS ALTOS, CALIFORNIA" — small letterpress serif capitals, letters 24 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "APRIL 1", "1976", and "LOS ALTOS, CALIFORNIA". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom (tungsten workbench light from above):
- Top: **#9C7A4A** (warm tungsten-lit sepia)
- Bottom: **#4F3A20** (deep tobacco brown)

If only a solid color is wanted: **#5C452A**.

Layer settings, matching the default icon's recipe: glass off, neutral shadow ~0.5,
translucency ~0.5 (paper stays visually opaque; this only feeds the specular pass).
The apple die-cut and the two notches read as holes because the gradient fill shows
through them.
