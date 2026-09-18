extends Node

var failures := 0


func _ready() -> void:
	await _test_menu()
	await _test_player_physics()
	await _test_level_one()
	await _test_boss_level()
	await _test_pause()
	await _test_smoke_run()
	_test_save()
	if failures == 0:
		print("test_neon_rush: OK")
	get_tree().quit(1 if failures > 0 else 0)


func _check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error("FEHLER: " + label)


func _test_menu() -> void:
	var menu: Control = load("res://scenes/menu/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	var button_count := 0
	for hierarchy in menu.find_children("*", "Button", true, false):
		button_count += 1
	_check(button_count >= 5, "Hauptmenü hat Knöpfe")
	menu.queue_free()
	await get_tree().process_frame


func _spawn_game(level: int) -> Node:
	GameState.current_level = level
	var game: Node = load("res://scenes/game/game.tscn").instantiate()
	get_tree().root.add_child(game)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return game


func _test_player_physics() -> void:
	var game: Node = await _spawn_game(1)
	var player: Player = game.get_node("World/Player")
	await get_tree().physics_frame
	await get_tree().physics_frame

	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	await get_tree().physics_frame
	_check(player.velocity.y < -120.0, "Spieler springt")

	for i in 18:
		await get_tree().physics_frame
	var fall_speed := player.velocity.y
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	await get_tree().physics_frame
	_check(player.velocity.y < fall_speed - 200.0, "Doppelsprung gibt neuen Auftrieb")

	for i in 60:
		await get_tree().physics_frame
	var start_x := player.global_position.x
	Input.action_press("move_right")
	for i in 24:
		await get_tree().physics_frame
	Input.action_release("move_right")
	_check(player.global_position.x > start_x + 10.0, "Spieler läuft nach rechts")

	game.queue_free()
	await get_tree().process_frame


func _test_pause() -> void:
	var game: Node = await _spawn_game(1)
	game._toggle_pause()
	_check(get_tree().paused, "Pause pausiert den Baum")
	_check(game._pause.visible, "Pausenmenü ist sichtbar")
	game._toggle_pause()
	_check(not get_tree().paused, "Fortsetzen hebt die Pause auf")
	game.queue_free()
	await get_tree().process_frame


func _test_smoke_run() -> void:
	var game: Node = await _spawn_game(1)
	var player: Player = game.get_node("World/Player")
	Input.action_press("move_right")
	for i in 150:
		await get_tree().physics_frame
		if i % 24 == 0:
			Input.action_press("jump")
			await get_tree().physics_frame
			Input.action_release("jump")
	Input.action_release("move_right")
	_check(is_instance_valid(player), "Spieler überlebt den Smoke-Run")
	_check(game._time > 1.0, "Spielzeit läuft")
	game.queue_free()
	await get_tree().process_frame


func _settle(frames := 4) -> void:
	for i in frames:
		await get_tree().physics_frame


func _test_level_one() -> void:
	var game: Node = await _spawn_game(1)
	_check(game._built["chips"].size() > 0, "Level 1 hat Chips")
	_check(game._chips_total == game._built["chips"].size(), "Chip-Gesamtzahl stimmt")
	_check(game._built["goal"] != null, "Level 1 hat ein Terminal")
	_check(game._built["boss"] == null, "Level 1 hat keinen Boss")
	_check(game._built["hazards"].size() >= 1, "Level 1 hat Gefahren")
	_check(game._built["movers"].size() >= 1, "Level 1 hat eine bewegliche Plattform")

	var mover: Mover = game._built["movers"][0]
	var mover_x := mover.position.x
	for i in 12:
		await get_tree().physics_frame
	_check(mover.position.x != mover_x, "Bewegliche Plattform bewegt sich")

	var player: Player = game.get_node("World/Player")
	var chips: Array = game._built["chips"]
	player.global_position = chips[0].global_position
	await _settle()
	_check(game._chips_collected == 1, "Chip eingesammelt")

	var hazard: Spikes = game._built["hazards"][0]
	player.global_position = hazard.global_position
	await _settle()
	_check(game._deaths == 1, "Tod durch Gefahr")
	await get_tree().create_timer(1.2).timeout

	var checkpoint: Checkpoint = game._built["checkpoints"][0]
	player.global_position = checkpoint.global_position
	await _settle()
	_check(checkpoint.active, "Checkpoint aktiviert")
	_check(game._respawn_point.distance_to(checkpoint.global_position) < 20.0, "Respawnpunkt am Checkpoint")

	await get_tree().create_timer(1.3).timeout
	player.global_position = hazard.global_position
	await _settle()
	_check(game._deaths == 2, "Zweiter Tod durch Gefahr")
	await get_tree().create_timer(1.2).timeout
	_check(player.global_position.distance_to(checkpoint.global_position) < 40.0, "Respawn am Checkpoint")

	var goal: GoalTerminal = game._built["goal"]
	player.global_position = goal.global_position
	await _settle()
	_check(game._finished, "Levelende am Terminal")
	_check(GameState.best_times.has(1), "Bestzeit für Level 1 gespeichert")

	game.queue_free()
	await get_tree().process_frame


func _test_boss_level() -> void:
	var game: Node = await _spawn_game(3)
	_check(game._boss != null, "Level 3 hat einen Boss")
	_check(game._goal.locked, "Terminal ist bis zum Boss gesperrt")

	var player: Player = game.get_node("World/Player")
	player.global_position = game._boss.global_position + Vector2(0.0, 30.0)
	player.velocity = Vector2.ZERO
	game._boss._on_body_entered(player)
	await get_tree().physics_frame
	_check(game._deaths == 1, "Bosskontakt verletzt den Spieler")
	await get_tree().create_timer(1.2).timeout

	for i in 3:
		player.global_position = game._boss.global_position + Vector2(0.0, -30.0)
		player.velocity = Vector2(0.0, 300.0)
		game._boss._on_body_entered(player)
		await get_tree().process_frame
	_check(game._boss.hits >= 3, "Boss nimmt drei Stomps")
	_check(not game._goal.locked, "Terminal nach Boss freigeschaltet")

	game.queue_free()
	await get_tree().process_frame


func _test_save() -> void:
	var backup_times: Dictionary = GameState.best_times.duplicate()
	var backup_unlocked: int = GameState.unlocked_level
	GameState.best_times.erase(2)
	GameState.set_best_time(2, 42.5)
	_check(GameState.best_times.get(2, 0.0) == 42.5, "Bestzeit im Speicher")
	var config := ConfigFile.new()
	var err := config.load(GameState.SAVE_PATH)
	_check(err == OK, "Speicherdatei lesbar")
	var stored: Dictionary = config.get_value("progress", "best_times", {})
	_check(stored.get(2, 0.0) == 42.5, "Bestzeit aus Datei geladen")
	GameState.best_times = backup_times
	GameState.unlocked_level = backup_unlocked
	GameState.save_progress()
