class_name Hud
extends CanvasLayer
## In-run overlay: health, resources, wave counter, build hints and the
## game-over screen. Owns the restart flow (R) which resets the run seed.

const HP_BAR_SIZE := Vector2(220.0, 18.0)
const MENU_SCENE := "res://src/menu/menu.tscn"
const STATUS_CLEAR_SECONDS := 2.5

var _hp_fill: ColorRect
var _resources_label: Label
var _wave_label: Label
var _hint_label: Label
var _message: Label
var _objective_label: Label
var _status_label: Label
var _card: PanelContainer
var _card_title: Label
var _card_body: Label

var _restarting := false
var _game_over := false
var _won := false
var _failed := false
var _next_chapter := 0


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
	_objective_label = _make_label(top_left, 15)
	_objective_label.modulate = Color(1.0, 0.9, 0.6)
	_resources_label = _make_label(top_left, 18)
	_hint_label = _make_label(root_ui, 15)
	_hint_label.position = Vector2(16.0, -30.0)
	_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint_label.grow_vertical = Control.GROW_DIRECTION_BEGIN

	_status_label = _make_label(root_ui, 20)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_status_label.position.y = 48.0

	_build_card(root_ui)

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
	Events.run_won.connect(_on_run_won)
	Events.objective_failed.connect(_on_objective_failed)
	_refresh_resources()


func set_objective(text: String) -> void:
	_objective_label.text = text


## Short-lived top-center announcement (EMP warnings, dark cycles...).
func show_status(text: String) -> void:
	_status_label.text = text
	get_tree().create_timer(STATUS_CLEAR_SECONDS, true).timeout.connect(_clear_status_if_match.bind(text))


func _clear_status_if_match(text: String) -> void:
	if _status_label.text == text:
		_status_label.text = ""


## Full-screen interlude card (chapter intro/outro). Auto-hides.
func show_card(title: String, body: String, seconds := 5.0) -> void:
	_card_title.text = title
	_card_body.text = body
	_card.visible = true
	get_tree().create_timer(seconds, false).timeout.connect(_hide_card)


func _hide_card() -> void:
	_card.visible = false


func _build_card(parent: Control) -> void:
	_card = PanelContainer.new()
	_card.visible = false
	_card.set_anchors_preset(Control.PRESET_CENTER)
	_card.custom_minimum_size = Vector2(520.0, 0.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	_card_title = Label.new()
	_card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_title.add_theme_font_size_override("font_size", 28)
	column.add_child(_card_title)
	_card_body = Label.new()
	_card_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_body.custom_minimum_size = Vector2(480.0, 0.0)
	_card_body.add_theme_font_size_override("font_size", 15)
	column.add_child(_card_body)
	parent.add_child(_card)


func set_hp(current: int, maximum: int) -> void:
	_on_player_health_changed(current, maximum)


func _unhandled_input(event: InputEvent) -> void:
	if _restarting:
		return
	if event.is_action_pressed("restart"):
		_restarting = true
		if _won:
			if _next_chapter > 0:
				RunState.configure_story(_next_chapter)
				get_tree().paused = false
				get_tree().reload_current_scene()
			else:
				_return_to_menu()
		else:
			RngService.reset()
			GameState.reset()
			get_tree().paused = false
			get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_cancel") and not _game_over and not _won and not _failed:
		_restarting = true
		_return_to_menu()


## Story flow: what "R" does after a win. 0 = campaign complete -> menu.
func prepare_advance(next_chapter: int) -> void:
	_next_chapter = next_chapter


func _return_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(MENU_SCENE)


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


func _on_wave_started(number: int, heavy: bool) -> void:
	_wave_label.text = "WAVE %d%s" % [number, "!" if heavy else ""]


func _on_build_mode_changed(enabled: bool, blueprint_kind: StringName) -> void:
	if enabled:
		_hint_label.text = "BUILD: %s   [TAB] switch   [E] place   [B] exit" % String(blueprint_kind).to_upper()
	else:
		_hint_label.text = ""


func _on_player_died() -> void:
	_game_over = true
	_message.text = "YOU DIED\n\npress R to retry   ESC for menu"
	_message.visible = true
	get_tree().paused = true


func _on_objective_failed(reason: String) -> void:
	if _failed or _won or _game_over:
		return
	_failed = true
	_message.text = "OBJECTIVE FAILED - %s\n\npress R to retry" % reason
	_message.visible = true
	get_tree().paused = true


func _on_run_won() -> void:
	if _game_over or _failed:
		return
	_won = true
	SaveGame.unlock_chapter(maxi(RunState.chapter + 1, 1))
	if RunState.chapter >= ChapterCatalog.count():
		_message.text = "SIGNAL RESTORED\n\nthe zone answers - campaign complete\n\npress R for menu"
	else:
		_message.text = "%s SECURED\n\nnext: CH.%d %s\n\npress R to continue   ESC for menu" % [
			config_title().to_upper(), _next_chapter, next_title()]
	_message.visible = true
	get_tree().paused = true


func config_title() -> String:
	var config := ChapterCatalog.get_chapter(RunState.chapter)
	return config.title


func next_title() -> String:
	if _next_chapter < 1 or _next_chapter > ChapterCatalog.count():
		return ""
	return ChapterCatalog.get_chapter(_next_chapter).title
