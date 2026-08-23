class_name Enemy
extends CharacterBody2D
## Melee chaser. Walks toward the injected target, damages it on contact and
## chews through blocking buildings. Announces death on the Events bus so the
## loot director can drop pickups.

const CONTACT_PAD := 14.0
const ATTACK_COOLDOWN := 0.8
const REPATH_INTERVAL := 0.45
const WAYPOINT_RADIUS := 18.0
const GUNNER_FIRE_RANGE := 220.0
const GUNNER_MIN_RANGE := 150.0
const GUNNER_COOLDOWN := 1.6
const DRONE_HEAL_INTERVAL := 1.0
const KIND_STATS := {
	&"chaser": {"health": 3, "speed": 130.0, "damage": 1, "radius": 12.0, "color": Color(0.9, 0.35, 0.3)},
	&"brute": {"health": 12, "speed": 75.0, "damage": 2, "radius": 22.0, "color": Color(0.62, 0.25, 0.55)},
	&"skirmisher": {"health": 2, "speed": 195.0, "damage": 1, "radius": 10.0, "color": Color(0.85, 0.82, 0.6)},
	&"gunner": {"health": 5, "speed": 95.0, "damage": 1, "radius": 14.0, "color": Color(0.45, 0.6, 0.78)},
	&"repair_drone": {"health": 4, "speed": 150.0, "damage": 0, "radius": 11.0, "color": Color(0.35, 0.8, 0.85)},
}

var kind: StringName = &"chaser"
var speed := 130.0
var contact_damage := 1
var target: Node2D
var nav_service: NavService = null
var health: HealthComponent

var _radius := 12.0
var _attack_cooldown := 0.0
var _repath_cooldown := 0.0
var _path := PackedVector2Array()
var _sway_phase := 0.0
var _heal_tick := 0.0


func configure(enemy_kind: StringName) -> void:
	kind = enemy_kind
	var stats: Dictionary = KIND_STATS[kind]
	speed = stats["speed"]
	contact_damage = stats["damage"]
	_radius = stats["radius"]


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1 | 2 | 8 | 32
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var stats: Dictionary = KIND_STATS[kind]
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _radius
	shape.shape = circle
	add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.circle(_radius)
	visual.color = stats["color"]
	add_child(visual)
	health = HealthComponent.new()
	health.setup(stats["health"])
	add_child(health)
	health.died.connect(_on_health_died)
	_repath_cooldown = float(get_instance_id() % 45) / 100.0


func is_dead() -> bool:
	return health != null and health.is_dead()


func take_damage(amount: int) -> void:
	health.take_damage(amount)


static func chase_direction(from_position: Vector2, to_position: Vector2) -> Vector2:
	var diff := to_position - from_position
	return diff.normalized() if diff.length() > 0.001 else Vector2.ZERO


func _physics_process(delta: float) -> void:
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	_repath_cooldown = maxf(_repath_cooldown - delta, 0.0)
	if is_dead():
		return
	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	var dist_to_target := global_position.distance_to(target.global_position)
	match kind:
		&"gunner":
			velocity = _gunner_steering(dist_to_target) * speed
		&"repair_drone":
			velocity = _drone_steering() * speed
			_tick_healing(delta)
		_:
			velocity = _steering_direction(dist_to_target) * speed
	move_and_slide()
	_run_contact_attacks(dist_to_target)


func _run_contact_attacks(dist_to_target: float) -> void:
	if contact_damage <= 0 or _attack_cooldown > 0.0:
		return
	if dist_to_target <= _radius + CONTACT_PAD:
		if target.has_method("take_damage"):
			target.take_damage(contact_damage)
			_attack_cooldown = ATTACK_COOLDOWN
		return
	for i in get_slide_collision_count():
		var blocker := get_slide_collision(i).get_collider()
		if blocker == null or blocker is Enemy or not blocker.has_method("take_damage"):
			continue
		blocker.take_damage(contact_damage)
		_attack_cooldown = ATTACK_COOLDOWN
		break


## Path-following when a NavService is wired, straight chase otherwise.
func _steering_direction(dist_to_target: float) -> Vector2:
	var direction := _nav_or_chase_direction(dist_to_target)
	if kind == &"skirmisher" and direction != Vector2.ZERO:
		direction = apply_sway(direction, _sway_phase)
		_sway_phase += 0.12
	return direction


func _nav_or_chase_direction(dist_to_target: float) -> Vector2:
	if nav_service == null:
		return chase_direction(global_position, target.global_position)
	if dist_to_target <= _radius + NavService.GRID:
		return Vector2.ZERO
	if _repath_cooldown <= 0.0:
		_path = nav_service.find_path(global_position, target.global_position)
		_repath_cooldown = REPATH_INTERVAL
	while not _path.is_empty() and global_position.distance_to(_path[0]) < WAYPOINT_RADIUS:
		_path.remove_at(0)
	if _path.is_empty():
		return chase_direction(global_position, target.global_position)
	return (_path[0] - global_position).normalized()


## Gunners hold a firing range: advance when far, retreat when crowded,
## shoot while standing.
func _gunner_steering(dist_to_target: float) -> Vector2:
	if dist_to_target > GUNNER_FIRE_RANGE:
		return _nav_or_chase_direction(dist_to_target)
	if dist_to_target < GUNNER_MIN_RANGE:
		return -chase_direction(global_position, target.global_position)
	_try_gunner_shot()
	return Vector2.ZERO


func _try_gunner_shot() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = GUNNER_COOLDOWN
	var bullet := Projectile.new()
	bullet.target_mask = 1 | 8 | 32
	bullet.direction = (target.global_position - global_position).normalized()
	bullet.source = self
	bullet.speed = 420.0
	bullet.position = global_position + bullet.direction * 16.0
	get_parent().add_child(bullet)
	Sfx.play(&"turret_shot", -10.0)


## Repair drones shadow the nearest damaged ally and heal it.
func _drone_steering() -> Vector2:
	var patient := _find_patient()
	if patient == null:
		return chase_direction(global_position, target.global_position) * 0.6
	var dist := global_position.distance_to(patient.global_position)
	if dist <= 40.0:
		return Vector2.ZERO
	return (patient.global_position - global_position).normalized()


func _find_patient() -> Enemy:
	var best: Enemy = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("enemies"):
		var ally := node as Enemy
		if ally == null or ally == self or not is_instance_valid(ally) or ally.is_dead():
			continue
		if ally.health == null or ally.health.current >= ally.health.max_health:
			continue
		var d := global_position.distance_squared_to(ally.global_position)
		if d < best_dist:
			best_dist = d
			best = ally
	return best


func _tick_healing(delta: float) -> void:
	_heal_tick -= delta
	if _heal_tick > 0.0:
		return
	_heal_tick = DRONE_HEAL_INTERVAL
	var patient := _find_patient()
	if patient != null and global_position.distance_to(patient.global_position) <= 56.0:
		patient.health.heal(1)


static func apply_sway(direction: Vector2, phase: float) -> Vector2:
	return direction.rotated(sin(phase) * 0.7)


## Gunners hold a firing range: advance when far, retreat when crowded.
static func gunner_should_advance(dist: float) -> bool:
	return dist > GUNNER_FIRE_RANGE


func _on_health_died() -> void:
	Events.enemy_died.emit(global_position)
	queue_free()
