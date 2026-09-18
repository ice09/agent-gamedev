Für dein WSL-Projekt würde ich ungefähr diese Struktur verwenden:

my-cyberpunk-game/
├── docs/
│   └── art/
│       ├── character_bible/
│       │   ├── player_master_reference.png
│       │   ├── player_turnaround.png
│       │   ├── player_keyposes.png
│       │   ├── player_character_bible.png
│       │   └── player_palette.md
│       ├── environment_bible/
│       └── ART_DIRECTION.md
│
├── assets/
│   ├── characters/
│   │   ├── player/
│   │   │   ├── source/
│   │   │   ├── sprites/
│   │   │   │   ├── idle/
│   │   │   │   ├── walk/
│   │   │   │   ├── run/
│   │   │   │   ├── jump/
│   │   │   │   ├── fall/
│   │   │   │   ├── land/
│   │   │   │   ├── crouch/
│   │   │   │   ├── slide/
│   │   │   │   ├── climb/
│   │   │   │   ├── attack/
│   │   │   │   ├── hurt/
│   │   │   │   └── death/
│   │   │   ├── equipment/
│   │   │   └── portraits/
│   │   └── enemies/
│   │
│   ├── environments/
│   │   ├── district_01/
│   │   │   ├── backgrounds/
│   │   │   │   ├── far/
│   │   │   │   ├── middle/
│   │   │   │   └── near/
│   │   │   ├── tiles/
│   │   │   ├── platforms/
│   │   │   ├── props/
│   │   │   ├── decals/
│   │   │   └── lighting/
│   │   └── common/
│   │
│   ├── fx/
│   │   ├── player/
│   │   ├── combat/
│   │   ├── environment/
│   │   └── particles/
│   │
│   ├── ui/
│   └── audio/
│
└── src/

Der entscheidende Unterschied ist:

docs/art/ = Wahrheit / Referenz
assets/ = tatsächlich vom Spiel verwendete Dateien

Deine jetzigen Bilder würde ich also nach docs/art/character_bible/ legen. Sie sollten nicht direkt als Spielsprites verwendet werden. Das sind die Bilder, die du künftig jedem Agenten bzw. Bildmodell als verbindliche Referenz gibst.

Bei OpenCode würde ich zusätzlich im Projekt eine Datei wie

docs/art/ART_DIRECTION.md

anlegen. Darin sollten die unveränderlichen Regeln stehen, beispielsweise:

# Visual Direction

## Game
2D atmospheric cyberpunk action platformer / side-scroller.

## Player Character
Use docs/art/character_bible as canonical reference.

Do not redesign the character.
Do not alter:
- facial structure
- glasses
- hair/baldness pattern
- body proportions
- coat silhouette
- violet technology accents
- boots
- shoulder armour
- holographic coat panels

## Camera
Strict 2D side view for gameplay assets.
Orthographic appearance.
No perspective distortion.
No cinematic camera angles for sprites.

## Palette
Near-black / charcoal base.
Muted indigo and cold steel.
Violet technology glow.
Occasional cyan secondary accents.
Warm colors are rare and therefore visually important.

## World
Dark, wet, oppressive cyberpunk city.
Not generic neon Tokyo.
Industrial, old infrastructure mixed with advanced technology.
Dense atmosphere, fog, rain, steam and volumetric light.

Damit kannst du später deinem Coding-Agenten einfach sagen:

Read docs/art/ART_DIRECTION.md before creating or modifying any visual asset.

Das hilft enorm gegen schleichende Stiländerungen.

Für die Welt würde ich zuerst keine fertigen Levelbilder erzeugen

Für ein Jump'n'Run brauchst du die Welt in Schichten.

Typischer Aufbau:

Foreground FX
────────────────────
Gameplay / collision layer
────────────────────
Near background
────────────────────
Mid background
────────────────────
Far city skyline
────────────────────
Sky / fog

Dadurch kannst du Parallax erzeugen.

Bei einer Kamerabewegung nach rechts könnten beispielsweise gelten:

Sky             0.05x
Far skyline     0.15x
Mid buildings   0.35x
Near buildings  0.60x
Gameplay        1.00x
Foreground      1.10x

Das sieht sofort wesentlich hochwertiger aus als ein einzelnes großes Hintergrundbild.

Der zentrale Environment-Prompt

Den würde ich auf Englisch verwenden, weil Bildmodelle mit solchen Art-Direction-Prompts meist stabiler arbeiten.

MASTER ART DIRECTION — 2D CYBERPUNK PLATFORMER

Create production concept art and game-asset reference for an atmospheric
2D cyberpunk action platformer.

The world is dark, oppressive, mysterious and beautiful rather than colorful
or cheerful.

SETTING:
A vast decaying megacity where old brutalist infrastructure, abandoned
industrial machinery and improvised urban architecture have gradually been
covered by extremely advanced technology.

Avoid the stereotypical neon-Tokyo cyberpunk look.

Instead combine:

- brutalist concrete megastructures
- heavy industrial architecture
- obsolete infrastructure
- exposed pipes, ducts and cables
- maintenance tunnels
- rain-soaked metal
- cracked concrete
- old apartment blocks
- gigantic technological systems integrated into old buildings
- sparse holographic interfaces
- mysterious high-tech machinery
- abandoned transit infrastructure
- vertical city depth
- distant megastructures disappearing into fog

COLOR LANGUAGE:

Primary:
near-black
charcoal
cold gray
desaturated blue
dark indigo

Technology accents:
deep violet
electric lavender
occasional cyan

Very limited warm amber/orange light may appear from windows,
old lamps or machinery.

Neon must be used sparingly.
Darkness should dominate the image.

ATMOSPHERE:

constant light rain
wet reflective surfaces
mist
steam
low hanging fog
floating particles
subtle volumetric light
deep shadows
distant silhouettes
occasional flickering technology

The city should feel inhabited but lonely.

MOOD:

melancholic
mysterious
dangerous
quiet
oppressive
beautiful
technologically incomprehensible

GAMEPLAY REQUIREMENTS:

Strict side-view composition suitable for a 2D platformer.

Clear readable traversal space.

Platforms, ledges, floors and obstacles must have immediately readable
silhouettes.

Background detail must never visually compete with the playable layer.

Avoid perspective-heavy compositions.

No dramatic cinematic camera angle.

Characters must be able to move horizontally through the scene.

VISUAL STYLE:

high-end stylized game concept art
clean readable shapes
semi-realistic materials
strong silhouettes
controlled detail
subtle anime influence
modern premium indie game production quality

Do not imitate an existing game or franchise.

The world must have its own distinctive visual identity.

Das ist dein Basis-Prompt. Danach ergänzt du lediglich das konkrete Asset.