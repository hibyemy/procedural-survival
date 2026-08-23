extends GutTest

var _level: Node2D


func before_each() -> void:
	if _level != null:
		_level.free()
	_level = Node2D.new()
	add_child(_level)


func test_count_structures_tallies_live_only() -> void:
	var wall := Wall.new()
	_level.add_child(wall)
	var dying_wall := Wall.new()
	_level.add_child(dying_wall)
	dying_wall.queue_free()
	var turret := Turret.new()
	_level.add_child(turret)
	_level.add_child(Enemy.new())
	var counts := Hud.count_structures(_level)
	assert_eq(counts["walls"], 1)
	assert_eq(counts["turrets"], 1)


func test_count_structures_handles_empty_container() -> void:
	var counts := Hud.count_structures(_level)
	assert_eq(counts["walls"], 0)
	assert_eq(counts["turrets"], 0)
	assert_eq(Hud.count_structures(null)["walls"], 0)


func test_interaction_prompt_format() -> void:
	assert_eq(InteractionScanner.prompt_for(&"wall", 12), "[E] REPAIR WALL  (+8 HP, 3 SCRAP)")
	assert_eq(InteractionScanner.prompt_for(&"turret", 3), "[E] REPAIR TURRET  (+3 HP, 3 SCRAP)")
