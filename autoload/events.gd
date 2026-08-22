extends Node
## Global signal bus. Systems communicate through Events signals only;
## never reach across modules via direct node references.

signal player_died
signal enemy_died(at_position: Vector2)
signal loot_collected(kind: StringName, amount: int)
signal wave_started(number: int)
