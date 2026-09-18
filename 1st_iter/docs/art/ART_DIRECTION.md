# Visual Direction

## Game

2D atmospheric cyberpunk action platformer / side-scroller.
All paths below are relative to `1st_iter/`.

## Player Character

Use `docs/art/character_bible/` as canonical reference. Do not redesign the character.
Preserve:

- Facial structure, rectangular glasses, and hair/baldness pattern.
- Body proportions and coat silhouette.
- Violet technology accents and holographic coat panels.
- Boots and shoulder armour.

Use `player_master_reference.png` for identity, details, materials, and exact
palette labels; `player_turnaround.png` for directional consistency; and the
pose sheets for motion reference. `player_character_bible.png` collects wider
production ideas. Its optional equipment, effects, and example timings do not
establish gameplay requirements. Where sheets differ, retain the master design
rather than blending them into a new character.

## Camera

Strict 2D side view for gameplay assets, with an orthographic appearance.
No perspective distortion or cinematic camera angles for sprites.
Reference sheets may show other views to explain the design; production
sprites must follow the gameplay camera.

## Palette and Materials

Near-black and charcoal dominate, with muted indigo and cold steel.
Violet technology glow is the primary accent; use cyan only occasionally.
Warm environmental light is rare and visually important.
Follow `docs/art/character_bible/player_palette.md` for player colors.

Keep fabric matte, armour readable, metal worn, and boot soles rubber-like.
Holographic coat panels are translucent, geometric, and lavender.
Restrict bright emission to technology details so the body silhouette survives.

## World

A dark, wet, oppressive cyberpunk city with old industrial infrastructure
overlaid by advanced technology. Avoid generic neon Tokyo and franchise imitation.
Use brutalist concrete, exposed pipes and cables, abandoned transit structures,
old apartment blocks, and vast machinery disappearing into fog.

Rain, steam, mist, particles, and subtle volumetric light establish depth.
The city should feel inhabited but lonely: melancholic, mysterious, and dangerous.
Darkness dominates; neon and warm lamps remain sparse.

## Readability and Layers

Platforms, ledges, floors, and obstacles need immediately readable silhouettes.
Background detail must not compete with the playable layer. Preserve clear
horizontal traversal space and separate backgrounds, collision-bearing assets,
and foreground effects. Do not flatten the world into one finished level image.

Use `docs/art/environment_bible/README.md` for the layer order and initial
parallax factors. The environment prompt in that folder supplies the shared
brief; append the specific asset request to it.

## Production

Keep the supplied reference sheets in `docs/art/`. Do not import whole sheets
as playable sprites. Store editable production originals in
`assets/characters/player/source/` and transparent animation exports in the
matching `sprites/<animation>/` folder.

Use a consistent canvas, scale, and foot pivot across animation frames.
Keep FX separate where possible. Check silhouettes at gameplay scale before
adding detail; use controlled shapes and semi-realistic materials with a subtle
anime influence.
