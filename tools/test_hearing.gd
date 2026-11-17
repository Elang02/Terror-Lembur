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
	# --- LINE OF SIGHT: wall between boss and player ---
	# Boss at (400,180) above the y=7 wall (y=224), player at (400,400)
	# below it. Same x, 220px apart, boss facing down, flashlight on.
	boss.global_position = Vector2(400, 180)
	boss.set("facing", Vector2.DOWN)
	boss.set("state", 0)
	boss.set("blind_timer", 0.0)
	player.global_position = Vector2(400, 400)
	player.set("hiding", false)
	player.set("flashlight_on", true)
	player.set("locked", false)
	player.velocity = Vector2.ZERO
	var seen = boss.call("_nearest_visible_player")
	if seen == null:
		_ok("boss CANNOT see player through the wall (LOS blocked)")
	else:
		_fail("boss SEES player THROUGH THE WALL (LOS broken)")
	# Control: same setup in the open corridor, no wall
	boss.global_position = Vector2(400, 656)
	boss.set("facing", Vector2.RIGHT)
	player.global_position = Vector2(600, 656)
	seen = boss.call("_nearest_visible_player")
	if seen == player:
		_ok("boss sees player in the open corridor (control)")
	else:
		_fail("boss blind in the open corridor (control failed)")
	# --- HEARING: player sprinting within 360px ---
	# Put the player out of the vision cone (behind the boss) so only
	# hearing can trigger the FSM, not vision.
	boss.global_position = Vector2(400, 656)
	boss.set("facing", Vector2.RIGHT)
	boss.set("state", 0)
	boss.set("blind_timer", 0.0)
	player.global_position = Vector2(200, 656)
	player.set("flashlight_on", false)
	player.velocity = Vector2(-300, 0)
	player.set("sprinting", true)
	boss.call("_update_detection")
	if int(boss.get("state")) == 1:
		_ok("boss hears sprinting player 200px away (PATROL -> SUSPICIOUS)")
	else:
		_fail("boss ignores sprinting player 200px away (state=" + str(boss.get("state")) + ")")
	# --- HEARING: player walking within 200px ---
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	player.global_position = Vector2(250, 656)
	player.velocity = Vector2(-200, 0)
	player.set("sprinting", false)
	boss.call("_update_detection")
	if int(boss.get("state")) == 1:
		_ok("boss hears walking player 150px away (PATROL -> SUSPICIOUS)")
	else:
		_fail("boss ignores walking player 150px away (state=" + str(boss.get("state")) + ")")
	# --- HEARING: player walking at 140px (within new 160px range, beyond old 120px) ---
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	player.global_position = Vector2(260, 656)
	player.velocity = Vector2(-200, 0)
	player.set("sprinting", false)
	boss.call("_update_detection")
	if int(boss.get("state")) == 1:
		_ok("boss hears walking player 140px away (PATROL -> SUSPICIOUS)")
	else:
		_fail("boss ignores walking player 140px away (state=" + str(boss.get("state")) + ")")
	# --- HEARING: player walking at 250px (beyond walk range 200) ---
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	player.global_position = Vector2(150, 656)
	player.velocity = Vector2(-200, 0)
	player.set("sprinting", false)
	boss.call("_update_detection")
	if int(boss.get("state")) == 0:
		_ok("boss does NOT hear walking player 250px away (beyond 200px)")
	else:
		_fail("boss hears walking player 250px away (state=" + str(boss.get("state")) + ")")
	# --- HEARING: player standing still within 200px (silent) ---
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	player.global_position = Vector2(250, 656)
	player.velocity = Vector2.ZERO
	player.set("sprinting", false)
	boss.call("_update_detection")
	if int(boss.get("state")) == 0:
		_ok("boss does NOT hear standing-still player (silent)")
	else:
		_fail("boss hears standing-still player (state=" + str(boss.get("state")) + ")")
	# --- HEARING: hiding player sprinting (silent, hidden) ---
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	player.global_position = Vector2(300, 656)
	player.velocity = Vector2(-300, 0)
	player.set("sprinting", true)
	player.set("hiding", true)
	boss.call("_update_detection")
	if int(boss.get("state")) == 0:
		_ok("boss does NOT hear hiding player (hidden is silent)")
	else:
		_fail("boss hears hiding player (state=" + str(boss.get("state")) + ")")
	print("=== HEARING TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== HEARING TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
