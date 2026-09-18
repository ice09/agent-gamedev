# Second iteration: playable Lower Transit Sector

This iteration turns the existing environment into a playable side-scrolling
level. The player must be visible when the scene starts and must be able to
cross the maintenance route under keyboard control.

## Brief

- [GAMEPLAY.md](GAMEPLAY.md): objective, controls, movement, camera, checkpoints,
  failure, and completion criteria.
- [CHARACTER.md](CHARACTER.md): character identity, visual references, animation,
  and the scope of the first playable representation.

The canonical art direction and supplied reference sheets remain in
`../1st_iter/docs/art/`. The standalone Godot artifact is
`../dist/level1/project.godot`; this folder contains the second-iteration brief.

## Correction to the environment brief

“No characters” in `level1.md` is an instruction for generating environment
artwork. Keep characters out of background and platform textures. The playable
Godot scene must contain the main character as a separate controllable entity.

## Implementation order

1. Establish gameplay and character requirements in this folder.
2. Add the player and movement to the existing standalone level.
3. Verify every platform transition, fall recovery, camera follow, and the exit.
4. Render the player in the level and record actual results in the handoff.

## Template-Doku

Gesamt-Flow: `../README.md`. Assets mit Chatmodellen erstellen:
`../docs/ASSETS.md`. Veröffentlichen: `../docs/PUBLISH.md`.
