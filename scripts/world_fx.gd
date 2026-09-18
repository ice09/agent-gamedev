class_name WorldFx

const POST_SHADER := """
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform float aberration = 0.0016;
uniform float scanline_strength = 0.05;
uniform float vignette_strength = 0.38;

void fragment() {
	vec2 uv = SCREEN_UV;
	float dist = distance(uv, vec2(0.5));
	vec2 dir = normalize(uv - vec2(0.5) + vec2(0.0001));
	vec2 offset = dir * aberration * dist;
	vec3 col;
	col.r = texture(screen_tex, uv + offset).r;
	col.g = texture(screen_tex, uv).g;
	col.b = texture(screen_tex, uv - offset).b;
	float scan = 1.0 - scanline_strength * step(0.5, fract(SCREEN_UV.y * 360.0));
	col *= scan;
	col *= 1.0 - vignette_strength * smoothstep(0.35, 0.9, dist);
	COLOR = vec4(col, 1.0);
}
"""


static func build_environment() -> WorldEnvironment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CANVAS
	environment.glow_enabled = true
	environment.glow_intensity = 0.95
	environment.glow_bloom = 0.3
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	environment.glow_hdr_threshold = 0.85
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 1.18
	environment.adjustment_contrast = 1.08
	var node := WorldEnvironment.new()
	node.name = "WorldEnvironment"
	node.environment = environment
	return node


static func build_post_fx() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.name = "PostFX"
	layer.layer = 4
	var rect := ColorRect.new()
	rect.name = "PostProcess"
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = POST_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	rect.material = material
	layer.add_child(rect)
	return layer


static func build_rain() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.name = "Weather"
	layer.layer = 3

	var rain := GPUParticles2D.new()
	rain.name = "Rain"
	rain.amount = 240
	rain.lifetime = 1.5
	rain.texture = load("res://assets/fx/rain.png")
	rain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rain.position = Vector2(640.0, -30.0)
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(760.0, 10.0, 0.0)
	material.direction = Vector3(-0.28, 1.0, 0.0)
	material.spread = 3.0
	material.initial_velocity_min = 560.0
	material.initial_velocity_max = 720.0
	material.gravity = Vector3(-70.0, 420.0, 0.0)
	material.scale_min = 0.8
	material.scale_max = 1.4
	rain.process_material = material
	layer.add_child(rain)
	rain.emitting = true
	return layer
