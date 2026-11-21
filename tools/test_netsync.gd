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
	var tl = preload("res://tools/tlib.gd").new()
	await tl.wait(self, 0.5)
	if lvl == null:
		_fail("level null")
		_report()
		return
	_test_code_sync_api()
	await _test_keypad_reads_synced_code()
	await _test_reveal_broadcast()
	await _test_exit_sync()
	await _test_minigame_sync()
	await _test_connection_failed_menu()
	_test_noise_cap()
	_report()

func _test_code_sync_api() -> void:
	if not lvl.has_method("sync_code"):
		_fail("level has no sync_code: client can never learn the server code")
		return
	_ok("level has sync_code")
	if not lvl.has_method("request_code_sync"):
		_fail("level has no request_code_sync")
		return
	_ok("level has request_code_sync")
	var server_digits := [2, 3, 1, 4, 2]
	var server_found := [true, false, false, true, false]
	lvl.call("sync_code", server_digits, server_found)
	if str(lvl.get("code_digits")) == str(server_digits):
		_ok("sync_code overwrites local code with server code")
	else:
		_fail("sync_code did not apply server code: " + str(lvl.get("code_digits")))
	if str(lvl.get("code_found")) == str(server_found):
		_ok("sync_code applies server code_found")
	else:
		_fail("sync_code did not apply code_found: " + str(lvl.get("code_found")))
	if lvl.get("code_synced") == true:
		_ok("sync_code marks code_synced")
	else:
		_fail("code_synced still false after sync_code")

func _test_keypad_reads_synced_code() -> void:
	var tp3: Node = null
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == 3:
			tp3 = tp
	if tp3 == null:
		_fail("exit task point missing")
		return
	var popup: Node = lvl.get("popup")
	if popup == null:
		_fail("popup missing")
		return
	popup.call("open_popup", lvl, 3, tp3, "keypad", "Keypad Pintu", false)
	await process_frame
	if str(popup.get("key_code")) == str(lvl.get("code_digits")):
		_ok("keypad reads the synced server code")
	else:
		_fail("keypad code " + str(popup.get("key_code")) + " != synced code " + str(lvl.get("code_digits")))
	popup.call("close_popup", false)
	await process_frame

func _test_reveal_broadcast() -> void:
	lvl.rpc("_reveal_code_digit", 2)
	await process_frame
	if bool((lvl.get("code_found") as Array)[2]):
		_ok("reveal via rpc marks digit found on this peer")
	else:
		_fail("reveal via rpc did not mark digit found (reveal is server-local only)")
	var label: Label = lvl.get("hud_code_label")
	if label != null and label.text != "" and str(lvl.get("code_digits")[2]) in label.text:
		_ok("reveal shows the digit in the HUD")
	else:
		_fail("reveal did not show digit in HUD")

func _test_exit_sync() -> void:
	if not lvl.has_method("sync_exit_state"):
		_fail("level has no sync_exit_state: client never sees the door open")
		return
	_ok("level has sync_exit_state")
	lvl.call("sync_exit_state", true, false, 0.05)
	await tl.wait(self, 0.3)
	if lvl.get("exit_open") == true:
		_ok("synced exit opening counts down to open on this peer")
	else:
		_fail("exit_open still false after synced opening timer")
	lvl.call("try_open_task_popup", 3)
	await tl.wait(self, 0.2)
	if lvl.get("game_over") == true:
		_ok("client can finish through the synced open door")
	else:
		_fail("game_over false after walking out the synced open door")

func _test_minigame_sync() -> void:
	lvl.set("code_found", [false, false, false, false, false])
	var tp_scene := load("res://scenes/task_point.tscn") as PackedScene
	var probe := tp_scene.instantiate() as Node
	var syncer: Node = probe.get_node_or_null("MultiplayerSynchronizer")
	if syncer == null:
		_fail("task_point has no MultiplayerSynchronizer")
		probe.queue_free()
		return
	var cfg: SceneReplicationConfig = syncer.get("replication_config")
	var has_prog := cfg.has_property(NodePath(".:progress"))
	var has_done := cfg.has_property(NodePath(".:done"))
	var spawn_prog := has_prog and cfg.property_get_spawn(NodePath(".:progress"))
	var spawn_done := has_done and cfg.property_get_spawn(NodePath(".:done"))
	if has_prog and has_done and spawn_prog and spawn_done:
		_ok("task_point synchronizer replicates progress + done (TASK-04)")
	else:
		_fail("task_point synchronizer missing progress/done spawn sync: prog=" + str(has_prog) + "/" + str(spawn_prog) + " done=" + str(has_done) + "/" + str(spawn_done))
	probe.queue_free()
	var tp1: Node = null
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == 1:
			tp1 = tp
	if tp1 == null:
		_fail("task 1 missing")
		return
	lvl.rpc("popup_set_progress", 1, 0.5)
	await process_frame
	if absf(float(tp1.get("progress")) - 0.5) < 0.01:
		_ok("popup_set_progress reaches the server task point")
	else:
		_fail("popup_set_progress did not set progress: " + str(tp1.get("progress")))
	lvl.rpc("popup_task_done", 1)
	await process_frame
	if bool(tp1.get("done")):
		_ok("popup_task_done marks the server task done")
	else:
		_fail("popup_task_done did not mark task done")
	if bool((lvl.get("code_found") as Array)[0]):
		_ok("task done reveals code digit 0")
	else:
		_fail("task done did not reveal code digit 0")
	lvl.rpc("popup_task_cancel", 1)
	await process_frame

func _test_connection_failed_menu() -> void:
	var net: Node = lvl.get_node_or_null("Network")
	if net == null:
		_fail("Network node missing")
		return
	var menu: CanvasLayer = net.get("menu")
	if menu == null:
		_fail("menu missing")
		return
	menu.visible = false
	net.call("_on_connection_failed")
	await process_frame
	if menu.visible:
		_ok("connection failure brings the menu back")
	else:
		_fail("menu stays hidden after connection failure (player stuck)")

func _test_noise_cap() -> void:
	lvl.set("noise_queue", [])
	for i in range(20):
		lvl.rpc("report_noise", Vector2(100, 100), 100.0)
	var n := int((lvl.get("noise_queue") as Array).size())
	if n <= 8:
		_ok("report_noise queue capped (" + str(n) + "/20 kept)")
	else:
		_fail("report_noise queue uncapped: " + str(n) + " queued, floodable")

func _report() -> void:
	print("=== NETSYNC TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== NETSYNC TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
