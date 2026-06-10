# 2001 "iPod" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #4 (`layered-icons.md` · 23 Oct 2001 · Apple Campus),
same recipe as the default / 1976 / 1984 flat versions: one transparent ticket PNG,
background as a fill in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Background note:** the layered spec's L1 is a white Aqua-glow field — flat white fill
behind a pearl-white gift card melts together and fails tinted-mono, the same problem as
1976/1984. The fill below uses the spec's *dark note* (black with the cool silver-blue
bloom — the iPod silhouette-ad look). The era canvases stay hue-keyed: cool silver-blue
here vs. the warm charcoals and sepias of the others.

---

## Layer — glossy gift-card ticket (complete, with print and die-cut)

A 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of glossy pearl-white plastic gift-card material (#F4F6F8, like an early iTunes gift card): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The card face carries one soft diagonal specular band of slightly brighter white sweeping across its upper half — glossy plastic, not paper — and a faint cool highlight along its top edge so it reads slightly thick.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a cool light gray (#C3CAD3): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height, a die-cut silhouette is punched fully through the card: a single classic white-earbud shape — the round bud with its short stem — with one graceful looping curve of cable flowing below it, the whole motif about 115 pixels tall, drawn as one connected cut about 12 pixels wide along the cable so the hole stays sturdy and reads at small sizes. The hole shows the transparent background; the cut edge shows the slight thickness of the card.

The ticket's printing is in a deep cool slate ink (#373C42), crisp like screen-printed plastic, rotated together with the ticket. All printing is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge and vertically centered: a two-line stack in slender old-style serif capitals (Apple-Garamond-like), letters 34 pixels tall per line, wide letter-spacing, 14 pixels between lines:
   - "1,000 SONGS"
   - "IN YOUR POCKET"
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "OCT 23" — clean light humanist sans-serif capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2001" — large clean humanist sans-serif numerals, semibold, digits 110 pixels tall, the focal point of the entire icon.
   - The words "APPLE CAMPUS, CUPERTINO" — small humanist sans-serif capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "1,000 SONGS", "IN YOUR POCKET", "OCT 23", "2001", and "APPLE CAMPUS, CUPERTINO". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom (cool silver-blue bloom fading to black — the
silhouette-ad look):
- Top: **#3A4756** (cool silver-blue)
- Bottom: **#10141A** (near-black blue-tinted)

If only a solid color is wanted: **#242C37**.

Layer settings, same recipe as the rest of the set: glass off, neutral shadow ~0.5,
translucency ~0.5. The earbud die-cut and the two notches read as holes because the
dark fill shows through them; the pearl-white card separates from the fill by luminance,
so the tinted-mono check passes.
