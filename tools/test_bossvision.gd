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
	# Case 1: player walks past BEHIND the boss, 100px away.
	# The boss faces +X (east) while patrolling the bottom corridor.
	# The player is 100px west of it (behind). The boss must still
	# notice (proximity radius 120px) and chase.
	boss.global_position = Vector2(400, 656)
	boss.set("facing", Vector2(1, 0))
	boss.set("path", PackedVector2Array([Vector2(800, 656)]))
	_pin_boss()
	me.global_position = Vector2(300, 656)
	me.set("flashlight_on", true)
	me.set("velocity", Vector2(-50, 0))
	var chased := false
	for i in 60:
		await process_frame
		if int(boss.get("state")) == 2:
			chased = true
			break
	ok("boss chases a player walking past 100px behind it", chased, "state=" + str(int(boss.get("state"))))
	# Case 2: player in front of the boss, inside the vision cone,
	# 250px away, flashlight on. The boss must chase.
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("blind_timer", 0.0)
	me.global_position = Vector2(650, 656)
	me.set("velocity", Vector2(0, 0))
	chased = false
	for i in 60:
		await process_frame
		if int(boss.get("state")) == 2:
			chased = true
			break
	ok("boss chases a player 250px in front of it in the cone", chased, "state=" + str(int(boss.get("state"))))
	# Case 3: player sprinting 300px away in the open. Hearing
	# (sprint 360px) must make the boss at least suspicious.
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.set("slow_mult", 0.0)
	boss.set("blind_timer", 0.0)
	boss.set("path", PackedVector2Array())
	me.global_position = Vector2(700, 656)
	me.set("sprinting", true)
	me.set("velocity", Vector2(300, 0))
	var noticed := false
	for i in 60:
		await process_frame
		var st := int(boss.get("state"))
		if st == 1 or st == 2:
			noticed = true
			break
	ok("boss notices a sprinting player 300px away (hearing)", noticed, "state=" + str(int(boss.get("state"))))
	print("=== BOSSVISION TEST: " + str(passes) + " passed, " + str(fails) + " failed ===")
	quit()
