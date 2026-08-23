class_name Projectile
extends Area2D
## Straight-flying bullet. Damages the first damageable body it touches,
## then frees itself. Configure fields before adding to the tree.
## Passes over buildings; dies on world_static borders and rocks.

var direction := Vector2.RIGHT
var speed := 760.0
var damage := 1
var lifetime := 1.2
var source: Node = null


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2 | 32
	z_index = 5
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4.0
	shape.shape = circle
	add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.rect(Vector2(12.0, 4.0))
	visual.color = Color(1.0, 0.92, 0.4)
	visual.rotation = direction.angle()
	add_child(visual)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body == source or not is_instance_valid(body):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		Sfx.play(&"impact", -6.0)
		queue_free()
