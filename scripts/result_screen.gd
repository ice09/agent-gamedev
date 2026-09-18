extends CanvasLayer
class_name ResultScreen

signal next_requested
signal retry_requested
signal menu_requested

var _title: Label
var _stats: Label
var _best: Label
var _next_button: Button


func _ready() -> void:
	layer = 21
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	add_child(UiKit.make_dim(0.78))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(640.0, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.04, 0.1, 0.96)
	style.border_color = UiKit.MAGENTA
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(32.0)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	_title = UiKit.make_title("SEKTOR GESCHAFFT", 42)
	box.add_child(_title)

	_stats = UiKit.make_label("", 26, UiKit.TEXT, UiKit.MONO)
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_stats)

	_best = UiKit.make_label("", 24, UiKit.CYAN, UiKit.MONO)
	_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_best)

	_next_button = UiKit.make_button("NÄCHSTER SEKTOR")
	_next_button.pressed.connect(_on_next)
	box.add_child(_next_button)

	var retry := UiKit.make_button("NOCHMAL", UiKit.MAGENTA)
	retry.pressed.connect(_on_retry)
	box.add_child(retry)

	var menu := UiKit.make_button("HAUPTMENÜ", UiKit.VIOLET)
	menu.pressed.connect(_on_menu)
	box.add_child(menu)


func show_result(level_name: String, chips: int, total: int, deaths: int,
		seconds: float, previous_best: float, is_last: bool) -> void:
	visible = true
	_title.text = level_name.to_upper() + " GESCHAFFT"
	_stats.text = "CHIPS %d / %d     AUSFÄLLE %d\nZEIT %s" % [chips, total, deaths, UiKit.format_time(seconds)]
	var best := minf(seconds, previous_best)
	var prefix := "NEUE BESTZEIT  " if seconds < previous_best else "BESTZEIT  "
	_best.text = prefix + UiKit.format_time(best)
	_next_button.visible = not is_last


func _on_next() -> void:
	GameState.play_sfx("click")
	next_requested.emit()


func _on_retry() -> void:
	GameState.play_sfx("click")
	retry_requested.emit()


func _on_menu() -> void:
	GameState.play_sfx("click")
	menu_requested.emit()
