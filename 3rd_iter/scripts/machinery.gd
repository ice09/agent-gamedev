extends Node2D
## Animated details share the same coordinates as the separate structural SVG.

var clock := 0.0
var effects_enabled := true
const FANS := [Vector2(1050, 298), Vector2(2930, 283), Vector2(3330, 321)]


func _process(delta: float) -> void:
	if effects_enabled:
		clock += delta
		queue_redraw()


func _draw() -> void:
	for index in FANS.size():
		var center: Vector2 = FANS[index]
		# The third rotor is seized; the other two turn slowly and unevenly.
		var angle := clock * (0.16 if index == 0 else -0.10) if index < 2 else 0.4
		for blade in 7:
			draw_set_transform(center, angle + blade * TAU / 7.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(8, -9), Vector2(39, -27), Vector2(72, -12),
				Vector2(66, 6), Vector2(25, 14)
			]), Color("293941"))
			draw_line(Vector2(39, -27), Vector2(72, -12), Color("4a555c"), 1.0, true)
		draw_set_transform(Vector2.ZERO)
		draw_circle(center, 17, Color("131e27"))
		draw_arc(center, 17, 0, TAU, 40, Color("556069"), 2, true)
		# Fixed grille in front of moving blades.
		for offset in range(-56, 57, 14):
			var extent := sqrt(74.0 * 74.0 - offset * offset)
			draw_line(center + Vector2(offset, -extent), center + Vector2(offset, extent), Color("0d1720"), 2, true)
			draw_line(center + Vector2(-extent, offset), center + Vector2(extent, offset), Color("18232c"), 1, true)
	# Subtle traffic far below, never on the traversal layer.
	if effects_enabled:
		for index in 14:
			var x := fposmod(index * 297.0 + clock * (8.0 + index), 3840.0)
			var y := 647.0 + (index % 4) * 20.0
			draw_line(Vector2(x, y), Vector2(x + 5, y), Color(0.55, 0.48, 0.37, 0.22), 1)
