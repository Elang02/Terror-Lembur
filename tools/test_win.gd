extends SceneTree

var lvl: Node2D
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
	if lvl == null:
		_fail("level null")
		_report()
		return
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var player: Node2D = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	await process_frame
	await process_frame
	var tasks: Array = lvl.get("tasks")
	var tps := {}
	for tp in tasks:
		tps[int(tp.get("task_id"))] = tp
	for tid in [0, 1, 2]:
		var tp = tps[tid]
		tp.set("done", true)
		tp.set("progress", 1.0)
		lvl.call("_on_task_done", tp)
		await process_frame
	if lvl.call("_main_tasks_done") == true:
		_ok("all 3 main tasks done, exit unlocked")
	else:
		_fail("main tasks not all done")
	if lvl.get("boss_speed_mult") >= 1.3:
		_ok("boss enraged after all tasks (speed_mult " + str(lvl.get("boss_speed_mult")) + ")")
	else:
		_fail("boss not enraged, speed_mult " + str(lvl.get("boss_speed_mult")))
	var tp3 = tps[3]
	tp3.set("done", true)
	tp3.set("progress", 1.0)
	lvl.call("_on_task_done", tp3)
	await process_frame
	await process_frame
	await process_frame
	if lvl.get("game_over") == true:
		_ok("game over flag set after exit done")
	else:
		_fail("game_over false after exit done")
	if str(lvl.get("game_result")) == "HAPPY ENDING":
		_ok("solo happy ending (never caught, 3 stars expected)")
	else:
		_fail("game_result is " + str(lvl.get("game_result")))
	if int(lvl.get("stars")) == 3:
		_ok("3 stars for clean solo win")
	else:
		_fail("stars is " + str(lvl.get("stars")) + " expected 3")
	var end_title: Label = lvl.get("end_title")
	if end_title != null and end_title.text == "HAPPY ENDING":
		_ok("end screen shows HAPPY ENDING")
	else:
		_fail("end title missing or wrong")
	_report()

func _report() -> void:
	print("=== WIN TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== WIN TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
