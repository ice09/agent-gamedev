extends CanvasLayer
class_name PauseMenu

signal resumed
signal restart_requested
signal menu_requested

var _master_slider: HSlider
var _percent: Label


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	add_child(UiKit.make_dim(0.75))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.04, 0.1, 0.96)
	style.border_color = UiKit.CYAN
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(30.0)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	box.add_child(UiKit.make_title("PAUSE", 46))

	var resume := UiKit.make_button("FORTSETZEN")
	resume.pressed.connect(_on_resume)
	box.add_child(resume)

	var restart := UiKit.make_button("NEUSTART", UiKit.MAGENTA)
	restart.pressed.connect(_on_restart)
	box.add_child(restart)

	var row := UiKit.make_slider_row("LAUTSTÄRKE", GameState.master_volume)
	_master_slider = row["slider"]
	_percent = row["value_label"]
	_master_slider.value_changed.connect(_on_volume)
	box.add_child(row["row"])

	var menu := UiKit.make_button("HAUPTMENÜ", UiKit.VIOLET)
	menu.pressed.connect(_on_menu)
	box.add_child(menu)


func open() -> void:
	_master_slider.set_value_no_signal(GameState.master_volume)
	_percent.text = "%d%%" % int(GameState.master_volume * 100.0)


func _on_volume(value: float) -> void:
	GameState.set_volume("master", value)
	_percent.text = "%d%%" % int(value * 100.0)


func _on_resume() -> void:
	GameState.play_sfx("click")
	resumed.emit()


func _on_restart() -> void:
	GameState.play_sfx("click")
	restart_requested.emit()


func _on_menu() -> void:
	GameState.play_sfx("click")
	menu_requested.emit()
