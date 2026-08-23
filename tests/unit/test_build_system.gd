extends GutTest

const ARENA := Rect2(-1000.0, -600.0, 2000.0, 1200.0)

var _system: BuildSystem
var _level: Node2D
var _player: Player


func before_each() -> void:
	GameState.reset()
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)
	_player = Player.new()
	_player.position = Vector2(200, 0)
	_level.add_child(_player)
	_system = BuildSystem.new()
	_system.player = _player
	_system.container = _level
	_system.arena_rect = ARENA
	add_child(_system)


func test_blueprint_cycling_wraps() -> void:
	assert_eq(_system.blueprint()["kind"], &"wall")
	_system.cycle_blueprint()
	assert_eq(_system.blueprint()["kind"], &"turret")
	_system.cycle_blueprint()
	assert_eq(_system.blueprint()["kind"], &"wall")


func test_toggle_flips_state_and_signals() -> void:
	watch_signals(Events)
	assert_false(_system.enabled)
	_system.toggle()
	assert_true(_system.enabled)
	assert_signal_emitted_with_parameters(Events, "build_mode_changed", [true, &"wall"])
	_system.toggle()
	assert_false(_system.enabled)
	assert_signal_emitted(Events, "build_mode_changed")


func test_snap_to_grid() -> void:
	assert_eq(BuildSystem.snap_to_grid(Vector2(47, 47)), Vector2.ZERO)
	assert_eq(BuildSystem.snap_to_grid(Vector2(96, 50)), Vector2(96, 48))
	assert_eq(BuildSystem.snap_to_grid(Vector2(-1, -1)), Vector2(-48, -48))


func test_is_placeable_spot_respects_arena_bounds() -> void:
	assert_true(BuildSystem.is_placeable_spot(Vector2.ZERO, ARENA))
	assert_false(BuildSystem.is_placeable_spot(Vector2(5000, 0), ARENA))
	assert_false(BuildSystem.is_placeable_spot(Vector2(-990, 0), ARENA))


func test_try_place_denied_when_disabled() -> void:
	GameState.add(&"scrap", 100)
	assert_false(_system.try_place())


func test_try_place_denied_when_unaffordable() -> void:
	_system.toggle()
	assert_false(_system.try_place())
	assert_eq(GameState.get_count(&"scrap"), 0)
	var structures := 0
	for child in _level.get_children():
		if child is Wall or child is Turret:
			structures += 1
	assert_eq(structures, 0)


func test_try_place_builds_wall_and_spends_resources() -> void:
	GameState.add(&"scrap", 10)
	_system.toggle()
	assert_true(_system.try_place())
	assert_eq(GameState.get_count(&"scrap"), 5)
	var walls: Array[Wall] = []
	for child in _level.get_children():
		if child is Wall:
			walls.append(child)
	assert_eq(walls.size(), 1)
	assert_eq(walls[0].position, BuildSystem.snap_to_grid(Vector2(296, 0)))


func test_try_place_blocked_by_existing_structure() -> void:
	GameState.add(&"scrap", 100)
	GameState.add(&"cells", 10)
	_system.toggle()
	assert_true(_system.try_place())
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_false(_system.try_place())
	assert_eq(GameState.get_count(&"scrap"), 95)


func test_wall_takes_damage_and_dies() -> void:
	GameState.add(&"scrap", 10)
	_system.toggle()
	assert_true(_system.try_place())
	for child in _level.get_children():
		if child is Wall:
			child.take_damage(19)
			assert_false(child.health.is_dead())
			child.take_damage(1)
			assert_true(child.health.is_dead())
			return
	fail_test("no wall was built")


func test_turret_requires_cells_in_cost() -> void:
	_system.cycle_blueprint()
	var costs: Dictionary = _system.blueprint()["costs"]
	assert_true(costs.has(&"scrap"))
	assert_true(costs.has(&"cells"))


func test_repair_kit_joins_when_unlocked() -> void:
	_system.setup_blueprints(false)
	assert_eq(_system.blueprints.size(), 2)
	_system.setup_blueprints(true)
	var kinds := []
	for bp in _system.blueprints:
		kinds.append(bp["kind"])
	assert_true(kinds.has(&"repair_kit"))


func test_repair_selection_hides_ghost_and_repairs_wall() -> void:
	GameState.add(&"scrap", 10)
	_system.setup_blueprints(true)
	_system.toggle()
	while String(_system.blueprint()["kind"]) != "repair_kit":
		_system.cycle_blueprint()
	assert_false(_system._ghost.visible)

	var wall := Wall.new()
	wall.position = Vector2(150, 0)
	_level.add_child(wall)
	wall.health.take_damage(12)

	assert_true(_system.try_place())
	assert_eq(GameState.get_count(&"scrap"), 7)
	assert_eq(wall.health.current, 16)


func test_repair_denied_when_nothing_damaged() -> void:
	GameState.add(&"scrap", 10)
	_system.setup_blueprints(true)
	_system.toggle()
	while String(_system.blueprint()["kind"]) != "repair_kit":
		_system.cycle_blueprint()
	var before := GameState.get_count(&"scrap")
	assert_false(_system.try_place())
	assert_eq(GameState.get_count(&"scrap"), before)


func test_repair_denied_when_unaffordable() -> void:
	GameState.add(&"scrap", 0)
	_system.setup_blueprints(true)
	_system.toggle()
	while String(_system.blueprint()["kind"]) != "repair_kit":
		_system.cycle_blueprint()
	var wall := Wall.new()
	wall.position = Vector2(150, 0)
	_level.add_child(wall)
	wall.health.take_damage(5)
	assert_false(_system.try_place())
