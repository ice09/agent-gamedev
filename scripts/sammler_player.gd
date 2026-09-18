extends Node2D

@export var speed := 320.0
@export var field_margin := 20.0


func _physics_process(delta: float) -> void:
	var direction := _read_direction()
	if direction == Vector2.ZERO:
		return
	position += direction.normalized() * speed * delta
	_clamp_to_field()


func _read_direction() -> Vector2:
	var left := Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right")
	var up := Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up")
	var down := Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down")
	return Vector2(float(right) - float(left), float(down) - float(up))


func _clamp_to_field() -> void:
	var size := get_viewport_rect().size
	position.x = clampf(position.x, field_margin, size.x - field_margin)
	position.y = clampf(position.y, field_margin, size.y - field_margin)
