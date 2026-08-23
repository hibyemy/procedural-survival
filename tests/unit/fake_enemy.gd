class_name FakeEnemy
extends Node2D
## Minimal stand-in used by targeting/combat unit tests.

var dead := false


func is_dead() -> bool:
	return dead


func take_damage(_amount: int) -> void:
	pass
