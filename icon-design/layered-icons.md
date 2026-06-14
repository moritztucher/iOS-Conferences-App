# Layered Era Icons — generation spec (Icon Composer)

Supersedes the shared-blueprint direction (`mock-A-easter-eggs.md`): the blueprint spent
80% of the canvas on the part that never changed, so the set read as "seven blue icons."
New system — **the ticket is the only constant; everything else is era-keyed**:

1. **Era-keyed canvas** (Layer 1) — background, palette, and lighting belong to the moment.
2. **Era-accurate ticket material** (Layer 2) — letterpress → dot-matrix → glossy plastic
   → keynote glass → hologram → liquid chrome. The printing tech tells the story.
3. **Punched stub motif + date** (Layer 3) — a die-cut silhouette in the stub and the date
   treatment, separated so they catch Liquid Glass light independently.
4. **Assembled in Icon Composer** (`.icon`) — layered specular, plus dark / tinted / clear
   variants so the collection survives every home screen.

## Shared rules (every layer, every icon)

- **Canvas:** 1024×1024. Layer 1 is opaque full-bleed; Layers 2–3 are **transparent PNGs**
  containing only their subject.
- **Ticket silhouette is identical across all seven icons:** landscape ticket tilted ~-8°,
  perforated stub on the **right**, two punched semicircle notches at the seam (the app's
  `TicketShape`). Same size and position on every icon — the set's unifying constant.
- Keep the ticket inside the central ~80% (the system squircle-masks and bezels the edge).
- **No rounded corners, no baked drop shadows, no glow past the canvas edge** — depth and
  shadow come from Icon Composer's layer system, not the artwork.
- **Text must render exactly** (date + venue). If the model garbles it, reply:
  "fix the text to read exactly: `<string>`". If etched/embossed text keeps failing,
  fall back to the date on a small inset panel of the same material.
- Layer 3 subjects (stub punch + date) must align with the Layer 2 ticket — generate
  Layer 2 first, then ask for Layer 3 "matching the same ticket position and tilt".

## Icon Composer assembly (same recipe each icon)

1. New `.icon`, import Layer 1 → background; Layer 2 → middle group; Layer 3 → top group.
2. Enable **specular** on Layers 2 and 3 (the ticket catches the glass light sweep).
3. Translucency: only where the material calls for it (2023 hologram ~20%, 2026 liquid
   chrome ~30%); paper/plastic tickets stay opaque.
4. **Dark appearance:** swap Layer 1 per the icon's dark note below; Layers 2–3 carry over.
5. **Tinted/clear check:** view the mono rendering — the ticket must separate from the
   canvas by luminance alone. If it melts in, darken Layer 1 or lighten the ticket stock.

---

## 1 · Default — "Tickets" · 18 May 2026 · First commit

The only icon in the **app's own** design language, not an era's: marigold + ticket fan.

- **L1 — canvas:** near-black warm charcoal with a soft **marigold radial stage-light**
  glow from the top edge fading down (the app's `BrandBackground` language). No texture.
- **L2 — ticket:** the existing **fan of cream tickets** with the marigold lead ticket in
  front carrying a bold `18 MAY` date stub and a small barcode. Subtle paper grain.
- **L3 — punch + date:** the dubdub double-notch perforation highlighted with a faint
  light rim on the lead ticket; `18 MAY 2026` crisp on the stub.
- **Dark:** L1 deepens to true black, marigold glow narrows and brightens slightly.

## 2 · Apple Computer Co. · 1 Apr 1976 · Los Altos

- **L1 — canvas:** aged **parchment / workbench sepia** field — warm cream paper with
  faint foxing and a soft vignette; the feel of a garage workbench under tungsten light.
- **L2 — ticket:** **letterpress** ticket, deckled edges, ink-pressed serif type:
  `APRIL 1, 1976` / `LOS ALTOS, CALIFORNIA`, with the woodcut **Newton-under-the-tree**
  engraving as the ticket's artwork. Slightly uneven ink coverage (authentic letterpress).
- **L3 — punch + date:** a die-cut **apple outline** punched through the stub (canvas
  shows through); the date's ink given a faint emboss highlight.
- **Dark:** L1 becomes deep sepia-charcoal (tobacco brown), tungsten vignette stays.

## 3 · Macintosh · 24 Jan 1984 · Flint Center

- **L1 — canvas:** **Macintosh-beige plastic** panel (the platinum ABS tone) with a thin
  horizontal **six-colour rainbow stripe** along the lower third.
- **L2 — ticket:** matte card ticket printed in **Chicago bitmap** type: `JAN 24, 1984` /
  `FLINT CENTER, CUPERTINO`, with the *"Let Macintosh speak for itself — hello."* script
  line, dot-matrix print texture.
- **L3 — punch + date:** a die-cut **classic Macintosh silhouette** (the front face with
  screen + floppy slot) punched in the stub; the `hello.` script as a separate crisp pass.
- **Dark:** L1 becomes charcoal with the rainbow stripe glowing softly (CRT-in-a-dark-room).

## 4 · iPod · 23 Oct 2001 · Apple Campus

- **L1 — canvas:** **white Aqua glow** — clean white field with a cool silver-blue radial
  bloom and a hint of brushed-aluminium sheen at the edges (2001 keynote-invite white).
- **L2 — ticket:** **glossy plastic gift-card** ticket (iTunes-card material), pearl white
  face, printed `1,000 SONGS` / `IN YOUR POCKET` and `OCT 23, 2001 · APPLE CAMPUS`,
  with a soft plastic specular band.
- **L3 — punch + date:** a die-cut **earbud + looping cable** silhouette punched through
  the stub (the iconic white-cable curve); date text crisp.
- **Dark:** L1 inverts to black with the same cool silver-blue bloom (the silhouette-ad look).

## 5 · iPhone · 9 Jan 2007 · Moscone Center

- **L1 — canvas:** the **2007 keynote stage** — near-black gradient with a deep aqua-blue
  reflection floor at the bottom edge and a faint spotlight from above.
- **L2 — ticket:** **glassy skeuomorphic** ticket — glossy black face with an Aqua-style
  highlight arc across the top half, `JAN 9, 2007` / `MOSCONE CENTER, SAN FRANCISCO` in
  Myriad-style type, thin chrome edge.
- **L3 — punch + date:** a die-cut **original-iPhone silhouette** (rounded slab, home
  button) punched in the stub; the date given a glass-edge glint.
- **Dark:** L1 already dark — deepen the aqua floor slightly so tinted mode separates.

## 6 · Vision Pro · 5 Jun 2023 · Apple Park

- **L1 — canvas:** **dark spatial gradient** — deep violet-black with soft out-of-focus
  bokeh flares (the WWDC23 spatial-computing reveal lighting).
- **L2 — ticket:** **translucent holographic** ticket — frosted glass slab with a
  prismatic iridescent sheen shifting violet→cyan, `JUN 5, 2023` / `APPLE PARK` floating
  in the material. ~20% translucency in Composer, so keep internal contrast high.
- **L3 — punch + date:** a die-cut **Vision Pro visor** silhouette punched in the stub;
  a thin holographic rim light around the perforation notches.
- **Dark:** L1 unchanged (already dark); raise the bokeh flares ~10% so it doesn't go mute.

## 7 · WWDC26 · 8 Jun 2026 · Apple Park

The mock-D liquid-glass direction, now layered (see `mock-D-liquid-glass.md` for the full
material reference).

- **L1 — canvas:** **pure black** with a soft centred radial bloom.
- **L2 — ticket:** the **molten liquid-chrome / translucent glass** ticket — flowing
  specular highlights, prismatic edge refraction leaning **WWDC26 orange + blue**,
  perforation holes rimmed in light. ~30% translucency in Composer.
- **L3 — punch + date:** `8 JUN 2026` **etched into the glass**, catching an amber
  caustic; a die-cut **Apple Park ring** punched in the stub.
- **Dark:** identical (designed dark-first); for the **clear/tinted** variant this icon is
  the showcase — verify the etched date survives mono.

---

## Generation order & checklist

For each icon: L1 → L2 → L3 ("matching the same ticket position and tilt as the previous
image") → assemble → check dark → check tinted mono → export.

- [ ] 21 layer renders (7 icons × 3 layers) + 7 dark Layer-1 swaps
- [ ] Ticket silhouette/tilt identical across all seven L2 renders
- [ ] Dates render exactly; venue lines render exactly
- [ ] Each stub punch reads at 60×60 pt (home-screen size) — if not, simplify the cut
- [ ] Tinted mono: ticket separates from canvas on every icon
- [ ] Replace `AppIcon*` asset sets + `IconPreview-*` images; previews should use the
      composed light rendering
