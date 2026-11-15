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
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	player.global_position = Vector2(740, 760)
	boss = lvl.get("boss")
	# 1. Constants are aggressive
	if absf(float(boss.get("SPEED_PATROL")) - 130.0) < 0.01:
		_ok("patrol speed 130")
	else:
		_fail("patrol speed is " + str(boss.get("SPEED_PATROL")))
	if absf(float(boss.get("SPEED_CHASE")) - 240.0) < 0.01:
		_ok("chase speed 240")
	else:
		_fail("chase speed is " + str(boss.get("SPEED_CHASE")))
	if absf(float(boss.get("VISION_RANGE")) - 340.0) < 0.01:
		_ok("vision range 340")
	else:
		_fail("vision range is " + str(boss.get("VISION_RANGE")))
	if absf(float(boss.get("TELEPORT_MIN")) - 14.0) < 0.01 and absf(float(boss.get("TELEPORT_MAX")) - 20.0) < 0.01:
		_ok("teleport every 14-20s")
	else:
		_fail("teleport range is " + str(boss.get("TELEPORT_MIN")) + "-" + str(boss.get("TELEPORT_MAX")))
	if absf(float(boss.get("CHASE_TIRED")) - 8.0) < 0.01:
		_ok("chase lasts 8s")
	else:
		_fail("chase tired is " + str(boss.get("CHASE_TIRED")))
	# 2. Boss sees a player in the dark at close range (<150px in cone, no flashlight)
	# Use the open bottom corridor (y=656) so line of sight is clear.
	# Freeze the boss in SUSPICIOUS (it stands still) so its facing does not drift.
	player.set("flashlight_on", false)
	player.set("hiding", false)
	boss.global_position = Vector2(400, 656)
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("facing", Vector2(1, 0))
	player.global_position = Vector2(500, 656)
	var seen: Node2D = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player in the dark at 100px (no flashlight)")
	else:
		_fail("boss did NOT see player in the dark at 100px")
	# 3. Boss does NOT see a player in the dark at long range (>=150px, no flashlight)
	player.global_position = Vector2(650, 656)
	boss.set("facing", Vector2(1, 0))
	seen = boss.call("_nearest_visible_player")
	if seen == null:
		_ok("boss does not see player in the dark at 250px")
	else:
		_fail("boss saw player in the dark at 250px (should be invisible)")
	# 4. Boss still sees a player with flashlight on at long range
	player.set("flashlight_on", true)
	boss.set("facing", Vector2(1, 0))
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player with flashlight on at 250px")
	else:
		_fail("boss did NOT see player with flashlight on at 250px")
	# 5. Opening a popup alerts the boss toward the task
	# Check the noise queue immediately (before the boss consumes it on its next physics frame)
	# Boss 250px from the task: inside the 350px task-noise radius, so it hears it.
	player.set("flashlight_on", false)
	player.global_position = Vector2(400, 400)
	player.set("interacting", true)
	player.set("interact_target", 1)
	boss.global_position = Vector2(650, 400)
	boss.set("state", 0)
	lvl.call("try_open_task_popup", 1)
	var noise: Vector2 = lvl.call("consume_noise")
	if noise != Vector2.ZERO and noise.distance_to(Vector2(400, 400)) < 50.0:
		_ok("opening a popup alerts the boss to the task location")
	else:
		_fail("no noise queued toward the task (got " + str(noise) + ", popup_open=" + str(lvl.get("popup_open")) + ")")
	print("=== BOSSAGGRO TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== BOSSAGGRO TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
