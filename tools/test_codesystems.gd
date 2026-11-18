extends SceneTree

var lvl: Node2D
var results: Array[String] = []

func _init() -> void:
	DirAccess.remove_absolute("user://tutorial.cfg")
	DirAccess.remove_absolute("user://settings.cfg")
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
	for i in range(5):
		await process_frame
	if lvl == null:
		_fail("level null")
		_report()
		return
	var tasks: Array = lvl.get("tasks")
	if tasks.size() == 7:
		_ok("7 tasks built")
	else:
		_fail("task count wrong: " + str(tasks.size()))
	var typed_ok := true
	var defs_ok := true
	var want := {0: "GENERATOR", 1: "KOMPUTER", 2: "ARSIP", 3: "PINTU KELUAR", 4: "TUAS SEL", 5: "GUDANG", 6: "RAPAT"}
	for tp in tasks:
		if not (tp is TaskPoint):
			typed_ok = false
		if int(tp.get("task_id")) < 0 or int(tp.get("task_id")) > 6:
			defs_ok = false
		elif str(tp.get("label_text")) != want[int(tp.get("task_id"))]:
			defs_ok = false
	if typed_ok:
		_ok("tasks are TaskPoint instances")
	else:
		_fail("a task is not a TaskPoint")
	if defs_ok:
		_ok("task ids/labels match TASK_DEFS")
	else:
		_fail("task ids/labels mismatch TASK_DEFS")
	var pickups: Array = lvl.get("pickups")
	var pk_ok := pickups.size() == 6
	for pk in pickups:
		if not (pk is PickupItem):
			pk_ok = false
	if pk_ok:
		_ok("6 pickups are PickupItem instances")
	else:
		_fail("pickups wrong count/type: " + str(pickups.size()))
	var wall: TileMapLayer = lvl.get("wall_layer_ref")
	if wall != null and not wall.get_used_cells().is_empty():
		_ok("baked wall layer trusted (cells present)")
	else:
		_fail("wall_layer_ref missing or empty")
	lvl.call("_finish_tutorial")
	var cfg := ConfigFile.new()
	if cfg.load("user://tutorial.cfg") == OK and bool(cfg.get_value("tutorial", "done", false)) and int(cfg.get_value("meta", "version", 0)) == 1:
		_ok("tutorial.cfg saved with done + version")
	else:
		_fail("tutorial.cfg missing done/version")
	if bool(lvl.call("_tutorial_is_done")):
		_ok("tutorial done cached after finish")
	else:
		_fail("tutorial cache false after finish")
	DirAccess.remove_absolute("user://tutorial.cfg")
	if not bool(lvl.call("_tutorial_is_done")):
		_ok("tutorial done re-reads false after config deleted")
	else:
		_fail("tutorial cache stale after config deleted")
	lvl.call("_toggle_mute")
	if cfg.load("user://settings.cfg") == OK and bool(cfg.get_value("audio", "muted", false)) and int(cfg.get_value("meta", "version", 0)) == 1:
		_ok("settings.cfg saved muted + version")
	else:
		_fail("settings.cfg missing muted/version")
	lvl.call("_toggle_mute")
	if not bool(lvl.get("muted")):
		_ok("mute toggles back off")
	else:
		_fail("mute did not toggle back off")
	lvl.call("report_noise", Vector2(1008, 200), 500.0)
	var got: Vector2 = lvl.call("consume_noise")
	if got == Vector2(1008, 200):
		_ok("noise queue round-trips typed dict")
	else:
		_fail("noise queue round-trip wrong: " + str(got))
	lvl.call("spawn_throwable", Vector2(400, 400), Vector2.RIGHT)
	await process_frame
	await process_frame
	var ysort: Node = lvl.get_node_or_null("YSort")
	var th: Node = null
	for child in ysort.get_children():
		if child is Throwable:
			th = child
			break
	if th != null and th.get("level") == lvl:
		_ok("throwable gets level injected by spawner")
	else:
		_fail("throwable level not injected")
	DirAccess.remove_absolute("user://tutorial.cfg")
	DirAccess.remove_absolute("user://settings.cfg")
	_report()

func _report() -> void:
	print("=== CODESYSTEMS TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== CODESYSTEMS TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
