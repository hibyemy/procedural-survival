class_name Turret
extends StaticBody2D
## Defensive structure. Auto-fires at the nearest enemy in range.

const MAX_HEALTH := 15
const FIRE_COOLDOWN := 0.9
const FIRE_RANGE := 280.0

var health: HealthComponent

var _cooldown := 0.0
var _barrel: Polygon2D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	z_index = 4
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	add_child(shape)
	var base := Polygon2D.new()
	base.polygon = PolyShapes.circle(16.0)
	base.color = Color(0.3, 0.36, 0.42)
	add_child(base)
	_barrel = Polygon2D.new()
	_barrel.polygon = PolyShapes.rect(Vector2(26.0, 8.0))
	_barrel.position = Vector2(10.0, 0.0)
	_barrel.color = Color(0.6, 0.66, 0.72)
	add_child(_barrel)
	health = HealthComponent.new()
	health.setup(MAX_HEALTH)
	add_child(health)
	health.died.connect(_on_died)


func take_damage(amount: int) -> void:
	health.take_damage(amount)


func _on_died() -> void:
	Sfx.play(&"structure_down")
	Events.structure_removed.emit(&"turret", global_position)
	queue_free()


func acquire_target() -> Node2D:
	return Targeting.pick(get_tree().get_nodes_in_group("enemies"), global_position, FIRE_RANGE)


func fire(direction: Vector2) -> Projectile:
	var bullet := Projectile.new()
	bullet.direction = direction.normalized()
	bullet.source = self
	bullet.position = global_position + bullet.direction * 22.0
	var parent := get_parent()
	parent.add_child(bullet)
	return bullet


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	var target := acquire_target()
	if target == null:
		return
	var direction := target.global_position - global_position
	_barrel.rotation = direction.angle()
	if _cooldown == 0.0:
		_cooldown = FIRE_COOLDOWN
		fire(direction)
