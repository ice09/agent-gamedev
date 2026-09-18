# Third iteration: the signal infestation

The Lower Transit Sector has been occupied by malformed maintenance organisms.
Destroy the infestation and its Null Cantor, then reach the eastern exit.
This is a standalone Godot project built from the smooth, enlarged-character
version of the second iteration.

## Play loop

Run and jump between seven maintenance decks. Aim and fire while moving,
avoid enemy bodies and amber projectiles, collect green repair fragments,
defeat all eight enemies including the final boss, and leave through the exit.
Show score, remaining threats, suit integrity, and boss health. Death and
victory both offer a complete restart. Escape pauses combat.

## Controls

- A/D or Left/Right: run.
- Space/W/Up: jump; release early for a shorter jump.
- Hold left mouse: aim at the cursor and fire continuously.
- Hold J: fire horizontally in the facing direction.
- Escape: pause/resume; R/Home: restart the whole encounter.
- M: mute/unmute combat sound; F: environmental effects; H: HUD.

## Combat rules

- Six suit-integrity points; contact, projectiles, and falls cost one point.
- Brief invulnerability after a hit prevents overlapping attacks from draining
  the entire suit. Falls still cost integrity and respawn at the latest platform.
- A violet pulse pistol has unlimited ammunition and a fixed fire interval.
- Bullets sweep their travel segment for collision, hit the first body/wall,
  expire after about 735 px, and never damage their owner or teammates.
- Enemy attacks wind up visibly before firing or charging. Distant enemies
  do not attack until the player approaches. Enemies stay near their decks.
- Defeated enemies stay defeated after a fall. Every second kill releases a
  repair fragment attracted to a nearby player. Restart rebuilds everything.
- The exit opens only after the infestation is cleared. Platform practice
  shortcuts and the camera tour belong to the retained traversal test mode,
  not the combat run.

## Acceptance checks

Verify both shooting controls, aim direction, hit/kill/score, terrain blocking,
projectile expiry, enemy telegraphs and attacks, all enemy types, boss phase
change, player damage/invulnerability/death, repair fragments, falling,
pause/resume, exit gating, victory, and complete restart. Retain the existing
bidirectional traversal and 120-FPS/60-Hz motion regression checks.
