extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"


func _ready() -> void:
	GameState.play_music(GameState.MUSIC_MENU)
	add_child(UiKit.make_backdrop())

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	box.custom_minimum_size = Vector2(620.0, 0.0)
	center.add_child(box)

	box.add_child(UiKit.make_title("EINSTELLUNGEN", 50))
	box.add_child(UiKit.make_spacer(10))

	box.add_child(_volume_row("MASTER", "master", GameState.master_volume))
	box.add_child(_volume_row("MUSIK", "music", GameState.music_volume))
	box.add_child(_volume_row("EFFEKTE", "sfx", GameState.sfx_volume))

	var mute := CheckBox.new()
	mute.text = "STUMM"
	mute.button_pressed = GameState.muted
	mute.add_theme_font_override("font", load(UiKit.DISPLAY))
	mute.add_theme_font_size_override("font_size", 26)
	mute.toggled.connect(_on_mute)
	box.add_child(mute)

	box.add_child(UiKit.make_spacer(16))
	var back := UiKit.make_button("ZURÜCK", UiKit.VIOLET)
	back.pressed.connect(_back)
	box.add_child(back)


func _volume_row(text: String, kind: String, value: float) -> HBoxContainer:
	var row := UiKit.make_slider_row(text, value)
	var slider: HSlider = row["slider"]
	var value_label: Label = row["value_label"]
	slider.value_changed.connect(func(new_value: float) -> void:
		GameState.set_volume(kind, new_value)
		value_label.text = "%d%%" % int(new_value * 100.0))
	return row["row"]


func _on_mute(pressed: bool) -> void:
	GameState.set_muted(pressed)


func _back() -> void:
	GameState.play_sfx("click")
	get_tree().change_scene_to_file(MENU_SCENE)
