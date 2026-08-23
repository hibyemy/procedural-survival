extends GutTest

const TEST_PATH := "user://test_settings_store.cfg"


func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func test_defaults_are_sane() -> void:
	var store := SettingsStore.new()
	assert_eq(store.master_volume, 1.0)
	assert_false(store.fullscreen)


func test_save_and_load_roundtrip() -> void:
	var store := SettingsStore.new()
	store.master_volume = 0.5
	store.music_volume = 0.25
	store.sfx_volume = 0.75
	store.fullscreen = true
	store.seed_text = "1337"
	store.save_settings(TEST_PATH)

	var loaded := SettingsStore.new()
	loaded.load_settings(TEST_PATH)
	assert_eq(loaded.master_volume, 0.5)
	assert_eq(loaded.music_volume, 0.25)
	assert_eq(loaded.sfx_volume, 0.75)
	assert_true(loaded.fullscreen)
	assert_eq(loaded.seed_text, "1337")


func test_load_missing_file_keeps_defaults() -> void:
	var store := SettingsStore.new()
	store.load_settings("user://definitely_does_not_exist.cfg")
	assert_eq(store.master_volume, 1.0)


func test_clamped_values_on_load() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", 42.0)
	config.set_value("audio", "music", -3.0)
	config.save(TEST_PATH)
	var store := SettingsStore.new()
	store.load_settings(TEST_PATH)
	assert_eq(store.master_volume, 1.0)
	assert_eq(store.music_volume, 0.0)
