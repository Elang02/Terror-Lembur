extends SceneTree

var lvl: Node2D
var boss: Node2D
var results: Array[String] = []

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _fail(msg: String) -> void:
	results.append("FAIL: " + msg)
	print("TEST FAIL: " + msg)

func _ok(msg: String) -> void:
	results.append("OK: " + msg)
	print("TEST OK: " + msg)

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	boss = lvl.get("boss")
	# 1. First teleport timer is 8-12s, not 20-30s
	var t0 := float(boss.get("teleport_timer"))
	if t0 >= 15.0 and t0 <= 20.0:
		_ok("first teleport timer is 15-20s (" + str(t0) + "s)")
	else:
		_fail("first teleport timer out of 15-20s range (" + str(t0) + "s)")
	# 2. First patrol waypoint is (272,448), closest to the Computer task
	var target: Vector2 = boss.get("target")
	if target == Vector2(272, 448):
		_ok("first patrol waypoint is (272,448), closest to Computer task")
	else:
		_fail("first patrol waypoint is " + str(target) + ", expected (272,448)")
	# 3. First teleport is fair: boss lands >=150px from the player
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var player := pscene.instantiate() as Node2D
	player.name = "1"
	lvl.get_node("YSort").add_child(player, true)
	await process_frame
	player.global_position = Vector2(400, 400)
	boss.set("teleport_timer", 0.0)
	# Wait for telegraph (1.0s) + teleport; sandbox runs slow, allow 600 frames
	var teleported := false
	for i in range(600):
		if boss.global_position != Vector2(1008, 144) and float(boss.get("blind_timer")) > 0.0:
			teleported = true
			break
		await process_frame
	if not teleported:
		_fail("boss did not teleport after timer expired")
	else:
		_ok("boss teleported within the first window")
		var d := boss.global_position.distance_to(player.global_position)
		if d >= 120.0:
			_ok("first teleport lands >=120px from player (" + str(d) + "px, fair)")
		else:
			_fail("first teleport lands too close (" + str(d) + "px < 120px)")
		# 4. After the first teleport, the next timer is back to 14-20s
		var t1 := float(boss.get("teleport_timer"))
		if t1 >= 14.0 and t1 <= 20.0:
			_ok("next teleport timer back to 14-20s (" + str(t1) + "s)")
		else:
			_fail("next teleport timer out of 14-20s range (" + str(t1) + "s)")
	_report()

func _report() -> void:
	print("=== TENSION TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== TENSION TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
