extends Control
## Main menu: mode selection, settings (audio volumes, fullscreen, seed) and
## quit. Settings persist to user://settings.cfg via SettingsStore.

const GAME_SCENE := "res://src/main.tscn"
const MENU_MUSIC := &"menu"

var settings := SettingsStore.new()

var _settings_panel: PanelContainer
var _seed_input: LineEdit
var _master_slider: HSlider
var _music_slider: HSlider
var _sfx_slider: HSlider
var _fullscreen_check: CheckButton


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	settings.load_settings()
	settings.apply()
	MusicDirector.play_track(MENU_MUSIC)


## Sets up RunState for the chosen mode and returns the scene to load.
func prepare_run(mode: StringName) -> StringName:
	var custom_seed := 0
	var text := _seed_input.text.strip_edges()
	if text.is_valid_int():
		custom_seed = maxi(int(text), 0)
	var target := RunState.STORY_TARGET_WAVES if RunState.is_mode_story(mode) else 0
	RunState.configure(mode, target, custom_seed)
	return GAME_SCENE


func start_game(scene_path: StringName) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(String(scene_path))


func _on_story_pressed() -> void:
	_launch(RunState.MODE_STORY)


func _on_endless_pressed() -> void:
	_launch(RunState.MODE_ENDLESS)


func _launch(mode: StringName) -> void:
	Sfx.play(&"ui_click")
	start_game(prepare_run(mode))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _settings_panel.visible:
		_close_settings()


func _open_settings() -> void:
	Sfx.play(&"ui_click")
	_settings_panel.visible = true


func _close_settings() -> void:
	Sfx.play(&"ui_back")
	_sync_from_widgets()
	settings.save_settings()
	_settings_panel.visible = false


func _sync_from_widgets() -> void:
	settings.master_volume = _master_slider.value
	settings.music_volume = _music_slider.value
	settings.sfx_volume = _sfx_slider.value
	settings.fullscreen = _fullscreen_check.button_pressed
	settings.seed_text = _seed_input.text


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.07, 0.09, 0.08)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 14)
	add_child(layout)

	var title := Label.new()
	title.text = "PROCEDURAL SURVIVAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "the machines never got the memo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.modulate = Color(1, 1, 1, 0.55)
	layout.add_child(subtitle)

	layout.add_child(_make_spacer(24))
	var story_button := _make_button("STORY MODE", _on_story_pressed)
	layout.add_child(story_button)
	story_button.grab_focus()
	layout.add_child(_make_button("ENDLESS MODE", _on_endless_pressed))
	layout.add_child(_make_button("SETTINGS", _open_settings))
	layout.add_child(_make_button("QUIT", func() -> void: get_tree().quit()))
	layout.add_child(_make_spacer(40))

	_build_settings_panel()


func _build_settings_panel() -> void:
	_settings_panel = PanelContainer.new()
	_settings_panel.visible = false
	_settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_settings_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_right", 64)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 48)
	_settings_panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var heading := Label.new()
	heading.text = "SETTINGS"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 32)
	column.add_child(heading)

	_master_slider = _add_slider_row(column, "MASTER VOLUME")
	_music_slider = _add_slider_row(column, "MUSIC VOLUME")
	_sfx_slider = _add_slider_row(column, "SFX VOLUME")
	for slider in [_master_slider, _music_slider, _sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value_changed.connect(func(_value: float) -> void: _sync_from_widgets(); settings.apply())

	_fullscreen_check = CheckButton.new()
	_fullscreen_check.text = "FULLSCREEN"
	_fullscreen_check.toggled.connect(func(_on: bool) -> void: _sync_from_widgets(); settings.apply())
	column.add_child(_fullscreen_check)

	var seed_label := Label.new()
	seed_label.text = "RUN SEED (blank = default)"
	column.add_child(seed_label)
	_seed_input = LineEdit.new()
	_seed_input.placeholder_text = "e.g. 1337"
	_seed_input.text = settings.seed_text
	column.add_child(_seed_input)

	column.add_child(_make_spacer(16))
	column.add_child(_make_button("BACK", _close_settings))


func _add_slider_row(parent: Node, label_text: String) -> HSlider:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(320.0, 24.0)
	parent.add_child(slider)
	return slider


func _make_button(label_text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(260.0, 44.0)
	button.pressed.connect(handler)
	button.mouse_entered.connect(button.grab_focus)
	return button


func _make_spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	return spacer
