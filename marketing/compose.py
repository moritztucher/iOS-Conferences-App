#!/usr/bin/env python3
"""Compose App Store marketing screenshots (1242 x 2688, 6.5" display).

Each output = brand background + headline caption + device-framed real screenshot.
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

W, H = 1242, 2688
RAW = os.path.join(os.path.dirname(__file__), "raw")
OUT = os.path.join(os.path.dirname(__file__), "out")
os.makedirs(OUT, exist_ok=True)

SF_BOLD = "/System/Library/Fonts/SFNS.ttf"
SF_ROUND = "/System/Library/Fonts/SFNSRounded.ttf"

def font(path, size):
    return ImageFont.truetype(path, size)

# App-aligned palette (dark, ecosystem-native; accent per slide for variety)
BG_TOP = (18, 18, 20)
BG_BOT = (8, 8, 10)

SLIDES = [
    {
        "img": "01-list.png",
        "line1": "Every Apple dev",
        "line2": "conference, sorted by date",
        "accent": (10, 122, 255),   # system blue
    },
    {
        "img": "04-filter.png",
        "line1": "Conferences, watch parties",
        "line2": "& community events",
        "accent": (191, 90, 242),   # purple
    },
    {
        "img": "02-detail.png",
        "line1": "Dates, location &",
        "line2": "add to your calendar",
        "accent": (48, 209, 88),    # green
    },
    {
        "img": "03-settings.png",
        "line1": "Free, open &",
        "line2": "community-curated",
        "accent": (255, 69, 58),    # red
    },
]

def vertical_gradient(w, h, top, bot):
    base = Image.new("RGB", (w, h), top)
    draw = ImageDraw.Draw(base)
    for y in range(h):
        t = y / max(1, h - 1)
        r = int(top[0] + (bot[0] - top[0]) * t)
        g = int(top[1] + (bot[1] - top[1]) * t)
        b = int(top[2] + (bot[2] - top[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return base

def accent_glow(canvas, accent):
    """Soft radial accent glow behind the phone top area."""
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx, cy = W // 2, int(H * 0.46)
    rad = 760
    gd.ellipse([cx - rad, cy - rad, cx + rad, cy + rad],
               fill=accent + (60,))
    glow = glow.filter(ImageFilter.GaussianBlur(220))
    canvas.alpha_composite(glow)

def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, img.size[0], img.size[1]], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out

def device_frame(shot, target_w):
    """Wrap a screenshot in a thin dark bezel with rounded corners."""
    sw, sh = shot.size
    scale = target_w / sw
    new_w = target_w
    new_h = int(sh * scale)
    shot = shot.resize((new_w, new_h), Image.LANCZOS)

    bezel = 18
    corner = 96
    fw, fh = new_w + bezel * 2, new_h + bezel * 2
    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    # bezel body
    body = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    bd.rounded_rectangle([0, 0, fw, fh], radius=corner + bezel, fill=(28, 28, 30, 255))
    frame.alpha_composite(body)
    # screen (rounded)
    screen = rounded(shot, corner)
    frame.alpha_composite(screen, (bezel, bezel))
    return frame

def shadowed(canvas, frame, x, y):
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    fw, fh = frame.size
    sd.rounded_rectangle([x, y + 26, x + fw, y + fh + 26], radius=110, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(46))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(frame, (x, y))

def draw_caption(canvas, line1, line2, accent):
    d = ImageDraw.Draw(canvas)
    f = font(SF_BOLD, 96)
    # accent pill
    pill_y = 150
    d.rounded_rectangle([W//2 - 60, pill_y, W//2 + 60, pill_y + 12], radius=6, fill=accent + (255,))
    y = 230
    for line in (line1, line2):
        bbox = d.textbbox((0, 0), line, font=f)
        tw = bbox[2] - bbox[0]
        d.text(((W - tw) // 2, y), line, font=f, fill=(245, 245, 247, 255))
        y += 112
    return y

def compose(slide, idx):
    canvas = vertical_gradient(W, H, BG_TOP, BG_BOT).convert("RGBA")
    accent_glow(canvas, slide["accent"])
    draw_caption(canvas, slide["line1"], slide["line2"], slide["accent"])

    shot = Image.open(os.path.join(RAW, slide["img"])).convert("RGBA")
    frame = device_frame(shot, target_w=900)
    fw, fh = frame.size
    x = (W - fw) // 2
    y = 560
    shadowed(canvas, frame, x, y)

    out_path = os.path.join(OUT, f"{idx:02d}-{slide['img'].split('-',1)[1]}")
    canvas.convert("RGB").save(out_path, "PNG")
    w, h = canvas.size
    print(f"wrote {out_path}  {w}x{h}")

for i, s in enumerate(SLIDES, 1):
    compose(s, i)
print("done")
