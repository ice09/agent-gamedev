extends Area2D
class_name GoalTerminal

signal reached

const SHEET := "res://assets/sprites/terminal.png"

var locked := false
var _anim: AnimatedSprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 36.0)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.sprite_frames = SpriteFramesUtil.build(SHEET, Vector2i(24, 32), {
		"idle": {"frames": [[0, 0], [1, 0], [2, 0], [3, 0]], "fps": 6},
	})
	_anim.play("idle")
	add_child(_anim)

	var light := PointLight2D.new()
	light.texture = load("res://assets/fx/glow.png")
	light.texture_scale = 2.0
	light.energy = 0.9
	light.color = Color(0.3, 0.9, 1.0)
	light.position = Vector2(0.0, -4.0)
	add_child(light)

	body_entered.connect(_on_body_entered)


func set_locked(value: bool) -> void:
	locked = value
	modulate = Color(0.6, 0.6, 0.7) if locked else Color(1, 1, 1)
	if not locked:
		for body in get_overlapping_bodies():
			if body is Player:
				reached.emit()
				break


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not locked:
		reached.emit()
