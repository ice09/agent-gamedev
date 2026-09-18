# Main character brief

## Identity and references

Use the protagonist supplied in `../1st_iter/docs/art/character_bible/`.
The master reference defines identity, costume, materials, and palette; the
turnaround defines proportions and side views. The key-pose sheets explain
movement. Preserve these traits:

- A middle-aged man with a receding/bald crown and short dark side/back hair.
- Black rectangular glasses and the supplied facial profile.
- A long dark tactical coat, shoulder armour, utility belt, gloves, and heavy boots.
- Violet technology strips, the triangular shoulder emblem, and translucent
  lavender geometric coat panels.

Do not substitute the unrelated courier artwork from earlier game prototypes.

## First playable representation

Create a separate, animated 2D character using the references as the design
source. A compact vector rendition is acceptable for this playable iteration;
it must retain the listed identity and costume cues. It is a stylized gameplay
representation, not a claim of finished, reference-quality character art.

Do not put the reference sheets directly into the level as sprites, crop a
whole posed figure from the concept sheet, or bake the player into an
environment image. Keep the visual separate from the physics controller.

## Scale and collision

Use approximately 180 px standing height at the level's 1280 × 720 logical
resolution. The visual now uses a uniform 1.6× scale, with a 176 px-high
collision capsule. Preserve that scale when facing left/right and respawning.
The larger head should show the rounded bald crown, remaining side hair,
black rectangular glasses, brow, eye, nose, and jaw profile at gameplay scale.
Use a foot-position origin so standing feet align with platform tops.
The collision body represents the torso and legs; trailing coat panels and
arm animation must not snag on platform edges.

## Motion

- Idle: restrained breathing, grounded boots, slight coat movement.
- Run: grounded feet move backward relative to the body; lift the foot during
  its forward recovery. Tie the cycle to movement speed to prevent moonwalking.
  Use forward-bending knees, opposing bent-arm motion, a slight forward body
  lean, and a coat that trails behind the body. Idle legs should stand straight.
- Keep upper-arm and forearm lengths fixed while rotating their joints. Use a
  continuous swing rather than moving elbows and hands independently with the
  foot. Blend between idle, running, and airborne poses; keep head bob subtle.
- Physics interpolation and physics-timed camera follow must keep movement
  smooth when the display and physics tick rates differ. Reset interpolation
  on respawn and mirroring so the character does not smear or collapse.
- Jump: lifted knees and a readable upward pose.
- Fall: lowered feet and an open landing pose.
- Face the movement direction consistently. Keep the head, glasses, coat, and
  armour coherent when changing direction.

## Palette

Use the values documented in
`../1st_iter/docs/art/character_bible/player_palette.md`:
near-black `#0A0A0A`, charcoal `#2A2A33`, gunmetal `#4A4F5B`, indigo-black
`#1B1E2E`, violet `#8A5CFF`, lilac `#D7C6FF`, and holographic lavender `#B9A6FF`.
Keep skin tones natural and bright emission confined to technology details.

## Later art work

After the character's scale and movement are accepted, produce dedicated
transparent animation assets from the canonical references if a more detailed
rendering is needed. Replace the visual without changing the controller or
level collision.
