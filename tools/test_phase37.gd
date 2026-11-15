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

func _report() -> void:
	var fails := 0
	for r in results:
		print(r)
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("PHASE37 FAILS=" + str(fails))
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
	boss = lvl.get("boss")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	# PACE-01: teleport pertama 25-35 detik (dulu 15-20): pemain sempat
	# selesaikan tugas pertama sebelum bos bisa muncul di atas dia.
	if absf(float(boss.get("FIRST_TELEPORT_MIN")) - 25.0) < 0.01 and absf(float(boss.get("FIRST_TELEPORT_MAX")) - 35.0) < 0.01:
		_ok("first teleport 25-35s (was 15-20s)")
	else:
		_fail("first teleport is " + str(boss.get("FIRST_TELEPORT_MIN")) + "-" + str(boss.get("FIRST_TELEPORT_MAX")))
	# CELL-01: habis kabur dari sel, bos buta 5 detik + patroli menjauh 10 detik.
	player.global_position = Vector2(400, 400)
	player.set("locked", false)
	boss.call("send_back_to_room")
	if absf(float(boss.get("blind_timer")) - 5.0) < 0.01:
		_ok("post-rescue blind 5s (was 3s)")
	else:
		_fail("post-rescue blind is " + str(boss.get("blind_timer")))
	if absf(float(boss.get("post_rescue_timer")) - 10.0) < 0.01:
		_ok("post-rescue cooldown 10s")
	else:
		_fail("post-rescue timer is " + str(boss.get("post_rescue_timer")))
	# Waypoint yang dipilih saat cooldown = terjauh dari pemain.
	var loop: Array = lvl.get("PATROL_LOOP")
	var farthest := Vector2.INF
	var far_d := -1.0
	for wp in loop:
		if boss.global_position.distance_to(wp) < 50.0:
			continue
		var d := player.global_position.distance_to(wp)
		if d > far_d:
			far_d = d
			farthest = wp
	boss.call("_pick_waypoint")
	if boss.get("target") == farthest:
		_ok("post-rescue patrol picks farthest waypoint " + str(farthest))
	else:
		_fail("post-rescue patrol picked " + str(boss.get("target")) + ", expected farthest " + str(farthest))
	# Normal (cooldown habis): kembali ke waypoint terdekat dari pemain.
	boss.set("post_rescue_timer", 0.0)
	var nearest := Vector2.INF
	var near_d := 1e9
	for wp in loop:
		if boss.global_position.distance_to(wp) < 50.0:
			continue
		var d := player.global_position.distance_to(wp)
		if d < near_d:
			near_d = d
			nearest = wp
	boss.call("_pick_waypoint")
	if boss.get("target") == nearest:
		_ok("normal patrol picks nearest waypoint " + str(nearest))
	else:
		_fail("normal patrol picked " + str(boss.get("target")) + ", expected nearest " + str(nearest))
	_report()
