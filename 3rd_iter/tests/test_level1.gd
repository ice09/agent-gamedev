extends Node

var checks := 0
var failures := 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func tick(frames: int = 1) -> void:
	for frame in frames:
		await get_tree().physics_frame
		await get_tree().process_frame


func press_key(key: Key, frames: int = 3) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	await tick(frames)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await tick()


func traverse(level: Node2D, direction: int) -> void:
	var surfaces := level.get_node("WalkableSurfaces").get_children()
	var action := "move_right" if direction > 0 else "move_left"
	Input.action_press(action)
	for step in 6:
		var index: int = step if direction > 0 else 6 - step
		var source: CollisionShape2D = surfaces[index]
		var target: CollisionShape2D = surfaces[index + direction]
		var takeoff: float = source.position.x + direction * (source.shape.size.x * 0.5 - 32.0)
		for frame in 300:
			if (level.player.position.x - takeoff) * direction >= 0:
				break
			await tick()
		Input.action_press("jump")
		var landed := false
		for frame in 90:
			await tick()
			var top: float = target.position.y - target.shape.size.y * 0.5
			if level.player.is_on_floor() and absf(level.player.position.y - top) < 2 and absf(level.player.position.x - target.position.x) < target.shape.size.x * 0.5 - 15:
				landed = true
				break
		Input.action_release("jump")
		check(landed, "Physics traversal %d → %d" % [index + 1, index + direction + 1])
		if not landed:
			break
	Input.action_release(action)
	await tick(12)
	check(level.falls == 0, "Route traversal without falling, direction %d" % direction)


func face_center(image: Image, region: Rect2i) -> Vector2:
	var sum := Vector2.ZERO
	var count := 0
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			var color := image.get_pixel(x, y)
			if color.r > 0.5 and color.r > color.g * 1.12 and color.g > color.b * 1.08:
				sum += Vector2(x, y)
				count += 1
	return sum / count if count > 0 else Vector2.INF


func check_rendered_motion(level: Node2D) -> void:
	# Run with --fixed-fps 120 against 60 Hz physics. Inspect actual pixels,
	# not the stepped physics coordinates that originally hid the jitter.
	check(DisplayServer.get_name() != "headless", "Motion check requires rendering")
	if DisplayServer.get_name() == "headless":
		return
	var sheet := Image.create(960, 896, false, Image.FORMAT_RGBA8)
	var row := 0
	for following in [false, true]:
		for direction in [1, -1]:
			level.jump_to_sector(0)
			level.set_effects(false)
			level.get_node("HUD").visible = false
			var start := Vector2(1120, 471) if following else Vector2(180 if direction > 0 else 560, 507)
			level.player.respawn(start)
			level.camera.position.x = clampf(start.x, 640.0, 3200.0)
			level.camera.reset_physics_interpolation()
			level.camera.force_update_scroll()
			await tick(8)
			var action := "move_right" if direction > 0 else "move_left"
			Input.action_press(action)
			await tick(20)
			var previous := Vector2.INF
			var first := Vector2.ZERO
			var max_step := 0.0
			var stalls := 0
			var reversals := 0
			var detected := true
			for frame in 48:
				await RenderingServer.frame_post_draw
				var image := get_viewport().get_texture().get_image()
				var screen_x: float = level.player.position.x - level.camera.position.x + 640.0
				var region := Rect2i(int(screen_x) - 70, int(level.player.position.y) - 200, 140, 90)
				var center := face_center(image, region)
				detected = detected and center != Vector2.INF
				if frame == 0:
					first = center
				elif center != Vector2.INF and previous != Vector2.INF:
					var step: float = (center.x - previous.x) * direction
					max_step = maxf(max_step, absf(step))
					if step < 0.4:
						stalls += 1
					if step < -0.4:
						reversals += 1
				previous = center
				if frame % 8 == 0:
					sheet.blit_rect(image, Rect2i(int(screen_x) - 80, int(level.player.position.y) - 208, 160, 224), Vector2i(int(frame / 8) * 160, row * 224))
			Input.action_release(action)
			check(detected, "Face detected in all motion frames")
			if following:
				check(max_step < 1.5, "Following camera has no alternating physics-frame jumps")
			else:
				check(stalls <= 2 and reversals == 0, "Player advances smoothly between physics ticks, direction %d" % direction)
				check(max_step < 3.8 and (previous.x - first.x) * direction > 95.0, "Rendered displacement has no doubled physics steps")
			print("Motion: follow=%s direction=%d stalls=%d max_pixel_step=%.3f" % [following, direction, stalls, max_step])
			row += 1
	check(sheet.save_png("res://captures/run_motion_strip.png") == OK, "Consecutive-frame motion strip saved")


func _ready() -> void:
	var level := preload("res://scenes/level1.tscn").instantiate()
	level.combat_enabled = false
	add_child(level)
	await tick(8)
	if "--motion-check" in OS.get_cmdline_user_args():
		level.player.armed = true
		await check_rendered_motion(level)
		print("Motion regression: %d checks, %d failures" % [checks, failures])
		get_tree().quit(1 if failures else 0)
		return
	check(get_viewport().get_visible_rect().size == Vector2(1280, 720), "16:9 logical viewport")
	check(level.get_node("WalkableSurfaces").get_child_count() == 7, "Seven editable traversal surfaces")
	check(level.player is CharacterBody2D and level.player.is_on_floor(), "Visible controllable player starts grounded")
	check(level.player.get_node("Visual").is_visible_in_tree(), "Player visual is enabled")
	var visual = level.player.get_node("Visual")
	check(is_equal_approx(visual.transform.x.length(), 1.6) and is_equal_approx(visual.transform.y.length(), 1.6), "Character is enlarged uniformly to roughly 180 px")
	check(level.player.get_node("CollisionShape2D").shape.height == 176, "Collision height follows the larger character")
	var art := preload("res://scripts/player_visual.gd")
	check(get_tree().physics_interpolation, "Physics interpolation is enabled")
	check(level.camera.process_callback == Camera2D.CAMERA2D_PROCESS_PHYSICS, "Camera follows on the physics clock")
	var rigid_arms := true
	var smooth_arms := true
	for frame in 120:
		var pose: PackedVector2Array = art.arm_pose(frame / 120.0, 1.0)
		var next: PackedVector2Array = art.arm_pose((frame + 1) / 120.0, 1.0)
		rigid_arms = rigid_arms and absf(pose[0].distance_to(pose[1]) - 18.0) < 0.001 and absf(pose[1].distance_to(pose[2]) - 16.0) < 0.001
		smooth_arms = smooth_arms and pose[2].distance_to(next[2]) < 1.0
	check(rigid_arms, "Arm segments keep their length throughout the cycle")
	check(smooth_arms, "Arm swing is smooth including the cycle boundary")
	var stance_a: Vector2 = art.running_foot(0.1)
	var stance_b: Vector2 = art.running_foot(0.2)
	check(stance_b.x < stance_a.x and stance_a.y == -6.0 and stance_b.y == -6.0, "Planted foot travels backward, not forward")
	var swing_a: Vector2 = art.running_foot(0.6)
	var swing_b: Vector2 = art.running_foot(0.7)
	check(swing_b.x > swing_a.x and swing_a.y < -6.0 and swing_b.y < -6.0, "Forward recovery lifts the foot")
	check(art.running_foot(0.0).distance_to(art.running_foot(0.99999)) < 0.01, "Run cycle wraps without a foot-position pop")
	var smooth_contacts := true
	for boundary in [0.5, 1.0]:
		var before_contact: Vector2 = (art.running_foot(boundary) - art.running_foot(boundary - 0.0001)) / 0.0001
		var after_contact: Vector2 = (art.running_foot(boundary + 0.0001) - art.running_foot(boundary)) / 0.0001
		smooth_contacts = smooth_contacts and before_contact.distance_to(after_contact) < 1.0
	check(smooth_contacts, "Foot velocity stays continuous at lift-off and landing")
	var scale_x: float = visual.transform.x.length()
	var travel := 4.0
	var phase_delta: float = travel / (4.0 * art.STEP_REACH * scale_x)
	check(absf((art.running_foot(0.1 + phase_delta).x - stance_a.x) * scale_x + travel) < 0.001, "Grounded foot cancels body travel rather than sliding")
	var space: PhysicsDirectSpaceState2D = level.get_world_2d().direct_space_state
	for surface in level.get_node("WalkableSurfaces").get_children():
		var top: float = surface.position.y - surface.shape.size.y / 2.0
		var query := PhysicsRayQueryParameters2D.create(Vector2(surface.position.x, top - 25), Vector2(surface.position.x, top + 60), 1)
		var hit := space.intersect_ray(query)
		check(not hit.is_empty(), "Platform has collision: " + surface.name)
		if not hit.is_empty():
			check(is_equal_approx(hit.position.y, top), "Collision matches visible top: " + surface.name)
	for gap in [810, 1430, 1800, 2230, 2640, 3140]:
		check(space.intersect_ray(PhysicsRayQueryParameters2D.create(Vector2(gap, 400), Vector2(gap, 610), 1)).is_empty(), "Gap remains open: %d" % gap)
	level.move_camera(-100000.0)
	check(level.camera.position.x == 640.0, "Camera clamps at west edge")
	level.move_camera(100000.0)
	check(level.camera.position.x == 3200.0, "Camera clamps at east edge")
	await press_key(KEY_2)
	check(level.checkpoint_index == 2 and level.player.is_on_floor(), "Practice start 2 spawns player on lift landing")
	await press_key(KEY_3)
	check(level.checkpoint_index == 5 and level.player.is_on_floor(), "Practice start 3 spawns player on ventilation deck")
	await press_key(KEY_R)
	check(level.camera.position.x == 640.0 and level.checkpoint_index == 0, "Reset returns player and camera to entrance")
	var old_x: float = level.player.position.x
	await press_key(KEY_D, 12)
	check(level.player.position.x > old_x + 10, "D moves the player")
	await tick(12)
	check(absf(level.player.velocity.x) < 0.1, "Player stops after direction is released")
	# Check the actual basis every frame: negative Node2D scale can decompose
	# into a rotation, so checking the `facing` variable alone misses flips.
	for direction in [-1, 1]:
		var action := "move_left" if direction < 0 else "move_right"
		Input.action_press(action)
		var consistently_facing := true
		for frame in 20:
			await tick()
			var basis: Transform2D = level.player.get_node("Visual").transform
			consistently_facing = consistently_facing and is_equal_approx(basis.x.x * direction, 1.6) and is_equal_approx(basis.y.y, 1.6) and absf(basis.x.y) < 0.001 and absf(basis.y.x) < 0.001
		check(consistently_facing, "Stable upright visual throughout direction %d" % direction)
		Input.action_release(action)
		await tick(12)
	await press_key(KEY_SPACE)
	check(level.player.velocity.y < 0 and not level.player.is_on_floor(), "Space jumps rather than starting camera tour")
	await tick(60)
	check(level.player.is_on_floor(), "Jump returns to platform")
	await press_key(KEY_W)
	check(level.player.velocity.y < 0, "W is also a jump control")
	await tick(60)
	await press_key(KEY_T)
	check(level.touring, "Tour remains available on T")
	await press_key(KEY_A)
	check(not level.touring, "Manual input interrupts tour")
	await press_key(KEY_H)
	check(not level.get_node("HUD").visible, "HUD hides")
	await press_key(KEY_H)
	check(level.get_node("HUD").visible, "HUD restores")
	await press_key(KEY_F)
	var old_clock: float = level.clock
	await get_tree().process_frame
	check(not level.effects_enabled and not level.get_node("Machinery").effects_enabled, "Effects toggle disables animated machinery and atmosphere")
	check(level.clock == old_clock, "Disabled effects stop atmospheric clock")
	await press_key(KEY_F)
	check(level.effects_enabled, "Effects restore")
	# Camera-follow displacement and native parallax must remain proportional.
	level.jump_to_sector(0)
	await tick()
	var before: Vector2 = level.get_node("FarSkyline/Art").get_global_transform_with_canvas().origin
	var camera_before: float = level.camera.position.x
	level.jump_to_sector(1)
	await tick(3)
	var after: Vector2 = level.get_node("FarSkyline/Art").get_global_transform_with_canvas().origin
	check(absf((after.x - before.x) + (level.camera.position.x - camera_before) * 0.15) < 1, "Far skyline scrolls at 0.15 of camera movement")
	old_x = level.camera.position.x
	await press_key(KEY_D, 10)
	check(level.camera.position.x > old_x, "Camera follows player movement")
	level.jump_to_sector(0)
	await tick(8)
	await traverse(level, 1)
	check(level.checkpoint_index == 6, "Landing advances checkpoint to final deck")
	Input.action_press("move_right")
	for frame in 240:
		await tick()
		if level.completed:
			break
	Input.action_release("move_right")
	check(level.completed, "Grounded arrival at marked exit completes level")
	await tick()
	check("AUSGANG ERREICHT" in level.get_node("HUD/Subtitle").text, "Completion message offers restart")
	await press_key(KEY_R)
	check(not level.completed and level.falls == 0 and level.checkpoint_index == 0, "Restart clears completion, falls and checkpoint")
	# Start the reverse traversal on the east deck, before its completion trigger.
	level.player.respawn(Vector2(3515, 515))
	await tick(8)
	await traverse(level, -1)
	check(level.checkpoint_index == 0, "All six gaps are traversable in reverse")
	level.jump_to_sector(1)
	await tick(8)
	var safe_point: Vector2 = level.checkpoint
	level.player.position = Vector2(1800, 790)
	level.player.velocity = Vector2(200, 800)
	await tick(4)
	check(level.falls == 1 and level.player.position.distance_to(safe_point) < 3, "Fall restores last safe platform")
	check(level.player.velocity.length() < 1, "Respawn clears momentum")
	check(visual.transform.x == Vector2(1.6, 0) and visual.transform.y == Vector2(0, 1.6), "Respawn preserves the enlarged upright visual")
	# A falling player cannot win just by crossing the exit's x coordinate.
	level.player.position = Vector2(3740, 700)
	level.player.velocity = Vector2(0, 200)
	await tick(2)
	check(not level.completed, "Exit requires standing on its platform")
	for layer_name in ["Sky", "FarSkyline", "ResidentialTowers", "RailInfrastructure"]:
		var sprite: Sprite2D = level.get_node(layer_name + "/Art")
		check(sprite.texture.get_width() == 3840 and sprite.texture.get_height() == 960, "Imported full-resolution layer: " + layer_name)
	if "--capture" in OS.get_cmdline_user_args():
		check(DisplayServer.get_name() != "headless", "Captures require a real rendering driver")
		if DisplayServer.get_name() != "headless":
			for index in 3:
				level.jump_to_sector(index)
				await tick(10)
				await RenderingServer.frame_post_draw
				var result := get_viewport().get_texture().get_image().save_png("res://captures/sector_%d.png" % (index + 1))
				check(result == OK, "Rendered sector %d screenshot saved" % (index + 1))
			level.jump_to_sector(0)
			level.get_node("HUD").visible = false
			await tick(10)
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png("res://captures/sector_1_clean.png") == OK, "Clean playable-level screenshot saved")
			Input.action_press("move_right")
			await tick(15)
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png("res://captures/player_run.png") == OK, "Running pose rendered")
			Input.action_press("jump")
			await tick(8)
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png("res://captures/player_jump.png") == OK, "Jumping pose rendered")
			Input.action_release("move_right")
			Input.action_release("jump")
			level.jump_to_sector(0)
			level.player.respawn(Vector2(520, 507))
			await tick(8)
			Input.action_press("move_left")
			await tick(24)
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png("res://captures/player_run_left.png") == OK, "Enlarged left-facing run rendered")
			Input.action_release("move_left")
	print("Lower Transit Sector: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
