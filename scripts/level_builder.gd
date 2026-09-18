class_name LevelBuilder

const TILE := 16
const ATLAS := "res://assets/tiles/atlas.png"
const ATLAS_COLUMNS := 8

const TILE_FILL := 0
const TILE_TOP := 1
const TILE_CRATE := 4
const TILE_PIPE := 5
const TILE_SPIKE := 6


static func tile_to_world(tile: Array) -> Vector2:
	return Vector2((float(tile[0]) + 0.5) * TILE, (float(tile[1]) + 0.5) * TILE)


static func build(parent: Node2D, data: Dictionary) -> Dictionary:
	var width := int(data.get("width", 200))
	var height := int(data.get("height", 46))

	var tilemap := _make_tilemap()
	parent.add_child(tilemap)

	var result := {
		"spawn": tile_to_world(data.get("spawn", [3, 38])),
		"bounds": Rect2(0.0, 0.0, float(width * TILE), float(height * TILE)),
		"chips": [],
		"checkpoints": [],
		"enemies": [],
		"hazards": [],
		"movers": [],
		"goal": null,
		"boss": null,
	}

	_build_platforms(parent, tilemap, data.get("platforms", []))
	_build_spikes(parent, tilemap, data.get("spikes", []), result)
	_build_walls(parent, width, height)
	_build_killzone(parent, width, height, result)
	_build_movers(parent, data.get("movers", []), result)
	_build_chips(parent, data.get("chips", []), result)
	_build_checkpoints(parent, data.get("checkpoints", []), result)
	_build_enemies(parent, data.get("enemies", []), result)
	_build_goal(parent, data.get("goal", []), result)
	_build_boss(parent, data.get("boss", []), result)
	return result


static func _make_tilemap() -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = "Tiles"
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS)
	source.texture_region_size = Vector2i(TILE, TILE)
	for column in ATLAS_COLUMNS:
		source.create_tile(Vector2i(column, 0))
	tileset.add_source(source, 0)
	layer.tile_set = tileset
	return layer


static func _place_tile(layer: TileMapLayer, x: int, y: int, tile: int) -> void:
	layer.set_cell(Vector2i(x, y), 0, Vector2i(tile, 0))


static func _build_platforms(parent: Node2D, layer: TileMapLayer, platforms: Array) -> void:
	for platform in platforms:
		var x := int(platform[0])
		var y := int(platform[1])
		var w := int(platform[2])
		var h := int(platform[3])
		var kind := int(platform[4]) if platform.size() > 4 else -1
		for iy in h:
			for ix in w:
				var tile := TILE_TOP if iy == 0 else TILE_FILL
				if kind == TILE_CRATE and iy == 0:
					tile = TILE_CRATE
				elif kind == TILE_PIPE:
					tile = TILE_PIPE
				_place_tile(layer, x + ix, y + iy, tile)
		_add_solid(parent, Rect2(x * TILE, y * TILE, w * TILE, h * TILE))


static func _add_solid(parent: Node2D, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position + rect.size * 0.5
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	parent.add_child(body)


static func _build_spikes(parent: Node2D, layer: TileMapLayer, spikes: Array, result: Dictionary) -> void:
	for spike in spikes:
		var x := int(spike[0])
		var y := int(spike[1])
		var w := int(spike[2])
		var h := int(spike[3]) if spike.size() > 3 else 1
		for iy in h:
			for ix in w:
				_place_tile(layer, x + ix, y + iy, TILE_SPIKE)
		var danger := Spikes.new()
		danger.setup(Rect2(x * TILE, y * TILE, w * TILE, h * TILE))
		parent.add_child(danger)
		result["hazards"].append(danger)


static func _build_walls(parent: Node2D, width: int, height: int) -> void:
	_add_solid(parent, Rect2(-2 * TILE, 0.0, 2 * TILE, height * TILE))
	_add_solid(parent, Rect2(width * TILE, 0.0, 2 * TILE, height * TILE))


static func _build_killzone(parent: Node2D, width: int, height: int, result: Dictionary) -> void:
	var danger := Spikes.new()
	danger.name = "Killzone"
	danger.setup(Rect2(0.0, (height + 1) * TILE, width * TILE, 400.0))
	parent.add_child(danger)
	result["hazards"].append(danger)


static func _build_movers(parent: Node2D, movers: Array, result: Dictionary) -> void:
	for mover_data in movers:
		var axis_name := String(mover_data[0])
		var x := float(mover_data[1])
		var y := float(mover_data[2])
		var w := int(mover_data[3])
		var h := int(mover_data[4])
		var distance := float(mover_data[5])
		var speed := float(mover_data[6])
		var mover := Mover.new()
		mover.setup(Vector2i(w, h), Vector2.RIGHT if axis_name == "x" else Vector2.DOWN, distance, speed)
		mover.position = Vector2(x * TILE + w * TILE * 0.5, y * TILE + h * TILE * 0.5)
		parent.add_child(mover)
		result["movers"].append(mover)


static func _build_chips(parent: Node2D, chips: Array, result: Dictionary) -> void:
	for chip_data in chips:
		var chip := Chip.new()
		chip.position = tile_to_world(chip_data)
		parent.add_child(chip)
		result["chips"].append(chip)


static func _build_checkpoints(parent: Node2D, checkpoints: Array, result: Dictionary) -> void:
	for point in checkpoints:
		var checkpoint := Checkpoint.new()
		checkpoint.position = tile_to_world(point) - Vector2(0.0, 4.0)
		parent.add_child(checkpoint)
		result["checkpoints"].append(checkpoint)


static func _build_enemies(parent: Node2D, enemies: Array, result: Dictionary) -> void:
	for enemy in enemies:
		var kind := String(enemy[0])
		var position := tile_to_world([enemy[1], enemy[2]])
		var patrol := float(enemy[3]) if enemy.size() > 3 else 4.0
		var speed := float(enemy[4]) if enemy.size() > 4 else 0.0
		if kind == "walker":
			var walker := Walker.new()
			walker.setup(patrol, speed if speed > 0.0 else 55.0)
			walker.position = position
			parent.add_child(walker)
			result["enemies"].append(walker)
		elif kind == "drone":
			var drone := Drone.new()
			drone.setup(patrol, speed if speed > 0.0 else 70.0)
			drone.position = position
			parent.add_child(drone)
			result["enemies"].append(drone)


static func _build_goal(parent: Node2D, goal: Array, result: Dictionary) -> void:
	if goal.size() < 2:
		return
	var terminal := GoalTerminal.new()
	terminal.position = tile_to_world(goal) - Vector2(0.0, 4.0)
	parent.add_child(terminal)
	result["goal"] = terminal


static func _build_boss(parent: Node2D, boss_data: Array, result: Dictionary) -> void:
	if boss_data.size() < 3:
		return
	var boss := Boss.new()
	boss.position = tile_to_world([boss_data[1], boss_data[2]])
	parent.add_child(boss)
	result["boss"] = boss
