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
	var loop: Array = lvl.get("PATROL_LOOP")
	# 1. Player near waypoint (272,448) [index 7]: boss should pick it
	# Boss starts far away at (1328,272) so the nearest-to-player waypoint
	# is clearly (272,448), not the nearest-to-boss one.
	boss.global_position = Vector2(1328, 272)
	boss.set("teleport_timer", 99999.0)
	player.global_position = Vector2(272, 448)
	player.set("locked", false)
	boss.call("_pick_waypoint")
	var target: Vector2 = boss.get("target")
	if target == Vector2(272, 448):
		_ok("boss picks the waypoint nearest to the player (272,448)")
	else:
		_fail("boss picked " + str(target) + " instead of (272,448) nearest to player")
	# 2. Player moves near waypoint (1328,624) [index 4]: boss should pick it
	player.global_position = Vector2(1328, 624)
	boss.call("_pick_waypoint")
	target = boss.get("target")
	if target == Vector2(1328, 624):
		_ok("boss re-targets to the waypoint nearest to the player's new spot (1328,624)")
	else:
		_fail("boss picked " + str(target) + " instead of (1328,624) nearest to player")
	# 3. Boss stays near the player over time: run patrol for a while and
	# check the boss remains within 500px of the player on average.
	player.global_position = Vector2(400, 400)
	boss.global_position = Vector2(400, 656)
	boss.set("state", 0)
	boss.set("teleport_timer", 99999.0)
	# Pin blind so the boss cannot spot/catch the stationary player mid-test:
	# phase 3 measures pure patrol bias, not the catch mechanic (a stationary
	# player in the open SHOULD get caught, which moves them to the cell and
	# breaks the distance measurement). Same pin as test_bossdesk.
	boss.set("blind_timer", 999.0)
	var close_frames := 0
	var total_frames := 0
	for i in range(600):
		await process_frame
		total_frames += 1
		if boss.global_position.distance_to(player.global_position) < 500.0:
			close_frames += 1
	if close_frames > total_frames / 2:
		_ok("boss stays within 500px of the player most of the time (" + str(close_frames) + "/" + str(total_frames) + " frames)")
	else:
		_fail("boss wanders away from the player (" + str(close_frames) + "/" + str(total_frames) + " frames within 500px)")
	print("=== PATROLBIAS TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== PATROLBIAS TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
