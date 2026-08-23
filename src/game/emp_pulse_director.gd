class_name EmpPulseDirector
extends Node
## Chapter 5 mechanic: periodic map-wide EMP pulses disable all player
## turrets for a few seconds. Warning banner precedes each pulse.

const CYCLE_PERIOD := 45.0
const WARNING_SECONDS := 3.0
const DISABLE_SECONDS := 5.0

var turrets_parent: Node = null

signal pulse_warning(seconds_left: float)
signal pulse_started
signal pulse_ended

var _cycle_timer := CYCLE_PERIOD
var _warning_left := 0.0
var _disable_left := 0.0


func disabled_active() -> bool:
	return _disable_left > 0.0


func _physics_process(delta: float) -> void:
	if _warning_left > 0.0:
		_warning_left -= delta
		pulse_warning.emit(_warning_left)
		if _warning_left <= 0.0:
			_begin_pulse()
		return
	if _disable_left > 0.0:
		_disable_left -= delta
		if _disable_left <= 0.0:
			_set_turrets_disabled(false)
			pulse_ended.emit()
		return
	_cycle_timer -= delta
	if _cycle_timer <= 0.0:
		_cycle_timer = CYCLE_PERIOD
		_warning_left = WARNING_SECONDS
		Sfx.play(&"build_deny", -4.0)


func _begin_pulse() -> void:
	_disable_left = DISABLE_SECONDS
	_set_turrets_disabled(true)
	pulse_started.emit()


func _set_turrets_disabled(disabled: bool) -> void:
	if turrets_parent == null:
		return
	for node in turrets_parent.get_children():
		if node is Turret:
			node.disabled = disabled
