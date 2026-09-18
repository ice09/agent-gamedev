# Asset provenance

All six environment SVGs, the atmospheric shader, and the fan geometry were
created locally for this task. Editable SVG sources are included; their
deterministic generator is `tools/generate_art.py`.

The animated vector character in `scripts/player_visual.gd` was drawn for this
iteration from the user-supplied player design. The original reference images
remain in `1st_iter/`; they are not embedded or cropped into gameplay sprites.

The four creature designs in `scripts/enemy.gd`, weapon, pulse effects, and
repair fragments were created locally for the third iteration. Six original
synthetic WAV effects are included in `assets/audio/`; their standard-library
Python generator is `tools/generate_sfx.py`.

No third-party images, fonts, audio, or downloaded dependencies are included.
Text uses Godot's built-in fallback font. The retained environment and player
sources originate in the earlier iterations of this repository.
