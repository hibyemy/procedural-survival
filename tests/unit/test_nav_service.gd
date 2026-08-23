extends GutTest

const SMALL_RECT := Rect2(0, 0, 480, 480)


func _service() -> NavService:
	var nav := NavService.new()
	add_child(nav)
	nav.setup(SMALL_RECT)
	return nav


func test_world_cell_conversion_roundtrip() -> void:
	var nav := _service()
	var cell := Vector2i(3, 4)
	var world := nav.cell_center(cell)
	assert_eq(nav.world_to_cell(world), cell)
	assert_eq(nav.world_to_cell(Vector2.ZERO), Vector2i.ZERO)
	assert_eq(nav.cell_center(Vector2i.ZERO), Vector2(NavService.GRID, NavService.GRID) * 0.5)


func test_mark_solid_and_clear() -> void:
	var nav := _service()
	var center := nav.cell_center(Vector2i(2, 2))
	nav.mark_solid(center)
	assert_true(nav.is_cell_solid(Vector2i(2, 2)))
	nav.clear_solid(center)
	assert_false(nav.is_cell_solid(Vector2i(2, 2)))


func test_out_of_bounds_writes_are_ignored() -> void:
	var nav := _service()
	nav.set_cell_solid(Vector2i(-5, -5), true)
	nav.set_cell_solid(Vector2i(99, 99), true)
	assert_false(nav.is_cell_solid(Vector2i(-5, -5)))
	assert_false(nav.is_cell_solid(Vector2i(99, 99)))


func test_find_path_routes_around_solid_block() -> void:
	var nav := _service()
	for y in [4, 5]:
		nav.mark_solid(nav.cell_center(Vector2i(5, y)))
	var path := nav.find_path(
			nav.cell_center(Vector2i(2, 4)),
			nav.cell_center(Vector2i(8, 4)))
	assert_gt(path.size(), 0)
	var blocked_center := nav.cell_center(Vector2i(5, 4))
	for point in path:
		assert_ne(point, blocked_center)


func test_unreachable_goal_returns_empty_path() -> void:
	var nav := _service()
	for y in range(0, 10):
		nav.mark_solid(nav.cell_center(Vector2i(5, y)))
	var path := nav.find_path(
			nav.cell_center(Vector2i(1, 1)),
			nav.cell_center(Vector2i(8, 8)))
	assert_eq(path.size(), 0)


func test_adjacent_or_same_cell_shortcuts_to_goal() -> void:
	var nav := _service()
	var goal := Vector2(200.0, 130.0)
	var path := nav.find_path(goal + Vector2(10, 0), goal)
	assert_eq(path.size(), 1)
	assert_eq(path[0], goal)


func test_mark_circle_blocks_covered_cells() -> void:
	var nav := _service()
	nav.mark_circle(Vector2(240, 240), 24.0)
	assert_true(nav.is_cell_solid(Vector2i(4, 4)))
