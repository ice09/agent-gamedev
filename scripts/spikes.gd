extends Area2D
class_name Spikes

signal touched

var _cooldown := 0.0


func setup(rect: Rect2) -> void:
	position = rect.position + rect.size * 0.5
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	_cooldown = 0.25
	for body in get_overlapping_bodies():
		if body is Player:
			touched.emit()
			return


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched.emit()
