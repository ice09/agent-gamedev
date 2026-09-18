# Gameplay brief

## Objective and loop

Start at the western maintenance entrance of the Lower Transit Sector.
Run and jump across the suspended catwalks, pass the broken lift, and reach
the eastern exit beyond the ventilation hall.

The loop is: enter the level, cross the platforms, recover from falls at the
latest checkpoint, reach the exit, and restart if desired. This iteration
establishes traversal before combat or collection systems.

## Controls

| Input | Action |
| --- | --- |
| A / D or Left / Right | Move the main character |
| Space, W, or Up | Jump |
| Release jump early | Make a shorter jump |
| R / Home | Restart from the entrance |
| 1 / 2 / 3 | Practice start at entrance, lift, or ventilation hall |
| T | Toggle the existing environment camera tour |
| H | Hide or show the HUD |
| F | Toggle environmental animation and atmospheric effects |

Moving or jumping leaves camera-tour mode and returns control to the player.
Space belongs to jumping, not to the camera tour.

## Movement

- Use `CharacterBody2D` and the seven existing platform collision surfaces.
- Accelerate into running; decelerate promptly when the direction is released.
- Support one grounded jump, brief coyote time after leaving a ledge, and a
  short jump buffer before landing. Do not require frame-perfect input.
- Allow variable jump height by releasing the jump key early.
- Keep jump reach sufficient for all six authored gaps in both directions,
  including the raised platforms. Verify this with actual physics traversal.
- Keep the player within the horizontal world bounds.

Start with the movement pattern already used in the parent game's player code,
adapting only the needed controller behavior into the portable level project.

## Camera

Follow horizontal player movement with restrained smoothing and look-ahead.
Clamp the camera to the authored 3,840 px environment. Keep the 1280 × 720,
16:9 side view and existing parallax factors. Do not pan down into the abyss
when the player falls.

## Falls and checkpoints

Falling below the visible route respawns the player on the most recently
reached platform. Save a safe point on that platform only after landing;
crossing over a platform in midair must not activate it. Reset momentum and
pending jump input when respawning.

Show the active checkpoint in the HUD. Respawns are unlimited. Restart clears
checkpoint progress and returns to the entrance.

## Exit

Mark the eastern exit visibly. Reaching it while grounded displays a completion
message with a restart instruction. Do not trigger completion merely by
falling past its horizontal coordinate.

## Feedback

The HUD shows the current area, route progress, checkpoint, and clear controls.
The character visibly changes pose between idle, running, jumping, and falling.
Keep the violet character details readable against the dark environment.
Environmental effects must not be required to see the player or play the level.

## Acceptance criteria

- Import `dist/level1/project.godot` into Godot 4.7.2 and press F5: the main
  character is visible, standing on the entrance platform.
- Keyboard input moves the character; the camera follows once the player
  moves away from the starting edge.
- The player can cross every gap in both directions through normal physics.
- Falls restore a safe checkpoint with reset velocity; R restarts the level.
- Reaching the marked exit completes the route and offers restart.
- The project imports without errors, automated checks pass, and rendered
  screenshots show the character at gameplay scale.
