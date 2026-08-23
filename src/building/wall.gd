class_name Wall
extends StaticBody2D
## Cheap barricade. Absorbs contact damage from enemies until it crumbles.

const MAX_HEALTH := 20
const SIZE := Vector2(44.0, 44.0)

var health: HealthComponent


func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = SIZE
	shape.shape = rectangle
	add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.rect(SIZE)
	visual.color = Color(0.45, 0.5, 0.58)
	add_child(visual)
	health = HealthComponent.new()
	health.setup(MAX_HEALTH)
	add_child(health)
	health.died.connect(queue_free)


func take_damage(amount: int) -> void:
	health.take_damage(amount)
