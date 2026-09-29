#!/usr/bin/env python3
"""Generates the original ValVN launcher icon (no Riot/Valorant artwork).

Design: a bold, symmetric "V" chevron in ValVN red (#FF4655) with a small
five-pointed star in the notch (a nod to "VN"), on the app's dark navy
(#0F1923) with a subtle diagonal sheen.

Outputs (1024 x 1024):
  assets/icon/icon.png            full-bleed icon (iOS, legacy Android)
  assets/icon/icon_foreground.png adaptive-icon foreground (transparent,
                                  same artwork; flutter_launcher_icons
                                  insets it 16% into the safe zone)
  assets/icon/icon_monochrome.png Android 13 themed-icon mask (white)
  android/app/src/main/res/drawable-*/ic_stat_valvn.png
                                  white status-bar notification icon

Requires Pillow: `pip install pillow`, then `python3 tool/generate_icon.py`
and `dart run flutter_launcher_icons`.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
SS = 4  # supersampling factor for smooth edges
RED = (255, 70, 85, 255)
NAVY = (15, 25, 35, 255)
NAVY_LIGHT = (27, 40, 53, 255)
STAR = (236, 232, 225, 255)
WHITE = (255, 255, 255, 255)
STAT_SIZES = {'mdpi': 24, 'hdpi': 36, 'xhdpi': 48, 'xxhdpi': 72, 'xxxhdpi': 96}

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'assets', 'icon')

# Artwork in 1024-space, centred around (512, 520).
V_SHAPE = [
    (220, 250), (385, 250), (512, 600), (639, 250), (804, 250),
    (584, 800), (440, 800),
]
STAR_CENTER = (512, 372)
STAR_OUTER = 64
STAR_INNER = 26


def star_points(cx, cy, r_out, r_in):
    pts = []
    for i in range(10):
        r = r_out if i % 2 == 0 else r_in
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def transform(points, scale, center=(512, 525)):
    cx, cy = center
    return [
        ((512 + (x - cx) * scale) * SS, (512 + (y - cy) * scale) * SS)
        for x, y in points
    ]


def draw_artwork(img, scale, shadow=True, v_fill=RED, star_fill=STAR):
    if not shadow:
        # Flat silhouette (masks / status-bar icon): the V alone.
        ImageDraw.Draw(img).polygon(transform(V_SHAPE, scale), fill=v_fill)
        return
    d = ImageDraw.Draw(img)
    # Soft drop shadow under the V for depth.
    shadow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ds = ImageDraw.Draw(shadow)
    ds.polygon(
        [(x, y + 14 * SS * scale) for x, y in transform(V_SHAPE, scale)],
        fill=(0, 0, 0, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(18 * SS * scale))
    img.alpha_composite(shadow)
    d = ImageDraw.Draw(img)
    d.polygon(transform(V_SHAPE, scale), fill=v_fill)
    d.polygon(
        transform(star_points(*STAR_CENTER, STAR_OUTER, STAR_INNER), scale),
        fill=star_fill,
    )


def background():
    big = SIZE * SS
    img = Image.new('RGBA', (big, big), NAVY)
    d = ImageDraw.Draw(img)
    # Diagonal lighter band (top-left → bottom-right) for a subtle sheen.
    band = [(0, big * 0.18), (big * 0.18, 0), (big * 0.62, 0), (0, big * 0.62)]
    overlay = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    ImageDraw.Draw(overlay).polygon(band, fill=NAVY_LIGHT)
    overlay = overlay.filter(ImageFilter.GaussianBlur(40 * SS))
    img.alpha_composite(overlay)
    # Thin red accent bar along the bottom edge.
    d = ImageDraw.Draw(img)
    d.rectangle([big * 0.40, big * 0.905, big * 0.60, big * 0.915], fill=RED)
    return img


def main():
    os.makedirs(OUT, exist_ok=True)

    full = background()
    draw_artwork(full, 1.0)
    full = full.resize((SIZE, SIZE), Image.LANCZOS).convert('RGB')
    full.save(os.path.join(OUT, 'icon.png'), optimize=True)

    fg = Image.new('RGBA', (SIZE * SS, SIZE * SS), (0, 0, 0, 0))
    draw_artwork(fg, 1.0)
    fg = fg.resize((SIZE, SIZE), Image.LANCZOS)
    fg.save(os.path.join(OUT, 'icon_foreground.png'), optimize=True)

    # Monochrome mask: a solid white V; the star is left out (it would
    # merge with the V at small sizes).
    mono = Image.new('RGBA', (SIZE * SS, SIZE * SS), (0, 0, 0, 0))
    draw_artwork(mono, 1.0, shadow=False, v_fill=WHITE)
    mono = mono.resize((SIZE, SIZE), Image.LANCZOS)
    mono.save(os.path.join(OUT, 'icon_monochrome.png'), optimize=True)

    # Notification (status bar) icon: white V filling a 24dp box.
    stat = Image.new('RGBA', (SIZE * SS, SIZE * SS), (0, 0, 0, 0))
    draw_artwork(stat, 1.45, shadow=False, v_fill=WHITE)
    stat = stat.resize((SIZE, SIZE), Image.LANCZOS)
    res = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
    for density, px in STAT_SIZES.items():
        folder = os.path.join(res, 'drawable-' + density)
        os.makedirs(folder, exist_ok=True)
        stat.resize((px, px), Image.LANCZOS).save(
            os.path.join(folder, 'ic_stat_valvn.png'), optimize=True
        )
    print('Wrote icons to', OUT, 'and ic_stat_valvn.png to', res)


if __name__ == '__main__':
    main()
