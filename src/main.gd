extends Node2D
## Composition root: assembles terrain, player, systems and UI for one run.
## All wiring happens here; systems themselves stay decoupled via Events.

const ARENA_RECT := Rect2(-1000.0, -600.0, 2000.0, 1200.0)
const PLAYER_START := Vector2.ZERO
const ROCK_COUNT := 12
const WALL_THICKNESS := 64.0


func _ready() -> void:
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
	add_child(wave_director)
	wave_director.start()

	var hud := Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.set_hp(player.health.current, player.health.max_health)

	MusicDirector.play_track(&"exploration")

	print("main: booted ok")


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
	while placed.size() < ROCK_COUNT and attempts < 200:
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
