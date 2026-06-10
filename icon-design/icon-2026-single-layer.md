# 2026 "WWDC26" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #7 (`layered-icons.md` · 8 Jun 2026 · Apple Park),
same recipe as the other flat versions: one transparent ticket PNG, background as a
fill in Icon Composer. Material reference: `mock-D-liquid-glass.md`.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Background note:** the spec's L1 is pure black with a soft *centred radial* bloom; a
linear fill can only approximate it top-down, which reads fine behind the chrome. If
your Icon Composer version offers a radial fill, use it centred instead.

This icon is the **clear/tinted showcase** per the layered spec — after assembly,
verify the etched type survives the mono rendering.

---

## Layer — liquid-chrome glass ticket (complete, with etch and die-cut)

A 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of molten liquid chrome fused with translucent glass — a flowing, mirror-bright material with soft warped specular highlights streaming across it, like mercury under studio light: a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. Along the ticket's edges the material refracts prismatically, leaning warm orange on some edges and deep blue on others. The slab has visible thickness and a bright continuous rim of light around its whole silhouette.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background; each notch is rimmed in bright light. Between the two notches runs a dashed perforation line of small etched bright-silver dashes (#D8DCE2): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height, a die-cut ring is punched fully through the glass: an annulus shaped like Apple Park seen from above — outer diameter about 110 pixels, ring band about 16 pixels wide — the ring-shaped hole showing the transparent background while the glass disc inside the ring remains, like the campus courtyard. The cut edges are rimmed in light like the notches.

The ticket's type is etched into the glass — carved slightly into the surface, the etch lines catching a warm amber caustic glow (#FFB25E) along their lower edges while reading luminous silver-white (#EEF0F4) overall — in clean modern sans-serif type like SF Pro, rotated together with the ticket. All type is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge and vertically centered: a two-line stack in etched capitals, letters 32 pixels tall per line, wide letter-spacing, 14 pixels between lines:
   - "LIQUID"
   - "GLASS"
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three etched text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "JUN 8" — etched capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2026" — semibold etched numerals, digits 110 pixels tall, catching the strongest amber caustic, the focal point of the entire icon.
   - The words "APPLE PARK, CUPERTINO" — small etched capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "LIQUID", "GLASS", "JUN 8", "2026", and "APPLE PARK, CUPERTINO". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom (approximating the centred bloom):
- Top: **#232329** (soft graphite bloom)
- Bottom: **#050507** (pure black)

If only a solid color is wanted: **#0E0E11**. If your Composer version supports a
radial fill, prefer it: #232329 at center → #050507 at the edges.

Layer settings: glass off, neutral shadow ~0.5, translucency **~0.3** (the layered spec
gives liquid chrome ~30%; the mirror chrome should stay mostly solid, with the baked
refraction carrying the glass read). The ring die-cut and notches read as holes because
the black fill shows through them. Dark appearance is identical by design; the
**clear/tinted mono check is the acceptance test for this icon** — the etched date must
survive; if it fades, deepen the etch contrast rather than brightening the chrome.
