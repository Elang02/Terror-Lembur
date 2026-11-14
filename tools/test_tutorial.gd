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

func _set_task_done(task_id: int) -> void:
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == task_id:
			tp.set("done", true)
			tp.set("progress", 1.0)

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	lvl.get_node("YSort").add_child(player, true)
	lvl.call("show_hud")
	await process_frame
	await process_frame
	await process_frame
	if int(lvl.get("tutorial_step")) == 1:
		_ok("tutorial starts at step 1 when player spawns")
	else:
		_fail("tutorial did not start (step=" + str(lvl.get("tutorial_step")) + ")")
	var panel: PanelContainer = lvl.get("hud_tutorial_panel")
	if panel != null and panel.visible:
		_ok("tutorial panel visible")
	else:
		_fail("tutorial panel not visible")
	var label: Label = lvl.get("hud_tutorial_label")
	if label != null and label.text.begins_with("1/4"):
		_ok("step 1 text shown")
	else:
		_fail("step 1 text wrong: " + (label.text if label != null else "null"))
	# Step 1 -> 2: move >120px from spawn
	player.global_position = Vector2(player.global_position.x + 150.0, player.global_position.y)
	lvl.call("_update_tutorial")
	if int(lvl.get("tutorial_step")) == 2:
		_ok("step 1 -> 2 on movement")
	else:
		_fail("step 1 did not advance on movement (step=" + str(lvl.get("tutorial_step")) + ")")
	# Step 2 -> 3: Computer task done
	_set_task_done(1)
	lvl.call("_update_tutorial")
	if int(lvl.get("tutorial_step")) == 3:
		_ok("step 2 -> 3 when Computer task done")
	else:
		_fail("step 2 did not advance on task done (step=" + str(lvl.get("tutorial_step")) + ")")
	# Step 3 -> 4: player hides
	player.set("hiding", true)
	lvl.call("_update_tutorial")
	if int(lvl.get("tutorial_step")) == 4:
		_ok("step 3 -> 4 on hide")
	else:
		_fail("step 3 did not advance on hide (step=" + str(lvl.get("tutorial_step")) + ")")
	# Step 4 -> done: all main tasks done
	_set_task_done(0)
	_set_task_done(2)
	lvl.call("_update_tutorial")
	if int(lvl.get("tutorial_step")) == 5:
		_ok("step 4 -> done when all main tasks done")
	else:
		_fail("step 4 did not finish (step=" + str(lvl.get("tutorial_step")) + ")")
	if panel != null and not panel.visible:
		_ok("tutorial panel hidden after finish")
	else:
		_fail("tutorial panel still visible after finish")
	var cfg := ConfigFile.new()
	if cfg.load("user://tutorial.cfg") == OK and bool(cfg.get_value("tutorial", "done", false)):
		_ok("tutorial completion saved to user://tutorial.cfg")
	else:
		_fail("tutorial completion not saved")
	# Skip path: reset, restart tutorial, press T
	DirAccess.remove_absolute("user://tutorial.cfg")
	lvl.set("tutorial_step", 0)
	await process_frame
	await process_frame
	if int(lvl.get("tutorial_step")) == 1:
		_ok("tutorial restarts after config removed")
	else:
		_fail("tutorial did not restart (step=" + str(lvl.get("tutorial_step")) + ")")
	Input.action_press("skip_tutorial")
	lvl.call("_update_tutorial")
	Input.action_release("skip_tutorial")
	if int(lvl.get("tutorial_step")) == 5:
		_ok("T skips the tutorial")
	else:
		_fail("T did not skip (step=" + str(lvl.get("tutorial_step")) + ")")
	_report()

func _report() -> void:
	print("=== TUTORIAL TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== TUTORIAL TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
