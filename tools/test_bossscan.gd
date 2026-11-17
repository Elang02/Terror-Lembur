extends SceneTree

# QA: boss look-around scan at patrol waypoints.
# The boss must pause at a waypoint and sweep its facing (vision + flashlight)
# across an arc instead of staring where it walks, then resume patrol.
var results: Array = []
var lvl: Node2D
var boss: Node2D
var player: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _ok(msg: String) -> void:
	results.append("TEST OK: " + msg)

func _fail(msg: String) -> void:
	results.append("TEST FAIL: " + msg)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	boss = lvl.get("boss")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	# Keep the player far away and the boss blind so nothing interrupts the scan.
	player.global_position = Vector2(1328, 624)
	player.set("locked", false)
	boss.set("blind_timer", 999.0)
	boss.set("teleport_timer", 99999.0)
	boss.set("state", 0)
	# Put the boss exactly on its current patrol target so it arrives at once.
	var tgt: Vector2 = boss.get("target")
	boss.global_position = tgt
	boss.set("velocity", Vector2.ZERO)
	# 1. Scan starts on arrival.
	var scan_started := false
	for i in range(120):
		await process_frame
		if float(boss.get("scan_timer")) > 0.0:
			scan_started = true
			break
	if scan_started:
		_ok("scan starts when boss reaches a waypoint")
	else:
		_fail("scan never started after arrival (scan_timer=0)")
	# 2. Boss stays put while scanning, and its facing sweeps.
	var start_pos: Vector2 = boss.global_position
	var start_angle: float = (boss.get("facing") as Vector2).angle()
	var max_sweep := 0.0
	var moved := 0.0
	for i in range(120):
		await process_frame
		var f: Vector2 = boss.get("facing")
		var d: float = absf(wrapf(f.angle() - start_angle, -PI, PI))
		if d > max_sweep:
			max_sweep = d
		var m: float = boss.global_position.distance_to(start_pos)
		if m > moved:
			moved = m
		if float(boss.get("scan_timer")) <= 0.0:
			break
	if moved < 10.0:
		_ok("boss stays put during scan (moved %.0fpx)" % moved)
	else:
		_fail("boss walked away during scan (moved %.0fpx)" % moved)
	if max_sweep > 1.0:
		_ok("facing sweeps during scan (max %.2f rad)" % max_sweep)
	else:
		_fail("facing barely moves during scan (max %.2f rad)" % max_sweep)
	# 3. Scan ends and the boss resumes patrol toward a new waypoint.
	var resumed := false
	for i in range(120):
		await process_frame
		if float(boss.get("scan_timer")) <= 0.0 and boss.global_position.distance_to(start_pos) > 30.0:
			resumed = true
			break
	if resumed:
		_ok("boss resumes patrol after scan")
	else:
		_fail("boss did not resume patrol after scan")
	# 4. While walking, the boss's head sways: facing deviates from its
	# movement direction instead of staring straight ahead.
	var max_dev := 0.0
	for i in range(180):
		await process_frame
		if float(boss.get("scan_timer")) > 0.0:
			continue
		var vel: Vector2 = boss.get("velocity")
		if vel.length() < 50.0:
			continue
		var f: Vector2 = boss.get("facing")
		var dev: float = absf(wrapf(f.angle() - vel.normalized().angle(), -PI, PI))
		if dev > max_dev:
			max_dev = dev
	if max_dev > 0.2:
		_ok("head sways while walking (max deviation %.2f rad)" % max_dev)
	else:
		_fail("head does not sway while walking (max deviation %.2f rad)" % max_dev)
	print("=== BOSS_SCAN TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== BOSS_SCAN TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
