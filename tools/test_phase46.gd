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
	print("PHASE46 FAILS=" + str(fails))
	quit(0 if fails == 0 else 1)

func _run() -> void:
	var tl = preload("res://tools/tlib.gd").new()
	DirAccess.remove_absolute("user://tutorial.cfg")
	await tl.wait(self, 0.5)
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
	await tl.wait(self, 0.5)
	var boss: Node = lvl.get("boss")
	# SAFE-01a: teleport tidak pernah mendarat di Toilet.
	pl.global_position = Vector2(300, 384)
	for i in range(3):
		await process_frame
	var toilet := Rect2(32, 288, 192, 192)
	var landed_in_toilet := 0
	for i in range(20):
		var dest: Vector2 = lvl.call("teleport_destination")
		if toilet.has_point(dest):
			landed_in_toilet += 1
	if landed_in_toilet == 0:
		_ok("teleport never lands in the toilet")
	else:
		_fail("teleport landed in toilet " + str(landed_in_toilet) + "x / 20")
	# SAFE-01b: sel Toilet padat di AStar bos (bos tidak bisa masuk).
	var astar: AStarGrid2D = lvl.get("astar")
	if astar != null and astar.is_point_solid(Vector2i(3, 11)) and not astar.is_point_solid(Vector2i(10, 20)):
		_ok("toilet cells solid in boss AStar, corridor open")
	else:
		_fail("toilet AStar marking wrong")
	# SAFE-01c: di dalam Toilet, detak jantung mati dan musik tenang.
	pl.global_position = Vector2(128, 384)
	boss.global_position = Vector2(300, 384)
	boss.set("state", 2)
	lvl.set("heartbeat_timer", 5.0)
	lvl.set("music_tense_level", 0.0)
	await tl.wait(self, 0.5)
	if absf(float(lvl.get("heartbeat_timer")) - 5.0) < 0.01:
		_ok("heartbeat silent inside the toilet")
	else:
		_fail("heartbeat kept going inside the toilet")
	if float(lvl.get("music_tense_level")) < 0.05:
		_ok("music forced calm inside the toilet")
	else:
		_fail("music tense inside the toilet: " + str(lvl.get("music_tense_level")))
	# Kontrol: di luar Toilet, detak + musik tegang jalan.
	pl.global_position = Vector2(400, 400)
	boss.global_position = Vector2(500, 400)
	boss.set("state", 2)
	lvl.set("heartbeat_timer", 5.0)
	await tl.wait(self, 0.5)
	if float(lvl.get("heartbeat_timer")) < 5.0:
		_ok("heartbeat runs outside the toilet")
	else:
		_fail("heartbeat silent outside the toilet")
	if float(lvl.get("music_tense_level")) > 0.1:
		_ok("music tense outside the toilet")
	else:
		_fail("music calm outside the toilet")
	# FIRST-01a: encounter pertama muncul di 12 detik, bos lambat + buta.
	lvl.set("first_encounter_done", false)
	lvl.set("first_encounter_active", false)
	lvl.set("elapsed", 12.5)
	await tl.wait(self, 0.5)
	if bool(lvl.get("first_encounter_active")):
		_ok("first encounter triggers at 12s")
	else:
		_fail("first encounter did not trigger")
	if boss.global_position.distance_to(Vector2(400, 656)) < 100.0:
		_ok("boss walks in at the bottom corridor")
	else:
		_fail("boss not at encounter spot: " + str(boss.global_position))
	if absf(float(boss.get("slow_mult")) - 0.5) < 0.01 and float(boss.get("blind_timer")) > 5.0:
		_ok("boss slow + blind during the encounter")
	else:
		_fail("boss not slow/blind (slow " + str(boss.get("slow_mult")) + ", blind " + str(boss.get("blind_timer")) + ")")
	# FIRST-01b: ngumpet saat bos lewat mengakhiri encounter.
	lvl.set("tutorial_step", 3)
	pl.global_position = Vector2(400, 656)
	boss.global_position = Vector2(550, 656)
	pl.set("hiding", true)
	await tl.wait(self, 0.5)
	if bool(lvl.get("first_encounter_done")) and not bool(lvl.get("first_encounter_active")):
		_ok("encounter ends when the boss passes a hiding player")
	else:
		_fail("encounter did not end on hide")
	if absf(float(boss.get("slow_mult")) - 1.0) < 0.01:
		_ok("boss back to full speed after the encounter")
	else:
		_fail("boss still slow after the encounter")
	if int(lvl.get("tutorial_step")) == 4:
		_ok("tutorial hide step completes on the encounter")
	else:
		_fail("tutorial step stuck at " + str(lvl.get("tutorial_step")))
	pl.set("hiding", false)
	# FIRST-01c: tidak ada encounter kalau 40 detik sudah lewat.
	lvl.set("first_encounter_done", false)
	lvl.set("first_encounter_active", false)
	lvl.set("elapsed", 41.0)
	await tl.wait(self, 0.5)
	if bool(lvl.get("first_encounter_done")) and not bool(lvl.get("first_encounter_active")):
		_ok("encounter abandoned after 40s")
	else:
		_fail("encounter still pending after 40s")
	_report()
