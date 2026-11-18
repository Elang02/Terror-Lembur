extends SceneTree

var results: Array[String] = []
var lvl: Node2D
var pl: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _ok(msg: String) -> void:
	results.append("TEST OK: " + msg)

func _fail(msg: String) -> void:
	results.append("TEST FAIL: " + msg)

func _report() -> void:
	var fails := 0
	for r in results:
		print(r)
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("PHASE45 FAILS=" + str(fails))
	quit(0 if fails == 0 else 1)

func _press_p() -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_P
	ev.pressed = true
	Input.parse_input_event(ev)

func _release_p() -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_P
	ev.pressed = false
	Input.parse_input_event(ev)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	pl = pscene.instantiate() as Node2D
	pl.name = "1"
	ysort.add_child(pl, true)
	await process_frame
	await process_frame
	lvl.call("_dismiss_intro")
	var intro_dim: Node = lvl.get("intro_dim")
	if intro_dim != null:
		intro_dim.visible = false
	var intro_panel: Node = lvl.get("intro_panel")
	if intro_panel != null:
		intro_panel.visible = false
	for i in range(5):
		await process_frame
	# PAUSE-01: P jeda di solo, bos + timer berhenti, panel JEDA muncul.
	var boss: Node = lvl.get("boss")
	_press_p()
	for i in range(5):
		await process_frame
	if bool(lvl.get("paused")):
		_ok("P pauses the game in solo")
	else:
		_fail("P did not pause")
	var panel: PanelContainer = lvl.get("hud_pause_panel")
	if panel != null and panel.visible:
		_ok("pause panel shows")
	else:
		_fail("pause panel hidden while paused")
	var bpos: Vector2 = boss.global_position
	var t0: float = float(lvl.get("elapsed"))
	for i in range(10):
		await process_frame
	if boss.global_position.distance_to(bpos) < 0.5:
		_ok("boss frozen while paused")
	else:
		_fail("boss moved while paused")
	if absf(float(lvl.get("elapsed")) - t0) < 0.01:
		_ok("timer frozen while paused")
	else:
		_fail("timer ran while paused")
	_release_p()
	_press_p()
	for i in range(5):
		await process_frame
	if not bool(lvl.get("paused")):
		_ok("P resumes the game")
	else:
		_fail("P did not resume")
	_release_p()
	# MUG-01: mug yang diambil muncul lagi setelah 60 detik.
	var pickups: Array = lvl.get("pickups")
	var pk0: Node = pickups[0]
	var pk1: Node = pickups[1]
	pk0.set("taken", true)
	pk0.set_meta("respawn_at", float(lvl.get("elapsed")) + 0.05)
	pk1.set("taken", true)
	pk1.set_meta("respawn_at", float(lvl.get("elapsed")) + 9999.0)
	for i in range(5):
		await process_frame
	if not bool(pk0.get("taken")):
		_ok("mug respawns after its timer")
	else:
		_fail("mug did not respawn")
	if bool(pk1.get("taken")):
		_ok("mug stays taken before its timer")
	else:
		_fail("mug respawned too early")
	_report()
