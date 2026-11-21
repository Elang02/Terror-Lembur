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

func _report() -> void:
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== STAMINA TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)

func _run() -> void:
	var tl = preload("res://tools/tlib.gd").new()
	await tl.wait(self, 0.5)
	if lvl == null:
		_fail("level null")
		_report()
		return
	lvl.set_solo_mode(true)
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
	player.global_position = Vector2(400, 656)
	# 1. Constants: drain 50/s (bar penuh cuma ~2 detik sprint), regen 8/s (isi pelan)
	if absf(float(player.get("STAMINA_DRAIN")) - 50.0) < 0.01:
		_ok("stamina drain 50/s")
	else:
		_fail("stamina drain is " + str(player.get("STAMINA_DRAIN")))
	if absf(float(player.get("STAMINA_REGEN")) - 8.0) < 0.01:
		_ok("stamina regen 8/s")
	else:
		_fail("stamina regen is " + str(player.get("STAMINA_REGEN")))
	# 2. Sprint 20 frame (~2 detik game time) dari bar penuh -> bar hampir habis
	player.set("stamina", 100.0)
	Input.action_press("sprint")
	Input.action_press("right")
	await tl.wait(self, 2)
	var after_sprint: float = float(player.get("stamina"))
	Input.action_release("sprint")
	Input.action_release("right")
	if after_sprint < 30.0:
		_ok("sprint 2 detik habisin bar (stamina " + str(snappedf(after_sprint, 0.1)) + ")")
	else:
		_fail("sprint 2 detik stamina masih " + str(snappedf(after_sprint, 0.1)) + " (harus < 30)")
	# 3. Diam 20 frame (~2 detik) -> refill cuma dikit (8/s x 2 detik = ~16)
	await tl.wait(self, 2)
	var after_regen: float = float(player.get("stamina"))
	if after_regen > after_sprint and after_regen < 45.0:
		_ok("refill pelan, 2 detik cuma nambah ke " + str(snappedf(after_regen, 0.1)))
	else:
		_fail("refill aneh: " + str(snappedf(after_sprint, 0.1)) + " -> " + str(snappedf(after_regen, 0.1)))
	_report()
