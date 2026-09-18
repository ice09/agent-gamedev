extends Node2D

const PICKUP_COLOR := Color(0.35, 0.9, 0.55)
const HAZARD_COLOR := Color(0.95, 0.35, 0.35)
const PLAYER_HALF := 16.0
const PICKUP_HALF := 14.0
const HAZARD_HALF := 16.0
const SPAWN_MARGIN := 40.0
const MIN_SPAWN_DISTANCE := 90.0

@export var pickup_count := 5
@export var hazard_count := 3
@export var hazard_min_speed := 90.0
@export var hazard_max_speed := 170.0

@onready var player: Node2D = $Player
@onready var score_label: Label = $UI/ScoreLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var restart_button: Button = $UI/RestartButton

var score := 0
var running := true
var pickups: Array[Node2D] = []
var hazards: Array[Node2D] = []


func _ready() -> void:
	restart_button.pressed.connect(_start_round)
	_start_round()


func _physics_process(delta: float) -> void:
	if not running:
		return
	_move_hazards(delta)
	_check_pickups()
	_check_hazards()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_start_round()


func _start_round() -> void:
	for node in pickups + hazards:
		node.queue_free()
	pickups.clear()
	hazards.clear()

	score = 0
	running = true
	score_label.text = "Punkte: 0"
	message_label.text = "Sammle die grünen Kisten.\nWeiche den roten Gefahren aus.\nWASD oder Pfeiltasten zum Bewegen."
	restart_button.visible = false

	player.position = _field_size() * 0.5
	player.visible = true
	player.set_physics_process(true)

	for i in pickup_count:
		_spawn_pickup()
	for i in hazard_count:
		_spawn_hazard()


func _field_size() -> Vector2:
	return get_viewport_rect().size


func _random_point() -> Vector2:
	var size := _field_size()
	var point := Vector2.ZERO
	for attempt in 100:
		point = Vector2(
			randf_range(SPAWN_MARGIN, size.x - SPAWN_MARGIN),
			randf_range(SPAWN_MARGIN, size.y - SPAWN_MARGIN))
		if point.distance_to(player.position) >= MIN_SPAWN_DISTANCE:
			return point
	return point


func _make_block(at: Vector2, half: float, color: Color) -> Node2D:
	var node := Node2D.new()
	node.position = at
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half)])
	body.color = color
	node.add_child(body)
	add_child(node)
	return node


func _spawn_pickup() -> void:
	pickups.append(_make_block(_random_point(), PICKUP_HALF, PICKUP_COLOR))


func _spawn_hazard() -> void:
	var hazard := _make_block(_random_point(), HAZARD_HALF, HAZARD_COLOR)
	var velocity := Vector2.from_angle(randf() * TAU) * randf_range(hazard_min_speed, hazard_max_speed)
	hazard.set_meta("velocity", velocity)
	hazards.append(hazard)


func _move_hazards(delta: float) -> void:
	var size := _field_size()
	for hazard in hazards:
		var velocity: Vector2 = hazard.get_meta("velocity")
		var pos: Vector2 = hazard.position + velocity * delta
		if pos.x < SPAWN_MARGIN or pos.x > size.x - SPAWN_MARGIN:
			velocity.x = -velocity.x
			pos.x = clampf(pos.x, SPAWN_MARGIN, size.x - SPAWN_MARGIN)
		if pos.y < SPAWN_MARGIN or pos.y > size.y - SPAWN_MARGIN:
			velocity.y = -velocity.y
			pos.y = clampf(pos.y, SPAWN_MARGIN, size.y - SPAWN_MARGIN)
		hazard.position = pos
		hazard.set_meta("velocity", velocity)


# ponytail: AABB-Kontakt statt Physik-Bodies, reicht für ~10 Quadrate
func _touches(node: Node2D, half: float) -> bool:
	var offset := (player.position - node.position).abs()
	return offset.x < PLAYER_HALF + half and offset.y < PLAYER_HALF + half


func _check_pickups() -> void:
	for i in range(pickups.size() - 1, -1, -1):
		if _touches(pickups[i], PICKUP_HALF):
			pickups[i].queue_free()
			pickups.remove_at(i)
			score += 1
			score_label.text = "Punkte: %d" % score
			_spawn_pickup()


func _check_hazards() -> void:
	for hazard in hazards:
		if _touches(hazard, HAZARD_HALF):
			_end_round()
			return


func _end_round() -> void:
	running = false
	player.visible = false
	player.set_physics_process(false)
	message_label.text = "Getroffen!\nPunkte: %d\nR oder Knopf für eine neue Runde." % score
	restart_button.visible = true
