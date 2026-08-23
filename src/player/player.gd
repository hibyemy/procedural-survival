class_name Player
extends CharacterBody2D
## Top-down player avatar: WASD movement, auto-firing gun, health relayed
## onto the Events bus.

const MAX_HEALTH := 10
const SPEED := 240.0
const GUN_COOLDOWN := 0.35
const GUN_RANGE := 420.0

var facing := Vector2.RIGHT
var projectile_parent: Node = null
var health: HealthComponent

var _gun_cooldown := 0.0
var _nose: Polygon2D


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 8 | 32
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	var body_visual := Polygon2D.new()
	body_visual.polygon = PolyShapes.circle(14.0)
	body_visual.color = Color(0.55, 0.78, 1.0)
	add_child(body_visual)
	_nose = Polygon2D.new()
	_nose.polygon = PackedVector2Array([Vector2(7.0, 0.0), Vector2(-4.0, -5.0), Vector2(-4.0, 5.0)])
	_nose.color = Color(0.92, 0.98, 1.0)
	add_child(_nose)
	health = HealthComponent.new()
	health.setup(MAX_HEALTH)
	add_child(health)
	health.changed.connect(_on_health_changed)
	health.died.connect(_on_health_died)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = compute_velocity(input_dir)
	move_and_slide()
	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()
	_nose.position = facing * 16.0
	_nose.rotation = facing.angle()
	_gun_cooldown = maxf(_gun_cooldown - delta, 0.0)
	if _gun_cooldown == 0.0:
		_try_fire()


func take_damage(amount: int) -> void:
	health.take_damage(amount)


func acquire_target(max_range: float) -> Node2D:
	return Targeting.pick(get_tree().get_nodes_in_group("enemies"), global_position, max_range)


func fire(direction: Vector2) -> Projectile:
	var bullet := Projectile.new()
	bullet.direction = direction.normalized()
	bullet.source = self
	bullet.position = global_position + bullet.direction * 18.0
	var parent := projectile_parent if projectile_parent != null else get_parent()
	parent.add_child(bullet)
	Sfx.play(&"shoot", -8.0)
	return bullet


static func compute_velocity(input_dir: Vector2) -> Vector2:
	return input_dir.limit_length(1.0) * SPEED


func _try_fire() -> void:
	var target := acquire_target(GUN_RANGE)
	if target == null:
		return
	fire(target.global_position - global_position)


func _on_health_changed(current: int, maximum: int) -> void:
	Events.player_health_changed.emit(current, maximum)
	Sfx.play(&"hurt", -4.0)


func _on_health_died() -> void:
	Events.player_died.emit()
