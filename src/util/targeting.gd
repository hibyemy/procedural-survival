class_name Targeting
extends RefCounted
## Nearest-target selection shared by the player gun and turrets.


static func pick(candidates: Array, from_position: Vector2, max_range: float) -> Node2D:
	var best: Node2D = null
	var best_dist := max_range
	for node in candidates:
		var candidate := node as Node2D
		if candidate == null or not is_instance_valid(candidate):
			continue
		if candidate.has_method("is_dead") and candidate.is_dead():
			continue
		var dist := from_position.distance_to(candidate.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = candidate
	return best
