class_name SpriteFramesUtil


static func build(sheet_path: String, cell: Vector2i, animations: Dictionary) -> SpriteFrames:
	var texture: Texture2D = load(sheet_path)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for animation_name in animations:
		var data: Dictionary = animations[animation_name]
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, float(data.get("fps", 10)))
		frames.set_animation_loop(animation_name, bool(data.get("loop", true)))
		for cell_pos in data.get("frames", []):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2(cell_pos[0], cell_pos[1]) * Vector2(cell), Vector2(cell))
			frames.add_frame(animation_name, atlas)
	return frames
