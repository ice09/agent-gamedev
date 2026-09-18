extends Node2D
## Original vector gameplay rendition of the supplied bald, bespectacled protagonist.

const INK := Color("0a0a0a")
const COAT := Color("1b1e2e")
const ARMOUR := Color("2a2a33")
const STEEL := Color("4a4f5b")
const VIOLET := Color("8a5cff")
const LILAC := Color("d7c6ff")
const STEP_REACH := 20.0
var gait_phase := 0.0
var idle_time := 0.0
var run_blend := 0.0
var air_blend := 0.0
var aim_blend := 0.0


func _process(delta: float) -> void:
	var player = get_parent()
	idle_time += delta * 2.4
	aim_blend = move_toward(aim_blend, 1.0 if player.aiming else 0.0, delta * 12.0)
	modulate = Color.WHITE.lerp(Color(1.0, 0.62, 0.72), player.hurt_flash * 2.0)
	run_blend = move_toward(run_blend, clampf(absf(player.velocity.x) / player.speed, 0.0, 1.0), delta * 6.0)
	air_blend = move_toward(air_blend, 0.0 if player.is_on_floor() else 1.0, delta * 10.0)
	if player.is_on_floor() and absf(player.velocity.x) > 15.0:
		# Each stance covers 2 * reach over half a cycle; match world travel.
		gait_phase = fposmod(gait_phase + player.velocity.x * player.facing * delta / (4.0 * STEP_REACH * transform.x.length()), 1.0)
	queue_redraw()


static func running_foot(cycle: float) -> Vector2:
	var t := fposmod(cycle, 1.0)
	if t < 0.5:
		# Planted foot goes backward relative to the body, staying on the ground.
		return Vector2(STEP_REACH - 4.0 * STEP_REACH * t, -6.0)
	var swing := (t - 0.5) * 2.0
	# Match the stance velocity at both ends instead of snapping direction.
	var x := STEP_REACH * (-1.0 - 2.0 * swing + 12.0 * swing * swing - 8.0 * swing * swing * swing)
	return Vector2(x, -6.0 - pow(sin(swing * PI), 2.0) * 19.0)


static func arm_pose(cycle: float, blend: float) -> PackedVector2Array:
	# Fixed-length upper arm and forearm rotate at shoulder and elbow.
	var shoulder_angle := lerpf(0.05, 0.15 + cos(cycle * TAU) * 0.45, blend)
	var elbow := Vector2(0, 18).rotated(shoulder_angle)
	var hand := elbow + Vector2(0, 16).rotated(shoulder_angle - lerpf(0.08, 1.65, blend))
	return PackedVector2Array([Vector2.ZERO, elbow, hand])


func poly(points: Array, color: Color, outline: Color = INK) -> void:
	var vertices := PackedVector2Array(points)
	draw_colored_polygon(vertices, color)
	vertices.append(vertices[0])
	draw_polyline(vertices, outline, 1.1, true)


func limb(points: PackedVector2Array, width: float, color: Color) -> void:
	draw_polyline(points, INK, width + 2.0, true)
	draw_polyline(points, color, width, true)
	for point in points:
		draw_circle(point, width * 0.5, color)


func leg(hip: Vector2, ankle: Vector2, near: bool, motion: float) -> void:
	var axis := ankle - hip
	# Two equal segments bend the knee forward, including during foot recovery.
	var bend := lerpf(2.0, sqrt(maxf(0.0, 25.0 * 25.0 - axis.length_squared() * 0.25)), motion)
	var knee := (hip + ankle) * 0.5 + Vector2(axis.y, -axis.x).normalized() * bend
	limb(PackedVector2Array([hip, knee, ankle]), 9.0, ARMOUR if near else COAT)
	draw_line(hip + Vector2(-2, 2), knee + Vector2(-2, -2), STEEL, 1, true)
	poly([knee + Vector2(-4, -6), knee + Vector2(4, -5), knee + Vector2(6, 1), knee + Vector2(2, 7), knee + Vector2(-4, 4)], STEEL if near else ARMOUR)
	draw_line(knee + Vector2(2, -3), knee + Vector2(2, 3), VIOLET, 2, true)
	draw_line(knee.lerp(ankle, 0.3), knee.lerp(ankle, 0.75), COAT, 5, true)
	draw_line(knee.lerp(ankle, 0.35) + Vector2(2, 0), knee.lerp(ankle, 0.7) + Vector2(2, 0), LILAC, 1.2, true)
	poly([ankle + Vector2(-5, -6), ankle + Vector2(5, -5), ankle + Vector2(7, -1), ankle + Vector2(14, 1), ankle + Vector2(14, 6), ankle + Vector2(-6, 6)], ARMOUR)
	draw_line(ankle + Vector2(-5, 6), ankle + Vector2(14, 6), STEEL, 2, true)
	draw_line(ankle + Vector2(-3, -3), ankle + Vector2(-3, 3), LILAC, 1.5, true)
	for offset in [0, 3]:
		draw_line(ankle + Vector2(offset, -2), ankle + Vector2(offset + 4, 1), STEEL, 1, true)


func _draw() -> void:
	var player = get_parent()
	var bob := lerpf(sin(idle_time) * 0.2, sin(gait_phase * TAU * 2.0) * 0.35, run_blend) * (1.0 - air_blend)
	var trail := lerpf(lerpf(sin(idle_time) * 0.3, 7.0 + sin(gait_phase * TAU), run_blend), 12.0, air_blend)
	# Feet retain a world-ground pivot while the coat and head breathe above them.
	var front_foot := Vector2(7, -6).lerp(running_foot(gait_phase) + Vector2(3, 0), run_blend)
	var back_foot := Vector2(-7, -6).lerp(running_foot(gait_phase + 0.5) + Vector2(-3, 0), run_blend)
	var jump_lift := clampf(-player.velocity.y / 200.0, 0.0, 1.0)
	front_foot = front_foot.lerp(Vector2(18, -8 - jump_lift * 10.0), air_blend)
	back_foot = back_foot.lerp(Vector2(-16, -13), air_blend)
	if player.is_on_floor():
		draw_set_transform(Vector2(0, 1), 0, Vector2(1, 0.18))
		draw_circle(Vector2.ZERO, 24, Color(0.01, 0.01, 0.025, 0.42))
		draw_set_transform(Vector2.ZERO)
	var motion := maxf(run_blend, air_blend)
	leg(Vector2(-5, -48), back_foot, false, motion)
	leg(Vector2(5, -48), front_foot, true, motion)
	var lean := 0.08 * run_blend
	var hip := Vector2(0, -48)
	draw_set_transform(hip - hip.rotated(lean) + Vector2(0, bob), lean)
	# Rear arm and split, trailing coat silhouette.
	var arm_blend := maxf(run_blend, air_blend * 0.75)
	var far_arm := arm_pose(gait_phase + 0.5, arm_blend)
	var far_shoulder := Vector2(4, -80)
	limb(PackedVector2Array([far_shoulder, far_shoulder + far_arm[1], far_shoulder + far_arm[2]]), 8, COAT)
	poly([Vector2(-12, -73), Vector2(9, -69), Vector2(12, -40), Vector2(17 - trail, -19), Vector2(3 - trail, -25), Vector2(-10 - trail, -15), Vector2(-20 - trail, -24), Vector2(-12, -52)], COAT, STEEL)
	poly([Vector2(-10, -59), Vector2(-5, -51), Vector2(-14 - trail, -20), Vector2(-18 - trail, -25)], Color("303344"), STEEL)
	draw_line(Vector2(7, -52), Vector2(10 - trail, -26), STEEL, 0.8, true)
	poly([Vector2(-11, -53), Vector2(-2, -46), Vector2(-13 - trail, -23), Vector2(-22 - trail, -27)], Color(0.55, 0.40, 0.93, 0.56), VIOLET)
	poly([Vector2(3, -51), Vector2(12, -45), Vector2(8 - trail, -28), Vector2(-2 - trail, -32)], Color(0.73, 0.65, 1.0, 0.48), Color("b9a6ff"))
	for offset in [0, 6, 12]:
		draw_line(Vector2(-13 - offset * 0.35, -44 + offset), Vector2(-4 - trail * 0.6, -39 + offset), LILAC * Color(1, 1, 1, 0.6), 0.6, true)
	# Torso, raised collar, chest technology, belt and pouches.
	poly([Vector2(-12, -88), Vector2(5, -90), Vector2(13, -79), Vector2(10, -51), Vector2(-10, -48), Vector2(-16, -73)], ARMOUR, STEEL)
	poly([Vector2(-10, -83), Vector2(-3, -85), Vector2(0, -55), Vector2(-8, -54)], Color("343746"), STEEL)
	poly([Vector2(4, -80), Vector2(10, -77), Vector2(9, -58), Vector2(4, -56)], COAT)
	poly([Vector2(-15, -89), Vector2(-8, -94), Vector2(7, -88), Vector2(3, -76), Vector2(-12, -80)], COAT, STEEL)
	poly([Vector2(-16, -87), Vector2(-20, -80), Vector2(-16, -73), Vector2(-8, -76)], Color("141725"), STEEL)
	draw_line(Vector2(-11, -90), Vector2(-7, -81), VIOLET, 2, true)
	draw_line(Vector2(7, -80), Vector2(5, -53), STEEL, 1.5, true)
	draw_line(Vector2(3, -74), Vector2(3, -61), VIOLET, 1.5, true)
	draw_line(Vector2(-9, -76), Vector2(-5, -55), INK, 4, true)
	for y in [-76, -65]:
		draw_rect(Rect2(-10, y, 5, 4), STEEL, false, 0.8)
	draw_rect(Rect2(-12, -54, 24, 6), INK)
	draw_rect(Rect2(3, -54, 6, 5), STEEL, false, 1.3)
	for x in [-11, -4]:
		draw_rect(Rect2(x, -53, 6, 10), COAT)
		draw_rect(Rect2(x, -53, 6, 10), STEEL, false, 1)
	# Rounded bald crown and shaded facial planes follow the master side view.
	draw_rect(Rect2(-1, -96, 8, 10), Color("b8836b"))
	poly([Vector2(-6, -105), Vector2(-5, -109), Vector2(-2, -112), Vector2(2, -113.5), Vector2(6, -113), Vector2(10, -111), Vector2(12, -108), Vector2(12, -103), Vector2(11.5, -101), Vector2(15, -98), Vector2(12, -97), Vector2(12, -94), Vector2(11, -90), Vector2(7, -88), Vector2(2, -90), Vector2(-2, -94), Vector2(-6, -100)], Color("d9a98c"))
	poly([Vector2(-3, -109), Vector2(0, -112), Vector2(5, -112), Vector2(9, -109), Vector2(9, -106), Vector2(5, -107), Vector2(1, -107)], Color("e9bc9b"), Color("e9bc9b"))
	poly([Vector2(2, -99), Vector2(6, -96), Vector2(11, -96), Vector2(10, -91), Vector2(7, -90), Vector2(2, -92)], Color("bd8e73"), Color("bd8e73"))
	poly([Vector2(-5, -108), Vector2(-1, -110), Vector2(-2, -105), Vector2(-2, -98), Vector2(-3, -95), Vector2(-6, -98), Vector2(-7, -103)], Color("34343b"))
	for y in [-106, -103, -100]:
		draw_line(Vector2(-5, y), Vector2(-3, y - 2), Color("62616a"), 0.65, true)
	draw_circle(Vector2(0, -99), 2.7, Color("b8836b"))
	draw_arc(Vector2(0, -99), 1.6, -1.8, 1.7, 10, Color("efbea0"), 0.8, true)
	draw_line(Vector2(4, -107), Vector2(10, -106), Color("bb8b70"), 0.65, true)
	draw_line(Vector2(5, -105), Vector2(10, -104.5), Color("76594e"), 1.2, true)
	# Black rectangular glasses, bridge, temple implant and restrained lens glint.
	draw_rect(Rect2(5, -104, 8, 5.5), Color(0.52, 0.64, 0.68, 0.13))
	draw_line(Vector2(7, -101.5), Vector2(10, -101.5), Color("473b33"), 0.8, true)
	draw_circle(Vector2(9.5, -101.5), 0.7, INK)
	draw_rect(Rect2(5, -104, 8, 5.5), INK, false, 1.4)
	draw_line(Vector2(-2, -103), Vector2(5, -102), INK, 1.6, true)
	draw_line(Vector2(6, -103.5), Vector2(9, -103.5), Color("cfe8ff"), 0.55, true)
	draw_line(Vector2(-5, -104), Vector2(-1, -106), VIOLET, 1.0, true)
	draw_line(Vector2(11, -98), Vector2(13, -98), Color("9f705f"), 0.7, true)
	draw_line(Vector2(8, -93.5), Vector2(12, -93.5), Color("805e58"), 0.8, true)
	draw_line(Vector2(7, -91), Vector2(9, -90.5), Color("6e6160"), 1.1, true)
	# Near arm: shoulder plate with the reference's triangular violet insignia.
	var near_arm := arm_pose(gait_phase, arm_blend)
	var elbow := Vector2(-9, -81) + near_arm[1]
	var hand := Vector2(-9, -81) + near_arm[2]
	var aim := Vector2(player.aim_direction.x * player.facing, player.aim_direction.y).normalized()
	var shoulder := Vector2(-9, -81)
	var aim_hand := shoulder + aim * 30.0
	var aim_elbow := shoulder + aim * 15.0 + Vector2(-aim.y, aim.x) * 9.0
	elbow = elbow.lerp(aim_elbow, aim_blend)
	hand = hand.lerp(aim_hand, aim_blend)
	# Keep the firing arm in the same un-leaned space as the bullet origin.
	var arm_origin := (hip - hip.rotated(lean) + Vector2(0, bob)) * (1.0 - aim_blend)
	var arm_rotation := lean * (1.0 - aim_blend)
	draw_set_transform(arm_origin, arm_rotation)
	limb(PackedVector2Array([Vector2(-9, -81), elbow, hand]), 9, ARMOUR)
	poly([Vector2(-18, -86), Vector2(-8, -89), Vector2(-2, -82), Vector2(-5, -73), Vector2(-16, -74), Vector2(-20, -80)], STEEL)
	poly([Vector2(-16, -85), Vector2(-8, -86), Vector2(-5, -81), Vector2(-8, -75), Vector2(-16, -77)], ARMOUR)
	poly([Vector2(-14, -82), Vector2(-7, -82), Vector2(-11, -76)], COAT, LILAC)
	for rivet in [Vector2(-17, -81), Vector2(-7, -85)]:
		draw_circle(rivet, 0.85, Color("828895"))
	draw_line(elbow.lerp(hand, 0.2) + Vector2(-2, 0), elbow.lerp(hand, 0.8) + Vector2(-2, 0), VIOLET, 2.5, true)
	draw_circle(hand, 4.7, INK)
	for x in [-2, 1]:
		draw_circle(hand + Vector2(x, -2), 1.1, LILAC)
	if player.armed:
		var gun_angle := arm_rotation + lerp_angle(0.8, aim.angle(), aim_blend)
		draw_set_transform(arm_origin + hand.rotated(arm_rotation), gun_angle)
		poly([Vector2(-3, -5), Vector2(13, -5), Vector2(18, -2), Vector2(18, 3), Vector2(4, 4), Vector2(1, 10), Vector2(-4, 8)], ARMOUR, STEEL)
		draw_line(Vector2(3, -3), Vector2(15, -3), VIOLET, 2, true)
		if player.muzzle_flash > 0.0:
			poly([Vector2(18, -4), Vector2(28, -7), Vector2(23, 0), Vector2(30, 4), Vector2(18, 4)], LILAC, VIOLET)
	draw_set_transform(Vector2.ZERO)
