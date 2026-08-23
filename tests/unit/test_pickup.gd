extends GutTest

var _level: Node2D
var _player: Node2D


func before_each() -> void:
	GameState.reset()
	_level = Node2D.new()
	add_child(_level)
	_player = Node2D.new()
	_player.position = Vector2(1000, 1000)
	_level.add_child(_player)


func _make_pickup(kind: StringName, amount: int) -> Pickup:
	var pickup := Pickup.new()
	pickup.configure(kind, amount)
	pickup.player = _player
	_level.add_child(pickup)
	return pickup


func test_configure_stores_kind_and_amount() -> void:
	var pickup := _make_pickup(&"cells", 3)
	assert_eq(pickup.kind, &"cells")
	assert_eq(pickup.amount, 3)


func test_collect_grants_resources_and_signals() -> void:
	var pickup := _make_pickup(&"cells", 2)
	watch_signals(GameState)
	watch_signals(Events)
	pickup.collect()
	assert_eq(GameState.get_count(&"cells"), 2)
	assert_signal_emitted(Events, "loot_collected")
	assert_signal_emitted_with_parameters(Events, "loot_collected", [&"cells", 2])
	assert_true(pickup.is_queued_for_deletion())


func test_collect_is_idempotent() -> void:
	var pickup := _make_pickup(&"scrap", 4)
	pickup.collect()
	pickup.collect()
	assert_eq(GameState.get_count(&"scrap"), 4)


func test_negative_amount_clamped_to_one() -> void:
	var pickup := _make_pickup(&"scrap", -7)
	assert_eq(pickup.amount, 1)


func test_magnet_drifts_toward_player() -> void:
	var pickup := _make_pickup(&"scrap", 1)
	pickup.global_position = Vector2(1100, 1000)
	var before := pickup.global_position
	for i in 5:
		pickup._physics_process(0.016)
	assert_lt(pickup.global_position.distance_to(_player.global_position), before.distance_to(_player.global_position))


func test_far_pickup_does_not_drift() -> void:
	var pickup := _make_pickup(&"scrap", 1)
	pickup.global_position = Vector2(2000, 2000)
	var before := pickup.global_position
	pickup._physics_process(0.016)
	assert_eq(pickup.global_position, before)
