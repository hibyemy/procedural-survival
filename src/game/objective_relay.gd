class_name ObjectiveRelay
extends StaticBody2D
## Chapter 1 protect-target: the relay shack. Enemies chew it like a wall;
## if it dies the chapter fails.

const MAX_HEALTH := 40
const SIZE := Vector2(64.0, 64.0)

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
	visual.color = Color(0.55, 0.5, 0.35)
	add_child(visual)
	var dish := Polygon2D.new()
	dish.polygon = PolyShapes.circle(14.0, 12)
	dish.color = Color(0.7, 0.68, 0.55)
	dish.position = Vector2(0, -18)
	add_child(dish)
	health = HealthComponent.new()
	health.setup(MAX_HEALTH)
	add_child(health)
	health.died.connect(_on_died)


func take_damage(amount: int) -> void:
	health.take_damage(amount)


func _on_died() -> void:
	Events.objective_failed.emit("RELAY SHACK DESTROYED")
	queue_free()
