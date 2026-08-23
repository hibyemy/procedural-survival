extends GutTest

var _container: Node2D


func before_each() -> void:
	if _container != null:
		_container.free()
	_container = Node2D.new()
	add_child(_container)


func _fake_at(offset: Vector2, dead := false) -> FakeEnemy:
	var fake := FakeEnemy.new()
	fake.dead = dead
	fake.position = offset
	_container.add_child(fake)
	return fake


func test_picks_nearest_candidate_in_range() -> void:
	var near := _fake_at(Vector2(50, 0))
	var far := _fake_at(Vector2(90, 0))
	var picked := Targeting.pick([near, far], _container.global_position, 100.0)
	assert_same(picked, near)


func test_ignores_candidates_out_of_range() -> void:
	var near := _fake_at(Vector2(50, 0))
	var far := _fake_at(Vector2(300, 0))
	var picked := Targeting.pick([near, far], _container.global_position, 100.0)
	assert_same(picked, near)
	var none := Targeting.pick([far], _container.global_position, 100.0)
	assert_null(none)


func test_skips_dead_candidates() -> void:
	var dead_near := _fake_at(Vector2(10, 0), true)
	var alive_far := _fake_at(Vector2(80, 0))
	var picked := Targeting.pick([dead_near, alive_far], _container.global_position, 100.0)
	assert_same(picked, alive_far)


func test_returns_null_when_nothing_available() -> void:
	assert_null(Targeting.pick([], _container.global_position, 100.0))


func test_plain_nodes_without_is_dead_count_as_alive() -> void:
	var plain := Node2D.new()
	plain.position = Vector2(20, 0)
	_container.add_child(plain)
	assert_same(Targeting.pick([plain], _container.global_position, 100.0), plain)
