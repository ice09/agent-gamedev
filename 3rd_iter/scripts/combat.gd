extends Node2D

const ENEMY := preload("res://scripts/enemy.gd")
const PROJECTILE := preload("res://scripts/projectile.gd")
const ENCOUNTERS := [
	["maw", Vector2(615, 508), Vector2(440, 710)],
	["jelly", Vector2(1140, 348), Vector2.ZERO],
	["maw", Vector2(1650, 492), Vector2(1540, 1700)],
	["choir", Vector2(2020, 405), Vector2.ZERO],
	["jelly", Vector2(2450, 368), Vector2.ZERO],
	["maw", Vector2(2950, 480), Vector2(2810, 3040)],
	["choir", Vector2(3310, 380), Vector2.ZERO],
	["cantor", Vector2(3670, 342), Vector2.ZERO],
]
var player: CharacterBody2D
var active := false
var score := 0
var kills := 0
var muted := false
var sparks: Array[Dictionary] = []
var repairs: Array[Vector2] = []
var enemies := Node2D.new()
var projectiles := Node2D.new()
var sounds: Dictionary = {}


func _ready() -> void:
	player = get_parent().get_node("Player")
	enemies.name = "Enemies"
	projectiles.name = "Projectiles"
	add_child(enemies)
	add_child(projectiles)
	for sound in ["fire", "impact", "enemy_fire", "shatter", "repair", "hurt"]:
		var audio := AudioStreamPlayer.new()
		audio.stream = load("res://assets/audio/%s.wav" % sound)
		audio.volume_db = -14 if sound == "fire" else -10
		audio.max_polyphony = 6
		add_child(audio)
		sounds[sound] = audio
	player.shot.connect(fire_player)


func reset_encounter(enabled: bool) -> void:
	for node in enemies.get_children() + projectiles.get_children():
		node.free()
	repairs.clear()
	sparks.clear()
	score = 0
	kills = 0
	active = enabled
	visible = enabled
	if not enabled:
		return
	for definition in ENCOUNTERS:
		var enemy := ENEMY.new()
		enemy.combat = self
		enemy.configure(definition[0], definition[1], definition[2])
		enemy.defeated.connect(_on_enemy_defeated)
		enemies.add_child(enemy)


func remaining() -> int:
	var count := 0
	for enemy in enemies.get_children():
		if not enemy.dead:
			count += 1
	return count


func boss() -> CharacterBody2D:
	for enemy in enemies.get_children():
		if enemy.kind == "cantor" and not enemy.dead:
			return enemy
	return null


func fire_player(origin: Vector2, direction: Vector2) -> void:
	if active:
		spawn_projectile(origin, direction * 1050.0, true)
		play_sound("fire")


func spawn_projectile(origin: Vector2, velocity: Vector2, friendly: bool) -> Node2D:
	var bullet := PROJECTILE.new()
	bullet.position = origin
	bullet.velocity = velocity
	bullet.friendly = friendly
	bullet.lifetime = 0.70 if friendly else 3.0
	bullet.combat = self
	projectiles.add_child(bullet)
	return bullet


func clear_hostile_shots() -> void:
	for bullet in projectiles.get_children():
		if not bullet.friendly:
			bullet.spent = true
			bullet.queue_free()


func _on_enemy_defeated(enemy: CharacterBody2D) -> void:
	kills += 1
	score += 1000 if enemy.kind == "cantor" else 100
	burst(enemy.target_point(), Color("a6d1c6"), 24)
	play_sound("shatter")
	if kills % 2 == 0:
		repairs.append(enemy.target_point())


func play_sound(sound: String) -> void:
	if not muted and sounds.has(sound):
		sounds[sound].play()


func set_muted(value: bool) -> void:
	muted = value
	if muted:
		for audio in sounds.values():
			audio.stop()


func burst(at: Vector2, color: Color, count: int) -> void:
	for index in count:
		var angle := index * TAU / count + float(kills)
		sparks.append({"at": at, "velocity": Vector2.from_angle(angle) * (70.0 + index * 4), "life": 0.4, "color": color})


func _physics_process(delta: float) -> void:
	if not active:
		return
	for index in range(sparks.size() - 1, -1, -1):
		sparks[index].life -= delta
		sparks[index].at += sparks[index].velocity * delta
		if sparks[index].life <= 0:
			sparks.remove_at(index)
	var center := player.global_position + Vector2(0, -85)
	for index in range(repairs.size() - 1, -1, -1):
		if repairs[index].distance_to(center) < 200:
			repairs[index] = repairs[index].move_toward(center, 260 * delta)
		if repairs[index].distance_to(center) < 38:
			player.heal(1)
			score += 25
			repairs.remove_at(index)
			play_sound("repair")


func _process(_delta: float) -> void:
	if active:
		queue_redraw()


func _draw() -> void:
	for spark in sparks:
		var color: Color = spark.color
		color.a = spark.life / 0.4
		draw_line(spark.at, spark.at - spark.velocity * 0.025, color, 2, true)
	for at in repairs:
		draw_circle(at, 18, Color(0.3, 0.9, 0.7, 0.12))
		draw_colored_polygon(PackedVector2Array([at + Vector2(0, -12), at + Vector2(10, 0), at + Vector2(0, 12), at + Vector2(-10, 0)]), Color("5fb89b"))
		draw_line(at + Vector2(-5, 0), at + Vector2(5, 0), Color("e0ffee"), 2, true)
		draw_line(at + Vector2(0, -5), at + Vector2(0, 5), Color("e0ffee"), 2, true)
	if active:
		var mouse := get_global_mouse_position()
		for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			draw_line(mouse + direction * 6, mouse + direction * 12, Color("c4adeb"), 1.5, true)
