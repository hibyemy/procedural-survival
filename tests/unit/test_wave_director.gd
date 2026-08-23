extends GutTest

const ARENA := Rect2(-1000.0, -600.0, 2000.0, 1200.0)


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_composition_size_scales_with_wave() -> void:
	assert_eq(WaveDirector.compose_wave(1, _rng(1)).size(), 5)
	assert_eq(WaveDirector.compose_wave(2, _rng(1)).size(), 7)
	assert_eq(WaveDirector.compose_wave(10, _rng(1)).size(), 23)
	assert_eq(WaveDirector.compose_wave(40, _rng(1)).size(), WaveDirector.MAX_WAVE_SIZE)


func test_early_waves_have_no_brutes() -> void:
	for wave in [1, 2]:
		for kind in WaveDirector.compose_wave(wave, _rng(wave)):
			assert_eq(kind, &"chaser")


func test_later_waves_mix_in_brutes() -> void:
	var kinds := WaveDirector.compose_wave(3, _rng(3))
	var brutes := 0
	for kind in kinds:
		if kind == &"brute":
			brutes += 1
	assert_gt(brutes, 0)
	var late_kinds := WaveDirector.compose_wave(9, _rng(9))
	var late_brutes := 0
	for kind in late_kinds:
		if kind == &"brute":
			late_brutes += 1
	assert_gte(late_brutes, floori((9 - 1) / 2.0) - 1)
	assert_lte(late_brutes, floori(late_kinds.size() / 3.0))


func test_composition_is_deterministic_per_seed() -> void:
	assert_eq(WaveDirector.compose_wave(4, _rng(42)), WaveDirector.compose_wave(4, _rng(42)))
	assert_ne(WaveDirector.compose_wave(4, _rng(42)), WaveDirector.compose_wave(4, _rng(43)))


func test_edge_positions_stay_inside_arena() -> void:
	var director := WaveDirector.new()
	director.arena_rect = ARENA
	var rng := _rng(123)
	for i in 50:
		var point := director._edge_position(rng)
		assert_true(ARENA.grow(-WaveDirector.EDGE_INSET + 1.0).has_point(point))
	director.free()


func test_spawn_enemy_injects_target_and_position() -> void:
	var level := Node2D.new()
	add_child(level)
	var player := Node2D.new()
	level.add_child(player)
	var director := WaveDirector.new()
	director.container = level
	director.player = player
	add_child(director)
	director._spawn_enemy(&"chaser", Vector2(10, 10))
	assert_eq(level.get_child_count(), 2)
	var enemy: Enemy = null
	for child in level.get_children():
		if child is Enemy:
			enemy = child
	assert_not_null(enemy)
	assert_same(enemy.target, player)
	assert_eq(enemy.global_position, Vector2(10, 10))
	assert_eq(enemy.kind, &"chaser")
