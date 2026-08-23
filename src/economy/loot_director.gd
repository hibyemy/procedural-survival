class_name LootDirector
extends Node
## Turns enemy deaths into resource drops. Rolls are deterministic via the
## `loot` RNG stream, salted per drop event.

var container: Node = null
var player: Node2D = null

var _roll_salt := 0


func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)


static func roll_drops(rng: RandomNumberGenerator) -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	drops.append({"kind": &"scrap", "amount": rng.randi_range(1, 3)})
	if rng.randf() < 0.25:
		drops.append({"kind": &"cells", "amount": 1})
	return drops


func _on_enemy_died(at_position: Vector2) -> void:
	if container == null:
		return
	_roll_salt += 1
	var rng := RngService.fork(&"loot", _roll_salt)
	for drop in roll_drops(rng):
		var pickup := Pickup.new()
		pickup.configure(drop["kind"], drop["amount"])
		pickup.player = player
		pickup.position = at_position + Vector2(rng.randf_range(-14.0, 14.0), rng.randf_range(-14.0, 14.0))
		container.add_child(pickup)
