extends GutTest


func before_each() -> void:
	GameState.reset()


func test_add_increments_and_emits_signal() -> void:
	watch_signals(GameState)
	GameState.add(&"scrap", 5)
	assert_signal_emitted(GameState, "resources_changed")
	assert_eq(GameState.get_count(&"scrap"), 5)


func test_add_never_goes_negative() -> void:
	GameState.add(&"scrap", -10)
	assert_eq(GameState.get_count(&"scrap"), 0)


func test_spend_rejects_insufficient_funds() -> void:
	GameState.add(&"scrap", 3)
	assert_false(GameState.spend({&"scrap": 10}))
	assert_eq(GameState.get_count(&"scrap"), 3)


func test_spend_accepts_affordable_costs() -> void:
	GameState.add(&"scrap", 10)
	GameState.add(&"cells", 2)
	assert_true(GameState.spend({&"scrap": 4, &"cells": 2}))
	assert_eq(GameState.get_count(&"scrap"), 6)
	assert_eq(GameState.get_count(&"cells"), 0)


func test_can_afford_checks_all_kinds() -> void:
	GameState.add(&"scrap", 100)
	assert_false(GameState.can_afford({&"scrap": 1, &"cells": 1}))


func test_input_actions_registered() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right", "interact", "toggle_build"]:
		assert_true(InputMap.has_action(action), "missing action: %s" % action)
