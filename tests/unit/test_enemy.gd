extends GutTest

var _level: Node2D


func before_each() -> void:
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func _make_enemy(kind: StringName) -> Enemy:
	var enemy := Enemy.new()
	enemy.configure(kind)
	_level.add_child(enemy)
	return enemy


func test_configure_applies_kind_stats() -> void:
	var chaser := Enemy.new()
	autofree(chaser)
	chaser.configure(&"chaser")
	assert_eq(chaser.speed, 130.0)
	assert_eq(chaser.contact_damage, 1)
	var brute := _make_enemy(&"brute")
	assert_eq(brute.speed, 75.0)
	assert_eq(brute.contact_damage, 2)


func test_ready_registers_group_and_health() -> void:
	var enemy := _make_enemy(&"chaser")
	assert_true(enemy.is_in_group("enemies"))
	assert_eq(enemy.health.current, 3)


func test_chase_direction_math() -> void:
	assert_eq(Enemy.chase_direction(Vector2.ZERO, Vector2(10, 0)), Vector2.RIGHT)
	assert_almost_eq(Enemy.chase_direction(Vector2.ZERO, Vector2(3, 3)).x, 0.7071, 0.001)
	assert_eq(Enemy.chase_direction(Vector2(5, 5), Vector2(5, 5)), Vector2.ZERO)


func test_death_announces_position_and_frees() -> void:
	var enemy := _make_enemy(&"chaser")
	enemy.position = Vector2(120, 60)
	var captured: Array[Vector2] = []
	Events.enemy_died.connect(func(at_position: Vector2) -> void: captured.append(at_position))
	watch_signals(Events)
	enemy.take_damage(999)
	assert_signal_emit_count(Events, "enemy_died", 1)
	assert_eq(captured.size(), 1)
	assert_eq(captured[0], Vector2(120, 60))
	assert_true(enemy.is_queued_for_deletion())


func test_is_dead_reflects_health() -> void:
	var enemy := _make_enemy(&"brute")
	assert_false(enemy.is_dead())
	enemy.take_damage(11)
	assert_false(enemy.is_dead())
	enemy.take_damage(1)
	assert_true(enemy.is_dead())
