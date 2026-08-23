class_name DarkCycleDirector
extends Node
## Chapter 2 mechanic: lights fail on a cycle, dimming the whole arena via
## a CanvasModulate for a few seconds. Headless-safe (no shaders).

const CYCLE_PERIOD := 40.0
const DARK_SECONDS := 6.0
const LIT_COLOR := Color.WHITE
const DARK_COLOR := Color(0.16, 0.17, 0.22)

var canvas_modulate: CanvasModulate = null

var _timer := CYCLE_PERIOD
var _dark_left := 0.0


func setup(parent: Node) -> void:
	canvas_modulate = CanvasModulate.new()
	parent.add_child(canvas_modulate)


func darkness_active() -> bool:
	return _dark_left > 0.0


func _physics_process(delta: float) -> void:
	if canvas_modulate == null:
		return
	if _dark_left > 0.0:
		_dark_left -= delta
		if _dark_left <= 0.0:
			canvas_modulate.color = LIT_COLOR
			Sfx.play(&"ui_click", -8.0)
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = CYCLE_PERIOD
		_dark_left = DARK_SECONDS
		canvas_modulate.color = DARK_COLOR
		Sfx.play(&"build_deny", -10.0)
