extends Node

var checks := 0
var failures := 0
var level: Node2D


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func tick(frames: int = 1) -> void:
	for frame in frames:
		await get_tree().physics_frame
		await get_tree().process_frame


func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func restart() -> void:
	key(KEY_R, true)
	await tick()
	key(KEY_R, false)
	await tick(5)


func mouse(at: Vector2, pressed: bool) -> void:
	at = get_viewport().get_screen_transform() * at
	if DisplayServer.get_name() != "headless":
		Input.warp_mouse(at)
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	Input.parse_input_event(motion)
	var button := InputEventMouseButton.new()
	button.position = at
	button.global_position = at
	button.button_index = MOUSE_BUTTON_LEFT
	button.pressed = pressed
	Input.parse_input_event(button)


func capture(name: String) -> void:
	await tick(2)
	await RenderingServer.frame_post_draw
	check(get_viewport().get_texture().get_image().save_png("res://captures/" + name + ".png") == OK, "Capture saved: " + name)


func _ready() -> void:
	level = preload("res://scenes/level1.tscn").instantiate()
	add_child(level)
	await tick(8)
	var player = level.player
	var combat = level.combat
	check(player.armed and player.health == 6, "Starts armed with six integrity points")
	check(combat.remaining() == 8, "Eight opponents spawn")
	var kinds := {}
	for enemy in combat.enemies.get_children():
		kinds[enemy.kind] = true
	check(kinds.size() == 4, "Four distinct creature types including boss")
	check(combat.sounds.size() == 6, "Six local combat sounds loaded")
	check(player.try_shoot(), "Weapon emits a shot")
	check(not player.try_shoot(), "Fire interval prevents same-frame spam")
	check(combat.projectiles.get_child_count() == 1, "One projectile per accepted shot")
	await restart()
	key(KEY_J, true)
	await tick(115)
	key(KEY_J, false)
	check(combat.kills >= 1 and combat.score >= 100, "Held J kills first opponent through real swept bullets")
	check(combat.remaining() < 8, "Defeated opponent leaves the encounter")
	check(player.health > 0, "Opening encounter can be beaten without dying")
	await restart()
	mouse(Vector2(400, 250), true)
	await tick(4)
	check(player.aiming and player.aim_direction.x > 0 and player.aim_direction.y < -0.2, "Mouse aims upward and fires")
	check(combat.projectiles.get_child_count() > 0, "Mouse button emits actual projectiles")
	mouse(Vector2(400, 250), false)
	await tick()
	mouse(Vector2(20, 360), true)
	await tick(16)
	check(player.facing < 0 and player.aim_direction.x < -0.8, "Mouse aim turns and fires left")
	mouse(Vector2(20, 360), false)
	await tick()
	var wall_shot = combat.spawn_projectile(Vector2(380, 485), Vector2(0, 900), true)
	await tick(5)
	check(not is_instance_valid(wall_shot), "Swept shot stops at platform surface")
	var expiring = combat.spawn_projectile(Vector2(300, 200), Vector2.RIGHT * 10, true)
	expiring.lifetime = 0.02
	await tick(4)
	check(not is_instance_valid(expiring), "Projectile expires without hitting anything")
	var health: int = player.health
	combat.spawn_projectile(player.position + Vector2(0, -90), Vector2.RIGHT * 100, true)
	await tick(3)
	check(player.health == health, "Player projectile cannot hit its owner")
	player.invulnerability = 0
	combat.spawn_projectile(player.position + Vector2(-75, -90), Vector2.RIGHT * 400, false)
	await tick(15)
	check(player.health == health - 1, "Hostile projectile damages the player")
	check(not player.take_damage(1), "Hit invulnerability prevents stacked damage")
	check(player.health == health - 1, "Invulnerable hit does not remove integrity")
	player.invulnerability = 0
	check(player.take_damage(1), "Damage resumes after invulnerability")
	var before_repair: int = player.health
	combat.repairs.append(player.position + Vector2(0, -85))
	await tick(3)
	check(player.health == before_repair + 1, "Repair fragment restores one integrity point")
	check(combat.repairs.is_empty(), "Repair fragment is consumed")
	check(combat.score == 25, "Repair pickup awards score")
	# Freeze a live encounter, including a moving hostile projectile.
	var paused_shot = combat.spawn_projectile(Vector2(300, 200), Vector2.RIGHT * 100, false)
	key(KEY_ESCAPE, true)
	await tick()
	key(KEY_ESCAPE, false)
	var shot_position: Vector2 = paused_shot.position
	var player_position: Vector2 = player.position
	var enemy_position: Vector2 = combat.enemies.get_child(0).position
	await tick(20)
	check(level.paused and not combat.active, "Escape pauses combat")
	check(paused_shot.position == shot_position and player.position == player_position and combat.enemies.get_child(0).position == enemy_position, "Pause freezes player, enemies, and shots")
	check(level.get_node("HUD/Outcome").visible, "Pause overlay is visible")
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await capture("pause")
	level.get_node("HUD/Outcome/Panel/Resume").pressed.emit()
	await tick(3)
	check(not level.paused and paused_shot.position != shot_position, "Resume button restores simulation")
	key(KEY_M, true)
	await tick()
	key(KEY_M, false)
	check(combat.muted, "Mute shortcut works")
	await restart()
	check(combat.kills == 0 and combat.score == 0 and combat.remaining() == 8 and player.health == 6, "Restart fully restores encounter and player")
	# Each attack is checked after its actual warning countdown.
	for index in [0, 1, 3, 7]:
		var enemy = combat.enemies.get_child(index)
		var floors := [508.0, 472.0, 535.0, 516.0]
		var floor_y: float = floors[[0, 1, 3, 7].find(index)]
		player.respawn(Vector2(enemy.position.x - 180, floor_y - 1))
		player.invulnerability = 100
		enemy.cooldown = 0
		enemy.windup = 0
		var old_attacks: int = enemy.attacks
		await tick(2)
		check(enemy.windup > 0.5, "%s signals its attack before damage" % enemy.kind)
		await tick(48)
		check(enemy.attacks > old_attacks, "%s attack fires after warning" % enemy.kind)
		if enemy.kind == "maw":
			check(enemy.position.x >= enemy.bounds.x and enemy.position.x <= enemy.bounds.y, "Charging crawler remains on its deck")
	var boss = combat.boss()
	boss.take_damage(12)
	check(boss.health == 12, "Boss reaches second phase through damage")
	var bullet_count: int = combat.projectiles.get_child_count()
	boss.attack()
	check(combat.projectiles.get_child_count() == bullet_count + 5, "Second-phase boss emits five-shot fan")
	check(boss.cooldown < 1.9, "Second-phase boss increases attack cadence")
	await restart()
	player.respawn(Vector2(3750, 515))
	await tick(4)
	check(not level.completed, "Exit remains locked while threats live")
	await restart()
	# Clear all eight through actual projectiles. Immunity isolates shooting
	# coverage here; damage and death are verified separately below.
	var firing_points := [Vector2(300, 507), Vector2(930, 471), Vector2(1515, 491), Vector2(1880, 534), Vector2(2310, 497), Vector2(2740, 479), Vector2(3220, 515), Vector2(3370, 515)]
	var targets: Array[Node] = combat.enemies.get_children()
	for index in targets.size():
		var target = targets[index]
		player.respawn(firing_points[index])
		player.invulnerability = 100
		await tick(3)
		for frame in 600:
			if not is_instance_valid(target):
				break
			player.facing = signf(target.target_point().x - player.position.x)
			var shoulder: Vector2 = player.position + Vector2(-9 * player.facing, -81) * 1.6
			player.aim_direction = (target.target_point() - shoulder).normalized()
			player.try_shoot()
			await tick()
		check(not is_instance_valid(target), "Real projectile kill for encounter %d" % (index + 1))
	check(combat.remaining() == 0 and combat.kills == 8, "All threats including boss can be cleared")
	check(combat.score >= 1700, "Boss and ordinary kills award their scores")
	Input.action_press("move_right")
	for frame in 180:
		await tick()
		if level.completed:
			break
	Input.action_release("move_right")
	await tick()
	check(level.completed and level.get_node("HUD/Outcome").visible, "Cleared encounter can be won by walking to exit")
	check(not player.control_enabled and not combat.active, "Winning stops combat")
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await capture("victory")
	await restart()
	player.take_damage(2, true)
	player.position = Vector2(810, 790)
	await tick(4)
	check(player.health == 3 and level.falls == 1 and player.position.distance_to(level.checkpoint) < 3, "Fall costs integrity and returns to safe checkpoint")
	player.take_damage(3, true)
	await tick(3)
	check(level.game_over and player.health == 0, "Zero integrity ends the run")
	check(level.get_node("HUD/Outcome/Panel/Heading").text == "SIGNAL ERLOSCHEN", "Death overlay explains outcome")
	check(not player.try_shoot() and not combat.active, "Dead player cannot fire; encounter freezes")
	level.get_node("HUD/Outcome/Panel/Restart").pressed.emit()
	await tick(4)
	check(not level.game_over and player.health == 6 and combat.remaining() == 8, "Restart button rebuilds a fresh playable encounter")
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		combat.set_muted(false)
		await capture("combat_entrance")
		mouse(Vector2(600, 390), true)
		await tick(5)
		await capture("player_firing")
		mouse(Vector2(600, 390), false)
		for index in [1, 3, 7]:
			await restart()
			var enemy = combat.enemies.get_child(index)
			var floor_y: float = 472 if index == 1 else (535 if index == 3 else 516)
			var start_x: float = 960 if index == 1 else (1880 if index == 3 else 3420)
			player.respawn(Vector2(start_x, floor_y - 1))
			level.camera.position.x = clampf(enemy.position.x - 80, 640, 3200)
			level.camera.reset_physics_interpolation()
			level.camera.force_update_scroll()
			player.invulnerability = 100
			enemy.cooldown = 0
			await tick(15)
			await capture("enemy_" + enemy.kind)
		player.take_damage(6, true)
		await capture("defeat")
	# Let the audio mixer release the final hurt playback before engine shutdown.
	combat.set_muted(true)
	await tick(12)
	level.queue_free()
	await tick(3)
	print("Signal Infestation: %d combat checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
