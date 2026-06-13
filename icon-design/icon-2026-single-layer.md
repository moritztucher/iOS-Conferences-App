# 2026 "WWDC26" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #7 (`layered-icons.md` · 8 Jun 2026 · Apple Park).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, 22 px notches), lone ticket centered at (512, 512).

**Palette (WWDC26 identity + iOS 26 Liquid Glass):** clear glass (#EAF2FB tint at
highlights) with chromatic edge dispersion #4DA6FF → #B98CFF → #EAF2FB, etch #F5F7FA,
background #16181F → #0A0B0F. The stub mark is the WWDC26 Apple logo: a glowing,
three-dimensional metallic Apple rendered in white and blue (#EAF2FB / #4DA6FF). The
slab carries the dark stage inside its body so it reads as transparent on the matching
fill.

---

## Layer — Liquid Glass ticket

A square 1024×1024 PNG with a fully transparent background.

One event ticket of clear Liquid Glass — Apple's iOS 26 material: a transparent, highly refractive slab, not chrome and not frosted: a horizontal rounded rectangle, 640×280 pixels, 36-pixel corner radius, centered at (512, 512), rotated 8 degrees with the right end raised. The slab's body is deep near-black (#0A0B0F), as if the dark stage behind it shows through the clear glass; the glass reveals itself only through light: one long soft specular streak sweeping diagonally, a cool tint (#EAF2FB) where light catches, gentle lensing at the edges, and a thin bright rim around the whole silhouette that disperses into prismatic fringes of blue (#4DA6FF) and violet (#B98CFF), strongest at the corners.

The right 192 pixels are a tear-off stub, separated by a vertical perforation seam: a dashed line of etched bright-silver dashes (#D8DCE2, 3 pixels thick) running between two semicircular notches of 22-pixel radius punched into the top and bottom edges at the seam — the notches are cut through, showing the transparent background, rimmed in bright dispersing light.

All type is etched into the glass — luminous near-white (#F5F7FA) with a faint cool glow — clean SF-Pro-style sans-serif, rotated with the ticket:
1. Left, inset 48 pixels: a center-aligned two-line stack in etched capitals, 32 pixels tall per line — "LIQUID" / "GLASS" — vertically centered on the same horizontal line as the "2026" numerals.
2. To its right, centered in the remaining width, a center-aligned stack: "JUN 8" in capitals, 42 pixels tall; "2026" in semibold numerals, 110 pixels tall, the focal point; "APPLE PARK, CUPERTINO" in small capitals, 22 pixels tall.
3. On the stub, horizontally and vertically centered: the WWDC26 Apple logo — a glowing, three-dimensional metallic Apple rendered in white and blue (#EAF2FB highlights, #4DA6FF tones), with a soft luminous halo bleeding into the glass — about 110 pixels tall, light embedded in the glass, not a sticker.

Nothing else — no rules, no barcode, no shadows onto the background, nothing touching the canvas edges. Verify: "LIQUID", "GLASS", "JUN 8", "2026", "APPLE PARK, CUPERTINO".

---

## Icon Composer settings

- **Fill:** linear gradient, top **#16181F** → bottom **#0A0B0F** (solid fallback
  **#0F1117**) — the slab's near-black body blends into this, which makes it read as
  clear glass
- **Glass:** **on** — the one icon in the set using Composer's real Liquid Glass
  treatment
