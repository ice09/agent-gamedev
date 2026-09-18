# Environment production guide

District 01 uses the shared [visual direction](../ART_DIRECTION.md).
No environment artwork was supplied for this iteration.

## Layer order

Listed back to front. Factors describe initial visual travel relative to the
gameplay layer during horizontal camera movement; tune them in-engine.

| Layer | Factor | Export location under `assets/` | Content |
| --- | --- | --- | --- |
| Sky / fog | 0.05× | `environments/common/` | Broad sky and distant atmospheric base |
| Far city skyline | 0.15× | `environments/district_01/backgrounds/far/` | Megastructure silhouettes fading into fog |
| Mid buildings | 0.35× | `environments/district_01/backgrounds/middle/` | Apartment blocks, industry, transit infrastructure |
| Near buildings | 0.60× | `environments/district_01/backgrounds/near/` | Pipes, ducts, cables, maintenance facades |
| Gameplay / collision | 1.00× | `environments/district_01/tiles/`, `platforms/`, `props/` | Readable floors, ledges, obstacles, and traversable gaps |
| Foreground FX | 1.10× | `fx/environment/`, `fx/particles/` | Rain, drifting steam, sparse foreground atmosphere |

`decals/` holds cracks, grime, and surface markings; `lighting/` holds separate
light masks or overlays. Keep collision geometry in future gameplay scenes/code,
aligned with the visible platform surfaces. Decorative background details have
no collision.

## Asset brief

Use [MASTER_ENVIRONMENT_PROMPT.md](MASTER_ENVIRONMENT_PROMPT.md), then append:

```text
ASSET: [specific object or layer]
DISTRICT: district_01
LAYER: [one layer from the table]
OUTPUT: [dimensions, format, transparency, and tiling requirements]
TRAVERSAL: [readable playable surfaces, or background-only]
CONTINUITY: [neighboring assets, scale reference, light direction]
Exclude characters, captions, UI, and watermarks from environment exports.
Deliver this layer separately; do not flatten the complete level.
```

Choose dimensions and tile sizes when the gameplay camera and player scale are
established. Check horizontal seams for repeating backgrounds, alpha edges for
overlays, and platform readability against the near-background layer.
