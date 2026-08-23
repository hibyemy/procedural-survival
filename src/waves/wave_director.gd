class_name WaveDirector
extends Node
## Spawns waves from a ChapterConfig (or an endless synthetic config).
## Composition, spawn positions and boss escorts are deterministic via the
## `spawn` RNG stream. Story victory: clear the final wave's field, or kill
## the chapter boss early.

const FIRST_WAVE_DELAY := 3.0
const WAVE_GAP := 4.0
const MAX_WAVE_SIZE := 36
const EDGE_INSET := 56.0

var container: Node = null
var player: Node2D = null
var arena_rect := Rect2()
var nav_service: NavService = null
var config: ChapterConfig = null

var wave_number := 0

var _run_won := false
var _boss_down := false
var _boss: BossBase = null


func start() -> void:
	Events.enemy_died.connect(_on_enemy_died)
	Events.boss_defeated.connect(_on_boss_defeated)
	_schedule_wave(FIRST_WAVE_DELAY)


static func compose_wave(wave: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var config := ChapterConfig.new()
	config.brutes_from_wave = 3
	return compose_for_config(config, wave, rng)


## Deterministic composition honoring the chapter roster gates.
static func compose_for_config(config: ChapterConfig, wave: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var total := mini(3 + 2 * wave, MAX_WAVE_SIZE)
	var brutes := 0
	if config.brutes_from_wave > 0 and wave >= config.brutes_from_wave:
		brutes = mini(floori((wave - 1) / 2.0), floori(total / 3.0))
	var skirmishers := 0
	if config.skirmishers_from_wave > 0 and wave >= config.skirmishers_from_wave:
		skirmishers = floori(total * 0.25)
	var gunners := 0
	if config.gunners_from_wave > 0 and wave >= config.gunners_from_wave:
		gunners = mini(ceili(total * 0.15), 4)
	var drones := 0
	if config.repair_drones_from_wave > 0 and wave >= config.repair_drones_from_wave:
		drones = mini(brutes, 2)
	var chasers := total - brutes - skirmishers - gunners - drones
	var kinds: Array[StringName] = []
	for i in brutes:
		kinds.append(&"brute")
	for i in skirmishers:
		kinds.append(&"skirmisher")
	for i in gunners:
		kinds.append(&"gunner")
	for i in drones:
		kinds.append(&"repair_drone")
	for i in chasers:
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
	if not RunState.is_story():
		return true
	if _boss_down:
		return false
	return wave_number < config.target_waves


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
	var kinds := compose_for_config(config, wave_number, rng)
	for kind in kinds:
		_spawn_enemy(kind, _edge_position(rng))
	Events.wave_started.emit(wave_number, wave_is_heavy(kinds))
	Sfx.play(&"wave_horn", -6.0)
	if not RunState.is_story():
		SaveGame.record_endless_wave(wave_number)
	_maybe_spawn_boss()
	if _has_more_waves():
		_schedule_wave(WAVE_GAP)


func _maybe_spawn_boss() -> void:
	if not RunState.is_story() or not config.has_boss():
		return
	if wave_number < ceili(config.target_waves / 2.0) or _boss != null:
		return
	match config.boss_id:
		&"crawler_titan":
			var titan := CrawlerTitan.new()
			titan.player = player
			titan.level_container = container
			titan.arena_rect = arena_rect
			container.add_child(titan)
			titan.global_position = arena_rect.get_center() + Vector2(0, -minf(arena_rect.size.x, arena_rect.size.y) * 0.5 + 96.0)
			_boss = titan
		_:
			print("main: boss '%s' reserved for a later build" % config.boss_id)


func _on_boss_defeated(boss_id: StringName) -> void:
	if config != null and boss_id == config.boss_id:
		_boss_down = true
	_check_victory.call_deferred()


func _on_enemy_died(_at_position: Vector2) -> void:
	_check_victory.call_deferred()


func _check_victory() -> void:
	if _run_won or not RunState.is_story():
		return
	if config.has_boss():
		if not _boss_down:
			return
	else:
		if wave_number < config.target_waves:
			return
		if not _area_clear_of_enemies():
			return
	var player_actor := player as Player
	if player_actor != null and player_actor.health != null and player_actor.health.is_dead():
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
