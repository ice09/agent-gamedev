extends CanvasLayer
class_name Hud

var _level_label: Label
var _chip_label: Label
var _death_label: Label
var _time_label: Label
var _toast: Label
var _toast_timer := 0.0


func _ready() -> void:
	layer = 5

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.size = Vector2(760.0, 190.0)
	add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	margin.add_child(box)

	_level_label = UiKit.make_label("", 30, UiKit.MAGENTA, UiKit.DISPLAY)
	box.add_child(_level_label)
	_chip_label = UiKit.make_label("", 22, UiKit.CYAN, UiKit.MONO)
	box.add_child(_chip_label)
	_death_label = UiKit.make_label("", 22, Color(1.0, 0.5, 0.5), UiKit.MONO)
	box.add_child(_death_label)
	_time_label = UiKit.make_label("", 22, Color(0.7, 1.0, 0.85), UiKit.MONO)
	box.add_child(_time_label)

	_toast = UiKit.make_label("", 28, UiKit.TEXT, UiKit.DISPLAY)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.anchor_top = 1.0
	_toast.anchor_bottom = 1.0
	_toast.offset_left = -520.0
	_toast.offset_right = 520.0
	_toast.offset_top = -110.0
	_toast.offset_bottom = -60.0
	_toast.modulate.a = 0.0
	add_child(_toast)


func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		_toast.modulate.a = clampf(_toast_timer, 0.0, 1.0)


func set_level_name(text: String) -> void:
	_level_label.text = text.to_upper()


func set_chips(collected: int, total: int) -> void:
	_chip_label.text = "DATENCHIPS  %d / %d" % [collected, total]


func set_deaths(count: int) -> void:
	_death_label.text = "SYSTEMAUSFÄLLE  %d" % count


func set_time(seconds: float) -> void:
	_time_label.text = "ZEIT  " + UiKit.format_time(seconds)


func show_toast(text: String, duration := 2.0) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	_toast_timer = duration
