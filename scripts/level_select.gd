extends Control

const GAME_SCENE := "res://scenes/game/game.tscn"
const MENU_SCENE := "res://scenes/menu/main_menu.tscn"


func _ready() -> void:
	GameState.play_music(GameState.MUSIC_MENU)
	add_child(UiKit.make_backdrop())

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.custom_minimum_size = Vector2(620.0, 0.0)
	center.add_child(box)

	box.add_child(UiKit.make_title("LEVELAUSWAHL", 54))
	box.add_child(UiKit.make_spacer(16))

	for level in range(1, GameState.MAX_LEVEL + 1):
		var locked := level > GameState.unlocked_level
		var best: float = GameState.best_times.get(level, INF)
		var text := GameState.level_name(level)
		if locked:
			text += "   [GESPERRT]"
		else:
			text += "   BEST " + UiKit.format_time(best)
		var button := UiKit.make_button(text, UiKit.CYAN if not locked else Color(0.45, 0.45, 0.55))
		button.disabled = locked
		button.pressed.connect(_start_level.bind(level))
		box.add_child(button)

	box.add_child(UiKit.make_spacer(16))
	var back := UiKit.make_button("ZURÜCK", UiKit.VIOLET)
	back.pressed.connect(_back)
	box.add_child(back)


func _start_level(level: int) -> void:
	GameState.play_sfx("click")
	GameState.current_level = level
	get_tree().change_scene_to_file(GAME_SCENE)


func _back() -> void:
	GameState.play_sfx("click")
	get_tree().change_scene_to_file(MENU_SCENE)
