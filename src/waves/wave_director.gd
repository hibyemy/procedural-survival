class_name WaveDirector
extends Node
## Spawns escalating waves of enemies along the arena edges. Wave composition
## and spawn positions are deterministic via the `spawn` RNG stream.

const FIRST_WAVE_DELAY := 3.0
const WAVE_GAP := 4.0
const MAX_WAVE_SIZE := 36
const EDGE_INSET := 56.0

var container: Node = null
var player: Node2D = null
var arena_rect := Rect2()

var wave_number := 0


func start() -> void:
	_schedule_wave(FIRST_WAVE_DELAY)


static func compose_wave(wave: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var total := mini(3 + 2 * wave, MAX_WAVE_SIZE)
	var brutes := 0
	if wave >= 3:
		brutes = mini(floori((wave - 1) / 2.0), floori(total / 3.0))
	var kinds: Array[StringName] = []
	for i in brutes:
		kinds.append(&"brute")
	for i in total - brutes:
		kinds.append(&"chaser")
	for i in range(kinds.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swapped := kinds[i]
		kinds[i] = kinds[j]
		kinds[j] = swapped
	return kinds


func _schedule_wave(delay: float) -> void:
	get_tree().create_timer(delay, false).timeout.connect(_spawn_wave)


func _spawn_wave() -> void:
	if not is_inside_tree():
		return
	wave_number += 1
	var rng := RngService.fork(&"spawn", wave_number)
	for kind in compose_wave(wave_number, rng):
		_spawn_enemy(kind, _edge_position(rng))
	Events.wave_started.emit(wave_number)
	_schedule_wave(WAVE_GAP)


func _spawn_enemy(enemy_kind: StringName, at_position: Vector2) -> void:
	var enemy := Enemy.new()
	enemy.configure(enemy_kind)
	enemy.target = player
	container.add_child(enemy)
	enemy.global_position = at_position


func _edge_position(rng: RandomNumberGenerator) -> Vector2:
	var bounds := arena_rect.grow(-EDGE_INSET)
	match rng.randi_range(0, 3):
		0:
			return Vector2(rng.randf_range(bounds.position.x, bounds.end.x), bounds.position.y)
		1:
			return Vector2(bounds.end.x, rng.randf_range(bounds.position.y, bounds.end.y))
		2:
			return Vector2(rng.randf_range(bounds.position.x, bounds.end.x), bounds.end.y)
		_:
			return Vector2(bounds.position.x, rng.randf_range(bounds.position.y, bounds.end.y))
