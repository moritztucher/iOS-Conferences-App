# Default "Tickets" icon — layer generation prompts (Icon Composer)

Final layer structure for the default icon (18 May 2026 · First commit): **one complete
ticket per layer**, each with its own print baked in — no cross-layer print-alignment
risk. Background (warm charcoal + marigold top glow) is defined as a fill in Icon
Composer, not as artwork.

Assembly, bottom to top: Layer 1 → 2 → 3 → 4. No contact shadows are baked into the
artwork — Icon Composer generates inter-layer depth and specular itself.

Shared geometry: 1024×1024 canvas, x left→right, y top→bottom, origin top-left. Every
ticket is a horizontal rounded rectangle 640×280 px, 36 px corner radius.

---

## Layer 1 — rearmost cream ticket (complete, with print)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of warm cream paper (#F2EAD9): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (438, 412), rotated 32 degrees with its right end raised and its left end lowered. Very subtle paper grain and a faint warm-white highlight along its top edge so the paper reads slightly thick.

The ticket carries quiet printing in a soft warm gray ink (#B9AE9C), rotated together with the ticket:
1. One thin horizontal rule, 4 pixels thick, spanning 70% of the ticket's width, centered horizontally, sitting 64 pixels below the ticket's top edge.
2. One small barcode of about 24 thin vertical bars with irregular spacing, 96 pixels wide and 40 pixels tall, in the ticket's top-right corner area, inset 40 pixels from its top edge and 48 pixels from its right edge.

Nothing else: no other text, no perforation, no stub. No shadow is cast onto the transparent background, and nothing touches the canvas edges. Output as a transparent-background PNG.

---

## Layer 2 — middle cream ticket (complete, with print)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of warm cream paper (#F2EAD9): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (462, 442), rotated 24 degrees with its right end raised and its left end lowered. Very subtle paper grain and a faint warm-white highlight along its top edge.

The ticket carries the same quiet printing in soft warm gray ink (#B9AE9C), rotated together with the ticket:
1. One thin horizontal rule, 4 pixels thick, spanning 70% of the ticket's width, centered horizontally, 64 pixels below the ticket's top edge.
2. One small barcode of about 24 thin vertical bars with irregular spacing, 96 pixels wide and 40 pixels tall, in the top-right corner area, inset 40 pixels from the top edge and 48 pixels from the right edge.

Nothing else: no other text, no perforation, no stub. No shadow onto the transparent background; nothing touches the canvas edges. Output as a transparent-background PNG.

---

## Layer 3 — front cream ticket (complete, with print)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of warm cream paper (#F2EAD9): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (488, 472), rotated 16 degrees with its right end raised and its left end lowered. Very subtle paper grain and a faint warm-white highlight along its top edge.

The ticket carries the same quiet printing in soft warm gray ink (#B9AE9C), rotated together with the ticket:
1. One thin horizontal rule, 4 pixels thick, spanning 70% of the ticket's width, centered horizontally, 64 pixels below the ticket's top edge.
2. One small barcode of about 24 thin vertical bars with irregular spacing, 96 pixels wide and 40 pixels tall, in the top-right corner area, inset 40 pixels from the top edge and 48 pixels from the right edge.

Nothing else: no other text, no perforation, no stub. No shadow onto the transparent background; nothing touches the canvas edges. Output as a transparent-background PNG.

---

## Layer 4 — marigold lead ticket (complete, with print)

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains exactly one event ticket made of warm marigold paper (#F2A33C): a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, centered at (512, 596), rotated 8 degrees with its right end raised and its left end lowered. Subtle paper grain and a faint lighter highlight along its top edge.

The ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing the transparent background. Between the two notches runs a dashed perforation line in a slightly darker marigold (#D9892F): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

The ticket's printing is in deep warm charcoal ink (#2A2118), rotated together with the ticket:

On the stub, horizontally centered in its 192-pixel width, a vertical stack of three text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
1. The word "MAY" — uppercase, bold sans-serif, letters 40 pixels tall, wide letter-spacing.
2. The number "18" — very heavy, rounded numeral style, digits 140 pixels tall, the focal point of the entire icon.
3. The year "2026" — medium-weight sans-serif, digits 32 pixels tall.

On the body, one barcode of about 28 thin vertical bars with irregular spacing, 250 pixels wide and 72 pixels tall, placed in the body's lower-left area: 56 pixels in from the ticket's left edge and 44 pixels up from its bottom edge.

Nothing else: no rules, no shadows, no outlines. Verify the text reads exactly "MAY", "18", and "2026". Output as a transparent-background PNG.

---

## Single-layer variant — all four tickets flattened

For the one-layer fallback (or quick previews), bake everything into a single PNG. Because Icon Composer can't generate inter-layer depth for a flat image, soft contact shadows between the tickets ARE baked in here (still no shadow onto the transparent canvas itself).

A square 1024×1024 PNG with a fully transparent background. Coordinates: x runs left to right, y runs top to bottom, origin at the top-left corner.

The image contains a loose fanned stack of four event tickets. Every ticket is a horizontal rounded rectangle 640 pixels wide and 280 pixels tall with 36-pixel rounded corners, rotated with its right end raised and its left end lowered. Drawn rear to front, each ticket fully occluding the ones behind it where they overlap:

1. Rearmost ticket: warm cream paper (#F2EAD9), centered at (438, 412), rotated 32 degrees.
2. Second ticket: warm cream paper (#F2EAD9), centered at (462, 442), rotated 24 degrees.
3. Third ticket: warm cream paper (#F2EAD9), centered at (488, 472), rotated 16 degrees.
4. Front ticket: warm marigold paper (#F2A33C), centered at (512, 596), rotated 8 degrees.

All tickets have very subtle paper grain and a faint warm-white highlight along their top edges. Each ticket casts a very soft, short warm-dark shadow only onto the ticket directly beneath it — never onto the transparent background.

Each of the three cream tickets carries quiet printing in a soft warm gray ink (#B9AE9C), rotated together with its ticket (visible only where not covered by tickets in front):
- One thin horizontal rule, 4 pixels thick, spanning 70% of the ticket's width, centered horizontally, 64 pixels below the ticket's top edge.
- One small barcode of about 24 thin vertical bars with irregular spacing, 96 pixels wide and 40 pixels tall, in the top-right corner area, inset 40 pixels from the top edge and 48 pixels from the right edge.

The front marigold ticket has a perforated stub on its right end. Measured along the ticket's own width, a vertical perforation seam crosses it 448 pixels from its left edge, so the body is the left 448 pixels and the stub is the right 192 pixels. At the seam, two semicircular notches of 22-pixel radius are punched into the ticket — one into the top edge, one into the bottom edge, both centered exactly on the seam line — and these notch holes are truly cut through, showing whatever lies behind them (a cream ticket or transparency). Between the two notches runs a dashed perforation line in a slightly darker marigold (#D9892F): 3 pixels thick, dashes 10 pixels long with 12-pixel gaps.

The marigold ticket's printing is in deep warm charcoal ink (#2A2118), rotated together with the ticket:

On the stub, horizontally centered in its 192-pixel width, a vertical stack of three text elements, the stack as a whole vertically centered in the ticket's 280-pixel height, with 14 pixels of space between elements:
1. The word "MAY" — uppercase, bold sans-serif, letters 40 pixels tall, wide letter-spacing.
2. The number "18" — very heavy, rounded numeral style, digits 140 pixels tall, the focal point of the entire icon.
3. The year "2026" — medium-weight sans-serif, digits 32 pixels tall.

On the body, one barcode of about 28 thin vertical bars with irregular spacing, 250 pixels wide and 72 pixels tall, placed in the body's lower-left area: 56 pixels in from the ticket's left edge and 44 pixels up from its bottom edge.

Nothing else. Nothing touches the canvas edges. Verify the text reads exactly "MAY", "18", and "2026". Output as a transparent-background PNG.

---

## Icon Composer background fill

Linear gradient, top → bottom:
- Top: **#45331D** (warm charcoal lifted toward marigold — the "top glow")
- Bottom: **#241B11** (deep warm charcoal)

If only a solid color is wanted: **#2A2118** (the same warm charcoal as the lead ticket's ink — keeps the palette to paper-cream, marigold, and one charcoal).
