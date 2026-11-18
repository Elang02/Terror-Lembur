extends SceneTree

var results: Array[String] = []
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
	# Use the open bottom corridor y=656 for clear line of sight
	# 1. Player 200px in front of boss, flashlight ON, boss facing right
	boss.global_position = Vector2(400, 656)
	boss.set("facing", Vector2.RIGHT)
	boss.set("state", 0)
	boss.set("blind_timer", 0.0)
	player.global_position = Vector2(600, 656)
	player.set("hiding", false)
	player.set("flashlight_on", true)
	player.set("locked", false)
	var seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 200px ahead, flashlight on")
	else:
		_fail("boss BLIND to player 200px ahead, flashlight on (seen=" + str(seen) + ")")
	# 2. Player 250px ahead, flashlight ON
	player.global_position = Vector2(650, 656)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 250px ahead, flashlight on")
	else:
		_fail("boss BLIND to player 250px ahead, flashlight on")
	# 3. Player 100px ahead, flashlight OFF, dark area (not lit)
	player.global_position = Vector2(500, 656)
	player.set("flashlight_on", false)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 100px ahead in the dark (dark vision)")
	else:
		_fail("boss BLIND to player 100px ahead in the dark")
	# 4. Player 250px ahead, flashlight OFF, dark area: the boss sees them.
	# Requirement change 18 Nov (Elang): the old 240px dark-vision cutoff is
	# gone; vision is range (340px) + line of sight, flashlight or not.
	player.global_position = Vector2(650, 656)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 250px ahead in the dark")
	else:
		_fail("boss BLIND to player 250px ahead in the dark")
	# 4b. Player 220px ahead, flashlight OFF, dark area: dark vision now reaches 240px
	player.global_position = Vector2(620, 656)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 220px ahead in the dark (dark vision 240px)")
	else:
		_fail("boss BLIND to player 220px ahead in the dark")
	# 5. Player 320px ahead, flashlight ON: within the new 340px vision range
	player.global_position = Vector2(720, 656)
	player.set("flashlight_on", true)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player 320px ahead, flashlight on (vision range 340px)")
	else:
		_fail("boss BLIND to player 320px ahead, flashlight on")
	# 5. CATCH: boss directly ABOVE the player, touching (vertical contact ~36px)
	player.set("flashlight_on", true)
	player.global_position = Vector2(400, 656)
	boss.global_position = Vector2(400, 656 - 36)
	boss.set("blind_timer", 0.0)
	for i in range(3):
		await process_frame
	boss.call("_check_catch")
	if bool(player.get("locked")):
		_ok("boss catches player approaching from above (36px vertical contact)")
	else:
		_fail("boss CANNOT catch player from above (36px apart, CATCH_DIST=30)")
	# 6. CATCH: boss directly BELOW the player, touching (~28px)
	player.set("locked", false)
	player.global_position = Vector2(400, 656)
	boss.global_position = Vector2(400, 656 + 28)
	for i in range(3):
		await process_frame
	boss.call("_check_catch")
	if bool(player.get("locked")):
		_ok("boss catches player approaching from below (28px)")
	else:
		_fail("boss CANNOT catch player from below (28px apart)")
	# 7. CATCH: boss to the SIDE of the player, touching (~18px)
	player.set("locked", false)
	player.global_position = Vector2(400, 656)
	boss.global_position = Vector2(400 + 18, 656)
	for i in range(3):
		await process_frame
	boss.call("_check_catch")
	if bool(player.get("locked")):
		_ok("boss catches player from the side (18px)")
	else:
		_fail("boss CANNOT catch player from the side (18px apart)")
	print("=== VISION TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== VISION TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
