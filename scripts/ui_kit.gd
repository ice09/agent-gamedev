class_name UiKit

const MONO := "res://assets/fonts/ShareTechMono-Regular.ttf"
const DISPLAY := "res://assets/fonts/Rajdhani-Bold.ttf"
const BODY := "res://assets/fonts/Rajdhani-Regular.ttf"

const CYAN := Color(0.24, 0.94, 1.0)
const MAGENTA := Color(1.0, 0.35, 0.78)
const VIOLET := Color(0.62, 0.42, 1.0)
const TEXT := Color(0.86, 0.92, 1.0)


static func make_label(text: String, size: int, color: Color = TEXT, font_path: String = BODY) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", load(font_path))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


static func make_title(text: String, size: int = 64) -> Label:
	var label := make_label(text, size, MAGENTA, DISPLAY)
	label.add_theme_color_override("font_outline_color", CYAN)
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


static func style_button(button: Button, color: Color = CYAN) -> Button:
	button.add_theme_font_override("font", load(DISPLAY))
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", color)
	button.add_theme_color_override("font_pressed_color", color)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0.05, 0.05, 0.11, 0.92)
		box.border_color = Color(color.r, color.g, color.b, 0.5)
		box.set_border_width_all(2)
		box.set_corner_radius_all(3)
		box.content_margin_left = 20.0
		box.content_margin_right = 20.0
		box.content_margin_top = 8.0
		box.content_margin_bottom = 8.0
		if state == "hover":
			box.bg_color = Color(0.1, 0.08, 0.2, 0.95)
			box.border_color = color
		elif state == "pressed":
			box.bg_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0.95)
		elif state == "disabled":
			box.border_color = Color(0.3, 0.3, 0.35, 0.5)
		button.add_theme_stylebox_override(state, box)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


static func make_button(text: String, color: Color = CYAN) -> Button:
	var button := Button.new()
	button.text = text
	return style_button(button, color)


static func make_slider(value: float) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size = Vector2(300, 28)
	return slider


static func make_slider_row(text: String, value: float) -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var label := make_label(text, 24, TEXT, DISPLAY)
	label.custom_minimum_size = Vector2(170, 0)
	row.add_child(label)
	var slider := make_slider(value)
	row.add_child(slider)
	var percent := make_label("%d%%" % int(value * 100), 22, CYAN, MONO)
	percent.custom_minimum_size = Vector2(70, 0)
	row.add_child(percent)
	return {"row": row, "slider": slider, "value_label": percent}


static func make_dim(alpha: float = 0.72) -> ColorRect:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.05, alpha)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	return dim


static func make_backdrop() -> ColorRect:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.03, 0.02, 0.07, 0.65)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return backdrop


static func make_spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	return spacer


static func format_time(seconds: float) -> String:
	if is_inf(seconds):
		return "--:--.--"
	var minutes := int(seconds) / 60
	var rest := fmod(seconds, 60.0)
	return "%d:%05.2f" % [minutes, rest]
