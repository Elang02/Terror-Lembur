extends CharacterBody2D

const SPEED := 200.0
const ACCEL := 1400.0
const FRICTION := 1600.0
const SPRINT_MULT := 1.5
const STAMINA_DRAIN := 50.0
const STAMINA_REGEN := 8.0
const SHOUT_COOLDOWN := 5.0
const SHOUT_RADIUS := 500.0

var facing := Vector2.DOWN
var aim_dir := Vector2.DOWN
const LIGHT_SMOOTH := 14.0
const LIGHT_FADE := 6.0
const LIGHT_ENERGY := 2.5
var bot_mode := false
var bot_time := 0.0
var demo_mode := false
var demo_waypoints: Array[Vector2] = []
var demo_wp_index := 0
var demo_path: PackedVector2Array = []
var demo_path_index := 0
var demo_repath_timer := 0.0
var demo_task_id := -1
var demo_wait_timer := 0.0
var demo_stuck_timer := 0.0
var demo_last_pos := Vector2.ZERO
var demo_fleeing := false
var locked := false
var hiding := false
var interacting := false
var interact_target := -1
var flashlight_on := true
var has_throwable := false
var shout_timer := 0.0
var hide_spot := Vector2.ZERO
var stamina := 100.0
var sprinting := false
var step_timer := 0.0
var name_label: Label

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var light: PointLight2D = $Flashlight

const CONE_TEX := preload("res://assets/flashlight_cone.png")

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	bot_mode = "--bot" in OS.get_cmdline_user_args()
	demo_mode = "--demo" in OS.get_cmdline_user_args()
	if demo_mode:
		demo_waypoints = [Vector2(400, 400), Vector2(190, 560), Vector2(736, 400), Vector2(128, 176), Vector2(700, 128), Vector2(800, 760)]
		demo_task_id = 1
		demo_wp_index = 0
		demo_repath_timer = 0.0
	camera.enabled = is_multiplayer_authority()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	light.texture = CONE_TEX
	light.texture_scale = 2.5
	light.energy = 2.5
	light.enabled = flashlight_on
	var is_ara := name.to_int() == 1
	var char_name := "ARA" if is_ara else "BIMA"
	var name_color := Color(1.0, 0.85, 0.4) if is_ara else Color(0.6, 0.85, 1.0)
	if not is_ara:
		sprite.modulate = Color(0.65, 0.85, 1.0)
	else:
		sprite.modulate = Color(1.0, 0.92, 0.7)
	name_label = Label.new()
	name_label.text = char_name
	name_label.position = Vector2(-24, -56)
	name_label.size = Vector2(48, 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", name_color)
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	name_label.add_theme_constant_override("outline_size", 5)
	add_child(name_label)
	if name.to_int() == 1:
		position = Vector2(740, 760)
	else:
		position = Vector2(860, 760)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if shout_timer > 0.0:
		shout_timer -= delta
	var lvl0 := get_parent().get_parent()
	if lvl0 != null and bool(lvl0.get("popup_open")):
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move_and_slide()
		return
	if lvl0 != null and bool(lvl0.get("intro_open")):
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move_and_slide()
		return
	var input_dir := Vector2.ZERO
	if demo_mode:
		input_dir = _demo_update(delta)
	elif bot_mode:
		bot_time += delta
		var phase := int(bot_time / 2.0) % 4
		match phase:
			0:
				input_dir = Vector2.RIGHT
			1:
				input_dir = Vector2.DOWN
			2:
				input_dir = Vector2.LEFT
			3:
				input_dir = Vector2.UP
	else:
		input_dir = Input.get_vector("left", "right", "up", "down")
	if locked or hiding or interacting:
		input_dir = Vector2.ZERO
	sprinting = not bot_mode and Input.is_action_pressed("sprint") and input_dir.length() > 0.1 and stamina > 0.0
	var speed := SPEED * SPRINT_MULT if sprinting else SPEED
	if sprinting:
		stamina = maxf(0.0, stamina - STAMINA_DRAIN * delta)
	else:
		stamina = minf(100.0, stamina + STAMINA_REGEN * delta)
	if input_dir.length() > 0.1:
		velocity = velocity.move_toward(input_dir.normalized() * speed, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	_update_actions(input_dir)

func _demo_update(delta: float) -> Vector2:
	if locked:
		interacting = true
		interact_target = 99
		demo_stuck_timer = 0.0
		demo_last_pos = global_position
		return Vector2.ZERO
	var lvl := get_parent().get_parent()
	if lvl == null or demo_wp_index >= demo_waypoints.size():
		return Vector2.ZERO
	if demo_fleeing:
		return _demo_flee(delta, lvl)
	var bd := -1.0
	if lvl.has_method("_boss_distance"):
		bd = float(lvl.call("_boss_distance"))
	var bstate := -1
	var bossn: Node = lvl.get("boss")
	if bossn != null:
		bstate = int(bossn.get("state"))
	if (bstate == 2 and bd >= 0.0 and bd < 250.0) or (bd >= 0.0 and bd < 100.0):
		demo_fleeing = true
		demo_path = []
		demo_repath_timer = 0.0
		return _demo_flee(delta, lvl)
	var target: Vector2 = demo_waypoints[demo_wp_index]
	var dist := global_position.distance_to(target)
	if dist < 70.0:
		demo_stuck_timer = 0.0
		demo_last_pos = global_position
		var task_done := false
		if demo_task_id >= 0 and lvl.has_method("get"):
			for tp in lvl.get("tasks"):
				if tp.get("task_id") == demo_task_id and tp.get("done"):
					task_done = true
		if task_done:
			if demo_wp_index == 5:
				if bool(lvl.get("exit_open")):
					lvl.try_open_task_popup(3)
				return Vector2.ZERO
			demo_wp_index += 1
			if demo_wp_index == 1:
				demo_task_id = 2
			elif demo_wp_index == 2:
				demo_task_id = 0
			elif demo_wp_index == 3:
				demo_task_id = 5
			elif demo_wp_index == 4:
				demo_task_id = 6
			elif demo_wp_index == 5:
				demo_task_id = 3
			demo_path = []
			demo_path_index = 0
			return Vector2.ZERO
		interacting = true
		interact_target = demo_task_id
		if lvl.has_method("try_open_task_popup"):
			lvl.try_open_task_popup(demo_task_id)
		return Vector2.ZERO
	if global_position.distance_to(demo_last_pos) > 5.0:
		demo_stuck_timer = 0.0
		demo_last_pos = global_position
	else:
		demo_stuck_timer += delta
		if demo_stuck_timer > 2.0:
			demo_stuck_timer = 0.0
			demo_last_pos = global_position
			if demo_path_index < demo_path.size():
				global_position = demo_path[demo_path_index]
				demo_path_index += 1
				print("DEMO unstuck: jumped to path point " + str(demo_path_index))
			else:
				global_position = global_position.move_toward(target, 60.0)
				print("DEMO unstuck: nudged toward target")
	interacting = false
	interact_target = -1
	return _demo_move_to(delta, lvl, target)

func _demo_flee(delta: float, lvl: Node) -> Vector2:
	demo_stuck_timer = 0.0
	demo_last_pos = global_position
	interacting = false
	interact_target = -1
	var bd := -1.0
	if lvl.has_method("_boss_distance"):
		bd = float(lvl.call("_boss_distance"))
	if hiding:
		if bd < 0.0 or bd > 350.0:
			_unhide()
			demo_fleeing = false
			demo_path = []
			demo_repath_timer = 0.0
		return Vector2.ZERO
	var desk: Vector2 = lvl.nearest_desk(global_position) if lvl.has_method("nearest_desk") else Vector2.INF
	if desk == Vector2.INF:
		demo_fleeing = false
		return Vector2.ZERO
	if global_position.distance_to(desk) < 50.0:
		_toggle_hide()
		return Vector2.ZERO
	return _demo_move_to(delta, lvl, desk)

func _demo_move_to(delta: float, lvl: Node, target: Vector2) -> Vector2:
	demo_repath_timer -= delta
	if demo_path.is_empty() or demo_repath_timer <= 0.0:
		demo_repath_timer = 1.0
		if lvl.has_method("find_path"):
			demo_path = lvl.find_path(global_position, target)
			demo_path_index = 0
			if demo_path.size() > 0 and global_position.distance_to(demo_path[0]) < 20.0:
				demo_path_index = 1
	if demo_path_index < demo_path.size():
		var wp: Vector2 = demo_path[demo_path_index]
		if global_position.distance_to(wp) < 16.0:
			demo_path_index += 1
			if demo_path_index >= demo_path.size():
				return (target - global_position).normalized()
			wp = demo_path[demo_path_index]
		return (wp - global_position).normalized()
	return (target - global_position).normalized()

func _update_actions(input_dir: Vector2) -> void:
	if bot_mode:
		return
	if Input.is_action_just_pressed("flashlight"):
		flashlight_on = not flashlight_on
	if Input.is_action_just_pressed("shout") and shout_timer <= 0.0:
		shout_timer = SHOUT_COOLDOWN
		var lvl := get_parent().get_parent()
		if lvl != null:
			if lvl.has_method("play_sfx"):
				lvl.play_sfx("shout", -6.0)
			lvl.rpc_id(1, "report_noise", global_position, SHOUT_RADIUS)
	if Input.is_action_just_pressed("hide"):
		_toggle_hide()
	if Input.is_action_just_pressed("throw_item") and has_throwable:
		_throw()
	if input_dir.length() > 0.1 and hiding:
		_unhide()
	_update_interact()
	if Input.is_action_just_pressed("interact") and interacting and interact_target >= 0 and interact_target < 90:
		var lvl := get_parent().get_parent()
		if lvl != null and lvl.has_method("try_open_task_popup"):
			lvl.try_open_task_popup(interact_target)

func _update_interact() -> void:
	if demo_mode:
		return
	var lvl := get_parent().get_parent()
	if lvl == null or not lvl.has_method("nearest_interactable"):
		interacting = false
		interact_target = -1
		return
	if locked:
		if lvl.get("solo_mode") == true and Input.is_action_pressed("interact"):
			interacting = true
			interact_target = 99
			return
		interacting = false
		interact_target = -1
		return
	var id: int = lvl.nearest_interactable(global_position)
	if id < 0:
		interacting = false
		interact_target = -1
		return
	interacting = true
	interact_target = id

func _toggle_hide() -> void:
	if hiding:
		_unhide()
		return
	var lvl := get_parent().get_parent()
	if lvl == null or not lvl.has_method("nearest_desk"):
		return
	var spot: Vector2 = lvl.nearest_desk(global_position)
	if spot == Vector2.INF:
		return
	hiding = true
	hide_spot = spot
	# No collision while hiding: physics would push the player out of the
	# desk and leave them standing next to it instead of under it.
	collision_layer = 0
	collision_mask = 0
	global_position = spot + Vector2(0, -6)
	sprite.scale = Vector2(1.0, 0.6)
	sprite.modulate.a = 0.35
	if name_label != null:
		name_label.modulate.a = 0.0
	light.enabled = false
	if lvl.has_method("play_sfx"):
		lvl.play_sfx("hide", -6.0)

func _unhide() -> void:
	hiding = false
	collision_layer = 1
	collision_mask = 1
	sprite.scale = Vector2.ONE
	sprite.modulate.a = 1.0
	if name_label != null:
		name_label.modulate.a = 1.0
	light.enabled = flashlight_on
	var lvl := get_parent().get_parent()
	if lvl != null and lvl.has_method("play_sfx"):
		lvl.play_sfx("hide", -8.0, 1.3)

func _throw() -> void:
	has_throwable = false
	var lvl := get_parent().get_parent()
	if lvl != null:
		lvl.rpc_id(1, "spawn_throwable", global_position, facing)

func _process(_delta: float) -> void:
	if velocity.length() > 10.0:
		if absf(velocity.x) > absf(velocity.y):
			facing = Vector2.RIGHT if velocity.x > 0.0 else Vector2.LEFT
		else:
			facing = Vector2.DOWN if velocity.y > 0.0 else Vector2.UP
		aim_dir = velocity.normalized()
		sprite.play("walk_" + _dir_name(facing))
		if is_multiplayer_authority() and not bot_mode:
			step_timer -= _delta
			if step_timer <= 0.0:
				step_timer = 0.24 if sprinting else 0.34
				var lvl2 := get_parent().get_parent()
				if lvl2 != null and lvl2.has_method("play_sfx"):
					lvl2.play_sfx("step", -16.0, randf_range(0.92, 1.08))
	else:
		sprite.play("idle_" + _dir_name(facing))
	var w := clampf(LIGHT_SMOOTH * _delta, 0.0, 1.0)
	light.rotation = lerp_angle(light.rotation, aim_dir.angle(), w)
	light.position = light.position.lerp(aim_dir * 12.0, w)
	var want_energy := 0.0 if hiding else (LIGHT_ENERGY if flashlight_on else 0.0)
	light.energy = move_toward(light.energy, want_energy, LIGHT_FADE * _delta)
	light.enabled = light.energy > 0.05

func _dir_name(dir: Vector2) -> String:
	if dir == Vector2.RIGHT:
		return "right"
	if dir == Vector2.LEFT:
		return "left"
	if dir == Vector2.UP:
		return "up"
	return "down"

@rpc("any_peer", "call_local")
func set_locked(value: bool) -> void:
	locked = value
	if value:
		velocity = Vector2.ZERO
		interacting = false
		hiding = false
		sprite.modulate.a = 1.0
		if name_label != null:
			name_label.modulate.a = 1.0

@rpc("any_peer", "call_local")
func give_throwable() -> void:
	has_throwable = true
	var lvl := get_parent().get_parent()
	if lvl != null and lvl.has_method("play_sfx"):
		lvl.play_sfx("pickup", -6.0)
