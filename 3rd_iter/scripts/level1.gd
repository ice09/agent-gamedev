extends Node2D
## Playable traversal through the separately authored environment artwork.

const CAMERA_MIN := 640.0
const CAMERA_MAX := 3200.0
const PRACTICE_PLATFORMS := [0, 2, 5]
const SECTOR_NAMES := ["01 / WARTUNGSZUGANG", "02 / STILLGELEGTER AUFZUG", "03 / LÜFTUNGSHALLE"]
@export var combat_enabled := true
var game_over := false
var paused := false
var touring := false
var tour_direction := 1.0
var effects_enabled := true
var clock := 0.0
var checkpoint_index := 0
var checkpoint := Vector2(160, 507)
var falls := 0
var completed := false
@onready var camera: Camera2D = $Camera2D
@onready var player = $Player
@onready var combat = $Combat
@onready var atmosphere: ShaderMaterial = $Atmosphere/Overlay.material


func _ready() -> void:
	player.armed = combat_enabled
	player.died.connect(_on_player_died)
	player.damaged.connect(func(): combat.play_sound("hurt"))
	$HUD/Outcome/Panel/Restart.pressed.connect(func(): jump_to_sector(0))
	$HUD/Outcome/Panel/Resume.pressed.connect(toggle_pause)
	jump_to_sector(0)
	update_view()


func _physics_process(delta: float) -> void:
	var playing := not paused and not game_over and not completed
	combat.active = combat_enabled and playing
	player.set_physics_process(playing)
	player.get_node("Visual").set_process(playing)
	if not playing:
		player.control_enabled = false
		return
	if Input.get_axis("move_left", "move_right") or Input.is_action_just_pressed("jump"):
		touring = false
	player.control_enabled = not touring and not completed
	if player.position.y > 780.0:
		falls += 1
		if combat_enabled:
			player.take_damage(1, true)
			combat.clear_hostile_shots()
			if player.health <= 0:
				return
		player.respawn(checkpoint)
		camera.position.x = clampf(checkpoint.x + 80.0, CAMERA_MIN, CAMERA_MAX)
		camera.reset_physics_interpolation()
		camera.force_update_scroll()
	if player.is_on_floor():
		for index in $WalkableSurfaces.get_child_count():
			var surface: CollisionShape2D = $WalkableSurfaces.get_child(index)
			var top: float = surface.position.y - surface.shape.size.y * 0.5
			if absf(player.position.y - top) < 2.0 and absf(player.position.x - surface.position.x) < surface.shape.size.x * 0.5:
				if index != checkpoint_index:
					checkpoint_index = index
					checkpoint = Vector2(surface.position.x, top - 1.0)
				if index == 6 and player.position.x >= 3720.0 and (not combat_enabled or combat.remaining() == 0):
					completed = true
					player.control_enabled = false
					combat.active = false
				break
	# Camera and player transforms share the physics clock; Godot interpolates both.
	if touring:
		move_camera(tour_direction * 90.0 * delta)
		if camera.position.x >= CAMERA_MAX or camera.position.x <= CAMERA_MIN:
			tour_direction *= -1.0
	else:
		var target := clampf(player.position.x + player.velocity.x * 0.25, CAMERA_MIN, CAMERA_MAX)
		camera.position.x = lerpf(camera.position.x, target, 1.0 - exp(-8.0 * delta))


func _process(delta: float) -> void:
	if effects_enabled and not paused and not game_over and not completed:
		clock += delta
		atmosphere.set_shader_parameter("clock", clock)
	update_view()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1, KEY_2, KEY_3:
			if not combat_enabled:
				jump_to_sector(event.physical_keycode - KEY_1)
		KEY_R, KEY_HOME:
			jump_to_sector(0)
		KEY_T:
			if not combat_enabled:
				touring = not touring
				if camera.position.x >= CAMERA_MAX:
					tour_direction = -1.0
		KEY_ESCAPE:
			toggle_pause()
		KEY_M:
			combat.set_muted(not combat.muted)
		KEY_H:
			$HUD.visible = not $HUD.visible
		KEY_F:
			set_effects(not effects_enabled)
		_:
			return
	get_viewport().set_input_as_handled()


func move_camera(distance: float) -> void:
	camera.position.x = clampf(camera.position.x + distance, CAMERA_MIN, CAMERA_MAX)


func jump_to_sector(index: int) -> void:
	paused = false
	game_over = false
	touring = false
	completed = false
	falls = 0
	combat.reset_encounter(combat_enabled)
	player.restore()
	player.set_physics_process(true)
	player.get_node("Visual").set_process(true)
	checkpoint_index = PRACTICE_PLATFORMS[clampi(index, 0, 2)]
	var surface: CollisionShape2D = $WalkableSurfaces.get_child(checkpoint_index)
	checkpoint = Vector2(160 if checkpoint_index == 0 else surface.position.x, surface.position.y - surface.shape.size.y * 0.5 - 1.0)
	player.respawn(checkpoint)
	player.control_enabled = true
	camera.position.x = clampf(checkpoint.x, CAMERA_MIN, CAMERA_MAX)
	camera.reset_physics_interpolation()
	camera.force_update_scroll()
	update_view()


func set_effects(enabled: bool) -> void:
	effects_enabled = enabled
	atmosphere.set_shader_parameter("effects_enabled", enabled)
	$Machinery.effects_enabled = enabled


func update_view() -> void:
	atmosphere.set_shader_parameter("camera_left", camera.position.x - CAMERA_MIN)
	var sector := clampi(int(player.position.x / 1280.0), 0, 2)
	$HUD/Bottom/Location.text = SECTOR_NAMES[sector]
	$HUD/Bottom/Progress.value = clampf((player.position.x - 160.0) / (3720.0 - 160.0) * 100.0, 0.0, 100.0)
	$HUD/Telemetry.text = "CHECKPOINT %02d / 07    ·    STÜRZE %d\nTIEFE −840 M    ·    SEKTOR %02d\n%s" % [checkpoint_index + 1, falls, sector + 1, "KAMERATOUR · BEWEGEN ZUM SPIELEN" if touring else "ERREICHE DEN ÖSTLICHEN AUSGANG"]
	$HUD/Subtitle.text = "AUSGANG ERREICHT!  R zum Neustarten." if completed else "Überquere die Wartungsstege zum östlichen Ausgang."
	$HUD/Suit.visible = combat_enabled
	$HUD/Boss.visible = false
	if combat_enabled:
		$HUD/Suit/Value.value = player.health
		$HUD/Suit/Label.text = "ANZUG  %d / 6" % player.health
		$HUD/Telemetry.text = "BEDROHUNGEN %02d / 08    ·    PUNKTE %04d\nCHECKPOINT %02d    ·    STÜRZE %d\n%s" % [combat.remaining(), combat.score, checkpoint_index + 1, falls, "TON AUS · M" if combat.muted else "VIOLETTER IMPULS / UNBEGRENZTE MUNITION"]
		$HUD/Subtitle.text = "Maus halten: zielen & feuern  ·  J: geradeaus schießen"
		$WorldSigns/Exit.text = "AUSGANG →" if combat.remaining() == 0 else "SIGNALBLOCKADE"
		var boss = combat.boss()
		if is_instance_valid(boss) and absf(player.position.x - boss.position.x) < 700:
			$HUD/Boss.visible = true
			$HUD/Boss/Value.value = boss.health
			$HUD/Boss/Label.text = "NULLKANTOR  /  " + ("ÜBERLASTUNG" if boss.health <= 12 else "TRÄGERSIGNAL")
	var outcome := paused or game_over or completed
	$HUD/Outcome.visible = outcome
	if outcome:
		$HUD.visible = true
		$HUD/Outcome/Panel/Heading.text = "SIGNAL ERLOSCHEN" if game_over else ("SEKTOR BEFREIT" if completed else "PAUSE")
		$HUD/Outcome/Panel/Detail.text = ("Punkte %d  ·  Gegner %d / 8\nR: neu starten" % [combat.score, combat.kills]) if not paused else "Esc: fortsetzen  ·  R: neu starten"
		$HUD/Outcome/Panel/Resume.visible = paused


func _on_player_died() -> void:
	game_over = true
	combat.active = false
	update_view()


func toggle_pause() -> void:
	if not game_over and not completed:
		paused = not paused
		combat.active = combat_enabled and not paused
		update_view()
