extends Area2D
class_name Walker

signal touched_player

const SHEET := "res://assets/sprites/walker.png"

var speed := 55.0
var patrol_pixels := 64.0

var _origin_x := 0.0
var _direction := 1.0
var _anim: AnimatedSprite2D


func setup(patrol_tiles: float, walk_speed: float = 55.0) -> void:
	patrol_pixels = patrol_tiles * 16.0
	speed = walk_speed


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
		"walk": {"frames": [[0, 0], [1, 0], [2, 0], [3, 0]], "fps": 8},
	})
	_anim.play("walk")
	add_child(_anim)

	body_entered.connect(_on_body_entered)
	_origin_x = position.x


func _physics_process(delta: float) -> void:
	position.x += _direction * speed * delta
	if absf(position.x - _origin_x) >= patrol_pixels:
		_direction *= -1.0
		_anim.flip_h = _direction < 0.0


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched_player.emit()
