# Signal Infestation · Third iteration

A standalone Godot 4.7.2 action-platforming encounter in the Lower Transit
Sector. Fight eight strange opponents, defeat the Null Cantor, and reach the
eastern exit. The enlarged protagonist, smooth running, and interpolated
camera come from the second iteration.

## Play

Import **`3rd_iter/project.godot`** in Godot's Project Manager, open it, and
press **F5**. From the repository root on WSL:

```bash
./3rd_iter/tools/godot.sh
```

The complete `3rd_iter/` folder is portable. Runtime assets and sounds are
included; no parent project, plugins, downloads, or Python installation are
required. It uses the Compatibility renderer and a 1280 × 720 logical canvas.

## Controls

| Input | Action |
| --- | --- |
| A/D or Left/Right | Run |
| Space/W/Up | Jump; release early for a shorter jump |
| Hold left mouse | Aim at the cursor and fire continuously |
| Hold J | Fire horizontally in the facing direction |
| Escape | Pause/resume |
| R/Home | Restart the complete encounter |
| M | Mute/unmute sound |
| F | Environmental effects |
| H | Hide/show HUD |

## The encounter

- Rail Maws patrol on six mechanical legs and charge after opening their jaws.
- Eye Jellies hover on cable tentacles and spit aimed pulses.
- Gap Choirs are clusters of detached masks that fire three-shot fans.
- The Null Cantor is a mask-ring boss with a faster five-shot phase below
  half health.

Amber rings warn of attacks. Move or jump after an enemy locks its aim.
The pistol has unlimited ammunition, a 0.22-second shot interval, and about
735 px range. Bullets hit the first opponent or platform in their path.

The suit has six integrity points. Hits briefly grant invulnerability; falls
cost one point and return you to the most recently landed platform. Every
second kill drops a green repair fragment that is drawn toward a nearby player.
Ordinary kills award 100 points, the boss awards 1,000, and repairs award 25.

Eliminate all eight threats to unlock the exit. Zero integrity ends the run.
Death and victory offer restart buttons; R rebuilds enemies, projectiles,
pickups, score, checkpoints, and player health. Sound preference persists for
the current session.

## Files

- `GAMEPLAY.md`, `ENEMIES.md`: combat brief and creature designs.
- `scenes/level1.tscn`: environment, player, combat node, HUD, outcome buttons.
- `scripts/player.gd`, `player_visual.gd`: movement, damage, weapon, animated avatar.
- `scripts/combat.gd`: encounter placement, score, repair fragments, sound, hit effects.
- `scripts/enemy.gd`: four creature types, warning/attack cycles, original vector art.
- `scripts/projectile.gd`: swept first-hit collision and projectile lifetime.
- `tools/generate_art.py`, `tools/generate_sfx.py`: local source generators.
- `assets/CREDITS.md`: art and sound provenance.

The old traversal-only mode is retained for regression tests through the scene's
`combat_enabled` export. Combat is enabled by default; practice warps and the
camera tour are disabled during a combat run.

## Checks

From this folder:

```bash
./tools/check-project.sh
```

This imports the project, smoke-runs the main scene, and runs traversal/motion
logic and combat checks. The combat suite uses actual swept projectiles to
defeat every enemy type. Its isolated full-clear test grants immunity while
testing shooting; separate tests cover damage, invulnerability, and death.
It is not a human difficulty assessment.

Render combat screenshots on WSL:

```bash
xvfb-run -a -s "-screen 0 1280x720x24" ./tools/godot.sh --audio-driver Dummy --rendering-method gl_compatibility --fixed-fps 60 res://tests/test_combat.tscn -- --capture
```

Check smooth armed-character movement at 120 rendered FPS / 60 Hz physics:

```bash
xvfb-run -a -s "-screen 0 1280x720x24" ./tools/godot.sh --audio-driver Dummy --rendering-method gl_compatibility --fixed-fps 120 res://tests/test_level1.tscn -- --motion-check
```

Images are written to `captures/`. The motion test isolates the armed avatar
from enemy interference and measures consecutive-frame face positions with
stationary/following cameras in both directions. Fixed-rate tests do not
measure native GPU performance. Windows playtesting and audible sound review
remain the next human checks.

## Template docs

Overall flow: `../README.md`. Creating assets with chat models:
`../docs/ASSETS.md`. Publishing checklist: `../docs/PUBLISH.md`.
