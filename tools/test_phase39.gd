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

func _report() -> void:
	var fails := 0
	for r in results:
		print(r)
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("PHASE39 FAILS=" + str(fails))
	quit()

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	lvl.call("_dismiss_intro")
	var intro_dim: Node = lvl.get("intro_dim")
	if intro_dim != null:
		intro_dim.visible = false
	var intro_panel: Node = lvl.get("intro_panel")
	if intro_panel != null:
		intro_panel.visible = false
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	# TELE-02: bos tidak boleh teleport ke ruangan yang sama dengan pemain
	# yang lagi ngumpet (konsep 6). Pemain ngumpet di Gudang (128,176).
	player.global_position = Vector2(128, 176)
	player.set("locked", false)
	player.set("hiding", true)
	player.set("velocity", Vector2.ZERO)
	var gudang: Rect2 = lvl.get("GUDANG_ROOM")
	if not gudang.has_point(Vector2(128, 176)):
		_fail("test setup: (128,176) is not inside GUDANG_ROOM")
		_report()
		return
	var landed_in_room := 0
	var too_close := 0
	for i in range(20):
		var dest: Vector2 = lvl.call("teleport_destination")
		if gudang.has_point(dest):
			landed_in_room += 1
		if dest.distance_to(player.global_position) < 120.0:
			too_close += 1
	if landed_in_room == 0:
		_ok("teleport never lands in a hiding player's room (0/20 in Gudang)")
	else:
		_fail("teleport landed in the hiding player's room " + str(landed_in_room) + "/20 times")
	if too_close == 0:
		_ok("teleport still respects the 120px rule (0/20 too close)")
	else:
		_fail("teleport landed too close " + str(too_close) + "/20 times")
	_report()
