# Level 01 art direction

Derived from `1st_iter/docs/art/ART_DIRECTION.md` in the source repository.

Strict orthographic side view, with a readable horizontal traversal silhouette.
Use near-black, charcoal, cold steel, and desaturated indigo; sparse violet
diagnostics mark technology embedded in decaying infrastructure. Warm amber
appears only in a few windows, warning signs, and the improvised shelter's lamp.

Brutalist residential towers rise behind an abandoned magnetic railway.
Concrete supports, corroded catwalks, cables, utility pipes, ventilation
machinery, and broken lifts establish an industrial district. Avoid generic
neon-Tokyo imagery, excessive signage, and franchise imitation.

Maintain separate sky, far, middle, near, and gameplay layers. Fog and distant
traffic suggest the shaft's depth. Rain comes through broken roof sections.
Background detail stays lower-contrast than platform edges.

The environment artwork contains no characters; the playable scene adds the
protagonist as a separate animated entity. Use the
canonical character bible from the first iteration and preserve the supplied
identity, glasses, baldness pattern, coat, armour, boots, and violet holographic
panels. Reference sheets must not be used directly as sprites.

The current character is an original, approximately 180 px-high vector gameplay
rendition based on those references (1.6× visual scale, 176 px collision height).
The head has a rounded bald crown, side hair, rectangular glasses, and shaded
facial planes; the coat has layered panels, straps, and segmented armour.
The grounded running foot moves backward relative to the body, lifting on its
forward recovery. Animation cadence follows movement speed. Its visual remains
separate from movement, allowing later production sprites to replace it.
Arm joints retain fixed segment lengths and swing smoothly in opposition.
Pose transitions blend, head bob stays small, and foot velocity remains
continuous at ground contact. Physics interpolation smooths world motion;
the camera updates on the same physics clock as the player.

## Third-iteration combat

The pulse pistol adds restrained violet light to the player's near hand.
Its firing pose blends into the existing arm animation. Preserve the character's
head, coat, glasses, and scale when aiming in either direction.

Enemy forms combine articulated machinery, eyes, cable tentacles, and detached
masks; see `../ENEMIES.md`. Desaturated mint/porcelain defines their silhouettes,
amber telegraphs danger, and green repair fragments read separately from shots.
Use brief localized impact fragments and a gentle damage tint. Avoid camera
shake or rapid whole-character flashing, which would obscure the corrected
movement and aiming.
