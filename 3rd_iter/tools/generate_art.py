#!/usr/bin/env python3
"""Deterministic, layered transit-sector SVG art. Python standard library only."""
from pathlib import Path
import random

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "environments" / "district_01"
RNG = random.Random(170926)
WIDTH, HEIGHT = 3840, 960
DEFS = '''<defs>
<linearGradient id="sky" x2="0" y2="1"><stop stop-color="#101923"/><stop offset=".54" stop-color="#35434d"/><stop offset="1" stop-color="#151f2c"/></linearGradient>
<linearGradient id="tower" x2="1" y2="0"><stop stop-color="#141f29"/><stop offset=".12" stop-color="#25323a"/><stop offset=".78" stop-color="#1c2932"/><stop offset="1" stop-color="#101923"/></linearGradient>
<linearGradient id="concrete" x2="1" y2="0"><stop stop-color="#151c22"/><stop offset=".08" stop-color="#39434a"/><stop offset=".32" stop-color="#2d373d"/><stop offset="1" stop-color="#171f28"/></linearGradient>
<linearGradient id="metal" x2="0" y2="1"><stop stop-color="#47545b"/><stop offset=".15" stop-color="#222d33"/><stop offset=".65" stop-color="#151c24"/><stop offset="1" stop-color="#080f17"/></linearGradient>
<linearGradient id="pipe" x2="1" y2="0"><stop stop-color="#0c131b"/><stop offset=".36" stop-color="#4a5559"/><stop offset=".55" stop-color="#333f43"/><stop offset="1" stop-color="#101821"/></linearGradient>
<linearGradient id="haze" x2="0" y2="1"><stop stop-color="#71878c" stop-opacity="0"/><stop offset=".6" stop-color="#71878c" stop-opacity=".14"/><stop offset="1" stop-color="#71878c" stop-opacity="0"/></linearGradient>
<linearGradient id="abyss" x2="0" y2="1"><stop stop-color="#283b47" stop-opacity="0"/><stop offset=".62" stop-color="#425661" stop-opacity=".48"/><stop offset="1" stop-color="#0f1d2b" stop-opacity=".8"/></linearGradient>
<linearGradient id="beam" x2="0" y2="1"><stop stop-color="#9ab7c4" stop-opacity=".1"/><stop offset="1" stop-color="#7d9fb5" stop-opacity="0"/></linearGradient>
<radialGradient id="violet"><stop stop-color="#ac8cff" stop-opacity=".23"/><stop offset=".22" stop-color="#8161d0" stop-opacity=".1"/><stop offset="1" stop-color="#7451be" stop-opacity="0"/></radialGradient>
<radialGradient id="lamp"><stop stop-color="#f0c893" stop-opacity=".22"/><stop offset="1" stop-color="#d9b280" stop-opacity="0"/></radialGradient>
</defs>'''


def rect(x, y, w, h, fill, extra=""):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" {extra}/>'


def line(x1, y1, x2, y2, color, width=1, extra=""):
    return f'<path d="M{x1} {y1}L{x2} {y2}" fill="none" stroke="{color}" stroke-width="{width}" {extra}/>'


def path(d, color, width=1, fill="none", extra=""):
    return f'<path d="{d}" fill="{fill}" stroke="{color}" stroke-width="{width}" {extra}/>'


def circle(x, y, r, fill, extra=""):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" {extra}/>'


def save(name, parts):
    target = OUT / name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">{DEFS}' + ''.join(parts) + '</svg>\n')


def pipe(x, y, height, width=22):
    parts = [rect(x, y, width, height, 'url(#pipe)')]
    for yy in range(y + 20, y + height, 90):
        parts += [rect(x - 3, yy, width + 6, 7, '#111a23'), line(x - 3, yy, x + width + 3, yy, '#51606a')]
    return ''.join(parts)


def weathering(x, y, w, h, count=60):
    result = []
    for _ in range(count):
        xx, yy = RNG.randint(x, x + w), RNG.randint(y, y + h)
        result.append(line(xx, yy, xx, min(y + h, yy + RNG.randint(3, 90)), '#060d16', RNG.choice([1, 2, 3]), 'opacity=".23"'))
    return ''.join(result)


def platform(x, y, w):
    p = [rect(x, y + 3, w, 30, 'url(#metal)'), rect(x, y, w, 5, '#6c7b7e'), line(x, y + 6, x + w, y + 6, '#a8b8b6', 1, 'opacity=".5"')]
    for xx in range(x + 10, x + w - 5, 23):
        p += [line(xx, y + 12, xx + 9, y + 12, '#526069'), circle(xx + 4, y + 24, 1.5, '#67737a')]
    p += [rect(x, y + 34, w, 11, '#080f17'), line(x, y + 45, x + w, y + 45, '#33414a')]
    for xx in range(x + 20, x + w - 70, 112):
        p += [path(f'M{xx} {y + 45}l48 61 48 -61', '#283841', 7), line(xx, y + 45, xx + 96, y + 106, '#465159', 1)]
    p += [line(x, y + 107, x + w, y + 107, '#131e28', 9)]
    for xx in range(x + 20, x + w - 30, 155):
        p += [rect(xx, y + 1, RNG.randint(20, 70), 2, '#acb8bc', 'opacity=".4"')]
    return ''.join(p)


def railing(x, y, w):
    p = [line(x, y - 62, x + w, y - 62, '#45535a', 4), line(x, y - 32, x + w, y - 32, '#27363f', 3)]
    for xx in range(x, x + w + 1, 72):
        p += [line(xx, y - 62, xx, y, '#34434b', 4), line(xx + 2, y - 59, xx + 2, y, '#566168')]
    return ''.join(p)


def main():
    sky = [rect(0, 0, WIDTH, HEIGHT, 'url(#sky)')]
    for _ in range(65):
        x, y = RNG.randint(0, WIDTH), RNG.randint(490, 900)
        sky += [rect(x, y, RNG.randint(1, 5), 1, RNG.choice(['#917a62', '#708990', '#646385']), 'opacity=".5"')]
    save('backgrounds/sky.svg', sky)

    far = []
    for x in range(-90, WIDTH, 155):
        y, w = RNG.randint(-150, 170), RNG.randint(95, 180)
        far += [rect(x, y, w, HEIGHT - y, '#24343f'), rect(x + w - 15, y, 15, HEIGHT - y, '#1e2d38')]
        for yy in range(max(0, y + 30), HEIGHT, 23):
            for xx in range(x + 12, x + w - 15, 14):
                if RNG.random() < .57:
                    far.append(rect(xx, yy, 3, 6, RNG.choice(['#495960', '#3a4d58', '#56606a']), 'opacity=".48"'))
        far += [rect(x - 8, y + 48, w + 16, 10, '#1e2e39')]
    far += [rect(0, 330, WIDTH, 560, 'url(#haze)')]
    save('backgrounds/far/skyline.svg', far)

    mid = []
    for x, y, w in [(-80, -80, 260), (410, -160, 310), (980, -90, 220), (1530, -70, 310), (2160, -150, 280), (2750, -30, 340), (3310, -80, 310)]:
        mid += [rect(x, y, w, 1100, 'url(#tower)'), rect(x + 14, y, 9, 1100, '#37444b')]
        for yy in range(40, 960, 40):
            mid += [rect(x + 22, yy + 17, w - 35, 4, '#13222d'), line(x + 22, yy + 22, x + w - 10, yy + 22, '#35434c')]
            for xx in range(x + 35, x + w - 25, 27):
                mid += [rect(xx, yy, 13, 17, '#111e28'), rect(xx + 1, yy + 2, 4, 12, RNG.choice(['#53626a', '#293d48', '#263641', '#263641', '#8f8064']), 'opacity=".5"')]
        mid += [pipe(x + w - 20, 0, 960, 12), weathering(x, 0, w, 900, 80)]
    for y in [265, 700]:
        mid += [rect(0, y, WIDTH, 14, '#152531'), line(0, y, WIDTH, y, '#43515c')]
        for x in range(0, WIDTH, 140):
            mid += [path(f'M{x} {y+14}l70 40 70 -40', '#21333f', 5)]
    mid += [rect(0, 400, WIDTH, 500, 'url(#haze)')]
    save('backgrounds/middle/residential.svg', mid)

    near = []
    for x in [70, 1300, 2480, 3670]:
        near += [rect(x, -40, 130, 1000, 'url(#concrete)'), rect(x + 20, 100, 77, 810, '#1a2730'), rect(x + 27, 107, 6, 797, '#37444d')]
        near += [path(f'M{x-40} 190h210l-40 66H{x}Z', '#1b2731', 2, 'url(#concrete)'), weathering(x, 0, 125, 950), pipe(x + 105, 0, 960, 15)]
    # Abandoned magnetic guideway, behind the walkable maintenance route.
    near += [rect(0, 352, WIDTH, 36, 'url(#metal)'), rect(0, 347, WIDTH, 5, '#59646b'), rect(0, 366, WIDTH, 9, '#0b1621'), line(0, 389, WIDTH, 389, '#3a4a56', 2)]
    for x in range(0, WIDTH, 55):
        near += [rect(x, 354, 30, 6, '#52616a'), rect(x + 5, 368, 12, 7, '#262f43')]
    # Disused train shell, shuttered and unlit.
    near += [path('M395 340V267L422 249H804L836 275V340Z', '#46515b', 2, '#202e38')]
    for x in range(427, 802, 58):
        near += [rect(x, 269, 44, 33, '#0b1925'), line(x, 270, x + 44, 270, '#52616c'), line(x + 6, 278, x + 36, 278, '#293b49')]
    near += [rect(414, 315, 400, 3, '#746a58'), weathering(413, 270, 390, 65, 45)]
    for x in [280, 1090, 1800, 2700, 3350]:
        near += [path(f'M{x} -10Q{x+40} 180 {x+250} 125T{x+540} -10', '#0a1621', 3), path(f'M{x+30} -10Q{x+80} 240 {x+290} 150T{x+570} -10', '#19252d', 2)]
    near += [rect(0, 530, WIDTH, 430, 'url(#abyss)')]
    save('backgrounds/near/infrastructure.svg', near)

    world = []
    for x in [-58, 1225, 2550, 3780]:
        world += [rect(x, -60, 145, 1070, 'url(#concrete)'), rect(x + 100, -60, 27, 1070, '#121c24'), weathering(x + 5, 0, 128, 940, 160)]
        for yy in range(110, 940, 155):
            world += [line(x, yy, x + 100, yy, '#0c1620', 3), circle(x + 18, yy + 14, 3, '#0b141d'), circle(x + 85, yy + 14, 3, '#0b141d')]
        world += [path(f'M{x-35} 180h210v24l-40 38H{x+8}l-43 -38Z', '#121d27', 2, 'url(#metal)'), pipe(x + 115, 90, 870, 20)]
    # Rear safety rails leave the front edge and traversal silhouette unobstructed.
    for x, y, w in [(90, 508, 250), (510, 508, 215), (950, 472, 230), (1570, 492, 160), (1880, 535, 150), (2270, 498, 220), (2780, 480, 220), (3440, 516, 250)]:
        world.append(railing(x, y, w))
    for x, y, w in [(0, 508, 760), (865, 472, 510), (1485, 492, 270), (1850, 535, 340), (2275, 498, 320), (2700, 480, 400), (3190, 516, 650)]:
        world += [platform(x, y, w)]
        for xx in range(x + 25, x + w - 10, 300):
            world += [rect(xx, y + 14, 21, 3, '#ad98d0'), circle(xx + 10, y + 20, 60, 'url(#violet)')]
    # Drain outlets empty into the abyss.
    for x, y in [(250, 554), (1100, 518), (2330, 544), (3480, 562)]:
        world += [path(f'M{x} {y}v46h42v42', '#111b23', 23), path(f'M{x-5} {y}v50h42v37', '#34444d', 3)]
        for k in range(3):
            world += [line(x + 36 + k * 4, y + 91, x + 30 + k * 5, y + 260, '#7b969c', 1, 'opacity=".17"')]
    # Small improvised shelter with one surviving warm lamp.
    world += [rect(350, 412, 138, 96, '#101b23'), rect(363, 423, 38, 85, '#1b2830'), rect(410, 425, 63, 76, '#080f16'), path('M337 415L358 389 486 398 507 417Z', '#4a5357', 2, '#2c393f')]
    for x in range(362, 480, 11):
        world += [line(x, 401, x + 10, 412, '#526068')]
    world += [circle(421, 427, 115, 'url(#lamp)'), rect(408, 418, 26, 4, '#c5a476'), rect(326, 478, 22, 30, 'url(#metal)'), rect(484, 485, 28, 23, '#25313a')]
    # Lift: empty cage is stranded well below the missing path.
    world += [rect(1396, 65, 10, 880, '#3b4851'), rect(1460, 65, 10, 880, '#343f4b'), rect(1381, 66, 104, 37, 'url(#metal)')]
    for x in [1412, 1418, 1446, 1452]:
        world += [line(x, 92, x, 645, '#586169', 1)]
    world += [rect(1378, 643, 112, 119, '#14212c'), rect(1375, 639, 118, 8, '#57616b'), rect(1372, 760, 124, 10, '#45515d')]
    for x in range(1380, 1490, 15):
        world += [line(x, 649, x, 756, '#52616b', 2)]
    world += [line(1380, 650, 1485, 753, '#52616b', 2), line(1485, 650, 1380, 753, '#52616b', 2)]
    # Ventilation machinery: static housing; fan blades animate in Godot.
    for x, y in [(1050, 298), (2930, 283), (3330, 321)]:
        world += [rect(x - 104, y - 112, 208, 212, 'url(#metal)'), rect(x - 111, y + 102, 222, 11, '#0b141f')]
        world += [circle(x, y, 91, '#0b141c', 'stroke="#43525b" stroke-width="9"'), circle(x, y, 78, '#0a131c', 'stroke="#23323e" stroke-width="3"')]
        for dx in [-93, 93]:
            for dy in [-101, 95]:
                world += [circle(x + dx, y + dy, 3, '#758083')]
        world += [rect(x + 109, y - 70, 12, 140, '#141c29'), rect(x + 113, y - 59, 3, 31, '#b096ed'), circle(x + 110, y - 40, 115, 'url(#violet)')]
    # Holographic maintenance interfaces, kept sparse.
    for x, y in [(700, 463), (2440, 450), (3660, 468)]:
        world += [rect(x, y, 12, 45, 'url(#metal)'), path(f'M{x-9} {y-51}h62v43h-62Z', '#9676ce', 1, '#493b6c', 'opacity=".68"'), circle(x + 22, y - 25, 110, 'url(#violet)')]
        for k in range(4):
            world += [rect(x - 1, y - 42 + k * 8, 34 - k * 5, 2, '#b39adc', 'opacity=".75"')]
        world += [path(f'M{x+39} {y-37}l7 7 -7 7', '#c1a5f0', 1)]
    for x, y in [(156, 438), (1550, 424), (2800, 412)]:
        world += [rect(x, y, 47, 30, '#786c4e'), rect(x + 3, y + 3, 41, 24, '#171f24'), path(f'M{x+11} {y+23}l12 -17 12 17Z', '#b9a474', 1), line(x + 23, y + 12, x + 23, y + 18, '#b9a474', 2), circle(x + 23, y + 21, 1, '#b9a474')]
    # Wall utility pipes and fractured concrete edges.
    for x in [20, 1950, 3050]:
        world += [pipe(x, 35, 270, 24), path(f'M{x+12} 305v33h100v74', '#16222b', 24), path(f'M{x+7} 305v38h100v69', '#536166', 2)]
    save('platforms/transit.svg', world)

    roof = []
    for x, w in [(0, 285), (485, 880), (1570, 520), (2260, 730), (3200, 640)]:
        roof += [rect(x, 0, w, 52, '#0a1119'), rect(x, 51, w, 19, 'url(#metal)'), line(x, 71, x + w, 71, '#566168', 2)]
        for xx in range(x + 12, x + w, 42):
            roof += [rect(xx, 0, 8, 49, '#1a242c'), line(xx + 8, 0, xx + 8, 49, '#2d3840')]
        roof += [path(f'M{x+w-28} 73l15 24 13 -25', '#101a22', 5)]
    for x in [280, 1360, 2080, 2980]:
        roof += [path(f'M{x} 0h210l120 590H{x-110}Z', 'none', 0, 'url(#beam)'), path(f'M{x-10} 70q15 81 63 93t61 -163', '#070f17', 4), path(f'M{x+7} 70q-18 160 77 149', '#17232c', 2)]
    save('props/roof.svg', roof)
    print(f'Generated 6 SVG environment layers in {OUT.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
