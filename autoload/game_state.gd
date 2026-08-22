extends Node
## Session-wide resource economy. Single source of truth for resource counts.

signal resources_changed

const RESOURCE_KINDS: Array[StringName] = [&"scrap", &"cells"]

var counts: Dictionary = {}


func _ready() -> void:
	reset()


func reset() -> void:
	counts.clear()
	for kind in RESOURCE_KINDS:
		counts[kind] = 0
	resources_changed.emit()


func add(kind: StringName, amount: int) -> void:
	counts[kind] = maxi(counts.get(kind, 0) + amount, 0)
	resources_changed.emit()


func get_count(kind: StringName) -> int:
	return counts.get(kind, 0)


func can_afford(costs: Dictionary) -> bool:
	for kind in costs:
		if get_count(kind) < costs[kind]:
			return false
	return true


func spend(costs: Dictionary) -> bool:
	if not can_afford(costs):
		return false
	for kind in costs:
		add(kind, -int(costs[kind]))
	return true
