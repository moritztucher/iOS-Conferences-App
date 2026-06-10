# 1984 "Macintosh" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #3 (`layered-icons.md` · 24 Jan 1984 · Flint Center),
same recipe as the default and 1976 flat versions: one transparent ticket PNG,
background as a fill in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Background note:** the layered spec's L1 is Macintosh-beige plastic with a rainbow
stripe — both texture, neither possible as a Composer fill, and a flat beige fill behind
a beige card ticket would melt together. The fill below uses the spec's *dark note*
(charcoal, CRT-in-a-dark-room) instead, and the **six-colour rainbow stripe moves onto
the ticket** — printed across the card like the rainbow-logo-era collateral — so the
era's most recognizable mark survives inside the artwork layer.

---

## Layer — Macintosh card ticket (complete, with print and die-cut)

A 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of matte Macintosh-platinum card stock (#E3DCC8, the warm beige of the original Macintosh ABS plastic): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The card has a very subtle matte paper texture and a faint warm-white highlight along its top edge so it reads slightly thick.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a muted warm gray-beige (#B8AD92): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height, a die-cut silhouette is punched fully through the card: the front-face outline of the classic 1984 Macintosh computer — a vertical, slightly tapered boxy shape with its wide "chin" below the screen area — about 115 pixels tall, the hole showing the transparent background. Keep the cut a single simple closed silhouette so it reads at small sizes. The cut edge shows the slight thickness of the card.

A thin six-colour rainbow stripe is printed across the ticket body, rotated together with the ticket: six tight horizontal bands in the Apple-logo order green (#61BB46), yellow (#FDB827), orange (#F5821F), red (#E03A3E), purple (#963D97), blue (#009DDC), together 24 pixels tall, spanning the body's full 448-pixel width edge to edge, its top edge 56 pixels up from the ticket's bottom edge. The stripe stops at the perforation seam and does not enter the stub.

The ticket's printing is in a deep neutral charcoal ink (#2B2B2B) with a subtle dot-matrix print texture, rotated together with the ticket. All printing is on the body, above the rainbow stripe:

1. In the body's left area, inset 48 pixels from the ticket's left edge and vertically centered in the space above the stripe: the word "hello." written in a single flowing handwritten script line, like the script from the Macintosh introduction, about 90 pixels tall including the descender.
2. To the right of the script, horizontally centered in the remaining body width, a vertical stack of three text elements, the stack as a whole vertically centered in the space above the stripe, with 14 pixels of space between elements:
   - The words "JAN 24" — blocky bitmap serif capitals in the style of the Chicago typeface, letters 42 pixels tall, wide letter-spacing.
   - The number "1984" — very heavy blocky bitmap numerals in the same Chicago style, digits 110 pixels tall, the focal point of the entire icon.
   - The words "FLINT CENTER, CUPERTINO" — small bitmap capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "hello.", "JAN 24", "1984", and "FLINT CENTER, CUPERTINO". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom (a dark room lit faintly by a CRT):
- Top: **#3F3B36** (warm charcoal)
- Bottom: **#1E1C19** (near-black warm charcoal)

If only a solid color is wanted: **#2B2826**.

Layer settings, same recipe as the default and 1976: glass off, neutral shadow ~0.5,
translucency ~0.5. The Macintosh die-cut and the two notches read as holes because the
charcoal fill shows through them; the platinum card separates from the dark fill by
luminance, so the tinted-mono check passes.
