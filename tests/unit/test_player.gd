extends GutTest

var _level: Node2D


func before_each() -> void:
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func _make_player() -> Player:
	var player := Player.new()
	player.projectile_parent = _level
	_level.add_child(player)
	return player


func test_compute_velocity_scales_and_caps_input() -> void:
	assert_eq(Player.compute_velocity(Vector2.ZERO), Vector2.ZERO)
	assert_eq(Player.compute_velocity(Vector2(10, 0)), Vector2(Player.SPEED, 0))
	var diagonal := Player.compute_velocity(Vector2(1, 1))
	assert_almost_eq(diagonal.length(), Player.SPEED, 0.01)


func test_fire_spawns_projectile_in_parent_with_direction() -> void:
	var player := _make_player()
	player.position = Vector2(500, 500)
	var bullet := player.fire(Vector2.RIGHT)
	assert_eq(_level.get_child_count(), 2)
	assert_is(bullet, Projectile)
	assert_eq(bullet.direction, Vector2.RIGHT)
	assert_same(bullet.source, player)


func test_acquire_target_prefers_nearest_enemy() -> void:
	var player := _make_player()
	player.position = Vector2(500, 500)
	var enemy_near := FakeEnemy.new()
	enemy_near.position = Vector2(550, 500)
	_level.add_child(enemy_near)
	enemy_near.add_to_group("enemies")
	var enemy_far := FakeEnemy.new()
	enemy_far.position = Vector2(600, 500)
	_level.add_child(enemy_far)
	enemy_far.add_to_group("enemies")
	assert_same(player.acquire_target(200.0), enemy_near)
	assert_null(player.acquire_target(20.0))


func test_take_damage_relays_health_to_events() -> void:
	var player := _make_player()
	watch_signals(Events)
	player.take_damage(3)
	assert_signal_emitted(Events, "player_health_changed")
	assert_signal_emitted_with_parameters(Events, "player_health_changed", [7, Player.MAX_HEALTH])


func test_death_emits_player_died_once() -> void:
	var player := _make_player()
	watch_signals(Events)
	player.take_damage(9999)
	assert_signal_emit_count(Events, "player_died", 1)


func test_projectile_hits_enemy_and_consumes_itself() -> void:
	var enemy := Enemy.new()
	enemy.configure(&"chaser")
	enemy.position = Vector2(500, 500)
	_level.add_child(enemy)
	var bullet := Projectile.new()
	bullet.direction = Vector2.RIGHT
	bullet.position = Vector2(400, 500)
	_level.add_child(bullet)
	for i in 90:
		await get_tree().physics_frame
		if enemy.health.current < 3:
			break
	assert_lt(enemy.health.current, 3)
	assert_true(not is_instance_valid(bullet) or bullet.is_queued_for_deletion())
