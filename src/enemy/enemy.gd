class_name Enemy
extends CharacterBody2D
## Melee chaser. Walks toward the injected target, damages it on contact and
## chews through blocking buildings. Announces death on the Events bus so the
## loot director can drop pickups.

const CONTACT_PAD := 14.0
const ATTACK_COOLDOWN := 0.8
const REPATH_INTERVAL := 0.45
const WAYPOINT_RADIUS := 18.0
const KIND_STATS := {
	&"chaser": {"health": 3, "speed": 130.0, "damage": 1, "radius": 12.0, "color": Color(0.9, 0.35, 0.3)},
	&"brute": {"health": 12, "speed": 75.0, "damage": 2, "radius": 22.0, "color": Color(0.62, 0.25, 0.55)},
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
	velocity = _steering_direction(dist_to_target) * speed
	move_and_slide()
	if _attack_cooldown > 0.0:
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


func _on_health_died() -> void:
	Events.enemy_died.emit(global_position)
	queue_free()
