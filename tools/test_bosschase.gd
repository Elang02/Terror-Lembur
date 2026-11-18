extends SceneTree

var lvl: Node2D
var boss: Node2D
var me: Node
var passes := 0
var fails := 0

func ok(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		passes += 1
		print("TEST OK: " + name)
	else:
		fails += 1
		print("TEST FAIL: " + name + " " + detail)

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _pin_boss() -> void:
	boss.set("teleport_timer", 99999.0)
	boss.set("blind_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)

func _spawn_player() -> void:
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	me = pscene.instantiate()
	me.name = "1"
	lvl.get("ysort").add_child(me)

func _wait_state(want: int, frames: int) -> bool:
	for i in frames:
		await process_frame
		if int(boss.get("state")) == want:
			return true
	return false

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	lvl.call("_dismiss_intro")
	boss = lvl.get("boss")
	if boss == null:
		print("TEST FAIL: boss node missing")
		quit()
		return
	_spawn_player()
	await process_frame
	await process_frame
	# Case 1: player 250px away, flashlight ON, clear LOS down the
	# bottom corridor (y=656). Boss must chase.
	boss.global_position = Vector2(400, 656)
	boss.set("facing", Vector2(1, 0))
	boss.set("path", PackedVector2Array([Vector2(800, 656)]))
	_pin_boss()
	me.global_position = Vector2(650, 656)
	me.set("flashlight_on", true)
	me.set("velocity", Vector2(0, 0))
	var chased := await _wait_state(2, 60)
	ok("boss chases a visible player 250px away (flashlight on)", chased, "state=" + str(int(boss.get("state"))))
	# Case 2: same spot, flashlight OFF, in the dark (far from any lit
	# task point). Elang's complaint: the boss must still chase when it
	# can see the player, it must not be blind just because the light
	# is off. This is the dark-zone rule that made it look blind.
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("blind_timer", 0.0)
	me.global_position = Vector2(650, 656)
	me.set("flashlight_on", false)
	me.set("velocity", Vector2(0, 0))
	chased = await _wait_state(2, 60)
	ok("boss chases a visible player 250px away (flashlight off, dark)", chased, "state=" + str(int(boss.get("state"))))
	# Case 3: full loop. Boss chases, then the player gets far away
	# and breaks line of sight. Boss must leave CHASE, go SEARCH, then
	# RETURN, then back to PATROL. This is the behaviour Elang asked
	# for: chase on sight, back to the path only when the player is far.
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("blind_timer", 0.0)
	me.global_position = Vector2(650, 656)
	me.set("flashlight_on", true)
	me.set("velocity", Vector2(0, 0))
	chased = await _wait_state(2, 60)
	ok("boss chases before the far-away leg", chased, "state=" + str(int(boss.get("state"))))
	# Player teleports far away, behind a wall (boss room), so LOS is
	# broken and the player is out of vision range.
	me.global_position = Vector2(1008, 144)
	me.set("velocity", Vector2(0, 0))
	var left_chase := false
	for i in 120:
		await process_frame
		if int(boss.get("state")) != 2:
			left_chase = true
			break
	ok("boss leaves CHASE when the player is far and out of sight", left_chase, "state=" + str(int(boss.get("state"))))
	var back_patrol := false
	for i in 600:
		await process_frame
		if int(boss.get("state")) == 0:
			back_patrol = true
			break
	ok("boss returns to PATROL after losing the player", back_patrol, "state=" + str(int(boss.get("state"))))
	# Case 4: hiding player at 200px must NOT be chased (stealth still
	# works), but a hiding player at 50px must be noticed (proximity).
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("blind_timer", 0.0)
	boss.set("teleport_timer", 99999.0)
	boss.global_position = Vector2(400, 656)
	boss.set("path", PackedVector2Array([Vector2(800, 656)]))
	# Case 3 ends with the boss teleporting onto the player at the boss
	# room centre and catching them, which locks the player. A locked
	# player is invisible to the boss, so unlock here.
	me.set("locked", false)
	me.global_position = Vector2(600, 656)
	me.set("hiding", true)
	me.set("flashlight_on", false)
	me.set("velocity", Vector2(0, 0))
	var stayed := true
	for i in 60:
		me.set("hiding", true)
		# Re-pin the boss every frame: slow_mult 0 makes it look stuck,
		# and the stuck recovery would otherwise jump it along its path.
		boss.global_position = Vector2(400, 656)
		boss.set("stuck_timer", 0.0)
		await process_frame
		if int(boss.get("state")) == 2:
			stayed = false
			break
	ok("boss does not chase a hiding player 200px away", stayed, "state=" + str(int(boss.get("state"))))
	me.global_position = Vector2(450, 656)
	var noticed := false
	for i in 60:
		me.set("hiding", true)
		boss.global_position = Vector2(400, 656)
		boss.set("stuck_timer", 0.0)
		await process_frame
		if int(boss.get("state")) == 1 or int(boss.get("state")) == 2:
			noticed = true
			break
	ok("boss notices a hiding player 50px away (proximity)", noticed, "state=" + str(int(boss.get("state"))))
	print("=== BOSSCHASE TEST: " + str(passes) + " passed, " + str(fails) + " failed ===")
	quit()
