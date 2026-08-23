class_name WaveDirector
extends Node
## Spawns escalating waves of enemies along the arena edges. Wave composition
## and spawn positions are deterministic via the `spawn` RNG stream.
## In story mode it stops after RunState.target_waves and emits run_won when
## the final wave is wiped out.

const FIRST_WAVE_DELAY := 3.0
const WAVE_GAP := 4.0
const MAX_WAVE_SIZE := 36
const EDGE_INSET := 56.0

var container: Node = null
var player: Node2D = null
var arena_rect := Rect2()
var nav_service: NavService = null

var wave_number := 0

var _run_won := false


func start() -> void:
	Events.enemy_died.connect(_on_enemy_died)
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


static func wave_is_heavy(kinds: Array[StringName]) -> bool:
	return kinds.has(&"brute")


func _has_more_waves() -> bool:
	return not RunState.is_story() or wave_number < RunState.target_waves


func _area_clear_of_enemies() -> bool:
	for child in container.get_children():
		if child is Enemy and not child.is_queued_for_deletion():
			return false
	return true


func _schedule_wave(delay: float) -> void:
	get_tree().create_timer(delay, false).timeout.connect(_spawn_wave)


func _spawn_wave() -> void:
	if not is_inside_tree():
		return
	wave_number += 1
	var rng := RngService.fork(&"spawn", wave_number)
	var kinds := compose_wave(wave_number, rng)
	for kind in kinds:
		_spawn_enemy(kind, _edge_position(rng))
	Events.wave_started.emit(wave_number, wave_is_heavy(kinds))
	Sfx.play(&"wave_horn", -6.0)
	if _has_more_waves():
		_schedule_wave(WAVE_GAP)


func _on_enemy_died(_at_position: Vector2) -> void:
	_check_victory.call_deferred()


func _check_victory() -> void:
	if _run_won or not RunState.is_story():
		return
	if wave_number < RunState.target_waves:
		return
	var player_actor := player as Player
	if player_actor != null and player_actor.health != null and player_actor.health.is_dead():
		return
	if not _area_clear_of_enemies():
		return
	_run_won = true
	Events.run_won.emit()


func _spawn_enemy(enemy_kind: StringName, at_position: Vector2) -> void:
	var enemy := Enemy.new()
	enemy.configure(enemy_kind)
	enemy.target = player
	enemy.nav_service = nav_service
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
