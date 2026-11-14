extends SceneTree

var lvl: Node2D
var player: Node2D
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
	if lvl.get("solo_mode") == true:
		_ok("solo_mode set true")
	else:
		_fail("solo_mode not true")
	if absf(float(lvl.get("boss_speed_mult")) - 0.9) < 0.01:
		_ok("boss_speed_mult 0.9 in solo")
	else:
		_fail("boss_speed_mult is " + str(lvl.get("boss_speed_mult")))
	var ysort: Node = lvl.get_node_or_null("YSort")
	if ysort == null:
		_fail("YSort null")
		_report()
		return
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	await process_frame
	await process_frame
	player.global_position = Vector2(736, 400)
	Input.action_press("interact")
	var gen: Node = null
	for tp in lvl.get("tasks"):
		if tp.get("task_id") == 0:
			gen = tp
	player.set("interacting", true)
	player.set("interact_target", 0)
	lvl.call("try_open_task_popup", 0)
	await process_frame
	await process_frame
	await process_frame
	var pop: Node = lvl.get("popup")
	if pop != null and bool(pop.get("open")) and int(lvl.get("popup_task_id")) == 0:
		_ok("Generator popup opens with 1 worker in solo")
	else:
		_fail("Generator popup did not open in solo (open=" + str(pop.get("open")) + ")")
	if pop != null and str(pop.get("kind")) == "simon":
		_ok("Generator popup kind is simon (Panel Listrik)")
	else:
		_fail("Generator popup kind is " + str(pop.get("kind")))
	if pop != null and bool(pop.get("open")):
		pop.call("close_popup", false)
		await process_frame
		await process_frame
	if pop != null and not bool(pop.get("open")):
		_ok("popup closes on cancel")
	else:
		_fail("popup still open after cancel")
	Input.action_release("interact")
	player.set("interacting", false)
	player.set("interact_target", -1)
	lvl.call("on_player_caught", player)
	await process_frame
	await process_frame
	if player.get("locked") == true:
		_ok("player locked after catch")
	else:
		_fail("player not locked after catch")
	Input.action_press("interact")
	var rescue_before := float(lvl.get("self_rescue_progress"))
	for i in range(30):
		await process_frame
	var rescue_after := float(lvl.get("self_rescue_progress"))
	if rescue_after > rescue_before + 0.01:
		_ok("self-rescue progress advances (" + str(rescue_before) + " -> " + str(rescue_after) + ")")
	else:
		_fail("self-rescue progress stuck at " + str(rescue_after))
	lvl.set("self_rescue_progress", 0.99)
	for i in range(10):
		await process_frame
	Input.action_release("interact")
	if player.get("locked") == false:
		_ok("player unlocked after self-rescue completes")
	else:
		_fail("player still locked after self-rescue should complete")
	var boss: Node2D = lvl.get("boss")
	if boss == null:
		_fail("boss null after self-rescue")
	else:
		var cell_pos: Vector2 = lvl.get("CELL_POS")
		var boss_cell_dist := boss.global_position.distance_to(cell_pos)
		if boss_cell_dist > 40.0:
			_ok("boss pushed away from cell on self-rescue (dist " + str(boss_cell_dist) + ", catch range 30)")
		else:
			_fail("boss still on top of cell after self-rescue (dist " + str(boss_cell_dist) + ")")
		if int(boss.get("state")) == 4 or int(boss.get("state")) == 0:
			_ok("boss back to patrol/return after self-rescue (state " + str(boss.get("state")) + ")")
		else:
			_fail("boss state is " + str(boss.get("state")) + " expected RETURN (4) or PATROL (0)")
		if float(boss.get("blind_timer")) > 0.0:
			_ok("boss blind after self-rescue (" + str(boss.get("blind_timer")) + "s)")
		else:
			_fail("boss blind_timer 0 after self-rescue")
	var catches_before := int(lvl.get("solo_catches"))
	lvl.call("on_player_caught", player)
	lvl.call("on_player_caught", player)
	await process_frame
	await process_frame
	var catches_after := int(lvl.get("solo_catches"))
	if catches_after == catches_before + 2:
		_ok("solo_catches increments (" + str(catches_before) + " -> " + str(catches_after) + ")")
	else:
		_fail("solo_catches is " + str(catches_after) + " expected " + str(catches_before + 2))
	if lvl.get("game_over") == true:
		_ok("game over after 3 solo catches")
	else:
		_fail("no game over after 3 solo catches")
	_report()

func _report() -> void:
	print("=== SOLO TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== SOLO TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
