class_name CrawlerTitan
extends BossBase
## Chapter 3 set-piece: a rail siege walker that circles the arena border,
## fires telegraphed line salvos that shred structures, and drops escort
## packs. Kill it and the chapter is won regardless of remaining waves.

const ORBIT_SPEED := 0.22
const SALVO_INTERVAL := 6.0
const TELEGRAPH_TIME := 1.0
const ESCORT_INTERVAL := 20.0
const SALVO_COUNT := 8

var arena_rect := Rect2()
var player: Node2D = null

var _angle := 0.0
var _salvo_timer := SALVO_INTERVAL - TELEGRAPH_TIME
var _telegraph_left := 0.0
var _escort_timer := ESCORT_INTERVAL
var _telegraph: Polygon2D
var _spawn_salt := 0


func _init() -> void:
	boss_id = &"crawler_titan"
	max_health = 120


func phases() -> int:
	return 3


func _build_body() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 46.0
	shape.shape = circle
	add_child(shape)
	var hull := Polygon2D.new()
	hull.polygon = PolyShapes.circle(46.0, 12)
	hull.color = Color(0.45, 0.28, 0.2)
	add_child(hull)
	var plating := Polygon2D.new()
	plating.polygon = PolyShapes.rect(Vector2(60.0, 24.0))
	plating.color = Color(0.3, 0.2, 0.16)
	add_child(plating)
	_telegraph = Polygon2D.new()
	_telegraph.color = Color(1.0, 0.4, 0.25, 0.35)
	_telegraph.visible = false
	add_child(_telegraph)


static func orbit(center: Vector2, radius: float, angle: float) -> Vector2:
	return center + Vector2(cos(angle), sin(angle)) * radius


func _physics_process(delta: float) -> void:
	if is_dead():
		return
	update_phase()
	var speed_multiplier: float = [1.0, 1.5, 2.1][phase - 1]
	_angle += ORBIT_SPEED * speed_multiplier * delta
	var ring := minf(arena_rect.size.x, arena_rect.size.y) * 0.5 - 96.0
	global_position = orbit(arena_rect.get_center(), ring, _angle)

	if _telegraph_left > 0.0:
		_telegraph_left -= delta
		if _telegraph_left <= 0.0:
			_telegraph.visible = false
			_fire_salvo()

	_salvo_timer -= delta * speed_multiplier
	if _salvo_timer <= 0.0:
		_salvo_timer = SALVO_INTERVAL
		_begin_telegraph()

	_escort_timer -= delta
	var escort_period := ESCORT_INTERVAL if phase < 3 else ESCORT_INTERVAL * 0.6
	if _escort_timer <= 0.0:
		_escort_timer = escort_period
		_spawn_escorts()


func _begin_telegraph() -> void:
	_telegraph.visible = true
	_telegraph.rotation = TAU * 0.125 if player == null else (player.global_position - global_position).angle()
	_telegraph_left = TELEGRAPH_TIME
	Sfx.play(&"wave_horn", -4.0)


func _fire_salvo() -> void:
	for i in SALVO_COUNT:
		var spread := TAU * float(i) / float(SALVO_COUNT)
		_spawn_shell(Vector2.RIGHT.rotated(spread + _angle))


func _spawn_shell(direction: Vector2) -> void:
	var shell := Projectile.new()
	shell.target_mask = 1 | 8 | 32
	shell.direction = direction
	shell.speed = 420.0
	shell.damage = 2
	shell.lifetime = 2.4
	shell.source = self
	shell.position = global_position + direction * 50.0
	get_parent().add_child(shell)


func _spawn_escorts() -> void:
	if level_container == null:
		return
	_spawn_salt += 1
	var rng := RngService.fork(&"boss_escort", _spawn_salt)
	for i in 3:
		var escort := Enemy.new()
		escort.configure(&"chaser")
		escort.target = player
		level_container.add_child(escort)
		escort.global_position = global_position + Vector2(rng.randf_range(-40, 40), rng.randf_range(-40, 40))
