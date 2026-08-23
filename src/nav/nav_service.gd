class_name NavService
extends Node
## Grid-based pathfinding over the arena using AStarGrid2D. One service is
## shared by all enemies; solid cells come from rocks and player-built
## structures. World<->cell conversions use the same 48 px grid as BuildSystem.

const GRID := 48
const CLEARANCE_PAD := 14.0

var arena_rect := Rect2()

var _astar := AStarGrid2D.new()


func setup(rect: Rect2) -> void:
	arena_rect = rect
	var origin := world_to_cell(rect.position)
	var end := world_to_cell(rect.end - Vector2.ONE)
	_astar.region = Rect2i(origin, end - origin + Vector2i.ONE)
	_astar.cell_size = Vector2(GRID, GRID)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()


func mark_circle(center: Vector2, radius: float) -> void:
	var padded := radius + CLEARANCE_PAD
	_mark_cells_in_rect(Rect2(center - Vector2(padded, padded), Vector2(padded, padded) * 2.0), true)


func mark_solid(world_position: Vector2) -> void:
	set_cell_solid(world_to_cell(world_position), true)


func clear_solid(world_position: Vector2) -> void:
	set_cell_solid(world_to_cell(world_position), false)


func set_cell_solid(cell: Vector2i, solid: bool) -> void:
	if _in_bounds(cell):
		_astar.set_point_solid(cell, solid)


func is_cell_solid(cell: Vector2i) -> bool:
	return _in_bounds(cell) and _astar.is_point_solid(cell)


func world_to_cell(world_position: Vector2) -> Vector2i:
	var local := (world_position - arena_rect.position) / float(GRID)
	return Vector2i(floori(local.x), floori(local.y))


func cell_center(cell: Vector2i) -> Vector2:
	return arena_rect.position + (Vector2(cell) + Vector2(0.5, 0.5)) * float(GRID)


## Returns world-space waypoints from `from` toward `to` (excluding start,
## including goal). Empty when unreachable or trivially adjacent.
func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	var start := world_to_cell(from_world)
	var goal := world_to_cell(to_world)
	if not _in_bounds(goal) or _astar.is_point_solid(goal):
		return PackedVector2Array()
	if start == goal or start.distance_squared_to(goal) <= 1:
		return PackedVector2Array([to_world])
	var ids := _astar.get_id_path(start, goal)
	if ids.is_empty():
		return PackedVector2Array()
	var points := PackedVector2Array()
	for i in range(1, ids.size()):
		points.append(cell_center(ids[i]))
	points[points.size() - 1] = to_world
	return points


func _mark_cells_in_rect(area: Rect2, solid: bool) -> void:
	var min_cell := world_to_cell(area.position)
	var max_cell := world_to_cell(area.end)
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			set_cell_solid(Vector2i(x, y), solid)


func _in_bounds(cell: Vector2i) -> bool:
	return _astar.is_in_boundsv(cell)
