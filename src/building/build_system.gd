class_name BuildSystem
extends Node
## Build mode: [B] toggles, [TAB] cycles blueprints, [E] places the selected
## structure on a grid near the player if affordable and unobstructed.

const GRID := 48
const PLACE_DISTANCE := 168.0
const CLEARANCE_RADIUS := 18.0

const BLUEPRINTS: Array[Dictionary] = [
	{"kind": &"wall", "costs": {&"scrap": 5}},
	{"kind": &"turret", "costs": {&"scrap": 10, &"cells": 2}},
]

var player: Node2D = null
var container: Node = null
var arena_rect := Rect2()

var enabled := false
var selection := 0

var _ghost: Node2D


func _ready() -> void:
	_ghost = _make_ghost()
	_ghost.visible = false
	container.add_child(_ghost)


func blueprint() -> Dictionary:
	return BLUEPRINTS[selection]


func toggle() -> void:
	enabled = not enabled
	_ghost.visible = enabled
	if enabled:
		_update_ghost_position()
	Events.build_mode_changed.emit(enabled, blueprint()["kind"])


func cycle_blueprint() -> void:
	selection = (selection + 1) % BLUEPRINTS.size()
	_refresh_ghost_style()
	if enabled:
		Events.build_mode_changed.emit(enabled, blueprint()["kind"])


func try_place() -> bool:
	if not enabled or player == null or not is_instance_valid(player):
		return false
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
