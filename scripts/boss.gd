extends CharacterBody2D

const SPEED_PATROL := 130.0
const SPEED_CHASE := 240.0
const SPEED_SEARCH := 160.0
const SPEED_RETURN := 100.0
const VISION_RANGE := 340.0
const VISION_ANGLE := 1.9
const CATCH_DIST := 40.0
const TELEPORT_MIN := 14.0
const TELEPORT_MAX := 20.0
const FIRST_TELEPORT_MIN := 25.0
const FIRST_TELEPORT_MAX := 35.0
const BLIND_TIME := 1.5
const CHASE_TIRED := 8.0
const CHASE_WINDUP := 1.0
const HEARING_WALK := 200.0
const HEARING_SPRINT := 360.0

enum State { PATROL, SUSPICIOUS, CHASE, SEARCH, RETURN }

var state: State = State.PATROL
var facing := Vector2.DOWN
var target: Vector2 = Vector2.ZERO
var state_timer := 0.0
var chase_timer := 0.0
var chase_windup_timer := 0.0
var chase_lost_timer := 0.0
var post_rescue_timer := 0.0
var teleport_timer := 0.0
var blind_timer := 0.0
var telegraph_timer := 0.0
var search_center := Vector2.ZERO
var waypoint_timer := 0.0
var patrol_index := 2
var speed_mult := 1.0
var slow_mult := 1.0
var teleport_mult := 1.0
var path: PackedVector2Array = []
var path_index := 0
var repath_timer := 0.0
var search_repath_timer := 0.0
var stuck_timer := 0.0
var stuck_last_pos := Vector2.ZERO
var search_desk_checked := false
var search_desk_target := Vector2.ZERO
var search_desk_pause := 0.0
var bob_phase := 0.0
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
	teleport_timer = rng.randf_range(FIRST_TELEPORT_MIN, FIRST_TELEPORT_MAX)
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
		var w := clampf(8.0 * _delta, 0.0, 1.0)
		boss_light.rotation = lerp_angle(boss_light.rotation, facing.angle(), w)
		boss_light.position = boss_light.position.lerp(facing * 12.0, w)

func _circle_points(center: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a := TAU * float(i) / 8.0
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if level != null and bool(level.get("paused")):
		velocity = Vector2.ZERO
		return
	if blind_timer > 0.0:
		blind_timer -= delta
	if post_rescue_timer > 0.0:
		post_rescue_timer -= delta
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
	_update_stuck(delta)
	_update_bob(delta)

func _update_bob(delta: float) -> void:
	if boss_sprite == null:
		return
	if velocity.length() > 10.0:
		bob_phase += velocity.length() * delta * 0.06
		boss_sprite.position.y = -22.0 + sin(bob_phase) * 2.0
		boss_sprite.rotation = clampf(velocity.x * 0.00015, -0.04, 0.04)
	else:
		boss_sprite.position.y = -22.0
		boss_sprite.rotation = 0.0

func _update_stuck(delta: float) -> void:
	# Selama wind-up kejaran bos memang diam - jangan anggap itu nyangkut.
	if chase_windup_timer > 0.0:
		return
	# A* waypoints are cell centres, but the boss capsule can clip a prop
	# corner between two waypoints and wedge. If it barely moves while it
	# has a path, jump it to the next path point instead of grinding the wall.
	if path.is_empty() or path_index >= path.size():
		# No route at all: the boss may be standing where A* cannot start
		# (solid cell). After 1s still, snap to the nearest walkable cell
		# centre so pathfinding can resume.
		if global_position.distance_to(stuck_last_pos) > 5.0:
			stuck_timer = 0.0
			stuck_last_pos = global_position
			return
		stuck_timer += delta
		if stuck_timer >= 1.0:
			stuck_timer = 0.0
			var cell := Vector2i(int(global_position.x / 32.0), int(global_position.y / 32.0))
			var w: Vector2i = level.call("_nearest_walkable", cell)
			global_position = Vector2(w.x * 32 + 16, w.y * 32 + 16)
			stuck_last_pos = global_position
			velocity = Vector2.ZERO
			path = []
			path_index = 0
		return
	if global_position.distance_to(stuck_last_pos) > 5.0:
		stuck_timer = 0.0
		stuck_last_pos = global_position
		return
	stuck_timer += delta
	if stuck_timer >= 1.0:
		stuck_timer = 0.0
		global_position = path[path_index]
		stuck_last_pos = global_position
		velocity = Vector2.ZERO
		# Fresh route to the real target, so the boss does not grind the
		# same bad path again right after the jump.
		_request_path(target)

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

func _nearest_player_pos() -> Vector2:
	var best := Vector2.INF
	var best_d := 1e9
	for child in level.ysort.get_children():
		if not (child is CharacterBody2D):
			continue
		if not child.has_method("set_locked"):
			continue
		if child.get("locked"):
			continue
		var d := global_position.distance_to(child.global_position)
		if d < best_d:
			best_d = d
			best = child.global_position
	return best

func _pick_waypoint() -> void:
	var loop: Array = level.PATROL_LOOP
	# Patrol near the player, not across the map: pick the waypoint
	# nearest to the nearest player, skipping the one the boss is
	# already standing on. This keeps the boss in the player's area so
	# encounters actually happen, instead of the boss wandering far away
	# while the player does tasks undisturbed.
	var anchor := _nearest_player_pos()
	if anchor == Vector2.INF and post_rescue_timer > 0.0:
		anchor = level.CELL_POS
	if anchor != Vector2.INF:
		# Habis pemain kabur dari sel, bos patroli MENJAUH dulu 10 detik
		# (bukan mendekat): pemain yang baru kabur butuh ruang bernapas.
		var want_far := post_rescue_timer > 0.0
		var best: Vector2 = Vector2.INF
		var best_d := -1.0 if want_far else 1e9
		for wp in loop:
			if global_position.distance_to(wp) < 50.0:
				continue
			var d := anchor.distance_to(wp)
			if want_far:
				if d > best_d:
					best_d = d
					best = wp
			elif d < best_d:
				best_d = d
				best = wp
		if best != Vector2.INF:
			target = best
			waypoint_timer = 0.0
			_request_path(target)
			if not path.is_empty():
				return
	# Fallback: sequential loop.
	for _i in range(loop.size()):
		target = loop[patrol_index % loop.size()]
		patrol_index += 1
		waypoint_timer = 0.0
		_request_path(target)
		if not path.is_empty():
			return
	target = level.boss_room_center()
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
	if path.is_empty():
		# No route: wait for the next repath instead of pushing straight
		# into a wall toward an unreachable point.
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
		return
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
	if path.is_empty():
		_request_path(target)
		if path.is_empty():
			_pick_waypoint()
	# Long cross-map legs take ~10-22s at patrol speed, so the timeout must
	# be generous or the boss skips the far waypoints forever.
	if global_position.distance_to(target) < 24.0 or waypoint_timer > 30.0:
		if rng.randf() < 0.25:
			target = level.boss_room_center()
			_request_path(target)
		else:
			_pick_waypoint()
	_steer_to(target, SPEED_PATROL * speed_mult)
	for child in level.ysort.get_children():
		if not (child is CharacterBody2D):
			continue
		if not child.has_method("set_locked"):
			continue
		if child.get("locked"):
			continue
		if not bool(child.get("hiding")):
			continue
		if global_position.distance_to(child.global_position) < 100.0:
			state = State.SUSPICIOUS
			target = child.global_position
			state_timer = 0.0
			return

func _update_suspicious(delta: float) -> void:
	velocity = Vector2.ZERO
	if state_timer > 1.5:
		_enter_search(target)

func _update_chase(delta: float) -> void:
	chase_timer += delta
	repath_timer -= delta
	var p := _nearest_visible_player()
	if p == null:
		chase_lost_timer += delta
		if chase_lost_timer > 0.5:
			level.rpc("on_boss_lost")
			_enter_search(target)
			chase_lost_timer = 0.0
			return
	else:
		chase_lost_timer = 0.0
		target = p.global_position
	if chase_windup_timer > 0.0:
		chase_windup_timer -= delta
		velocity = Vector2.ZERO
		return
	if repath_timer <= 0.0:
		repath_timer = 0.4
		_request_path(target)
	_steer_to(target, SPEED_CHASE * speed_mult)
	if chase_timer > CHASE_TIRED:
		level.rpc("on_boss_lost")
		_enter_search(target)
		chase_timer = 0.0

func _enter_search(center: Vector2) -> void:
	state = State.SEARCH
	search_center = center
	state_timer = 0.0
	search_desk_checked = false
	search_desk_target = Vector2.ZERO
	search_desk_pause = 0.0
	_request_path(search_center)

func _nearest_desk_in_range(center: Vector2, max_dist: float) -> Vector2:
	var best := Vector2.INF
	var best_d := max_dist
	for d in level.desk_positions:
		var dist := center.distance_to(d)
		if dist < best_d:
			best_d = dist
			best = d
	return best

func _update_search(delta: float) -> void:
	if search_desk_pause > 0.0:
		search_desk_pause -= delta
		velocity = Vector2.ZERO
		return
	# Walking to a desk: keep going there, do not get pulled back to the
	# search center while en route.
	if search_desk_target != Vector2.ZERO:
		if global_position.distance_to(search_desk_target) > 45.0:
			_steer_to(search_desk_target, SPEED_SEARCH * speed_mult)
			return
		search_desk_target = Vector2.ZERO
		search_desk_pause = 1.5
		velocity = Vector2.ZERO
		return
	if global_position.distance_to(search_center) > 30.0:
		_steer_to(search_center, SPEED_SEARCH * speed_mult)
	else:
		if not search_desk_checked:
			var desk := _nearest_desk_in_range(search_center, 300.0)
			search_desk_checked = true
			if desk != Vector2.INF:
				search_desk_target = desk
				_request_path(desk)
				return
		var orbit := Vector2(cos(state_timer * 1.2), sin(state_timer * 1.2)) * 60.0
		var orbit_target := search_center + orbit
		search_repath_timer -= delta
		if search_repath_timer <= 0.0 or global_position.distance_to(orbit_target) < 20.0:
			search_repath_timer = 1.0
			_request_path(orbit_target)
		_steer_to(orbit_target, SPEED_SEARCH * speed_mult * 0.5)
	if state_timer > 5.0 and search_desk_target == Vector2.ZERO:
		state = State.RETURN
		state_timer = 0.0
		_request_path(level.boss_room_center())
	elif state_timer > 10.0:
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
	# Stay in the room while the post-teleport blind lasts (3s), so the boss
	# does not patrol straight past the cell right after a self-rescue.
	if state_timer > 3.0 and global_position.distance_to(level.boss_room_center()) < 40.0:
		state = State.PATROL
		state_timer = 0.0
		_pick_waypoint()

func _move_toward(dest: Vector2, speed: float) -> void:
	var dir := dest - global_position
	if dir.length() < 4.0:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * get_physics_process_delta_time())
		return
	dir = dir.normalized()
	var want := dir * speed * slow_mult
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
			chase_lost_timer = 0.0
			chase_windup_timer = CHASE_WINDUP
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
		return
	# Hearing: a moving player makes noise. Walking is quiet, sprinting is
	# loud. Sound goes through walls (like the noise queue), but the range
	# is short, so the boss must be close to hear it. The FSM treats a
	# heard player exactly like a heard noise: SUSPICIOUS, then SEARCH.
	var heard := _nearest_audible_player()
	if heard != null:
		if state == State.PATROL or state == State.RETURN:
			state = State.SUSPICIOUS
			target = heard.global_position
			state_timer = 0.0
		elif state == State.SEARCH:
			search_center = heard.global_position
			target = heard.global_position
			search_desk_checked = false
			search_desk_target = Vector2.ZERO
			_request_path(search_center)

func _nearest_audible_player() -> Node2D:
	var best: Node2D = null
	var best_d := 1e9
	for child in level.ysort.get_children():
		if not (child is CharacterBody2D):
			continue
		if not child.has_method("set_locked"):
			continue
		if child.get("locked"):
			continue
		if child.get("hiding"):
			continue
		if child.velocity.length() < 50.0:
			continue
		var hear_range := HEARING_SPRINT if bool(child.get("sprinting")) else HEARING_WALK
		var d := global_position.distance_to(child.global_position)
		if d > hear_range:
			continue
		if d < best_d:
			best = child
			best_d = d
	return best

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
		var prox := 60.0 if bool(child.get("hiding")) else 120.0
		if d < prox:
			if d < best_d:
				best = child
				best_d = d
			continue
		if child.get("hiding"):
			continue
		var to_p: Vector2 = (child.global_position - global_position).normalized()
		if facing.dot(to_p) < cos(VISION_ANGLE):
			continue
		if not child.get("flashlight_on") and not level.is_lit(child.global_position) and d >= 240.0:
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

func _has_line_of_sight_to(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, pos, 1, [self])
	var hit: Dictionary = space.intersect_ray(query)
	return hit.is_empty()

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
			post_rescue_timer = 20.0
			state = State.PATROL
			state_timer = 0.0
			_pick_waypoint()
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

func send_back_to_room() -> void:
	global_position = level.boss_room_center()
	blind_timer = 5.0
	post_rescue_timer = 10.0
	teleport_timer = rng.randf_range(TELEPORT_MIN, TELEPORT_MAX) * teleport_mult
	state = State.RETURN
	state_timer = 0.0
	path = []
	path_index = 0
