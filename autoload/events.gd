extends Node
## Global signal bus. Systems communicate through Events signals only;
## never reach across modules via direct node references.

signal player_died
signal player_health_changed(current: int, maximum: int)
signal enemy_died(at_position: Vector2)
signal loot_collected(kind: StringName, amount: int)
signal wave_started(number: int, heavy: bool)
signal wave_cleared(number: int)
signal building_placed(kind: StringName, at_position: Vector2)
signal structure_removed(kind: StringName, at_position: Vector2)
signal build_mode_changed(enabled: bool, blueprint_kind: StringName)
signal run_won
