extends GutTest

var _director: LootDirector
var _level: Node2D
var _player: Node2D


func before_each() -> void:
	RngService.reset(1337)
	_level = Node2D.new()
	add_child(_level)
	_player = Node2D.new()
	_level.add_child(_player)
	_director = LootDirector.new()
	_director.container = _level
	_director.player = _player
	add_child(_director)


func test_roll_drops_deterministic_per_seed() -> void:
	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 5
	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 5
	assert_eq(LootDirector.roll_drops(first_rng), LootDirector.roll_drops(second_rng))


func test_rolls_always_yield_scrap_in_valid_range() -> void:
	for seed_value in 50:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var drops := LootDirector.roll_drops(rng)
		assert_gte(drops.size(), 1)
		assert_lte(drops.size(), 2)
		assert_eq(drops[0]["kind"], &"scrap")
		assert_between(drops[0]["amount"], 1, 3)


func test_cells_drop_occasionally() -> void:
	var saw_cells := false
	for seed_value in 100:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		for drop in LootDirector.roll_drops(rng):
			if drop["kind"] == &"cells":
				saw_cells = true
	assert_true(saw_cells)


func test_enemy_death_spawns_matching_pickups() -> void:
	var expected := LootDirector.roll_drops(RngService.fork(&"loot", 1))
	_director._on_enemy_died(Vector2(30, 40))
	assert_eq(_level.get_child_count(), expected.size() + 1)
	var spawned: Array[Pickup] = []
	for child in _level.get_children():
		if child is Pickup:
			spawned.append(child)
	assert_eq(spawned.size(), expected.size())
	for i in spawned.size():
		assert_eq(spawned[i].kind, expected[i]["kind"])
		assert_eq(spawned[i].amount, expected[i]["amount"])
		assert_same(spawned[i].player, _player)


func test_salt_advances_per_death() -> void:
	_director._on_enemy_died(Vector2.ZERO)
	_director._on_enemy_died(Vector2.ONE)
	assert_eq(_director._roll_salt, 2)
