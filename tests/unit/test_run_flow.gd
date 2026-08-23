extends GutTest

const ARENA := Rect2(-1000.0, -600.0, 2000.0, 1200.0)


func before_each() -> void:
	RunState.reset_to_endless()


func after_each() -> void:
	RunState.reset_to_endless()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _director_with_container(enemy_count: int, queued_free_count := 0) -> WaveDirector:
	var level := Node2D.new()
	add_child(level)
	for i in enemy_count:
		var enemy := Enemy.new()
		enemy.configure(&"chaser")
		level.add_child(enemy)
	for i in queued_free_count:
		var dying := Enemy.new()
		dying.configure(&"chaser")
		level.add_child(dying)
		dying.queue_free()
	var director := WaveDirector.new()
	director.container = level
	add_child(director)
	return director


func test_endless_mode_always_has_more_waves() -> void:
	RunState.configure(RunState.MODE_ENDLESS, 0, 0)
	var director := WaveDirector.new()
	autofree(director)
	director.wave_number = 9999
	assert_true(director._has_more_waves())


func test_story_mode_stops_at_target_waves() -> void:
	RunState.configure(RunState.MODE_STORY, RunState.STORY_TARGET_WAVES, 0)
	var director := WaveDirector.new()
	autofree(director)
	director.wave_number = RunState.STORY_TARGET_WAVES - 1
	assert_true(director._has_more_waves())
	director.wave_number = RunState.STORY_TARGET_WAVES
	assert_false(director._has_more_waves())


func test_wave_is_heavy_only_with_brutes() -> void:
	assert_true(WaveDirector.wave_is_heavy(WaveDirector.compose_wave(5, _rng(5))))
	var light: Array[StringName] = [&"chaser", &"chaser"]
	assert_false(WaveDirector.wave_is_heavy(light))


func test_area_clear_ignores_dying_enemies() -> void:
	var busy := _director_with_container(1)
	assert_false(busy._area_clear_of_enemies())
	busy.free()

	var clearing := _director_with_container(0, 1)
	assert_true(clearing._area_clear_of_enemies())
	clearing.free()


func test_victory_emits_once_when_final_wave_cleared() -> void:
	RunState.configure(RunState.MODE_STORY, 2, 0)
	var director := _director_with_container(0)
	director.player = autofree(Node2D.new())
	director.wave_number = 2
	watch_signals(Events)
	director._check_victory()
	director._check_victory()
	assert_signal_emit_count(Events, "run_won", 1)


func test_no_victory_while_enemies_alive() -> void:
	RunState.configure(RunState.MODE_STORY, 2, 0)
	var director := _director_with_container(1)
	director.player = autofree(Node2D.new())
	director.wave_number = 2
	watch_signals(Events)
	director._check_victory()
	assert_signal_not_emitted(Events, "run_won")


func test_no_victory_in_endless_mode() -> void:
	RunState.configure(RunState.MODE_ENDLESS, 0, 0)
	var director := _director_with_container(0)
	director.player = autofree(Node2D.new())
	director.wave_number = 10
	watch_signals(Events)
	director._check_victory()
	assert_signal_not_emitted(Events, "run_won")
