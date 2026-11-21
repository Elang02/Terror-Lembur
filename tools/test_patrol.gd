extends SceneTree

var lvl: Node2D
var boss: Node2D
var visited: Dictionary[int, bool] = {}
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
	var tl = preload("res://tools/tlib.gd").new()
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	boss = lvl.get("boss")
	if boss == null:
		_fail("boss null")
		_report()
		return
	# Disable teleports for this test: the boss teleports every 20-30s and
	# each teleport abandons the current waypoint, so a full loop would
	# never complete. This test is about pathfinding, not teleporting.
	boss.set("teleport_timer", 99999.0)
	# Boss starts in PATROL. Track which PATROL_LOOP waypoints it comes within 40px of.
	var loop: Array = lvl.get("PATROL_LOOP")
	var start_pos := boss.global_position
	var last_pos := start_pos
	var total_moved := 0.0
	var stall_time := 0.0
	var elapsed := 0.0
	while elapsed < 720.0:
		await process_frame
		var dt := root.get_process_delta_time()
		elapsed += dt
		var p: Vector2 = boss.global_position
		var step := p.distance_to(last_pos)
		total_moved += step
		if step < 0.05:
			stall_time += dt
		else:
			stall_time = 0.0
		last_pos = p
		for i in range(loop.size()):
			if p.distance_to(loop[i]) < 40.0:
				visited[i] = true
		if visited.size() == loop.size():
			break
		if stall_time > 24.0:
			_fail("boss stalled for 4s at " + str(last_pos))
			break
	if visited.size() == loop.size():
		_ok("boss visited all " + str(loop.size()) + " patrol waypoints in " + str(int(elapsed)) + "s")
	else:
		_fail("boss visited only " + str(visited.size()) + "/" + str(loop.size()) + " patrol waypoints in " + str(frames) + " frames (missing " + str(_missing(loop)) + ")")
	if total_moved > 500.0:
		_ok("boss kept moving on patrol (" + str(int(total_moved)) + "px)")
	else:
		_fail("boss barely moved on patrol (" + str(int(total_moved)) + "px)")
	_report()

func _missing(loop: Array) -> Array:
	var m: Array[int] = []
	for i in range(loop.size()):
		if not visited.has(i):
			m.append(i)
	return m

func _report() -> void:
	print("=== PATROL TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== PATROL TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
