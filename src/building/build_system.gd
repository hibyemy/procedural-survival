class_name BuildSystem
extends Node
## Build mode: [B] toggles, [TAB] cycles blueprints, [E] places the selected
## structure on a grid near the player if affordable and unobstructed.

const GRID := 48
const PLACE_DISTANCE := 168.0
const CLEARANCE_RADIUS := 18.0
const REPAIR_RANGE := 96.0
const REPAIR_COST := 3
const REPAIR_AMOUNT := 8

const WALL_BLUEPRINT := {"kind": &"wall", "costs": {&"scrap": 5}}
const TURRET_BLUEPRINT := {"kind": &"turret", "costs": {&"scrap": 10, &"cells": 2}}
const REPAIR_BLUEPRINT := {"kind": &"repair_kit", "costs": {&"scrap": REPAIR_COST}}

var player: Node2D = null
var container: Node = null
var arena_rect := Rect2()
## Blueprint roster for this run; the Repair Kit joins from Ch.3 on.
var blueprints: Array[Dictionary] = [WALL_BLUEPRINT, TURRET_BLUEPRINT]

var enabled := false
var selection := 0

var _ghost: Node2D


func setup_blueprints(include_repair_kit: bool) -> void:
	blueprints = [WALL_BLUEPRINT, TURRET_BLUEPRINT]
	if include_repair_kit:
		blueprints.append(REPAIR_BLUEPRINT)
	selection = clampi(selection, 0, blueprints.size() - 1)


func _is_repair_selection() -> bool:
	return blueprint()["kind"] == &"repair_kit"


func _ready() -> void:
	_ghost = _make_ghost()
	_ghost.visible = false
	container.add_child(_ghost)


func blueprint() -> Dictionary:
	return blueprints[selection]


func toggle() -> void:
	enabled = not enabled
	_ghost.visible = enabled and not _is_repair_selection()
	if enabled:
		_update_ghost_position()
	Events.build_mode_changed.emit(enabled, blueprint()["kind"])


func cycle_blueprint() -> void:
	selection = (selection + 1) % blueprints.size()
	_refresh_ghost_style()
	if enabled:
		_ghost.visible = not _is_repair_selection()
		Events.build_mode_changed.emit(enabled, blueprint()["kind"])


func try_place() -> bool:
	if not enabled or player == null or not is_instance_valid(player):
		return false
	if _is_repair_selection():
		return _try_repair()
	var spot := _ghost.position
	if not is_placeable_spot(spot, arena_rect):
		return false
	var costs: Dictionary = blueprint()["costs"]
	if not GameState.can_afford(costs):
		Sfx.play(&"build_deny", -6.0)
		return false
	if not _spot_clear(spot):
		Sfx.play(&"build_deny", -6.0)
		return false
	if not GameState.spend(costs):
		return false
	var structure := _make_structure(blueprint()["kind"])
	structure.position = spot
	container.add_child(structure)
	Sfx.play(&"place", -4.0)
	Events.building_placed.emit(blueprint()["kind"], spot)
	return true


## Repair Kit: patch the most damaged structure near the player instead of
## placing anything.
func _try_repair() -> bool:
	var target := _nearest_damaged_structure()
	if target == null:
		Sfx.play(&"build_deny", -8.0)
		return false
	if not GameState.spend(REPAIR_BLUEPRINT["costs"]):
		Sfx.play(&"build_deny", -6.0)
		return false
	target.health.heal(REPAIR_AMOUNT)
	Sfx.play(&"place", -6.0)
	return true


## Public entry point for the interaction scanner (E outside build mode).
func try_repair_from_player() -> bool:
	if not enabled:
		return _try_repair()
	return false


func _nearest_damaged_structure() -> Node2D:
	var best: Node2D = null
	var best_dist := REPAIR_RANGE
	for node in container.get_children():
		var structure := node as Node2D
		if structure == null or not (structure is Wall or structure is Turret):
			continue
		if structure.health == null or structure.health.is_dead() \
				or structure.health.current >= structure.health.max_health:
			continue
		var dist := player.global_position.distance_to(structure.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = structure
	return best


static func snap_to_grid(value: Vector2) -> Vector2:
	return (value / float(GRID)).floor() * GRID


static func is_placeable_spot(spot: Vector2, rect: Rect2) -> bool:
	return rect.grow(-24.0).has_point(spot)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_build"):
		toggle()
	elif enabled and event.is_action_pressed("cycle_blueprint"):
		cycle_blueprint()
	elif enabled and event.is_action_pressed("interact"):
		try_place()


func _physics_process(_delta: float) -> void:
	if enabled and is_instance_valid(player):
		_update_ghost_position()


func _update_ghost_position() -> void:
	var facing := Vector2.RIGHT
	var player_actor := player as Player
	if player_actor != null:
		facing = player_actor.facing
	var anchor := snap_to_grid(player.global_position + facing * GRID * 2.0)
	anchor.x = clampf(anchor.x, arena_rect.position.x + GRID, arena_rect.end.x - GRID)
	anchor.y = clampf(anchor.y, arena_rect.position.y + GRID, arena_rect.end.y - GRID)
	_ghost.position = anchor


func _spot_clear(center: Vector2) -> bool:
	var space := (player as Node2D).get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = CLEARANCE_RADIUS
	query.shape = circle
	query.transform = Transform2D(0.0, center)
	query.collision_mask = 1 | 2 | 8 | 32
	return space.intersect_shape(query, 1).is_empty()


func _make_ghost() -> Node2D:
	var ghost := Node2D.new()
	ghost.name = "BuildGhost"
	ghost.z_index = 6
	_add_ghost_shape(ghost)
	return ghost


func _refresh_ghost_style() -> void:
	for child in _ghost.get_children():
		child.queue_free()
	_add_ghost_shape(_ghost)


func _add_ghost_shape(ghost: Node2D) -> void:
	var visual := Polygon2D.new()
	if blueprint()["kind"] == &"turret":
		visual.polygon = PolyShapes.circle(16.0)
	else:
		visual.polygon = PolyShapes.rect(Vector2(44.0, 44.0))
	visual.color = Color(0.4, 0.9, 0.6, 0.35)
	ghost.add_child(visual)


func _make_structure(structure_kind: StringName) -> StaticBody2D:
	if structure_kind == &"turret":
		return Turret.new()
	return Wall.new()
