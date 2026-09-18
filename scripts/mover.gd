extends AnimatableBody2D
class_name Mover

var move_axis := Vector2.RIGHT
var distance_pixels := 80.0
var speed := 60.0
var size_tiles := Vector2i(3, 1)

var _origin := Vector2.ZERO
var _phase := 0.0


func setup(size: Vector2i, axis: Vector2, distance_tiles: float, move_speed: float) -> void:
	size_tiles = size
	move_axis = axis.normalized()
	distance_pixels = distance_tiles * 16.0
	speed = move_speed


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	_origin = position

	var half := Vector2(size_tiles) * 8.0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size_tiles) * 16.0
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y)])
	body.color = Color(0.16, 0.15, 0.26)
	add_child(body)

	var edge := Line2D.new()
	edge.points = PackedVector2Array([Vector2(-half.x, -half.y), Vector2(half.x, -half.y)])
	edge.width = 2.0
	edge.default_color = Color(0.24, 0.94, 1.0)
	add_child(edge)


func _physics_process(delta: float) -> void:
	_phase = fposmod(_phase + speed * delta, distance_pixels * 2.0)
	var travelled := _phase if _phase < distance_pixels else distance_pixels * 2.0 - _phase
	position = _origin + move_axis * travelled
