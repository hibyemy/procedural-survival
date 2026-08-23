class_name HealthComponent
extends Node
## Tracks an entity's hit points. Emits `changed` on damage and a single
## `died` when health reaches zero.

signal changed(current: int, maximum: int)
signal died

@export var max_health: int = 1

var current: int = 0


func setup(max_hp: int) -> void:
	max_health = maxi(max_hp, 1)
	current = max_health
	changed.emit(current, max_health)


func is_dead() -> bool:
	return current <= 0


func take_damage(amount: int) -> void:
	if amount <= 0 or current <= 0:
		return
	current = maxi(current - amount, 0)
	changed.emit(current, max_health)
	if current == 0:
		died.emit()
