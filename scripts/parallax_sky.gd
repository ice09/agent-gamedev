class_name ParallaxSky

const LAYERS := [
	{"path": "res://assets/parallax/sky.png", "scale": Vector2.ZERO, "mirror": Vector2.ZERO, "tint": Color(1, 1, 1)},
	{"path": "res://assets/parallax/far.png", "scale": Vector2(0.08, 0.04), "mirror": Vector2(1280, 0), "tint": Color(0.75, 0.7, 1.0)},
	{"path": "res://assets/parallax/mid.png", "scale": Vector2(0.22, 0.10), "mirror": Vector2(1280, 0), "tint": Color(1, 1, 1)},
	{"path": "res://assets/parallax/near.png", "scale": Vector2(0.45, 0.22), "mirror": Vector2(1280, 0), "tint": Color(1, 1, 1)},
]


static func build(tint: Color = Color(1, 1, 1)) -> ParallaxBackground:
	var background := ParallaxBackground.new()
	background.name = "Parallax"
	background.layer = -10
	for data in LAYERS:
		var layer := ParallaxLayer.new()
		layer.motion_scale = data["scale"]
		layer.motion_mirroring = data["mirror"]
		var sprite := Sprite2D.new()
		sprite.texture = load(data["path"])
		sprite.centered = false
		sprite.modulate = data["tint"] * tint
		layer.add_child(sprite)
		background.add_child(layer)
	return background
