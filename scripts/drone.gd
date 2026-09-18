extends Area2D
class_name Drone

signal touched_player

const SHEET := "res://assets/sprites/drone.png"

var speed := 70.0
var patrol_pixels := 80.0
var hover_pixels := 10.0

var _origin := Vector2.ZERO
var _direction := 1.0
var _time := 0.0
var _anim: AnimatedSprite2D


func setup(patrol_tiles: float, fly_speed: float = 70.0, hover: float = 10.0) -> void:
	patrol_pixels = patrol_tiles * 16.0
	speed = fly_speed
	hover_pixels = hover


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := RectangleShape2D.new()
	shape.size = Vector2(22.0, 20.0)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.sprite_frames = SpriteFramesUtil.build(SHEET, Vector2i(24, 24), {
		"fly": {"frames": [[0, 0], [1, 0], [2, 0], [3, 0]], "fps": 12},
	})
	_anim.play("fly")
	add_child(_anim)

	body_entered.connect(_on_body_entered)
	_origin = position


func _physics_process(delta: float) -> void:
	_time += delta
	position.x += _direction * speed * delta
	if absf(position.x - _origin.x) >= patrol_pixels:
		_direction *= -1.0
		_anim.flip_h = _direction < 0.0
	position.y = _origin.y + sin(_time * 2.5) * hover_pixels


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched_player.emit()
