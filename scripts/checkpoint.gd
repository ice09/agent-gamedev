extends Area2D
class_name Checkpoint

signal activated(spawn_position: Vector2)

const SHEET := "res://assets/sprites/checkpoint.png"

var active := false
var _anim: AnimatedSprite2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := RectangleShape2D.new()
	shape.size = Vector2(20.0, 30.0)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.sprite_frames = SpriteFramesUtil.build(SHEET, Vector2i(16, 24), {
		"off": {"frames": [[0, 0]], "fps": 1, "loop": false},
		"on": {"frames": [[1, 0]], "fps": 1, "loop": false},
	})
	_anim.play("off")
	add_child(_anim)

	var light := PointLight2D.new()
	light.texture = load("res://assets/fx/glow.png")
	light.texture_scale = 1.6
	light.energy = 0.7
	light.color = Color(1.0, 0.35, 0.78)
	light.position = Vector2(0.0, -6.0)
	add_child(light)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not active:
		active = true
		_anim.play("on")
		GameState.play_sfx("checkpoint")
		activated.emit(global_position + Vector2(0.0, -8.0))
