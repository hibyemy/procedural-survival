extends GutTest

var _level: Node2D


func before_each() -> void:
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func test_orbit_math() -> void:
	var pos := CrawlerTitan.orbit(Vector2.ZERO, 100.0, 0.0)
	assert_almost_eq(pos.x, 100.0, 0.001)
	assert_almost_eq(pos.y, 0.0, 0.001)
	var top := CrawlerTitan.orbit(Vector2(10, 10), 50.0, -PI / 2.0)
	assert_almost_eq(top.y, -40.0, 0.001)


func test_titan_configures_as_shootable_boss() -> void:
	var titan := CrawlerTitan.new()
	_level.add_child(titan)
	assert_eq(titan.max_health, 120)
	assert_eq(titan.boss_id, StringName("crawler_titan"))
	assert_true(titan.is_in_group("enemies"))


func test_phases_track_health_fraction() -> void:
	var titan := CrawlerTitan.new()
	autofree(titan)
	titan.max_health = 120
	titan.health = HealthComponent.new()
	autofree(titan.health)
	titan.health.setup(120)
	titan.update_phase()
	assert_eq(titan.phase, 1)
	titan.take_damage(45)
	titan.update_phase()
	assert_eq(titan.phase, 2)
	titan.take_damage(40)
	titan.update_phase()
	assert_eq(titan.phase, 3)


func test_death_emits_boss_defeated_once() -> void:
	var titan := CrawlerTitan.new()
	autofree(titan)
	titan.max_health = 120
	titan._build_body()
	titan.health = HealthComponent.new()
	autofree(titan.health)
	titan.health.setup(120)
	titan.health.died.connect(titan._on_died)
	watch_signals(Events)
	titan.take_damage(999)
	assert_signal_emit_count(Events, "boss_defeated", 1)
	assert_signal_emitted_with_parameters(Events, "boss_defeated", [StringName("crawler_titan")])
