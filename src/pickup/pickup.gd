class_name Pickup
extends Area2D
## Resource drop. Drifts toward the player when close; grants resources via
## GameState and announces it on the Events bus when collected.

const MAGNET_RADIUS := 150.0
const COLLECT_RADIUS := 18.0
const DRIFT_SPEED := 320.0
const KIND_COLORS := {
	&"scrap": Color(0.95, 0.65, 0.2),
	&"cells": Color(0.3, 0.85, 0.95),
}

var kind: StringName = &"scrap"
var amount := 1
var player: Node2D

var _collected := false


func configure(pickup_kind: StringName, pickup_amount: int) -> void:
	kind = pickup_kind
	amount = maxi(pickup_amount, 1)


func _ready() -> void:
	collision_layer = 16
	collision_mask = 0
	monitoring = false
	z_index = 3
	var visual := Polygon2D.new()
	visual.polygon = PolyShapes.rect(Vector2(10.0, 10.0))
	visual.color = KIND_COLORS.get(kind, Color.WHITE)
	visual.rotation = PI / 4.0
	add_child(visual)


func _physics_process(delta: float) -> void:
	if _collected or player == null or not is_instance_valid(player):
		return
	var dist := global_position.distance_to(player.global_position)
	if dist <= COLLECT_RADIUS:
		collect()
	elif dist <= MAGNET_RADIUS:
		global_position += (player.global_position - global_position).normalized() * DRIFT_SPEED * delta


func collect() -> void:
	if _collected:
		return
	_collected = true
	GameState.add(kind, amount)
	Events.loot_collected.emit(kind, amount)
	queue_free()
