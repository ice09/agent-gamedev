extends Area2D
class_name BossShot

signal touched_player

var velocity := Vector2.ZERO
var lifetime := 2.6


func setup(start: Vector2, shot_velocity: Vector2) -> void:
	position = start
	velocity = shot_velocity


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := CircleShape2D.new()
	shape.radius = 5.0
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	var glow := Sprite2D.new()
	glow.texture = load("res://assets/fx/glow.png")
	glow.scale = Vector2(0.5, 0.5)
	glow.modulate = Color(1.0, 0.45, 0.35)
	add_child(glow)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched_player.emit()
		queue_free()
