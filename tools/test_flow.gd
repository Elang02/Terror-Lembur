extends SceneTree

var lvl: Node2D
var results: Array[String] = []

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _ok(msg: String) -> void:
	results.append("OK: " + msg)
	print("TEST OK: " + msg)

func _fail(msg: String) -> void:
	results.append("FAIL: " + msg)
	print("TEST FAIL: " + msg)

func _run() -> void:
	for i in range(5):
		await process_frame
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var p1 := pscene.instantiate() as Node2D
	p1.name = "1"
	ysort.add_child(p1, true)
	var p2 := pscene.instantiate() as Node2D
	p2.name = "2"
	ysort.add_child(p2, true)
	await process_frame
	await process_frame
	p1.global_position = Vector2(400, 400)
	p2.global_position = Vector2(1200, 600)
	p1.set("interacting", true)
	p1.set("interact_target", 1)
	var min_dist := 99999.0
	for i in range(20):
		var dest: Vector2 = lvl.call("teleport_destination")
		var d1 := dest.distance_to(p1.global_position)
		var d2 := dest.distance_to(p2.global_position)
		var d := minf(d1, d2)
		if d < min_dist:
			min_dist = d
		if d < 120.0:
			_fail("teleport landed " + str(d) + "px from a player (attempt " + str(i) + ")")
			_report()
			return
	_ok("teleport never lands within 120px of a player (20 tries, min dist " + str(min_dist) + "px)")
	var boss: Node2D = null
	for child in ysort.get_children():
		if child.name == "Boss":
			boss = child
			break
	if boss == null:
		_fail("boss not found")
		_report()
		return
	var speed_before := float(lvl.get("boss_speed_mult"))
	for tp in lvl.get("tasks"):
		if tp.get("task_id") < 3:
			tp.set("done", true)
	lvl.call("_on_task_done", lvl.get("tasks")[0])
	await process_frame
	var speed_after := float(lvl.get("boss_speed_mult"))
	if absf(speed_after - (speed_before + 0.1 + 0.3)) < 0.01:
		_ok("enrage adds +0.3 speed on top of +0.1 task bonus (" + str(speed_before) + " -> " + str(speed_after) + ")")
	else:
		_fail("enrage speed wrong: " + str(speed_before) + " -> " + str(speed_after))
	if absf(float(boss.get("teleport_mult")) - 0.6) < 0.01:
		_ok("enrage sets boss teleport_mult 0.6")
	else:
		_fail("boss teleport_mult is " + str(boss.get("teleport_mult")))
	_report()

func _report() -> void:
	print("=== FLOW TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== FLOW TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
