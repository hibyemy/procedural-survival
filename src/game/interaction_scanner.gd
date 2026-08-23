class_name InteractionScanner
extends Node
## Watches the player's surroundings and surfaces contextual prompts.
## Currently: damaged structures near a player with the Repair Kit.

const REPAIR_RANGE := 96.0

var player: Node2D = null
var container: Node = null
var hud: Hud = null
var build_system: BuildSystem = null
var can_repair := false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if build_system != null and build_system.enabled:
		return
	try_interact()


func try_interact() -> bool:
	if not can_repair or build_system == null:
		return false
	return build_system.try_repair_from_player()


func _physics_process(_delta: float) -> void:
	if hud == null or player == null or not is_instance_valid(player):
		return
	var target := find_damaged_structure()
	if target == null:
		hud.set_prompt("")
		return
	var missing: int = target.health.max_health - target.health.current
	hud.set_prompt(InteractionScanner.prompt_for(target_kind(target), missing))


func target_kind(structure: Node2D) -> StringName:
	return &"turret" if structure is Turret else &"wall"


func find_damaged_structure() -> Node2D:
	if not can_repair or build_system == null or container == null:
		return null
	var best: Node2D = null
	var best_dist := REPAIR_RANGE
	for node in container.get_children():
		var structure := node as Node2D
		if structure == null or not (structure is Wall or structure is Turret):
			continue
		if structure.health == null or structure.health.is_dead() \
				or structure.health.current >= structure.health.max_health:
			continue
		var dist := player.global_position.distance_to(structure.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = structure
	return best


static func prompt_for(kind: StringName, missing_hp: int) -> String:
	return "[E] REPAIR %s  (+%d HP, %d SCRAP)" % [
			String(kind).to_upper(), mini(missing_hp, BuildSystem.REPAIR_AMOUNT), BuildSystem.REPAIR_COST]
