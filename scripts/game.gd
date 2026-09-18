extends Node2D

const LEVEL_PATH := "res://data/levels/level_%d.json"
const PLAYER_SCENE := "res://scenes/game/player.tscn"
const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

@onready var world: Node2D = $World

var _data: Dictionary = {}
var _built: Dictionary = {}
var _player: Player
var _hud: Hud
var _pause: PauseMenu
var _result: ResultScreen
var _boss: Boss
var _goal: GoalTerminal

var _chips_total := 0
var _chips_collected := 0
var _deaths := 0
var _time := 0.0
var _running := true
var _finished := false
var _paused := false
var _respawn_point := Vector2.ZERO
var _bounds := Rect2()


func _ready() -> void:
	var level := clampi(GameState.current_level, 1, GameState.MAX_LEVEL)
	_data = _load_level(level)
	GameState.play_music(String(_data.get("music", GameState.MUSIC_LEVEL)))

	add_child(ParallaxSky.build(_tint()))
	add_child(WorldFx.build_environment())
	add_child(WorldFx.build_post_fx())
	add_child(WorldFx.build_rain())

	_build_ui()
	_build_level()
	_build_player()
	_wire_signals()

	_hud.set_level_name(String(_data.get("name", "Sektor")))
	_hud.set_chips(0, _chips_total)
	_hud.set_deaths(0)
	_hud.set_time(0.0)
	_hud.show_toast("Finde das Terminal", 2.5)


func _process(delta: float) -> void:
	if _running and not _finished:
		_time += delta
		_hud.set_time(_time)


func _unhandled_input(event: InputEvent) -> void:
	if _finished:
		return
	if event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("restart"):
		_restart_level()


func _tint() -> Color:
	var values: Array = _data.get("tint", [])
	if values.size() >= 3:
		return Color(float(values[0]), float(values[1]), float(values[2]))
	return Color(1, 1, 1)


func _load_level(level: int) -> Dictionary:
	var path := LEVEL_PATH % level
	if not FileAccess.file_exists(path):
		push_error("Level fehlt: " + path)
		return {"name": "Leer", "width": 200, "height": 46, "spawn": [3, 38]}
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Level-JSON ungültig: " + path)
		return {"name": "Leer", "width": 200, "height": 46, "spawn": [3, 38]}
	return parsed


func _build_ui() -> void:
	_hud = Hud.new()
	add_child(_hud)

	_pause = PauseMenu.new()
	_pause.resumed.connect(_toggle_pause)
	_pause.restart_requested.connect(_restart_level)
	_pause.menu_requested.connect(_go_to_menu)
	add_child(_pause)

	_result = ResultScreen.new()
	_result.next_requested.connect(_go_to_next_level)
	_result.retry_requested.connect(_restart_level)
	_result.menu_requested.connect(_go_to_menu)
	add_child(_result)


func _build_level() -> void:
	_built = LevelBuilder.build(world, _data)
	_bounds = _built["bounds"]
	_chips_total = _built["chips"].size()
	_goal = _built["goal"]
	_boss = _built["boss"]


func _build_player() -> void:
	_player = load(PLAYER_SCENE).instantiate()
	_respawn_point = _built["spawn"]
	_player.position = _respawn_point
	world.add_child(_player)
	_player.died.connect(_on_player_died)
	_player.landed.connect(_on_player_landed)

	var camera: Camera2D = _player.camera
	camera.limit_left = int(_bounds.position.x)
	camera.limit_top = int(_bounds.position.y)
	camera.limit_right = int(_bounds.end.x)
	camera.limit_bottom = int(_bounds.end.y)

	if _boss and is_instance_valid(_boss):
		var arena := _bounds
		var arena_data: Array = _data.get("arena", [])
		if arena_data.size() >= 4:
			arena = Rect2(
				float(arena_data[0]) * LevelBuilder.TILE,
				float(arena_data[1]) * LevelBuilder.TILE,
				float(arena_data[2]) * LevelBuilder.TILE,
				float(arena_data[3]) * LevelBuilder.TILE)
		_boss.setup(arena, _player)


func _wire_signals() -> void:
	for chip in _built["chips"]:
		chip.collected.connect(_on_chip_collected)
	for checkpoint in _built["checkpoints"]:
		checkpoint.activated.connect(_on_checkpoint)
	for enemy in _built["enemies"]:
		enemy.touched_player.connect(_kill_player)
	for hazard in _built["hazards"]:
		hazard.touched.connect(_kill_player)
	if _goal:
		_goal.reached.connect(_on_goal_reached)
	if _boss and is_instance_valid(_boss):
		_boss.touched_player.connect(_kill_player)
		_boss.defeated.connect(_on_boss_defeated)
		if _goal:
			_goal.set_locked(true)


func _kill_player() -> void:
	if _finished:
		return
	_player.kill()


func _on_player_died() -> void:
	_deaths += 1
	_hud.set_deaths(_deaths)
	_hud.show_toast("Systemausfall – Neustart am letzten Checkpoint", 1.8)
	_spawn_burst(_player.global_position, Color(1.0, 0.3, 0.45))
	await get_tree().create_timer(0.85).timeout
	if not _finished and is_inside_tree():
		_player.respawn(_respawn_point)


func _on_player_landed() -> void:
	_spawn_burst(_player.global_position + Vector2(0.0, 14.0), Color(0.7, 0.8, 1.0, 0.8), 12, 130.0)


func _on_chip_collected() -> void:
	_chips_collected += 1
	_hud.set_chips(_chips_collected, _chips_total)
	if _chips_collected >= _chips_total:
		_hud.show_toast("Alle Datenchips gesichert!", 2.2)


func _on_checkpoint(position: Vector2) -> void:
	_respawn_point = position
	_hud.show_toast("Checkpoint aktiviert", 1.6)


func _on_goal_reached() -> void:
	_complete_level()


func _on_boss_defeated() -> void:
	_spawn_burst(_boss.global_position, Color(1.0, 0.9, 0.4))
	if _goal:
		_goal.set_locked(false)
	_hud.show_toast("Sicherheitsschloss offen – zum Terminal!", 2.5)


func _complete_level() -> void:
	if _finished:
		return
	_finished = true
	_running = false
	_player.set_control(false)
	GameState.play_sfx("complete")
	var previous_best: float = GameState.best_times.get(GameState.current_level, INF)
	GameState.set_best_time(GameState.current_level, _time)
	_result.show_result(
		String(_data.get("name", "Sektor")),
		_chips_collected, _chips_total, _deaths, _time, previous_best,
		GameState.current_level >= GameState.MAX_LEVEL)


func _toggle_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	get_tree().paused = _paused
	_pause.visible = _paused
	if _paused:
		_pause.open()


func _restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _go_to_next_level() -> void:
	get_tree().paused = false
	GameState.current_level = mini(GameState.current_level + 1, GameState.MAX_LEVEL)
	get_tree().reload_current_scene()


func _go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)


func _spawn_burst(at: Vector2, color: Color, amount := 24, max_speed := 240.0) -> void:
	var particles := GPUParticles2D.new()
	particles.amount = amount
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.texture = load("res://assets/fx/particle.png")
	particles.position = at
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 6.0
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = max_speed * 0.4
	material.initial_velocity_max = max_speed
	material.gravity = Vector3(0, 500, 0)
	material.color = color
	particles.process_material = material
	world.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)
