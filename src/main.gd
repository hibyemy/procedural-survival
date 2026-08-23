extends Node2D
## Composition root: assembles terrain, player, systems and UI for one run
## of the chapter selected in RunState (or an endless synthetic chapter).
## All wiring happens here; systems stay decoupled via Events.

var ARENA_RECT := Rect2(-1000.0, -600.0, 2000.0, 1200.0)
const PLAYER_START := Vector2.ZERO
const WALL_THICKNESS := 64.0

var config := ChapterConfig.new()


func _ready() -> void:
	config = _resolve_config()
	ARENA_RECT = Rect2(-config.arena_size.x * 0.5, -config.arena_size.y * 0.5,
			config.arena_size.x, config.arena_size.y)

	RngService.reset(RunState.seed_override if RunState.seed_override != 0 else RngService.DEFAULT_SEED)
	GameState.reset()

	var level := Node2D.new()
	level.name = "Level"
	add_child(level)

	var nav := NavService.new()
	nav.name = "NavService"
	add_child(nav)
	nav.setup(ARENA_RECT)

	_build_terrain(level, nav)
	Events.building_placed.connect(nav.mark_solid)
	Events.structure_removed.connect(func(_kind: StringName, at_position: Vector2) -> void: nav.clear_solid(at_position))

	var player := Player.new()
	player.name = "Player"
	player.projectile_parent = level
	player.position = PLAYER_START
	level.add_child(player)
	var camera := Camera2D.new()
	player.add_child(camera)
	camera.make_current()

	var build_system := BuildSystem.new()
	build_system.name = "BuildSystem"
	build_system.player = player
	build_system.container = level
	build_system.arena_rect = ARENA_RECT
	build_system.setup_blueprints(config.repair_kit_unlocked)
	add_child(build_system)

	var loot_director := LootDirector.new()
	loot_director.name = "LootDirector"
	loot_director.container = level
	loot_director.player = player
	add_child(loot_director)

	var wave_director := WaveDirector.new()
	wave_director.name = "WaveDirector"
	wave_director.container = level
	wave_director.player = player
	wave_director.arena_rect = ARENA_RECT
	wave_director.nav_service = nav
	wave_director.config = config
	add_child(wave_director)

	if config.protect_target:
		var relay := ObjectiveRelay.new()
		relay.name = "RelayShack"
		relay.position = Vector2(0, -ARENA_RECT.size.y * 0.5 + 176.0)
		level.add_child(relay)
		nav.mark_solid(relay.position)

	if config.dark_cycles:
		var dark_director := DarkCycleDirector.new()
		dark_director.name = "DarkCycleDirector"
		add_child(dark_director)
		dark_director.setup(level)

	var hud: Hud = null

	if config.emp_pulses:
		var emp_director := EmpPulseDirector.new()
		emp_director.name = "EmpPulseDirector"
		emp_director.turrets_parent = level
		add_child(emp_director)
		emp_director.pulse_warning.connect(func(seconds_left: float) -> void:
			hud.show_status("EMP IN %d.." % ceili(seconds_left)))
		emp_director.pulse_started.connect(func() -> void:
			hud.show_status("TURRETS OFFLINE"))
		emp_director.pulse_ended.connect(func() -> void:
			hud.show_status("TURRETS ONLINE"))

	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.set_hp(player.health.current, player.health.max_health)
	hud.set_objective(_objective_text())
	hud.prepare_advance(RunState.chapter + 1 if RunState.is_story() else 0)
	hud.show_card("CH.%d  %s" % [config.id, config.title.to_upper()],
			config.intro_text, 6.0)

	MusicDirector.play_track(&"exploration")

	print("main: booted ok ch%d %s" % [config.id, config.title])


func _resolve_config() -> ChapterConfig:
	if RunState.is_story():
		return ChapterCatalog.get_chapter(RunState.chapter)
	var synthetic := ChapterConfig.new()
	synthetic.id = 0
	synthetic.title = "Endless"
	synthetic.style_name = "Ashfall Rust"
	synthetic.target_waves = 999999
	synthetic.brutes_from_wave = 3
	synthetic.skirmishers_from_wave = 8
	synthetic.gunners_from_wave = 12
	synthetic.repair_drones_from_wave = 16
	return synthetic


func _objective_text() -> String:
	if config.protect_target:
		return "OBJECTIVE: PROTECT THE RELAY SHACK"
	if config.has_boss():
		return "OBJECTIVE: SURVIVE AND KILL THE %s" % String(config.boss_id).to_upper()
	return "OBJECTIVE: HOLD UNTIL WAVE %d IS CLEARED" % config.target_waves


func _build_terrain(level: Node2D, nav: NavService) -> void:
	var ground := Polygon2D.new()
	ground.polygon = PolyShapes.rect(ARENA_RECT.size)
	ground.color = Color(0.12, 0.16, 0.12)
	z_index = -10
	level.add_child(ground)

	_add_block(level, Rect2(ARENA_RECT.position.x - WALL_THICKNESS, ARENA_RECT.position.y - WALL_THICKNESS,
			ARENA_RECT.size.x + WALL_THICKNESS * 2.0, WALL_THICKNESS), Color(0.24, 0.22, 0.2))
	_add_block(level, Rect2(ARENA_RECT.position.x - WALL_THICKNESS, ARENA_RECT.end.y,
			ARENA_RECT.size.x + WALL_THICKNESS * 2.0, WALL_THICKNESS), Color(0.24, 0.22, 0.2))
	_add_block(level, Rect2(ARENA_RECT.position.x - WALL_THICKNESS, ARENA_RECT.position.y,
			WALL_THICKNESS, ARENA_RECT.size.y), Color(0.24, 0.22, 0.2))
	_add_block(level, Rect2(ARENA_RECT.end.x, ARENA_RECT.position.y,
			WALL_THICKNESS, ARENA_RECT.size.y), Color(0.24, 0.22, 0.2))

	var rng := RngService.stream(&"terrain")
	var placed: Array[Vector2] = []
	var attempts := 0
	while placed.size() < config.rock_count and attempts < 200:
		attempts += 1
		var point := Vector2(
				rng.randf_range(ARENA_RECT.position.x + 160.0, ARENA_RECT.end.x - 160.0),
				rng.randf_range(ARENA_RECT.position.y + 160.0, ARENA_RECT.end.y - 160.0))
		if point.distance_to(PLAYER_START) < 220.0:
			continue
		var clear := true
		for existing in placed:
			if existing.distance_to(point) < 130.0:
				clear = false
				break
		if not clear:
			continue
		placed.append(point)
		var radius := rng.randf_range(24.0, 46.0)
		_add_rock(level, point, radius)
		nav.mark_circle(point, radius)


func _add_block(level: Node2D, rect: Rect2, color: Color) -> void:
	var block := StaticBody2D.new()
	block.collision_layer = 32
	block.collision_mask = 0
	block.position = rect.get_center()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	block.add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.rect(rect.size)
	visual.color = color
	block.add_child(visual)
	level.add_child(block)


func _add_rock(level: Node2D, at_position: Vector2, radius: float) -> void:
	var rock := StaticBody2D.new()
	rock.collision_layer = 32
	rock.collision_mask = 0
	rock.position = at_position
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	rock.add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.circle(radius, 9)
	visual.color = Color(0.38, 0.38, 0.36)
	rock.add_child(visual)
	level.add_child(rock)
