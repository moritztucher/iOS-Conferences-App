# 2026 "WWDC26" icon — single-layer prompt (Icon Composer)

Single-layer variant of era icon #7 (`layered-icons.md` · 8 Jun 2026 · Apple Park).
One transparent ticket PNG; background fill set in Icon Composer.

Geometry is the set's unifying constant (640×280, 36 px corners, 8° tilt, stub on the
right, seam at 448, 22 px notches), lone ticket centered at (512, 512).

**Reworked from the first draft:** the molten-chrome material read as mercury, not
Liquid Glass, and the Apple Park ring die-cut wasn't legible — both replaced. The
material is now a *clear* refractive glass slab (it carries the dark stage inside its
body, so on the matching fill it reads as transparent), and the stub motif is the
**glowing Swift bird** from the actual WWDC26 identity.

**Palette (researched — WWDC26 "All Systems Glow" + iOS 26 Liquid Glass):** the WWDC26
identity is a dark field with glowing elements centered on the Swift mark's warm orange
(#FF8A3D); Liquid Glass is clear (#EAF2FB tint at highlights) with chromatic edge
dispersion #4DA6FF → #B98CFF → #FF8A3D; etch/text #F5F7FA; background #16181F → #0A0B0F.

---

## Layer — Liquid Glass ticket (complete, with etch and glowing motif)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of clear Liquid Glass — Apple's iOS 26 material: a transparent, highly refractive glass slab, not chrome and not frosted: a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 512), rotated 8 degrees with its right end raised and its left end lowered. The slab's body is filled with deep near-black (#0A0B0F), as if the dark stage behind it is showing through the clear glass, while the glass itself reveals its presence only through light: one long soft specular streak sweeping diagonally across the surface, a cool glass tint (#EAF2FB) where the light catches, gentle lensing distortion near the edges, and a thin bright rim of light around the entire silhouette. Along the rim the light disperses chromatically into delicate prismatic fringes of cool blue (#4DA6FF), violet (#B98CFF), and warm orange (#FF8A3D) — strongest at the corners.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background; each notch is rimmed in bright dispersing light. Between the two notches runs a dashed perforation line of small etched bright dashes (#D8DCE2): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

In the stub, centered exactly both horizontally in its 192-pixel width and vertically in the ticket's 280-pixel height — equal space above and below — the Swift bird logo glows from within the glass: the swift in flight, about 110 pixels wide, rendered as warm radiant orange light (#FF8A3D) with a soft luminous halo bleeding into the surrounding glass — the "All Systems Glow" mark of WWDC26. It is light embedded in the glass, not a printed sticker and not a hole.

The ticket's type is etched into the glass — carved slightly into the surface, the etch lines reading luminous near-white (#F5F7FA), their lower edges catching a faint warm glow from the Swift mark — in clean modern sans-serif type like SF Pro, rotated together with the ticket. All type is on the body:

1. In the body's left area, inset 48 pixels from the ticket's left edge: a two-line stack in etched capitals, letters 32 pixels tall per line, wide letter-spacing, 14 pixels between lines, the two lines center-aligned with each other — the event's tagline:
   - "ALL SYSTEMS"
   - "GLOW"
   The stack as a whole is vertically centered in the ticket's 280-pixel height, so its vertical center lines up exactly with the center of the large "2026" numerals.
2. To the right of that stack, horizontally centered in the remaining body width, a vertical stack of three etched text elements, each line center-aligned with the others, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
   - The words "JUN 8" — etched capitals, letters 42 pixels tall, wide letter-spacing.
   - The number "2026" — semibold etched numerals, digits 110 pixels tall, catching the strongest warm glow, the focal point of the entire icon.
   - The words "APPLE PARK, CUPERTINO" — small etched capitals, letters 22 pixels tall, wide letter-spacing.

Nothing else: no rules, no barcode, no shadows onto the transparent background, and nothing touches the canvas edges. Verify the text reads exactly "ALL SYSTEMS", "GLOW", "JUN 8", "2026", and "APPLE PARK, CUPERTINO". Output as a transparent-background PNG.

---

## Icon Composer settings

Only the background fill colors and the Glass toggle are set in Composer:

- **Fill:** linear gradient, top **#16181F** → bottom **#0A0B0F** (the "All Systems
  Glow" dark field; solid fallback **#0F1117**). The slab's near-black body blends into
  this fill, which is what makes the ticket read as clear glass.
- **Glass:** **on** — this is the one icon in the set that should use Composer's real
  Liquid Glass treatment; the baked artwork provides tint and glow, Composer provides
  the live specular.
