extends CharacterBody2D

const SPEED_PATROL := 90.0
const SPEED_CHASE := 220.0
const SPEED_SEARCH := 120.0
const SPEED_RETURN := 100.0
const VISION_RANGE := 260.0
const VISION_ANGLE := 1.2
const CATCH_DIST := 30.0
const TELEPORT_MIN := 20.0
const TELEPORT_MAX := 30.0
const BLIND_TIME := 1.5
const CHASE_TIRED := 6.0

enum State { PATROL, SUSPICIOUS, CHASE, SEARCH, RETURN }

var state: State = State.PATROL
var facing := Vector2.DOWN
var target: Vector2 = Vector2.ZERO
var state_timer := 0.0
var chase_timer := 0.0
var teleport_timer := 0.0
var blind_timer := 0.0
var telegraph_timer := 0.0
var search_center := Vector2.ZERO
var waypoint_timer := 0.0
var patrol_index := 0
var speed_mult := 1.0
var teleport_mult := 1.0
var path: PackedVector2Array = []
var path_index := 0
var repath_timer := 0.0
var level: Node2D
var rng := RandomNumberGenerator.new()

var boss_sprite: Sprite2D
var eye_l: Polygon2D
var eye_r: Polygon2D
var state_mark: Label
var boss_light: PointLight2D

const CONE_TEX := preload("res://assets/flashlight_cone.png")
const PALE_TEX := preload("res://assets/monster/pale_figure.png")
var _last_mark := ""

func _enter_tree() -> void:
	set_multiplayer_authority(1)

func _ready() -> void:
	rng.randomize()
	level = get_parent().get_parent()
	_build_visual()
	teleport_timer = rng.randf_range(TELEPORT_MIN, TELEPORT_MAX)
	_pick_waypoint()

func _get_or_create(parent: Node, node_name: String, type: Variant) -> Node:
	var existing := get_node_or_null(node_name)
	if existing != null:
		return existing
	var n: Node = type.new()
	n.name = node_name
	parent.add_child(n)
	return n

func _build_visual() -> void:
	boss_sprite = _get_or_create(self, "Gambar", Sprite2D) as Sprite2D
	boss_sprite.texture = PALE_TEX
	boss_sprite.position = Vector2(0, -22)
	boss_sprite.scale = Vector2(1.25, 1.25)
	eye_l = _get_or_create(self, "Mata_Kiri", Polygon2D) as Polygon2D
	eye_l.color = Color(1, 1, 1, 1)
	eye_l.polygon = _circle_points(Vector2(-6, -54), 3.5)
	eye_r = _get_or_create(self, "Mata_Kanan", Polygon2D) as Polygon2D
	eye_r.color = Color(1, 1, 1, 1)
	eye_r.polygon = _circle_points(Vector2(6, -54), 3.5)
	state_mark = _get_or_create(self, "Tanda", Label) as Label
	state_mark.text = ""
	state_mark.position = Vector2(-14, -74)
	state_mark.add_theme_font_size_override("font_size", 30)
	state_mark.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	state_mark.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	state_mark.add_theme_constant_override("outline_size", 8)
	boss_light = _get_or_create(self, "Senter_Merah", PointLight2D) as PointLight2D
	boss_light.texture = CONE_TEX
	boss_light.texture_scale = 2.0
	boss_light.energy = 2.0
	boss_light.color = Color(1.0, 0.15, 0.15, 1.0)

func _process(_delta: float) -> void:
	if boss_light != null:
		boss_light.position = facing * 12.0
		boss_light.rotation = facing.angle()

func _circle_points(center: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a := TAU * float(i) / 8.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if blind_timer > 0.0:
		blind_timer -= delta
	if telegraph_timer > 0.0:
		telegraph_timer -= delta
		visible = int(Time.get_ticks_msec() / 120) % 2 == 0
		if telegraph_timer <= 0.0:
			_do_teleport()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	visible = true
	teleport_timer -= delta
	if teleport_timer <= 0.0:
		_start_telegraph()
	state_timer += delta
	match state:
		State.PATROL:
			_update_patrol(delta)
		State.SUSPICIOUS:
			_update_suspicious(delta)
		State.CHASE:
			_update_chase(delta)
		State.SEARCH:
			_update_search(delta)
		State.RETURN:
			_update_return(delta)
	_update_detection()
	_refresh_mark()
	move_and_slide()
	_check_catch()

func _refresh_mark() -> void:
	var m := ""
	match state:
		State.SUSPICIOUS, State.SEARCH:
			m = "?"
		State.CHASE:
			m = "!"
	if m != _last_mark:
		_last_mark = m
		rpc("_set_mark", m)

@rpc("any_peer", "call_local")
func _set_mark(t: String) -> void:
	state_mark.text = t

func _pick_waypoint() -> void:
	var loop: Array = level.PATROL_LOOP
	target = loop[patrol_index % loop.size()]
	patrol_index += 1
	waypoint_timer = 0.0
	_request_path(target)

func _request_path(dest: Vector2) -> void:
	path = []
	path_index = 0
	if level == null or not level.has_method("find_path"):
		return
	path = level.find_path(global_position, dest)
	if path.size() > 0 and global_position.distance_to(path[0]) < 20.0:
		path_index = 1

func _steer_to(dest: Vector2, speed: float) -> void:
	if path_index < path.size():
		var wp: Vector2 = path[path_index]
		if global_position.distance_to(wp) < 16.0:
			path_index += 1
			if path_index >= path.size():
				_move_toward(dest, speed)
				return
			wp = path[path_index]
		_move_toward(wp, speed)
		return
	_move_toward(dest, speed)

func _in_other_room(p: Vector2) -> bool:
	for room in level.ALL_ROOMS:
		if room.has_point(p) and not room.has_point(global_position):
			return true
	return false

func _update_patrol(_delta: float) -> void:
	waypoint_timer += _delta
	if global_position.distance_to(target) < 24.0 or waypoint_timer > 8.0:
		if rng.randf() < 0.25:
			target = level.boss_room_center()
			_request_path(target)
		else:
			_pick_waypoint()
	_steer_to(target, SPEED_PATROL * speed_mult)

func _update_suspicious(delta: float) -> void:
	velocity = Vector2.ZERO
	if state_timer > 1.5:
		state = State.SEARCH
		search_center = target
		state_timer = 0.0
		_request_path(search_center)

func _update_chase(delta: float) -> void:
	chase_timer += delta
	repath_timer -= delta
	var p := _nearest_visible_player()
	if p == null:
		state = State.SEARCH
		search_center = target
		state_timer = 0.0
		_request_path(search_center)
		return
	target = p.global_position
	if repath_timer <= 0.0:
		repath_timer = 0.4
		_request_path(target)
	_steer_to(target, SPEED_CHASE * speed_mult)
	if chase_timer > CHASE_TIRED:
		state = State.SEARCH
		search_center = target
		state_timer = 0.0
		chase_timer = 0.0
		_request_path(search_center)

func _update_search(delta: float) -> void:
	if global_position.distance_to(search_center) > 30.0:
		_steer_to(search_center, SPEED_SEARCH * speed_mult)
	else:
		velocity = Vector2.ZERO
		var orbit := Vector2(cos(state_timer * 1.2), sin(state_timer * 1.2)) * 60.0
		_move_toward(search_center + orbit, SPEED_SEARCH * speed_mult * 0.5)
	if state_timer > 5.0:
		state = State.RETURN
		state_timer = 0.0
		_request_path(level.boss_room_center())

func _update_return(_delta: float) -> void:
	if state_timer > 8.0:
		global_position = level.boss_room_center()
		velocity = Vector2.ZERO
		state = State.PATROL
		state_timer = 0.0
		_pick_waypoint()
		return
	_steer_to(level.boss_room_center(), SPEED_RETURN * speed_mult)
	if global_position.distance_to(level.boss_room_center()) < 40.0:
		state = State.PATROL
		state_timer = 0.0
		_pick_waypoint()

func _move_toward(dest: Vector2, speed: float) -> void:
	var dir := dest - global_position
	if dir.length() < 4.0:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
		return
	dir = dir.normalized()
	var want := dir * speed
	velocity = velocity.lerp(want, clampf(6.0 * get_physics_process_delta_time(), 0.0, 1.0))
	facing = dir

func _update_detection() -> void:
	if blind_timer > 0.0:
		return
	var p := _nearest_visible_player()
	if p != null:
		if state != State.CHASE:
			state = State.CHASE
			chase_timer = 0.0
			state_timer = 0.0
			repath_timer = 0.0
			level.rpc("on_boss_chase")
		target = p.global_position
		return
	var noise: Vector2 = level.consume_noise()
	if noise != Vector2.ZERO:
		if state == State.PATROL or state == State.RETURN:
			state = State.SUSPICIOUS
			target = noise
			state_timer = 0.0

func _nearest_visible_player() -> Node2D:
	var best: Node2D = null
	var best_d := VISION_RANGE
	for child in level.ysort.get_children():
		if not (child is CharacterBody2D):
			continue
		if not child.has_method("set_locked"):
			continue
		if child.get("locked"):
			continue
		var d := global_position.distance_to(child.global_position)
		if d > VISION_RANGE:
			continue
		if d < 60.0:
			if d < best_d:
				best = child
				best_d = d
			continue
		if child.get("hiding"):
			continue
		var to_p: Vector2 = (child.global_position - global_position).normalized()
		if facing.dot(to_p) < cos(VISION_ANGLE):
			continue
		if not child.get("flashlight_on") and not level.is_lit(child.global_position):
			continue
		if not _has_line_of_sight(child):
			continue
		if d < best_d:
			best = child
			best_d = d
	return best

func _has_line_of_sight(p: Node2D) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, p.global_position, 1, [self])
	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		return true
	return hit.get("collider") == p

func _check_catch() -> void:
	if blind_timer > 0.0:
		return
	for child in level.ysort.get_children():
		if not (child is CharacterBody2D):
			continue
		if not child.has_method("set_locked"):
			continue
		if child.get("locked"):
			continue
		if global_position.distance_to(child.global_position) < CATCH_DIST:
			level.on_player_caught(child)
			state = State.RETURN
			state_timer = 0.0
			return

func _start_telegraph() -> void:
	telegraph_timer = 1.0
	level.rpc("on_boss_telegraph")

func _do_teleport() -> void:
	var dest: Vector2 = level.teleport_destination()
	global_position = dest
	blind_timer = BLIND_TIME
	teleport_timer = rng.randf_range(TELEPORT_MIN, TELEPORT_MAX) * teleport_mult
	state = State.PATROL
	state_timer = 0.0
	_pick_waypoint()
	level.rpc("on_boss_teleported", dest)
