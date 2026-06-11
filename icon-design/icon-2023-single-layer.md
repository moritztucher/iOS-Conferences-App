# 2023 "Vision Pro" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #6 (`layered-icons.md` · 5 Jun 2023 · Apple Park).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched — the WWDC23 identity):** glass #E8EAF0 (Vision Pro's laminated
glass front / aluminum silver), iridescent sheen #6FB7E8 → #C77DD6 → #F2B45C (the
WWDC23 logo's thin-film "oil-slick" interference: cool blue → magenta → warm amber —
not the violet/cyan guess used previously), text #F5F5F7 (Apple's near-white on dark),
background #1C1C24 → #050507 (the dark, slightly cool field the WWDC23 logo floated on).

**Year check (known failure mode):** generated versions of this ticket have rendered
the year wrong before — verify the numerals read exactly **2023**, not 2025.

---

## Layer — holographic glass ticket (complete, with print and die-cut)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of frosted translucent glass — a softly luminous slab like the laminated front plate of a Vision Pro, its base a cool silver-white (#E8EAF0) where the light catches it: a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. A thin-film iridescent sheen drifts across the glass like an oil slick, shifting from cool blue (#6FB7E8) on the ticket's left end through soft magenta (#C77DD6) to warm amber (#F2B45C) on its right end, with one brighter diagonal band of spectral light crossing the surface. The slab has visible thickness: its edges catch a thin brighter rim of light all the way around the silhouette.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background; each notch edge carries a thin prismatic rim light. Between the two notches runs a dashed perforation line in a pale silver-lavender (#C9C8D8): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered exactly both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height — equal space above and below — a die-cut silhouette is punched fully through the glass: the front outline of the Apple Vision Pro headset — a single wide, smoothly curved goggle/visor shape, about 150 pixels wide and 70 pixels tall — the hole showing the transparent background, its cut edge rimmed with the same thin prismatic light as the notches. Keep it one simple closed cut so it reads at small sizes.

The ticket's text appears to float inside the glass: near-white (#F5F5F7) with a very subtle glow, in clean modern sans-serif type like SF Pro, rotated together with the ticket. All text is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge: a four-line quote in mixed-case type, letters 26 pixels tall per line (cap height), normal letter-spacing, 12 pixels between lines, the four lines center-aligned with each other — Tim Cook's line from the reveal, written exactly:
   - "It's the first"
   - "Apple product"
   - "you look through,"
   - "and not at."
   The stack as a whole is vertically centered in the ticket's 280-pixel height, so its vertical center lines up exactly with the center of the large "2023" numerals.
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three text elements, each line center-aligned with the others, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "JUN 5" — capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2023" — semibold numerals, digits 110 pixels tall, the focal point of the entire icon.
   - The words "APPLE PARK, CUPERTINO" — small capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "It's the first", "Apple product", "you look through,", "and not at.", "JUN 5", "2023", and "APPLE PARK, CUPERTINO" — in particular the year must be exactly "2023". Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#1C1C24** → bottom **#050507** (the WWDC23 dark
  field; solid fallback **#101014**)
- **Glass:** off (the frosted look is baked into the artwork)
