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

func _click(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = pos
	ev.pressed = true
	Input.parse_input_event(ev)
	var ev2 := InputEventMouseButton.new()
	ev2.button_index = MOUSE_BUTTON_LEFT
	ev2.position = pos
	ev2.pressed = false
	Input.parse_input_event(ev2)

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
	lvl.call("show_hud")
	for i in range(5):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_fail("intro did not open, cannot test click dismiss")
		_finish()
		return
	_ok("intro opens on first run")
	_click(Vector2(100, 100))
	for i in range(5):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_ok("click on dim area dismisses intro")
	else:
		_fail("click on dim area did NOT dismiss intro (hint says click to start)")
	lvl.call("_show_intro")
	for i in range(5):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_fail("intro did not reopen for panel click test")
		_finish()
		return
	_click(Vector2(640, 360))
	for i in range(5):
		await process_frame
	if not bool(lvl.get("intro_open")):
		_ok("click on intro panel dismisses intro")
	else:
		_fail("click on intro panel did NOT dismiss intro (hint says click to start)")
	_finish()

func _finish() -> void:
	print("=== INTRO CLICK TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== INTRO CLICK TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
