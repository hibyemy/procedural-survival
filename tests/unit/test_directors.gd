extends GutTest

var _level: Node2D


func before_each() -> void:
	GameState.reset()
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func _make_turret(at_position: Vector2) -> Turret:
	var turret := Turret.new()
	turret.position = at_position
	_level.add_child(turret)
	return turret


func test_emp_pulse_disables_and_restores_turrets() -> void:
	var turret := _make_turret(Vector2.ZERO)
	var director := EmpPulseDirector.new()
	director.turrets_parent = _level
	add_child(director)

	assert_false(turret.disabled)
	director._begin_pulse()
	assert_true(director.disabled_active())
	assert_true(turret.disabled)
	turret._physics_process(0.016)
	assert_eq(turret._barrel.modulate, Color(0.5, 0.5, 0.55))

	director._disable_left = 0.001
	director._physics_process(0.016)
	assert_false(director.disabled_active())
	assert_false(turret.disabled)


func test_disabled_turret_never_fires() -> void:
	var turret := _make_turret(Vector2.ZERO)
	var enemy := Enemy.new()
	enemy.configure(&"chaser")
	enemy.position = Vector2(100, 0)
	_level.add_child(enemy)
	turret.disabled = true
	turret._cooldown = 0.0
	var before := _level.get_child_count()
	turret._physics_process(0.016)
	assert_eq(_level.get_child_count(), before)


func test_dark_cycles_dim_and_restore() -> void:
	var director := DarkCycleDirector.new()
	add_child(director)
	director.setup(_level)
	assert_not_null(director.canvas_modulate)
	assert_eq(director.canvas_modulate.color, Color.WHITE)

	director._timer = 0.0
	director._physics_process(0.016)
	assert_true(director.darkness_active())
	assert_eq(director.canvas_modulate.color, DarkCycleDirector.DARK_COLOR)

	director._dark_left = 0.001
	director._physics_process(0.016)
	assert_false(director.darkness_active())
	assert_eq(director.canvas_modulate.color, Color.WHITE)


func test_relay_relay_announces_failure_on_death() -> void:
	var relay := ObjectiveRelay.new()
	_level.add_child(relay)
	watch_signals(Events)
	relay.take_damage(ObjectiveRelay.MAX_HEALTH)
	assert_signal_emitted_with_parameters(Events, "objective_failed", ["RELAY SHACK DESTROYED"])
	assert_true(relay.is_queued_for_deletion())
