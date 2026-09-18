extends CharacterBody2D
class_name Player

signal died
signal landed

const SPRITE_SHEET := "res://assets/sprites/player.png"
const CELL := Vector2i(24, 32)

@export var speed := 260.0
@export var acceleration := 1900.0
@export var friction := 2600.0
@export var gravity := 1850.0
@export var jump_velocity := -560.0
@export var double_jump_velocity := -470.0
@export var max_fall_speed := 950.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
@export var invulnerability_time := 1.3

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera

var _coyote := 0.0
var _buffer := 0.0
var _jumps_left := 2
var _invuln := 0.0
var _control_enabled := true
var _was_on_floor := false


func _ready() -> void:
	sprite.sprite_frames = SpriteFramesUtil.build(SPRITE_SHEET, CELL, {
		"idle": {"frames": [[0, 0], [1, 0]], "fps": 4},
		"run": {"frames": [[0, 1], [1, 1], [2, 1], [3, 1]], "fps": 13},
		"jump": {"frames": [[0, 2], [1, 2]], "fps": 6, "loop": false},
		"fall": {"frames": [[0, 3], [1, 3]], "fps": 6, "loop": false},
		"hit": {"frames": [[0, 4]], "fps": 1, "loop": false},
	})
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)

	var on_floor := is_on_floor()
	if on_floor:
		_coyote = coyote_time
		_jumps_left = 2
	else:
		_coyote = maxf(_coyote - delta, 0.0)

	if _control_enabled:
		_read_movement(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if not on_floor:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	var fall_speed := velocity.y
	move_and_slide()

	var now_on_floor := is_on_floor()
	if now_on_floor and not _was_on_floor and fall_speed > 320.0:
		GameState.play_sfx("land")
		landed.emit()
	_was_on_floor = now_on_floor

	camera.offset.x = lerpf(camera.offset.x, velocity.x * 0.22, 0.1)

	if _control_enabled:
		_animate(now_on_floor)


func _read_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer_time
	else:
		_buffer = maxf(_buffer - delta, 0.0)

	if _buffer > 0.0:
		if _coyote > 0.0:
			_do_jump(jump_velocity)
			_buffer = 0.0
			_coyote = 0.0
			_jumps_left = 1
		elif _jumps_left > 0:
			_do_jump(double_jump_velocity)
			_buffer = 0.0
			_jumps_left -= 1

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45


func _do_jump(velocity_y: float) -> void:
	velocity.y = velocity_y
	GameState.play_sfx("jump")


func _animate(on_floor: bool) -> void:
	if not on_floor:
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif absf(velocity.x) > 12.0:
		sprite.play("run")
	else:
		sprite.play("idle")


func _update_invulnerability(delta: float) -> void:
	if _invuln > 0.0:
		_invuln -= delta
		sprite.modulate.a = 0.4 if int(_invuln * 20.0) % 2 == 0 else 1.0
	elif sprite.modulate.a != 1.0:
		sprite.modulate.a = 1.0


func is_invulnerable() -> bool:
	return _invuln > 0.0


func set_control(enabled: bool) -> void:
	_control_enabled = enabled
	if not enabled:
		velocity.x = 0.0


func kill() -> void:
	if _invuln > 0.0 or not _control_enabled:
		return
	_control_enabled = false
	velocity = Vector2.ZERO
	sprite.play("hit")
	GameState.play_sfx("death")
	died.emit()


func respawn(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	_control_enabled = true
	_invuln = invulnerability_time
	_jumps_left = 2
	_coyote = 0.0
	_was_on_floor = false
	sprite.modulate.a = 1.0
	sprite.play("idle")


func bounce(strength: float) -> void:
	velocity.y = -strength
	_jumps_left = 2
