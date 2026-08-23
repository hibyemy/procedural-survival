class_name Hud
extends CanvasLayer
## In-run overlay: health, resources, wave counter, build hints and the
## game-over screen. Owns the restart flow (R) which resets the run seed.

const HP_BAR_SIZE := Vector2(220.0, 18.0)

var _hp_fill: ColorRect
var _resources_label: Label
var _wave_label: Label
var _hint_label: Label
var _message: Label

var _restarting := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	var root_ui := Control.new()
	root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ui)

	var top_left := VBoxContainer.new()
	top_left.position = Vector2(16.0, 12.0)
	top_left.add_theme_constant_override("separation", 6)
	root_ui.add_child(top_left)

	var hp_background := ColorRect.new()
	hp_background.color = Color(0.1, 0.1, 0.12, 0.8)
	hp_background.custom_minimum_size = HP_BAR_SIZE
	hp_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_left.add_child(hp_background)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.85, 0.3, 0.3)
	_hp_fill.size = Vector2(HP_BAR_SIZE.x, 0.0)
	_hp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_background.add_child(_hp_fill)

	_wave_label = _make_label(top_left, 18)
	_resources_label = _make_label(top_left, 18)
	_hint_label = _make_label(root_ui, 15)
	_hint_label.position = Vector2(16.0, -30.0)
	_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint_label.grow_vertical = Control.GROW_DIRECTION_BEGIN

	_message = Label.new()
	_message.text = ""
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 42)
	_message.set_anchors_preset(Control.PRESET_FULL_RECT)
	_message.visible = false
	root_ui.add_child(_message)

	GameState.resources_changed.connect(_refresh_resources)
	Events.player_health_changed.connect(_on_player_health_changed)
	Events.player_died.connect(_on_player_died)
	Events.wave_started.connect(_on_wave_started)
	Events.build_mode_changed.connect(_on_build_mode_changed)
	_refresh_resources()


func set_hp(current: int, maximum: int) -> void:
	_on_player_health_changed(current, maximum)


func _unhandled_input(event: InputEvent) -> void:
	if _restarting or not event.is_action_pressed("restart"):
		return
	_restarting = true
	RngService.reset()
	GameState.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _make_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.text = ""
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _on_player_health_changed(current: int, maximum: int) -> void:
	var ratio := 0.0 if maximum <= 0 else clampf(float(current) / float(maximum), 0.0, 1.0)
	_hp_fill.size = Vector2(HP_BAR_SIZE.x * ratio, HP_BAR_SIZE.y)
	_hp_fill.color = Color(0.85, 0.3, 0.3).lerp(Color(0.35, 0.8, 0.4), ratio)


func _refresh_resources() -> void:
	_resources_label.text = "SCRAP %d    CELLS %d" % [GameState.get_count(&"scrap"), GameState.get_count(&"cells")]


func _on_wave_started(number: int) -> void:
	_wave_label.text = "WAVE %d" % number


func _on_build_mode_changed(enabled: bool, blueprint_kind: StringName) -> void:
	if enabled:
		_hint_label.text = "BUILD: %s   [TAB] switch   [E] place   [B] exit" % String(blueprint_kind).to_upper()
	else:
		_hint_label.text = ""


func _on_player_died() -> void:
	_message.text = "YOU DIED\n\npress R to retry"
	_message.visible = true
	get_tree().paused = true
