# 2023 "Vision Pro" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #6 (`layered-icons.md` · 5 Jun 2023 · Apple Park).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, 22 px notches), lone ticket centered at (512, 512).

**Palette (researched — WWDC23 identity):** glass #E8EAF0 (Vision Pro laminated front),
sheen #6FB7E8 → #C77DD6 → #F2B45C (the WWDC23 logo's thin-film "oil-slick" drift),
text #F5F5F7, background #1C1C24 → #050507 (the dark field the WWDC23 logo floated on).

**Year check (known failure mode):** verify the numerals read exactly **2023**, not 2025.

---

## Layer — holographic glass ticket

A square 1024×1024 PNG with a fully transparent background.

One event ticket of frosted translucent glass — a softly luminous slab like the laminated front of a Vision Pro, its base a cool silver-white (#E8EAF0) where light catches: a horizontal rounded rectangle, 640×280 pixels, 36-pixel corner radius, centered at (512, 512), rotated 8 degrees with the right end raised. A thin-film iridescent sheen drifts across it like an oil slick — cool blue (#6FB7E8) on the left through soft magenta (#C77DD6) to warm amber (#F2B45C) on the right — with one brighter diagonal band of spectral light. The slab has visible thickness: a thin brighter rim of light around the whole silhouette.

The right 192 pixels are a tear-off stub, separated by a vertical perforation seam: a dashed line in pale silver-lavender (#C9C8D8, 3 pixels thick) running between two semicircular notches of 22-pixel radius punched into the top and bottom edges at the seam — the notches are cut through, showing the transparent background, each rimmed with thin prismatic light.

All text floats inside the glass: near-white (#F5F5F7) with a subtle glow, clean SF-Pro-style sans-serif, rotated with the ticket:
1. Left, inset 48 pixels: a center-aligned four-line quote in mixed case, 26 pixels tall per line — "It's the first" / "Apple product" / "you look through," / "and not at." — vertically centered on the same horizontal line as the "2023" numerals.
2. To its right, centered in the remaining width, a center-aligned stack: "JUN 5" in capitals, 42 pixels tall; "2023" in semibold numerals, 110 pixels tall, the focal point; "APPLE PARK, CUPERTINO" in small capitals, 22 pixels tall.
3. On the stub, horizontally and vertically centered: the Apple Vision Pro headset — the wide, smoothly curved visor — drawn as a luminous illustration floating in the glass like the text, about 150×70 pixels.

Nothing else — no rules, no barcode, no shadows onto the background, nothing touching the canvas edges. Verify: "It's the first", "Apple product", "you look through,", "and not at.", "JUN 5", "2023" (exactly 2023, never 2025), "APPLE PARK, CUPERTINO".

---

## Icon Composer settings

- **Fill:** linear gradient, top **#1C1C24** → bottom **#050507** (solid fallback **#101014**)
- **Glass:** off (the frosted look is baked into the artwork)
