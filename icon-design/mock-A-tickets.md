# Mock A — Fanned Conference Tickets

iOS app icon for **iOS-Conferences** — an indie aggregator app that lists upcoming
developer/tech conferences sorted by date.

**Output format:** flat **square** 1024×1024 image (no rounded corners — iOS applies
the corner radius at display time). No drop shadow extending beyond the canvas edge.

## Prompt

A square 1024×1024 iOS app icon, rendered as a flat square (no rounded corners).
Apple "blueprint" family style — bright blue gradient background going from lighter
sky-blue in the top-left (#5FA8FF) through mid-blue (#2C7BEE) to a deeper blue in
the bottom-right (#1457C8). A faint white grid overlays the whole background, with
a finer 64px grid and a stronger 256px grid on top, both at low opacity (~15–20%).
Subtle white concentric guide circles centred on the canvas (radii ~200, 300, 400),
plus a horizontal and vertical centre line and small white corner-registration
ticks in each corner — all at low opacity, evoking a draftsman's blueprint.

Centred on the canvas: three event tickets fanned out like a hand of cards. Each
ticket is a horizontal rectangle (~700×320), warm off-white body (cream
#FCF7EB → #E0D7C0 gradient), with a vertical perforated stub on the right side
filled in vibrant warm orange (#FF8A5C → #D9521D gradient). The perforation is a
dashed line in dark brown. The stub displays the date "**26**" in a large bold
sans-serif and "**JUN**" below it in smaller letter-spaced caps, both in warm cream.
The ticket body shows: a thick dark horizontal title bar at the top (representing
the event name), two thinner lines below it (subtitle / venue), and a black
barcode pattern across the lower half. Each ticket has a soft top sheen for a
slight 3D feel.

The three tickets are rotated and overlapped so all three read at once: back
ticket rotated ~+14° (peeking out to the right), middle ticket rotated ~-2°
(barely visible spine on the left), front ticket rotated ~-16° (most prominent,
showing the full barcode-and-title face). Stack centred slightly above the
canvas mid-line. Beneath the stack, a soft elliptical ground shadow on the
blueprint surface (dark, blurred, fading outward).

Overall feel: indie, friendly, a touch playful — clearly says "events you can
attend" without resembling Apple's stock Calendar, Wallet, or Developer app.

## Palette

| Element              | Colour(s)                                              |
|----------------------|--------------------------------------------------------|
| Background gradient  | `#5FA8FF` → `#2C7BEE` → `#1457C8`                      |
| Grid lines           | `#FFFFFF` at ~16–20% opacity                           |
| Compass / ticks      | `#FFFFFF` at ~18–30% opacity                           |
| Ticket body          | `#FCF7EB` → `#E0D7C0`                                  |
| Ticket stub          | `#FF8A5C` → `#D9521D`                                  |
| Perforation          | `#7A5A3A` dashed                                        |
| Ticket text / lines  | `#2B2218`                                              |
| Stub date / "JUN"    | `#FFF4E6`                                              |
| Ground shadow        | `#000` at ~40–55% in centre, fading to 0 at edges       |

## Composition

- Canvas: **1024 × 1024**, square fill, no rounded mask.
- Tickets grouped at canvas centre, slightly above (centre at ~`(512, 540)`).
- Ticket dimensions: `700 × 320` each.
- Fan rotations: back `+14°`, middle `-2°`, front `-16°`.
- Ground shadow: `cx=512 cy=850 rx=380 ry=46`, radial fade.

## Source

`mock-A-tickets.svg` (in this folder) renders this design directly.

To re-render to PNG:

```sh
qlmanage -t -s 1024 -o . mock-A-tickets.svg && \
  magick mock-A-tickets.svg.png -resize 1024x1024 mock-A-tickets.png && \
  rm mock-A-tickets.svg.png
```
