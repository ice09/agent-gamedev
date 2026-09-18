extends Node2D
## Swept collision avoids tunnelling even at low physics tick rates.

var combat: Node2D
var velocity := Vector2.ZERO
var friendly := true
var lifetime := 2.5
var spent := false


func _ready() -> void:
	rotation = velocity.angle()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if spent or not combat.active:
		return
	var next := global_position + velocity * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next, 5 if friendly else 3)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		spent = true
		global_position = hit.position
		if hit.collider.has_method("take_damage"):
			hit.collider.take_damage(1)
		combat.burst(global_position, Color("c7b6ff") if friendly else Color("f4b976"), 5)
		queue_free()
		return
	global_position = next
	lifetime -= delta
	if lifetime <= 0.0 or global_position.y > 900 or global_position.y < -100:
		spent = true
		queue_free()


func _draw() -> void:
	if friendly:
		draw_line(Vector2(-22, 0), Vector2(4, 0), Color(0.55, 0.35, 1.0, 0.25), 9, true)
		draw_line(Vector2(-16, 0), Vector2(4, 0), Color("bca2ff"), 3, true)
		draw_line(Vector2(-7, 0), Vector2(5, 0), Color("f0e8ff"), 1.5, true)
	else:
		draw_circle(Vector2.ZERO, 11, Color(1.0, 0.46, 0.25, 0.13))
		draw_circle(Vector2.ZERO, 5, Color("ef9868"))
		draw_arc(Vector2.ZERO, 7, 0, TAU, 18, Color("f5cda0"), 1, true)
