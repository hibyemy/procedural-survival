extends GutTest

const ARENA := Rect2(-1000.0, -600.0, 2000.0, 1200.0)

var _level: Node2D


func before_each() -> void:
	RunState.reset_to_endless()
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func after_each() -> void:
	RunState.reset_to_endless()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _config(target_waves: int, boss := StringName()) -> ChapterConfig:
	var config := ChapterConfig.new()
	config.target_waves = target_waves
	config.boss_id = boss
	return config


func _director_with_container(enemy_count: int, queued_free_count := 0) -> WaveDirector:
	var container := Node2D.new()
	add_child(container)
	for i in enemy_count:
		var enemy := Enemy.new()
		enemy.configure(&"chaser")
		container.add_child(enemy)
	for i in queued_free_count:
		var dying := Enemy.new()
		dying.configure(&"chaser")
		container.add_child(dying)
		dying.queue_free()
	var director := WaveDirector.new()
	director.container = container
	add_child(director)
	return director


func test_legacy_compose_still_matches_original_curve() -> void:
	assert_eq(WaveDirector.compose_wave(1, _rng(1)).size(), 5)
	assert_eq(WaveDirector.compose_wave(2, _rng(1)).size(), 7)
	assert_eq(WaveDirector.compose_wave(40, _rng(1)).size(), WaveDirector.MAX_WAVE_SIZE)


func test_config_gates_control_new_enemy_mix() -> void:
	var config := ChapterConfig.new()
	config.brutes_from_wave = 3
	config.skirmishers_from_wave = 4
	config.gunners_from_wave = 6
	var early := WaveDirector.compose_for_config(config, 1, _rng(1))
	for kind in early:
		assert_eq(kind, &"chaser")
	var mid := WaveDirector.compose_for_config(config, 5, _rng(5))
	assert_true(mid.has(&"brute"))
	assert_true(mid.has(&"skirmisher"))
	assert_false(mid.has(&"gunner"))
	var late := WaveDirector.compose_for_config(config, 9, _rng(9))
	assert_true(late.has(&"gunner"))


func test_disabled_gates_never_spawn() -> void:
	var config := ChapterConfig.new()
	for kind in WaveDirector.compose_for_config(config, 20, _rng(20)):
		assert_eq(kind, &"chaser")


func test_endless_mode_always_has_more_waves() -> void:
	RunState.configure_endless()
	var director := WaveDirector.new()
	autofree(director)
	director.config = _config(999999)
	director.wave_number = 5000
	assert_true(director._has_more_waves())


func test_story_mode_stops_at_target_waves() -> void:
	RunState.configure_story(4)
	var director := WaveDirector.new()
	autofree(director)
	director.config = _config(12)
	director.wave_number = 11
	assert_true(director._has_more_waves())
	director.wave_number = 12
	assert_false(director._has_more_waves())


func test_boss_down_cancels_remaining_waves() -> void:
	RunState.configure_story(4)
	var director := WaveDirector.new()
	autofree(director)
	director.config = _config(12, &"crawler_titan")
	director.wave_number = 6
	director._on_boss_defeated(&"crawler_titan")
	assert_false(director._has_more_waves())


func test_area_clear_ignores_dying_enemies() -> void:
	var busy := _director_with_container(1)
	assert_false(busy._area_clear_of_enemies())
	busy.free()

	var clearing := _director_with_container(0, 1)
	assert_true(clearing._area_clear_of_enemies())
	clearing.free()


func test_victory_emits_once_when_final_wave_cleared() -> void:
	RunState.configure_story(2)
	var director := _director_with_container(0)
	director.player = autofree(Node2D.new())
	director.config = _config(2)
	director.wave_number = 2
	watch_signals(Events)
	director._check_victory()
	director._check_victory()
	assert_signal_emit_count(Events, "run_won", 1)


func test_boss_defeat_grants_victory_mid_campaign() -> void:
	RunState.configure_story(4)
	var director := _director_with_container(0)
	director.player = autofree(Node2D.new())
	director.config = _config(12, &"crawler_titan")
	director.wave_number = 6
	watch_signals(Events)
	director._check_victory()
	assert_signal_not_emitted(Events, "run_won")
	director._on_boss_defeated(&"crawler_titan")
	director._check_victory()
	assert_signal_emitted(Events, "run_won")


func test_no_victory_while_enemies_alive() -> void:
	RunState.configure_story(2)
	var director := _director_with_container(1)
	director.player = autofree(Node2D.new())
	director.config = _config(2)
	director.wave_number = 2
	watch_signals(Events)
	director._check_victory()
	assert_signal_not_emitted(Events, "run_won")


func test_no_victory_in_endless_mode() -> void:
	RunState.configure_endless()
	var director := _director_with_container(0)
	director.player = autofree(Node2D.new())
	director.config = _config(10)
	director.wave_number = 10
	watch_signals(Events)
	director._check_victory()
	assert_signal_not_emitted(Events, "run_won")
