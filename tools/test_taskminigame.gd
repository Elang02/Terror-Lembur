extends SceneTree

var lvl: Node2D
var player: Node2D
var results: Array[String] = []

func _init() -> void:
	DirAccess.remove_absolute("user://tutorial.cfg")
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

func _task(id: int) -> Node:
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == id:
			return tp
	return null

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	player.set("bot_mode", true)
	ysort.add_child(player)
	await process_frame
	await process_frame
	player.global_position = Vector2(400, 400)
	await process_frame
	# 1. Task params are distinct per task
	var komp := _task(1)
	var gen := _task(0)
	var arsip := _task(2)
	if komp != null and int(komp.get("hits_needed")) == 3 and absf(float(komp.get("marker_speed")) - 1.0) < 0.01:
		_ok("Komputer: 3 hits, speed 1.0")
	else:
		_fail("Komputer params wrong")
	if gen != null and int(gen.get("hits_needed")) == 4 and absf(float(gen.get("marker_speed")) - 1.5) < 0.01:
		_ok("Generator: 4 hits, speed 1.5")
	else:
		_fail("Generator params wrong")
	if arsip != null and int(arsip.get("hits_needed")) == 2 and absf(float(arsip.get("zone_size")) - 0.2) < 0.01:
		_ok("Arsip: 2 hits, zone 0.2")
	else:
		_fail("Arsip params wrong")
	# 2. Marker advances while a player is at the task
	player.set("interacting", true)
	player.set("interact_target", 1)
	var m0: float = komp.get("marker_pos")
	for i in range(5):
		lvl.call("_update_tasks", 0.1)
	var m1: float = komp.get("marker_pos")
	if absf(m1 - m0) > 0.05:
		_ok("marker advances while interacting (" + str(m0) + " -> " + str(m1) + ")")
	else:
		_fail("marker did not advance")
	if bool(komp.get("active")):
		_ok("task active while player at task")
	else:
		_fail("task not active while player at task")
	# 3. Hit inside the zone registers
	komp.set("marker_pos", float(komp.get("zone_center")))
	lvl.call("try_task_hit", 1)
	if int(komp.get("hits")) == 1 and absf(float(komp.get("progress")) - 1.0 / 3.0) < 0.01:
		_ok("hit inside zone: hits=1, progress=1/3")
	else:
		_fail("hit did not register (hits=" + str(komp.get("hits")) + " progress=" + str(komp.get("progress")) + ")")
	# 4. Miss outside the zone costs half a hit
	var zc: float = komp.get("zone_center")
	var outside: float = 0.0 if zc > 0.5 else 1.0
	komp.set("marker_pos", outside)
	lvl.call("try_task_hit", 1)
	if int(komp.get("hits")) == 1 and float(komp.get("progress")) < 1.0 / 3.0:
		_ok("miss outside zone: progress dropped, hits stay 1")
	else:
		_fail("miss did not cost progress (hits=" + str(komp.get("hits")) + " progress=" + str(komp.get("progress")) + ")")
	# 5. Task completes after hits_needed hits
	for i in range(3):
		komp.set("marker_pos", float(komp.get("zone_center")))
		lvl.call("try_task_hit", 1)
	if bool(komp.get("done")):
		_ok("task completes after 3 hits")
	else:
		_fail("task not done after 3 hits (hits=" + str(komp.get("hits")) + ")")
	# 6. Marker ping-pongs at the edge
	var g2 := _task(2)
	player.set("interact_target", 2)
	player.global_position = Vector2(190, 560)
	g2.set("marker_pos", 0.99)
	g2.set("marker_dir", 1.0)
	lvl.call("_update_tasks", 0.1)
	if float(g2.get("marker_dir")) < 0.0 and float(g2.get("marker_pos")) <= 1.0:
		_ok("marker reverses at the right edge")
	else:
		_fail("marker did not reverse (dir=" + str(g2.get("marker_dir")) + " pos=" + str(g2.get("marker_pos")) + ")")
	# 7. Zone re-randomizes after a hit
	var z_before: float = g2.get("zone_center")
	g2.set("marker_pos", z_before)
	lvl.call("try_task_hit", 2)
	if absf(float(g2.get("zone_center")) - z_before) > 0.001:
		_ok("zone moves after a hit")
	else:
		_fail("zone did not re-randomize")
	_report()

func _report() -> void:
	var passed := 0
	var failed := 0
	for r in results:
		if r.begins_with("OK:"):
			passed += 1
		else:
			failed += 1
	print("=== TASKMINIGAME TEST: " + str(passed) + " passed, " + str(failed) + " failed ===")
	quit(0)
