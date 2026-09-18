#!/usr/bin/env python3
"""Erzeugt die Pixel-Art-Assets fuer Neon Rush.

Benoetigt Pillow:
    python3 -m venv /tmp/assetvenv
    /tmp/assetvenv/bin/pip install pillow
    /tmp/assetvenv/bin/python tools/generate_assets.py
"""
from __future__ import annotations

import os
import random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

BG = (10, 8, 24, 255)
DEEP = (26, 16, 48, 255)
CONCRETE = (36, 33, 56, 255)
CONCRETE_LIGHT = (58, 54, 88, 255)
CONCRETE_DARK = (24, 22, 40, 255)
CYAN = (60, 240, 255, 255)
CYAN_DIM = (24, 120, 150, 255)
MAGENTA = (255, 60, 200, 255)
VIOLET = (150, 80, 255, 255)
YELLOW = (255, 214, 90, 255)
RED = (255, 70, 70, 255)
RED_DIM = (120, 30, 40, 255)
WHITE = (240, 245, 255, 255)
STEEL = (70, 76, 104, 255)
STEEL_DARK = (40, 44, 66, 255)

random.seed(7)


def save(img: Image.Image, *parts: str) -> None:
    path = os.path.join(ROOT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    print("geschrieben:", os.path.relpath(path, ROOT))


def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def mottle(img: Image.Image, box, color, chance=0.25) -> None:
    d = ImageDraw.Draw(img)
    for y in range(box[1], box[3]):
        for x in range(box[0], box[2]):
            if random.random() < chance:
                d.point((x, y), fill=color)


# ---------------------------------------------------------------- Tiles
TILE = 16


def tile_fill() -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, TILE - 1), fill=CONCRETE)
    mottle(img, (0, 0, TILE, TILE), CONCRETE_DARK, 0.22)
    mottle(img, (0, 0, TILE, TILE), CONCRETE_LIGHT, 0.10)
    d.rectangle((0, 0, TILE - 1, 1), fill=CONCRETE_LIGHT)
    d.rectangle((0, TILE - 1, TILE - 1, TILE - 1), fill=CONCRETE_DARK)
    return img


def tile_top() -> Image.Image:
    img = tile_fill()
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, 1), fill=CYAN)
    d.rectangle((0, 2, TILE - 1, 3), fill=CYAN_DIM)
    return img


def tile_panel(color) -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, TILE - 1), fill=DEEP)
    d.rectangle((1, 1, TILE - 2, TILE - 2), outline=color)
    d.rectangle((4, 4, TILE - 5, TILE - 5), outline=color)
    d.point((TILE // 2, TILE // 2), fill=WHITE)
    return img


def tile_crate() -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, TILE - 1), fill=(58, 48, 30, 255))
    d.rectangle((0, 0, TILE - 1, TILE - 1), outline=(120, 96, 48, 255))
    d.line((0, 0, TILE - 1, TILE - 1), fill=(120, 96, 48, 255))
    d.line((TILE - 1, 0, 0, TILE - 1), fill=(120, 96, 48, 255))
    d.rectangle((6, 6, 9, 9), fill=YELLOW)
    return img


def tile_pipe() -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, TILE - 1), fill=STEEL_DARK)
    d.rectangle((3, 0, 12, TILE - 1), fill=STEEL)
    d.rectangle((3, 0, 4, TILE - 1), fill=(110, 118, 150, 255))
    for y in (2, 8, 14):
        d.point((7, y), fill=CONCRETE_DARK)
        d.point((8, y), fill=CONCRETE_DARK)
    return img


def tile_spike() -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 12, TILE - 1, TILE - 1), fill=CONCRETE_DARK)
    for x in range(0, TILE, 4):
        d.polygon([(x, 12), (x + 2, 1), (x + 4, 12)], fill=RED_DIM)
        d.line((x + 2, 1, x + 1, 11), fill=RED)
    return img


def tile_bg() -> Image.Image:
    img = new(TILE, TILE)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, TILE - 1, TILE - 1), fill=(16, 12, 30, 255))
    for y in range(0, TILE, 4):
        for x in range(0, TILE, 8):
            off = 4 if (y // 4) % 2 else 0
            d.rectangle((x + off, y, x + off + 6, y + 2), outline=(24, 18, 42, 255))
    return img


def build_tiles() -> None:
    atlas = new(TILE * 8, TILE)
    order = [
        tile_fill(), tile_top(), tile_panel(VIOLET), tile_panel(CYAN),
        tile_crate(), tile_pipe(), tile_spike(), tile_bg(),
    ]
    for i, t in enumerate(order):
        atlas.paste(t, (i * TILE, 0))
    save(atlas, "assets", "tiles", "atlas.png")


# ---------------------------------------------------------------- Player
PF_W, PF_H = 24, 32


def draw_player(leg: int, arm: int, bob: int, lean: int, hurt: bool = False) -> Image.Image:
    img = new(PF_W, PF_H)
    d = ImageDraw.Draw(img)
    suit = (58, 24, 40, 255) if hurt else (34, 30, 58, 255)
    suit2 = (90, 34, 54, 255) if hurt else (48, 42, 80, 255)
    accent = RED if hurt else CYAN
    cx = PF_W // 2 + lean
    top = 3 + bob
    d.rectangle((cx - 5, top, cx + 4, top + 7), fill=suit)
    d.rectangle((cx - 5, top, cx + 4, top), fill=suit2)
    d.rectangle((cx - 4, top + 3, cx + 3, top + 4), fill=accent)
    d.rectangle((cx - 3, top + 3, cx + 1, top + 4), fill=WHITE)
    body_top = top + 8
    d.rectangle((cx - 4, body_top, cx + 3, body_top + 9), fill=suit)
    d.rectangle((cx - 4, body_top + 4, cx + 3, body_top + 5), fill=accent)
    d.rectangle((cx - 1, body_top, cx, body_top + 9), fill=accent)
    hip = body_top + 10
    lx = cx - 3 + leg
    rx = cx + 2 - leg
    d.rectangle((lx, hip, lx + 2, hip + 7), fill=suit2)
    d.rectangle((rx, hip, rx + 2, hip + 7), fill=suit2)
    d.rectangle((lx, hip + 7, lx + 2, hip + 8), fill=accent)
    d.rectangle((rx, hip + 7, rx + 2, hip + 8), fill=accent)
    ax = cx - 6
    bx = cx + 4
    d.rectangle((ax, body_top + 1 - arm, ax + 2, body_top + 5 - arm), fill=suit2)
    d.rectangle((bx, body_top + 1 + arm, bx + 2, body_top + 5 + arm), fill=suit2)
    return img


def build_player() -> None:
    cols, rows = 4, 5
    sheet = new(PF_W * cols, PF_H * rows)
    anims = {
        0: [(0, 0, 0, 0, 0), (0, 0, 1, 0, 0)],
        1: [(-3, 2, 0, 1, 0), (0, 0, -1, 1, 0), (3, -2, 0, 1, 0), (0, 0, -1, 1, 0)],
        2: [(-3, -4, -1, 0, 0), (-2, -4, 0, 0, 0)],
        3: [(3, 3, 0, 0, 0), (4, 2, -1, 0, 0)],
        4: [(2, -5, 1, -2, 1)],
    }
    for row, frames in anims.items():
        for col, f in enumerate(frames):
            sheet.paste(draw_player(*f), (col * PF_W, row * PF_H))
    save(sheet, "assets", "sprites", "player.png")


# ---------------------------------------------------------------- Enemies
def draw_walker(leg: int, eye: int) -> Image.Image:
    img = new(24, 24)
    d = ImageDraw.Draw(img)
    d.rectangle((4, 6, 19, 16), fill=STEEL_DARK)
    d.rectangle((4, 6, 19, 7), fill=STEEL)
    d.rectangle((7, 9, 16, 12), fill=(20, 16, 34, 255))
    d.rectangle((7 + eye, 10, 10 + eye, 11), fill=RED)
    d.rectangle((16, 9, 17, 11), fill=YELLOW)
    d.rectangle((6, 16, 8, 21 + leg), fill=STEEL)
    d.rectangle((15, 16, 17, 21 - leg), fill=STEEL)
    d.rectangle((4, 6, 19, 6), fill=CYAN_DIM)
    return img


def build_walker() -> None:
    sheet = new(24 * 4, 24)
    for i, (leg, eye) in enumerate([(-2, 0), (0, 1), (2, 0), (0, -1)]):
        sheet.paste(draw_walker(leg, eye), (i * 24, 0))
    save(sheet, "assets", "sprites", "walker.png")


def draw_drone(bob: int, rotor: int) -> Image.Image:
    img = new(24, 24)
    d = ImageDraw.Draw(img)
    y = 6 + bob
    d.rectangle((3, y, 20, y + 1), fill=STEEL)
    d.rectangle((8 - rotor, y - 1, 8, y), fill=CYAN)
    d.rectangle((15, y - 1, 15 + rotor, y), fill=CYAN)
    d.rectangle((7, y + 2, 16, y + 10), fill=STEEL_DARK)
    d.rectangle((9, y + 4, 14, y + 7), fill=(20, 16, 34, 255))
    d.rectangle((10, y + 5, 13, y + 6), fill=RED)
    d.point((11, y + 12), fill=RED)
    return img


def build_drone() -> None:
    sheet = new(24 * 4, 24)
    for i, (bob, rotor) in enumerate([(0, 2), (-1, 4), (0, 7), (-1, 4)]):
        sheet.paste(draw_drone(bob, rotor), (i * 24, 0))
    save(sheet, "assets", "sprites", "drone.png")


def draw_boss(open_amount: int, charge: bool) -> Image.Image:
    img = new(48, 48)
    d = ImageDraw.Draw(img)
    core = YELLOW if charge else RED
    d.rectangle((6, 10, 41, 36), fill=STEEL_DARK)
    d.rectangle((6, 10, 41, 12), fill=STEEL)
    d.rectangle((9, 14, 38, 32), fill=(24, 20, 40, 255))
    d.rectangle((16, 18, 31, 30), outline=CYAN_DIM)
    d.ellipse((17, 19, 30, 29), fill=(12, 8, 22, 255))
    d.ellipse((19, 21, 28, 27), fill=core)
    d.ellipse((21, 22, 26, 25), fill=WHITE)
    for side in (2, 40):
        d.rectangle((side, 12, side + 5, 34), fill=STEEL)
        d.rectangle((side, 12 + open_amount, side + 5, 16 + open_amount), fill=CYAN)
    d.rectangle((14, 33, 33, 36), fill=(30, 24, 48, 255))
    for x in range(15, 33, 4):
        d.rectangle((x, 33, x + 1, 35), fill=core)
    d.rectangle((10, 36, 37, 39), fill=STEEL_DARK)
    d.rectangle((18, 4, 29, 9), fill=STEEL)
    d.point((24, 3), fill=core)
    return img


def build_boss() -> None:
    sheet = new(48 * 4, 48)
    for i, (o, c) in enumerate([(0, False), (4, False), (8, True), (0, True)]):
        sheet.paste(draw_boss(o, c), (i * 48, 0))
    save(sheet, "assets", "sprites", "boss.png")


# ---------------------------------------------------------------- Objects
def draw_chip(scale: int) -> Image.Image:
    img = new(12, 12)
    d = ImageDraw.Draw(img)
    w = 1 + scale
    d.polygon([(6, 6 - w - 1), (6 + w, 6), (6, 6 + w + 1), (6 - w, 6)], fill=CYAN)
    d.polygon([(6, 6 - w), (6 + w - 1, 6), (6, 6 + w), (6 - w + 1, 6)], fill=WHITE)
    d.point((6, 6), fill=YELLOW)
    return img


def build_chip() -> None:
    sheet = new(12 * 6, 12)
    for i, s in enumerate([1, 3, 5, 3, 1, 0]):
        sheet.paste(draw_chip(s), (i * 12, 0))
    save(sheet, "assets", "sprites", "chip.png")


def draw_checkpoint(on: bool) -> Image.Image:
    img = new(16, 24)
    d = ImageDraw.Draw(img)
    d.rectangle((6, 6, 9, 23), fill=STEEL_DARK)
    d.rectangle((6, 6, 9, 7), fill=STEEL)
    lamp = MAGENTA if on else (70, 64, 90, 255)
    d.rectangle((3, 1, 12, 7), fill=STEEL_DARK)
    d.rectangle((4, 2, 11, 6), fill=lamp)
    if on:
        d.rectangle((5, 3, 10, 5), fill=WHITE)
    return img


def build_checkpoint() -> None:
    sheet = new(16 * 2, 24)
    sheet.paste(draw_checkpoint(False), (0, 0))
    sheet.paste(draw_checkpoint(True), (16, 0))
    save(sheet, "assets", "sprites", "checkpoint.png")


def draw_terminal(frame: int) -> Image.Image:
    img = new(24, 32)
    d = ImageDraw.Draw(img)
    d.rectangle((2, 4, 21, 24), fill=STEEL_DARK)
    d.rectangle((2, 4, 21, 5), fill=STEEL)
    d.rectangle((4, 7, 19, 20), fill=(10, 30, 34, 255))
    for i in range(3):
        y = 9 + i * 3
        w = 4 + ((frame + i * 3) % 9)
        d.rectangle((5, y, 5 + w, y + 1), fill=CYAN)
    d.rectangle((4, 7, 19, 7), fill=CYAN_DIM)
    d.rectangle((5, 25, 18, 26), fill=STEEL)
    d.rectangle((9, 27, 14, 30), fill=STEEL_DARK)
    d.point((12, 22), fill=YELLOW)
    return img


def build_terminal() -> None:
    sheet = new(24 * 4, 32)
    for i in range(4):
        sheet.paste(draw_terminal(i), (i * 24, 0))
    save(sheet, "assets", "sprites", "terminal.png")


# ---------------------------------------------------------------- Parallax
def build_parallax() -> None:
    w, h = 1280, 720

    sky = new(w, h)
    d = ImageDraw.Draw(sky)
    for y in range(h):
        t = y / (h - 1)
        r = int(8 + t * 36)
        g = int(6 + t * 10)
        b = int(22 + t * 58)
        d.line((0, y, w - 1, y), fill=(r, g, b, 255))
    for _ in range(320):
        x, y = random.randrange(w), random.randrange(h * 3 // 4)
        c = random.choice([WHITE, CYAN, VIOLET])
        d.point((x, y), fill=c)
    d.ellipse((940, 70, 1100, 230), fill=(60, 20, 70, 255))
    d.ellipse((952, 82, 1088, 218), fill=(120, 40, 120, 255))
    d.ellipse((970, 100, 1070, 200), fill=(255, 120, 220, 255))
    for y in range(360, h):
        d.line((0, y, w - 1, y), fill=(40, 14, 60, 255) if y % 2 else (30, 12, 50, 255))
    save(sky, "assets", "parallax", "sky.png")

    def layer(color, win_color, min_w, max_w, min_h, max_h, lights, seed, signs=0):
        rnd = random.Random(seed)
        img = new(w, h)
        dd = ImageDraw.Draw(img)
        x = 0
        boxes = []
        while x < w:
            bw = rnd.randint(min_w, max_w)
            bh = rnd.randint(min_h, max_h)
            boxes.append((x, h - bh, x + bw, h))
            x += bw + rnd.randint(8, 30)
        for bx in boxes:
            dd.rectangle(bx, fill=color)
            if rnd.random() < 0.5:
                dd.rectangle((bx[0] + 8, bx[1] - 12, bx[0] + 14, bx[1]), fill=color)
        for _ in range(lights):
            bx = rnd.choice(boxes)
            lx = rnd.randint(bx[0] + 2, max(bx[0] + 3, bx[2] - 3))
            ly = rnd.randint(bx[1] + 6, h - 6)
            dd.point((lx, ly), fill=win_color)
            dd.point((lx, ly + 1), fill=win_color)
        for _ in range(signs):
            x0 = rnd.randrange(w)
            y0 = rnd.randrange(h - 260, h - 80)
            col = rnd.choice([MAGENTA, CYAN, YELLOW, VIOLET])
            dd.rectangle((x0, y0, x0 + rnd.randint(24, 70), y0 + 9), outline=col)
            dd.rectangle((x0 + 2, y0 + 2, x0 + rnd.randint(20, 60), y0 + 7), fill=col)
        img.paste(img.crop((0, 0, 32, h)), (w - 32, 0))
        return img

    save(layer((18, 12, 38), VIOLET, 44, 96, 90, 320, 130, 11),
         "assets", "parallax", "far.png")
    save(layer((28, 20, 54), CYAN, 56, 120, 180, 480, 240, 22, 3),
         "assets", "parallax", "mid.png")
    save(layer((10, 7, 22), MAGENTA, 150, 320, 120, 300, 60, 33, 7),
         "assets", "parallax", "near.png")


# ---------------------------------------------------------------- FX
def radial(size: int, inner, outer) -> Image.Image:
    img = new(size, size)
    px = img.load()
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            dist = ((x - c) ** 2 + (y - c) ** 2) ** 0.5 / c
            a = max(0.0, 1.0 - dist)
            a = a ** 1.7
            r = int(inner[0] * a + outer[0] * (1 - a))
            g = int(inner[1] * a + outer[1] * (1 - a))
            b = int(inner[2] * a + outer[2] * (1 - a))
            px[x, y] = (r, g, b, int(255 * a))
    return img


def build_fx() -> None:
    save(radial(16, (255, 255, 255), (60, 240, 255)), "assets", "fx", "particle.png")
    save(radial(32, (255, 255, 255), (150, 80, 255)), "assets", "fx", "glow.png")
    spark = new(8, 8)
    ds = ImageDraw.Draw(spark)
    ds.line((0, 4, 7, 4), fill=WHITE)
    ds.line((2, 3, 5, 5), fill=CYAN)
    save(spark, "assets", "fx", "spark.png")
    rain = Image.new("RGBA", (2, 12), (0, 0, 0, 0))
    dr = ImageDraw.Draw(rain)
    dr.line((1, 0, 1, 11), fill=(120, 200, 255, 150))
    save(rain, "assets", "fx", "rain.png")


def build_icon() -> None:
    img = new(64, 64)
    d = ImageDraw.Draw(img)
    d.rectangle((2, 2, 61, 61), fill=(10, 8, 24, 255), outline=CYAN)
    d.polygon([(32, 10), (52, 32), (32, 54), (12, 32)], fill=VIOLET)
    d.polygon([(32, 18), (45, 32), (32, 46), (19, 32)], fill=MAGENTA)
    d.polygon([(32, 26), (38, 32), (32, 38), (26, 32)], fill=WHITE)
    save(img, "assets", "icon.png")


def main() -> None:
    build_tiles()
    build_player()
    build_walker()
    build_drone()
    build_boss()
    build_chip()
    build_checkpoint()
    build_terminal()
    build_parallax()
    build_fx()
    build_icon()
    print("Bild-Assets fertig.")


if __name__ == "__main__":
    main()
