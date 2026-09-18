# Third-iteration handoff · Signal Infestation

## Playable state

- Standalone Godot 4.7.2 project. Import `project.godot`, F5; from the source
  repository use `./3rd_iter/tools/godot.sh`.
- Built from the smoothed second-iteration level and enlarged 180 px character.
  All runtime art, audio, scripts, scenes, and checks live inside this folder.
- Mouse-held aimed fire and J-held horizontal fire; violet pulse pistol,
  0.22 s fire interval, ~735 px range, swept first-hit collision, no friendly fire.
- Eight opponents across four original vector designs: three Rail Maws, two
  Eye Jellies, two Gap Choirs, and the Null Cantor boss. Warning wind-ups precede
  attacks; the boss switches to faster five-shot fans at half health.
- Six integrity points, hit invulnerability, per-platform fall checkpoints,
  repair-fragment pickups, kill/repair score, boss bar, and exit gating.
- Escape pauses combat; R or UI button fully restarts. Victory/death overlays
  work. M mutes/unmutes six generated WAV effects. F/H retain FX/HUD controls.
- Combat is on by default. `combat_enabled = false` is retained for the old
  traversal regression scene; practice warps/tour are not available in combat.

## Files

- `GAMEPLAY.md`, `ENEMIES.md`, `README.md`: brief, creature behaviour, launch/controls.
- `scripts/player.gd`, `player_visual.gd`: damage, shooting, aim pose and sidearm.
- `scripts/enemy.gd`: all creature silhouettes, telegraphs, attacks, damage/death.
- `scripts/projectile.gd`: swept collision, faction masks, finite projectile life.
- `scripts/combat.gd`: encounter placement, score, pickups, effects, sound.
- `scenes/level1.tscn`, `scripts/level1.gd`: encounter integration, HUD and outcome UI.
- `tools/generate_sfx.py`: deterministic standard-library WAV generator.

## Verified

- `./tools/check-project.sh` passed: import, 120-frame main-scene smoke run,
  83 traversal/animation checks and 59 combat checks, zero failures.
- Combat checks exercise actual projectile kills for all eight opponents,
  both fire controls, aim direction, attack warnings, boss phase, damage,
  invulnerability, pickups, falling, pause/resume, exit gating, win/death/restart.
  The isolated all-enemy shooting test grants immunity; damage/death have
  separate checks. It does not establish human difficulty balance.
- Rendered combat suite under xvfb/Compatibility/Mesa llvmpipe: 67 checks,
  zero failures and no shutdown resource leaks after explicit test audio cleanup.
- Inspected the eight views in `captures/`: entrance, firing, jelly, choir,
  cantor, pause, defeat, and victory.
- Armed-avatar pixel-motion check at fixed 120 FPS / 60 Hz physics: 12 checks
  passed; zero stationary-camera stalled frames and under 0.5 px/frame drift
  with camera follow. `captures/run_motion_strip.png` records sampled poses.
- Runtime-resource search found no dependency on the earlier iteration folders.

## Open points

- Windows playtesting, difficulty balance, and audible sound review are pending.
  This WSL run used Dummy audio and a software renderer; fixed-rate tests are
  not native performance measurements. The driver warns about unsupported
  V-Sync switching but renders successfully.
- Character and opponents are stylized vector gameplay art.

## Next step

Play from entrance to exit on Windows and assess combat difficulty and aiming.
