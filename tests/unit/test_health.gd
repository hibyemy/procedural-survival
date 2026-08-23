extends GutTest


func _make(max_hp: int) -> HealthComponent:
	var component := HealthComponent.new()
	component.setup(max_hp)
	autofree(component)
	return component


func test_setup_starts_full() -> void:
	var component := _make(5)
	assert_eq(component.current, 5)
	assert_false(component.is_dead())


func test_damage_reduces_current_health() -> void:
	var component := _make(5)
	watch_signals(component)
	component.take_damage(2)
	assert_signal_emitted(component, "changed")
	assert_eq(component.current, 3)


func test_damage_clamps_at_zero_and_dies_once() -> void:
	var component := _make(4)
	watch_signals(component)
	component.take_damage(99)
	assert_eq(component.current, 0)
	assert_true(component.is_dead())
	assert_signal_emit_count(component, "died", 1)
	component.take_damage(10)
	assert_signal_emit_count(component, "died", 1)


func test_zero_or_negative_damage_is_ignored() -> void:
	var component := _make(4)
	watch_signals(component)
	component.take_damage(0)
	component.take_damage(-3)
	assert_signal_not_emitted(component, "changed")
	assert_eq(component.current, 4)


func test_dead_entity_ignores_further_damage() -> void:
	var component := _make(2)
	component.take_damage(2)
	watch_signals(component)
	component.take_damage(1)
	assert_signal_not_emitted(component, "changed")
	assert_eq(component.current, 0)


func test_setup_below_one_is_clamped_to_one() -> void:
	var component := _make(0)
	assert_eq(component.max_health, 1)
