# First iteration: art-production foundation

Implements the folder layout and visual guidance in `../1st_interation.md`.
This iteration contains reference art, production directories, and asset briefs.
It has no standalone Godot project or playable scene yet.

## Start here

1. Read [ART_DIRECTION.md](docs/art/ART_DIRECTION.md).
2. Consult the [character reference index](docs/art/character_bible/README.md) and [player palette](docs/art/character_bible/player_palette.md).
3. Use the [environment layer guide](docs/art/environment_bible/README.md) and [master environment prompt](docs/art/environment_bible/MASTER_ENVIRONMENT_PROMPT.md) when producing world assets.

## Layout

```text
docs/art/
  ART_DIRECTION.md
  character_bible/           Canonical supplied reference images and palette
  environment_bible/         Layer plan and reusable environment prompt
assets/
  characters/
    player/
      source/               Editable production originals
      sprites/
        idle/ walk/ run/ jump/ fall/ land/
        crouch/ slide/ climb/ attack/ hurt/ death/
      equipment/
      portraits/
    enemies/
  environments/
    district_01/
      backgrounds/far/ middle/ near/
      tiles/ platforms/ props/ decals/ lighting/
    common/
  fx/player/ combat/ environment/ particles/
  ui/
  audio/
src/                        Future gameplay implementation
```

Empty production directories contain `.gitkeep` so Git preserves the requested
layout. `.gdignore` keeps this art workspace out of the parent Godot project's
resource scan. All five supplied PNGs are copied without image conversion;
the reference index records their original names. Windows download metadata
(`:Zone.Identifier`) is not part of the art package.

## First production asset

Produce a strict side-view idle animation using the master reference and
turnaround. Export transparent PNG frames into
`assets/characters/player/sprites/idle/`, named `player_idle_0001.png`, etc.
Keep canvas size, character scale, and foot pivot consistent across frames.
The bible's 256 × 256 canvas and 160 px character height are examples, not
approved production dimensions; settle those in an in-engine scale test.

## Template-Doku

Gesamt-Flow: `../README.md`. Assets mit Chatmodellen erstellen:
`../docs/ASSETS.md`. Veröffentlichen: `../docs/PUBLISH.md`.
