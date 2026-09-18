extends CharacterBody2D
signal shot(origin: Vector2, direction: Vector2)
signal damaged
signal died
## Movement adapted from the parent project's player, without its game/audio dependencies.

@export var speed := 290.0
@export var acceleration := 1900.0
@export var friction := 2600.0
@export var gravity := 1550.0
@export var jump_velocity := -570.0
@export var max_fall_speed := 900.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
const MAX_HEALTH := 6
const FIRE_INTERVAL := 0.22
var health := MAX_HEALTH
var invulnerability := 0.0
var fire_cooldown := 0.0
var aim_direction := Vector2.RIGHT
var aiming := false
var armed := false
var muzzle_flash := 0.0
var hurt_flash := 0.0
var control_enabled := true
var facing := 1.0
var _coyote := 0.0
var _buffer := 0.0
@onready var _visual_scale: Vector2 = $Visual.scale.abs()


func _physics_process(delta: float) -> void:
	invulnerability = maxf(invulnerability - delta, 0.0)
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	muzzle_flash = maxf(muzzle_flash - delta, 0.0)
	hurt_flash = maxf(hurt_flash - delta, 0.0)
	_coyote = coyote_time if is_on_floor() else maxf(_coyote - delta, 0.0)
	var direction := Input.get_axis("move_left", "move_right") if control_enabled else 0.0
	velocity.x = move_toward(velocity.x, direction * speed, (acceleration if direction else friction) * delta)
	if direction:
		facing = signf(direction)
	aiming = armed and control_enabled and Input.is_action_pressed("shoot")
	if aiming:
		var shoulder := global_position + Vector2(-9.0 * facing, -81.0) * _visual_scale
		aim_direction = (get_global_mouse_position() - shoulder).normalized() if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else Vector2(facing, 0)
		if absf(aim_direction.x) > 0.05:
			facing = signf(aim_direction.x)
		try_shoot()
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	if control_enabled:
		_buffer = jump_buffer_time if Input.is_action_just_pressed("jump") else maxf(_buffer - delta, 0.0)
		if _buffer > 0.0 and _coyote > 0.0:
			velocity.y = jump_velocity
			_buffer = 0.0
			_coyote = 0.0
		# A buffered tap also produces a short jump if its key is already released.
		if not Input.is_action_pressed("jump") and velocity.y < jump_velocity * 0.45:
			velocity.y = jump_velocity * 0.45
	else:
		_buffer = 0.0
	move_and_slide()
	position.x = clampf(position.x, 18.0, 3822.0)
	_update_visual_transform()


func respawn(at: Vector2) -> void:
	position = at
	velocity = Vector2.ZERO
	_coyote = 0.0
	_buffer = 0.0
	facing = 1.0
	_update_visual_transform()
	reset_physics_interpolation()
	invulnerability = 1.25
	$Visual.modulate = Color.WHITE


func _update_visual_transform() -> void:
	# Preserve the authored size in both directions and after respawning.
	var turned: bool = $Visual.transform.x.x * facing < 0.0
	$Visual.transform = Transform2D(Vector2(facing * _visual_scale.x, 0), Vector2(0, _visual_scale.y), Vector2.ZERO)
	if turned:
		$Visual.reset_physics_interpolation()


func try_shoot() -> bool:
	if not armed or not control_enabled or health <= 0 or fire_cooldown > 0.0 or aim_direction.is_zero_approx():
		return false
	fire_cooldown = FIRE_INTERVAL
	muzzle_flash = 0.065
	shot.emit(global_position + Vector2(-9.0 * facing, -81.0) * _visual_scale, aim_direction.normalized())
	return true


func take_damage(amount: int = 1, ignore_invulnerability: bool = false) -> bool:
	if health <= 0 or (invulnerability > 0.0 and not ignore_invulnerability):
		return false
	health = maxi(0, health - amount)
	invulnerability = 1.1
	hurt_flash = 0.2
	damaged.emit()
	if health == 0:
		control_enabled = false
		aiming = false
		died.emit()
	return true


func heal(amount: int = 1) -> void:
	health = mini(MAX_HEALTH, health + amount)


func restore() -> void:
	health = MAX_HEALTH
	fire_cooldown = 0.0
	muzzle_flash = 0.0
	hurt_flash = 0.0
	aiming = false
	aim_direction = Vector2.RIGHT
