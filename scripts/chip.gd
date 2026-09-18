extends Area2D
class_name Chip

signal collected

const SHEET := "res://assets/sprites/chip.png"


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := CircleShape2D.new()
	shape.radius = 9.0
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	var anim := AnimatedSprite2D.new()
	anim.name = "Anim"
	anim.sprite_frames = SpriteFramesUtil.build(SHEET, Vector2i(12, 12), {
		"spin": {"frames": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0]], "fps": 9},
	})
	anim.play("spin")
	add_child(anim)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.play_sfx("chip")
		collected.emit()
		queue_free()
