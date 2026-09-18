extends Area2D
class_name Boss

signal defeated
signal touched_player

const SHEET := "res://assets/sprites/boss.png"

@export var max_hits := 3
@export var charge_speed := 240.0
@export var hover_height := 10.0

var hits := 0
var _state := "idle"
var _timer := 1.6
var _time := 0.0
var _charge_direction := 0.0
var _player: Player
var _origin := Vector2.ZERO
var _arena := Rect2()
var _anim: AnimatedSprite2D
var _rng := RandomNumberGenerator.new()
var _contact_cooldown := 0.0


func setup(arena: Rect2, player: Player) -> void:
	_arena = arena
	_player = player
	_rng.randomize()


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

	var shape := RectangleShape2D.new()
	shape.size = Vector2(44.0, 40.0)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.sprite_frames = SpriteFramesUtil.build(SHEET, Vector2i(48, 48), {
		"idle": {"frames": [[0, 0], [1, 0]], "fps": 4},
		"charge": {"frames": [[2, 0]], "fps": 1, "loop": false},
		"hurt": {"frames": [[3, 0]], "fps": 1, "loop": false},
	})
	_anim.play("idle")
	add_child(_anim)

	body_entered.connect(_on_body_entered)
	_origin = position


func _physics_process(delta: float) -> void:
	_time += delta
	_contact_cooldown -= delta
	if _contact_cooldown <= 0.0:
		_contact_cooldown = 0.25
		for body in get_overlapping_bodies():
			if body is Player:
				_resolve_contact(body)
				break
	match _state:
		"idle":
			position.y = _origin.y + sin(_time * 2.0) * hover_height
			_timer -= delta
			if _timer <= 0.0:
				_pick_attack()
		"charge":
			position.x += _charge_direction * charge_speed * delta
			position.y = _origin.y + sin(_time * 6.0) * 4.0
			position.x = clampf(position.x, _arena.position.x + 30.0, _arena.end.x - 30.0)
			_timer -= delta
			if _timer <= 0.0 or position.x <= _arena.position.x + 31.0 or position.x >= _arena.end.x - 31.0:
				_state = "idle"
				_timer = 1.4
				_anim.play("idle")


func _pick_attack() -> void:
	if _rng.randf() < 0.55:
		_state = "charge"
		_timer = 0.7
		_anim.play("charge")
		_charge_direction = signf(_player.global_position.x - global_position.x)
		if _charge_direction == 0.0:
			_charge_direction = 1.0
		if _anim:
			_anim.flip_h = _charge_direction < 0.0
	else:
		_burst()
		_state = "idle"
		_timer = 1.5


func _burst() -> void:
	for angle in [Vector2(-0.35, 1.0), Vector2(0.0, 1.0), Vector2(0.35, 1.0)]:
		var shot := BossShot.new()
		shot.setup(global_position + Vector2(0.0, 18.0), angle.normalized() * 260.0)
		get_parent().add_child(shot)
		shot.touched_player.connect(func() -> void: touched_player.emit())


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_resolve_contact(body)


func _resolve_contact(player: Player) -> void:
	if hits >= max_hits:
		return
	var stomp := player.velocity.y > 40.0 and player.global_position.y < global_position.y - 6.0
	if stomp:
		_take_hit(player)
	elif not player.is_invulnerable():
		touched_player.emit()


func _take_hit(player: Player) -> void:
	if hits >= max_hits:
		return
	hits += 1
	player.bounce(430.0)
	_anim.play("hurt")
	modulate = Color(1.6, 0.8, 0.8)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)
	GameState.play_sfx("hit")
	if hits >= max_hits:
		_defeat()


func _defeat() -> void:
	GameState.play_sfx("complete")
	defeated.emit()
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
