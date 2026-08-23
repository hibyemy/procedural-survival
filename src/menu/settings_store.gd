class_name SettingsStore
extends RefCounted
## Persists menu/settings choices to user://settings.cfg and applies them
## live (audio bus volumes + window mode). Headless-safe: window calls are
## skipped when no display server is present.

const DEFAULT_PATH := "user://settings.cfg"

var master_volume := 1.0
var music_volume := 0.8
var sfx_volume := 0.9
var fullscreen := false
var seed_text := ""


func load_settings(path: String = DEFAULT_PATH) -> void:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	master_volume = clampf(config.get_value("audio", "master", master_volume), 0.0, 1.0)
	music_volume = clampf(config.get_value("audio", "music", music_volume), 0.0, 1.0)
	sfx_volume = clampf(config.get_value("audio", "sfx", sfx_volume), 0.0, 1.0)
	fullscreen = config.get_value("display", "fullscreen", fullscreen)
	seed_text = String(config.get_value("run", "seed", seed_text))


func save_settings(path: String = DEFAULT_PATH) -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("run", "seed", seed_text)
	config.save(path)


func apply() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)
	if DisplayServer.get_name() == "headless":
		return
	var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.0001)))
		AudioServer.set_bus_mute(idx, linear <= 0.001)
