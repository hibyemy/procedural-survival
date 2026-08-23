class_name BossBase
extends CharacterBody2D
## Shared behavior for set-piece bosses: big shootable body on the enemy
## layer (auto-targeted by guns), phase tracking over a health fraction,
## and a boss_defeated broadcast on death.

var boss_id := &"boss"
var max_health := 100
var contact_damage := 2
var level_container: Node = null

var health: HealthComponent
var phase := 1


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	collision_layer = 2
	collision_mask = 8 | 32
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	_build_body()
	health = HealthComponent.new()
	health.setup(max_health)
	add_child(health)
	health.died.connect(_on_died)


## Subclasses build collision + visuals and stash them on the node.
func _build_body() -> void:
	pass


func phases() -> int:
	return 1


func is_dead() -> bool:
	return health != null and health.is_dead()


func take_damage(amount: int) -> void:
	health.take_damage(amount)


func update_phase() -> void:
	if health == null or health.max_health <= 0:
		return
	var fraction := float(health.current) / float(health.max_health)
	var total := phases()
	phase = clampi(total - floori(fraction * float(total)), 1, total)


func _on_died() -> void:
	Sfx.play(&"structure_down")
	Events.boss_defeated.emit(boss_id)
	queue_free()
