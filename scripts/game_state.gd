extends Node

signal settings_changed
signal progress_changed

const SAVE_PATH := "user://neon_rush.cfg"
const MAX_LEVEL := 3

const MUSIC_MENU := "res://assets/audio/music_menu.ogg"
const MUSIC_LEVEL := "res://assets/audio/music_level.ogg"
const MUSIC_BOSS := "res://assets/audio/music_boss.ogg"
const SOUND_CLICK := "res://assets/audio/click.wav"

const SFX := {
	"jump": "res://assets/audio/jump.wav",
	"land": "res://assets/audio/land.wav",
	"chip": "res://assets/audio/chip.wav",
	"checkpoint": "res://assets/audio/checkpoint.wav",
	"hit": "res://assets/audio/hit.wav",
	"death": "res://assets/audio/death.wav",
	"complete": "res://assets/audio/complete.wav",
	"click": "res://assets/audio/click.wav",
}

var master_volume := 1.0
var music_volume := 0.8
var sfx_volume := 0.9
var muted := false

var best_times: Dictionary = {}
var unlocked_level := 1
var current_level := 1

var _config := ConfigFile.new()
var _music_player: AudioStreamPlayer
var _current_music := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_buses()
	_setup_music_player()
	_load_save()
	_apply_audio()
	_build_theme()
	play_music(MUSIC_MENU)


func _setup_audio_buses() -> void:
	if AudioServer.get_bus_index("Musik") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Musik")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	if AudioServer.get_bus_index("Effekte") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Effekte")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")


func _setup_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusikPlayer"
	_music_player.bus = "Musik"
	add_child(_music_player)


func _build_theme() -> void:
	var theme := Theme.new()
	theme.default_font = load("res://assets/fonts/Rajdhani-Regular.ttf")
	theme.default_font_size = 22
	get_window().theme = theme


func play_music(path: String) -> void:
	if path == _current_music:
		return
	var stream: AudioStream = load(path)
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_current_music = path
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_current_music = ""
	_music_player.stop()


func play_sfx(sound: String) -> void:
	if not SFX.has(sound):
		return
	var player := AudioStreamPlayer.new()
	player.bus = "Effekte"
	player.stream = load(SFX[sound])
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _apply_audio() -> void:
	_set_bus("Master", master_volume, muted)
	_set_bus("Musik", music_volume, muted)
	_set_bus("Effekte", sfx_volume, muted)
	settings_changed.emit()


func _set_bus(bus_name: String, volume: float, is_muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, is_muted or volume <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(volume, 0.001)))


func set_volume(kind: String, value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	match kind:
		"master":
			master_volume = value
		"music":
			music_volume = value
		"sfx":
			sfx_volume = value
	_apply_audio()
	save_progress()


func set_muted(value: bool) -> void:
	muted = value
	_apply_audio()
	save_progress()


func level_name(level: int) -> String:
	var path := "res://data/levels/level_%d.json" % level
	if not FileAccess.file_exists(path):
		return "Sektor %d" % level
	var file := FileAccess.open(path, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		return String(data.get("name", "Sektor %d" % level))
	return "Sektor %d" % level


func set_best_time(level: int, seconds: float) -> void:
	var previous: float = best_times.get(level, INF)
	if seconds < previous:
		best_times[level] = seconds
	if level >= unlocked_level and level < MAX_LEVEL:
		unlocked_level = level + 1
	progress_changed.emit()
	save_progress()


func _load_save() -> void:
	if _config.load(SAVE_PATH) != OK:
		return
	master_volume = _config.get_value("audio", "master", master_volume)
	music_volume = _config.get_value("audio", "music", music_volume)
	sfx_volume = _config.get_value("audio", "sfx", sfx_volume)
	muted = _config.get_value("audio", "muted", muted)
	best_times = _config.get_value("progress", "best_times", {})
	unlocked_level = _config.get_value("progress", "unlocked", unlocked_level)


func save_progress() -> void:
	_config.set_value("audio", "master", master_volume)
	_config.set_value("audio", "music", music_volume)
	_config.set_value("audio", "sfx", sfx_volume)
	_config.set_value("audio", "muted", muted)
	_config.set_value("progress", "best_times", best_times)
	_config.set_value("progress", "unlocked", unlocked_level)
	_config.save(SAVE_PATH)
