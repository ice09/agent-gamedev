extends CharacterBody2D

signal defeated(enemy: CharacterBody2D)
const HEALTH := {"maw": 4, "jelly": 4, "choir": 5, "cantor": 24}
var combat: Node2D
var kind := "maw"
var origin := Vector2.ZERO
var bounds := Vector2.ZERO
var health := 4
var max_health := 4
var clock := 0.0
var cooldown := 1.0
var windup := 0.0
var charge := 0.0
var direction := -1.0
var locked_aim := Vector2.LEFT
var hit_flash := 0.0
var dead := false
var attacks := 0


func configure(type: String, at: Vector2, patrol: Vector2) -> void:
	kind = type
	origin = at
	position = at
	bounds = patrol
	max_health = HEALTH[kind]
	health = max_health


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 if kind == "maw" else 0
	var shape := CollisionShape2D.new()
	if kind == "maw":
		var box := RectangleShape2D.new()
		box.size = Vector2(68, 150)
		shape.shape = box
		shape.position.y = -75
	else:
		var circle := CircleShape2D.new()
		circle.radius = 72 if kind == "cantor" else (48 if kind == "choir" else 35)
		shape.shape = circle
	add_child(shape)
	reset_physics_interpolation()


func target_point() -> Vector2:
	return global_position + (Vector2(0, -105) if kind == "maw" else Vector2.ZERO)


func _physics_process(delta: float) -> void:
	if dead or not combat.active:
		return
	clock += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	var target: Vector2 = combat.player.global_position + Vector2(0, -90)
	var nearby := target.distance_to(target_point()) < (610.0 if kind == "cantor" else 480.0)
	if kind == "maw":
		charge = maxf(charge - delta, 0.0)
		velocity = Vector2(direction * (245.0 if charge > 0 else 42.0) if windup <= 0 else 0.0, minf(velocity.y + 1550.0 * delta, 900.0))
		move_and_slide()
		if position.x <= bounds.x or position.x >= bounds.y:
			position.x = clampf(position.x, bounds.x, bounds.y)
			direction = 1.0 if position.x <= bounds.x else -1.0
			charge = 0.0
	else:
		position = origin + Vector2(sin(clock * 0.8) * (24 if kind == "jelly" else 8), sin(clock * 1.6) * 10)
	if windup > 0.0:
		windup -= delta
		if windup <= 0.0:
			attack()
	elif nearby:
		cooldown -= delta
		if cooldown <= 0.0:
			locked_aim = (target - target_point()).normalized()
			windup = 0.75 if kind == "cantor" else 0.65
			if kind == "maw":
				direction = -1.0 if locked_aim.x < 0 else 1.0
	var player_bounds := Rect2(combat.player.global_position + Vector2(-18, -176), Vector2(36, 176))
	if player_bounds.grow(56 if kind == "cantor" else 30).has_point(target_point()):
		combat.player.take_damage(1)
	queue_redraw()


func attack() -> void:
	attacks += 1
	if kind == "maw":
		charge = 0.6
		cooldown = 1.7
		return
	var count := 1 if kind == "jelly" else 3
	if kind == "cantor":
		count = 5 if health <= max_health / 2 else 3
	for index in count:
		var angle := (index - (count - 1) * 0.5) * 0.19
		combat.spawn_projectile(target_point(), locked_aim.rotated(angle) * (245 if kind == "cantor" else 205), false)
	cooldown = (1.15 if health <= max_health / 2 else 1.9) if kind == "cantor" else 2.2
	combat.play_sound("enemy_fire")


func take_damage(amount: int) -> bool:
	if dead or not combat.active:
		return false
	health = maxi(0, health - amount)
	hit_flash = 0.13
	combat.burst(target_point(), Color("d8b5c9"), 5)
	combat.play_sound("impact")
	if health == 0:
		dead = true
		collision_layer = 0
		defeated.emit(self)
		queue_free()
	queue_redraw()
	return true


func _mask(center: Vector2, size: float, angle: float) -> void:
	draw_set_transform(center, angle, Vector2.ONE * size)
	var face := PackedVector2Array([Vector2(-17, -24), Vector2(14, -25), Vector2(22, -7), Vector2(12, 23), Vector2(0, 30), Vector2(-15, 14), Vector2(-23, -7)])
	draw_colored_polygon(face, Color("b4bdaf") if hit_flash <= 0 else Color("f2dfe8"))
	draw_polyline(PackedVector2Array([Vector2(-17, -24), Vector2(14, -25), Vector2(22, -7), Vector2(12, 23), Vector2(0, 30), Vector2(-15, 14), Vector2(-23, -7), Vector2(-17, -24)]), Color("3c5156"), 2, true)
	draw_line(Vector2(-14, -7), Vector2(-4, -4), Color("101924"), 4, true)
	draw_line(Vector2(5, -4), Vector2(15, -8), Color("101924"), 4, true)
	draw_circle(Vector2(0, 11), 7 + (3 if windup > 0 else 0), Color("090e19"))
	draw_line(Vector2(0, -23), Vector2(-2, -12), Color("526f6b"), 1.5, true)
	draw_set_transform(Vector2.ZERO)


func _draw() -> void:
	var warning := Color("ffc58a") if windup > 0 else Color("c08493")
	var core := Color("d1e2ce") if hit_flash > 0 else Color("768b82")
	if kind == "maw":
		for side in [-1, 1]:
			for index in 3:
				var foot := Vector2(side * (42 + index * 13), -3 - maxf(0, sin(clock * 7 + index * 2 + side)) * 9)
				var knee := Vector2(side * (65 + index * 5), -66 + index * 13)
				draw_polyline(PackedVector2Array([Vector2(side * 18, -104 + index * 12), knee, foot]), Color("0b1520"), 11, true)
				draw_polyline(PackedVector2Array([Vector2(side * 18, -104 + index * 12), knee, foot]), core, 3, true)
				draw_circle(knee, 4, warning)
		for index in 5:
			draw_arc(Vector2(0, -96 + index * 8), 26 - index * 2, 0.1, PI - 0.1, 20, core, 4, true)
		draw_circle(Vector2(0, -114), 30, Color("141d29"))
		draw_arc(Vector2(0, -114), 31, 0, TAU, 32, core, 4, true)
		for index in 10:
			var angle := index * TAU / 10.0
			draw_line(Vector2(0, -114) + Vector2.from_angle(angle) * 26, Vector2(0, -114) + Vector2.from_angle(angle) * (14 if windup <= 0 else 21), Color("d4c9b9"), 4, true)
		draw_circle(Vector2(direction * 5, -114), 9, warning)
		draw_line(Vector2(direction * 5, -121), Vector2(direction * 5, -108), Color("151421"), 3, true)
	elif kind == "jelly":
		for index in 7:
			var cable := PackedVector2Array()
			for segment in 10:
				cable.append(Vector2((index - 3) * 10 + sin(clock * 2 + segment * 0.6 + index) * (segment + 2), 18 + segment * 7))
			draw_polyline(cable, Color("647f79"), 2, true)
			draw_circle(cable[-1], 3, warning)
		draw_circle(Vector2.ZERO, 44, Color(0.48, 0.65, 0.61, 0.16))
		draw_arc(Vector2.ZERO, 40, PI, TAU, 32, core, 5, true)
		draw_colored_polygon(PackedVector2Array([Vector2(-41, 2), Vector2(-18, -28), Vector2(19, -28), Vector2(42, 2), Vector2(30, 21), Vector2(-29, 21)]), Color("283c43"))
		draw_circle(Vector2.ZERO, 26, core)
		draw_circle(locked_aim * 5, 15, warning)
		draw_circle(locked_aim * 7, 7 if windup <= 0 else 3, Color("121822"))
	elif kind == "choir":
		draw_polyline(PackedVector2Array([Vector2(-47, 30), Vector2(0, -57), Vector2(47, 30), Vector2(-47, 30)]), Color("586b73"), 4, true)
		for index in 3:
			var at := Vector2((index - 1) * 31, -15 if index == 1 else 15)
			draw_line(at, at + Vector2(sin(clock + index) * 20, 71), Color("677a77"), 2, true)
			_mask(at, 0.9, sin(clock * 1.5 + index) * 0.15)
	else:
		var enraged := health <= max_health / 2
		draw_circle(Vector2.ZERO, 91, Color(0.55, 0.26, 0.37, 0.11))
		draw_arc(Vector2.ZERO, 81, 0, TAU, 60, Color("7a667e"), 4, true)
		for index in 6:
			var angle := index * TAU / 6.0 + clock * 0.13
			var at := Vector2.from_angle(angle) * 80
			draw_line(at, Vector2.ZERO, Color("475462"), 3, true)
			_mask(at, 0.60, angle + PI * 0.5)
		for index in 5:
			var cable := PackedVector2Array()
			for segment in 12:
				cable.append(Vector2((index - 2) * 19 + sin(clock * 1.7 + segment * 0.5 + index) * segment * 2, 36 + segment * 8))
			draw_polyline(cable, Color("655b73"), 4, true)
		draw_circle(Vector2.ZERO, 52, Color("131623"))
		draw_arc(Vector2.ZERO, 50, 0, TAU, 40, warning, 3, true)
		draw_circle(locked_aim * 9, 25 if not enraged else 31, Color("b46e99"))
		draw_circle(locked_aim * 13, 13, Color("090e18"))
		draw_circle(locked_aim * 13 + Vector2(-5, -6), 4, Color("edd5f0"))
	var center := Vector2(0, -105) if kind == "maw" else Vector2.ZERO
	if windup > 0:
		draw_arc(center, 47 if kind != "cantor" else 105, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - windup / 0.75), 40, Color("ffd297"), 3, true)
	if kind != "cantor" and health < max_health:
		draw_rect(Rect2(center + Vector2(-25, -55), Vector2(50, 4)), Color("17202a"))
		draw_rect(Rect2(center + Vector2(-25, -55), Vector2(50.0 * health / max_health, 4)), Color("dda799"))
