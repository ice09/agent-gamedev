extends Control

const GAME_SCENE := "res://scenes/game/game.tscn"
const LEVEL_SELECT_SCENE := "res://scenes/menu/level_select.tscn"
const SETTINGS_SCENE := "res://scenes/menu/settings.tscn"
const BONUS_SCENE := "res://scenes/main.tscn"


func _ready() -> void:
	GameState.play_music(GameState.MUSIC_MENU)
	add_child(UiKit.make_backdrop())

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	box.add_child(UiKit.make_title("NEON RUSH", 86))
	var subtitle := UiKit.make_label("CYBERPUNK JUMP & RUN", 26, UiKit.CYAN, UiKit.MONO)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)
	box.add_child(UiKit.make_spacer(24))

	var play := UiKit.make_button("SPIELEN")
	play.pressed.connect(_on_play)
	box.add_child(play)

	var select := UiKit.make_button("LEVELAUSWAHL", UiKit.VIOLET)
	select.pressed.connect(func() -> void: _go(LEVEL_SELECT_SCENE))
	box.add_child(select)

	var settings := UiKit.make_button("EINSTELLUNGEN", UiKit.VIOLET)
	settings.pressed.connect(func() -> void: _go(SETTINGS_SCENE))
	box.add_child(settings)

	var bonus := UiKit.make_button("BONUS: SAMMLER", UiKit.MAGENTA)
	bonus.pressed.connect(func() -> void: _go(BONUS_SCENE))
	box.add_child(bonus)

	var quit := UiKit.make_button("BEENDEN", Color(1.0, 0.5, 0.5))
	quit.pressed.connect(_on_quit)
	box.add_child(quit)


func _on_play() -> void:
	GameState.play_sfx("click")
	GameState.current_level = mini(GameState.unlocked_level, GameState.MAX_LEVEL)
	_go(GAME_SCENE)


func _on_quit() -> void:
	GameState.play_sfx("click")
	get_tree().quit()


func _go(path: String) -> void:
	GameState.play_sfx("click")
	get_tree().change_scene_to_file(path)
