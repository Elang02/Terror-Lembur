extends SceneTree

var results: Array = []
var lvl: Node2D
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
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	player.global_position = Vector2(740, 760)
	# Intro should NOT auto-show here (show_hud path is via network), so force it
	lvl.call("show_hud")
	for i in range(5):
		await process_frame
	if bool(lvl.get("intro_open")):
		_ok("intro opens on first run (tutorial not done)")
	else:
		_fail("intro did not open (intro_open=false)")
	var intro_panel: Control = lvl.get("intro_panel")
	if intro_panel != null and intro_panel.visible:
		_ok("intro panel visible")
	else:
		_fail("intro panel missing or hidden")
	# Player cannot move while the intro is open (starts from rest, stays put)
	var start_pos := player.global_position
	player.set("demo_mode", false)
	player.set("velocity", Vector2.ZERO)
	for i in range(10):
		await process_frame
	if player.global_position.distance_to(start_pos) < 5.0:
		_ok("player frozen while intro is open")
	else:
		_fail("player moved during intro (dist=" + str(player.global_position.distance_to(start_pos)) + ")")
	# Dismiss the intro
	lvl.call("_dismiss_intro")
	for i in range(5):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_ok("intro dismisses")
	else:
		_fail("intro still open after dismiss")
	if intro_panel != null and not intro_panel.visible:
		_ok("intro panel hidden after dismiss")
	else:
		_fail("intro panel still visible after dismiss")
	# Intro does not reopen once the tutorial is done
	var cfg := ConfigFile.new()
	cfg.set_value("tutorial", "done", true)
	cfg.save("user://tutorial.cfg")
	lvl.call("_show_intro")
	for i in range(3):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_ok("intro does not show when tutorial is done")
	else:
		_fail("intro showed even though tutorial is done")
	# Clean up the config so later runs see the intro
	var dir := DirAccess.open("user://")
	if dir != null:
		dir.remove("tutorial.cfg")
	print("=== INTRO TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== INTRO TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
