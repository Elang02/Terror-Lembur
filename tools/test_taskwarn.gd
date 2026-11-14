extends SceneTree

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
	var warn_label: Label = lvl.get("hud_warn_label")
	# 1. Boss close to the task (200px): opening the popup warns the player
	player.global_position = Vector2(400, 400)
	player.set("interacting", true)
	player.set("interact_target", 1)
	boss.global_position = Vector2(600, 400)
	boss.set("state", 0)
	lvl.call("try_open_task_popup", 1)
	for i in range(3):
		await process_frame
	if warn_label.text == "BOS MENDENGAR SUARAMU! Dia menuju ke tugasmu!":
		_ok("warning shows when boss is close enough to hear the task (200px)")
	else:
		_fail("no warning with boss at 200px (got '" + warn_label.text + "')")
	# Close the popup so the next case can open one
	var popup = lvl.get("popup")
	if popup != null:
		popup.call("close_popup", false)
	for i in range(3):
		await process_frame
	warn_label.text = ""
	# 2. Boss far from the task (800px): no warning, boss will not come
	player.global_position = Vector2(400, 400)
	player.set("interacting", true)
	player.set("interact_target", 1)
	boss.global_position = Vector2(1200, 400)
	boss.set("state", 0)
	lvl.call("try_open_task_popup", 1)
	for i in range(3):
		await process_frame
	if warn_label.text == "":
		_ok("no warning when boss is too far to hear the task (800px)")
	else:
		_fail("warning shown with boss at 800px (got '" + warn_label.text + "')")
	print("=== TASKWARN TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== TASKWARN TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
