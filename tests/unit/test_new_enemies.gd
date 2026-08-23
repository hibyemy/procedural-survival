extends GutTest

var _level: Node2D


func before_each() -> void:
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func _make(kind: StringName) -> Enemy:
	var enemy := Enemy.new()
	enemy.configure(kind)
	_level.add_child(enemy)
	return enemy


func test_new_kinds_have_storyboard_stats() -> void:
	var skirmisher := _make(&"skirmisher")
	assert_eq(skirmisher.health.current, 2)
	assert_eq(skirmisher.speed, 195.0)
	var gunner := _make(&"gunner")
	assert_eq(gunner.health.current, 5)
	assert_eq(gunner.contact_damage, 1)
	var drone := _make(&"repair_drone")
	assert_eq(drone.health.current, 4)
	assert_eq(drone.contact_damage, 0)


func test_sway_rotates_direction_without_reversing() -> void:
	var swayed := Enemy.apply_sway(Vector2.RIGHT, PI / 2.0)
	assert_gt(swayed.y, 0.5)
	assert_gt(swayed.x, 0.0)
	assert_almost_eq(Enemy.apply_sway(Vector2.RIGHT, 0.0).x, 1.0, 0.001)


func test_gunner_range_logic_thresholds() -> void:
	assert_true(Enemy.gunner_should_advance(400.0))
	assert_false(Enemy.gunner_should_advance(200.0))


func test_health_heal_clamps_and_never_revives() -> void:
	var health := HealthComponent.new()
	health.setup(5)
	autofree(health)
	watch_signals(health)
	health.take_damage(3)
	health.heal(99)
	assert_eq(health.current, 5)
	health.take_damage(5)
	assert_true(health.is_dead())
	health.heal(10)
	assert_eq(health.current, 0)


func test_drone_heals_damaged_ally_nearby() -> void:
	var drone := _make(&"repair_drone")
	drone.position = Vector2.ZERO
	var patient := _make(&"brute")
	patient.position = Vector2(20, 0)
	patient.health.take_damage(4)
	drone._heal_tick = 0.0
	drone._tick_healing(0.016)
	assert_eq(patient.health.current, 9)


func test_drone_does_not_heal_full_allies() -> void:
	var drone := _make(&"repair_drone")
	var healthy := _make(&"chaser")
	healthy.position = Vector2(10, 0)
	drone._heal_tick = 0.0
	drone._tick_healing(0.016)
	assert_eq(healthy.health.current, healthy.health.max_health)


func test_drone_only_heals_within_range() -> void:
	var drone := _make(&"repair_drone")
	drone.position = Vector2.ZERO
	var far := _make(&"brute")
	far.position = Vector2(500, 0)
	far.health.take_damage(6)
	drone._heal_tick = 0.0
	drone._tick_healing(0.016)
	assert_lt(far.health.current, far.health.max_health)


func test_gunner_fires_projectile_targeting_player() -> void:
	var gunner := _make(&"gunner")
	gunner.position = Vector2.ZERO
	var player := Node2D.new()
	player.position = Vector2(200, 0)
	_level.add_child(player)
	gunner.target = player
	gunner._attack_cooldown = 0.0
	gunner._try_gunner_shot()
	var bullets: Array[Projectile] = []
	for child in _level.get_children():
		if child is Projectile:
			bullets.append(child)
	assert_eq(bullets.size(), 1)
	assert_eq(bullets[0].target_mask, 1 | 8 | 32)
	assert_almost_eq(bullets[0].direction.x, 1.0, 0.001)
