extends SceneTree

var lvl: Node2D
var player: Node2D
var boss: Node2D
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

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	player.set("bot_mode", true)
	lvl.get_node("YSort").add_child(player, true)
	lvl.call("show_hud")
	boss = lvl.get("boss")
	await process_frame
	await process_frame
	await process_frame
	var light: PointLight2D = player.get("light")
	if light == null:
		_fail("player flashlight node missing")
		_finish()
		return
	# 1. Diagonal aim: moving diagonally aims the light diagonally, not snapped to a cardinal
	player.set("velocity", Vector2(150, 150))
	for i in range(5):
		player.call("_process", 0.1)
	var aim: Vector2 = player.get("aim_dir")
	if aim.x > 0.5 and aim.y > 0.5:
		_ok("light aims diagonally on diagonal movement (aim=" + str(aim) + ")")
	else:
		_fail("light aim snapped to cardinal (aim=" + str(aim) + ")")
	if absf(angle_difference(light.rotation, aim.angle())) < 0.3:
		_ok("light rotation follows diagonal aim")
	else:
		_fail("light rotation does not follow aim (rot=" + str(light.rotation) + " aim_angle=" + str(aim.angle()) + ")")
	# 2. Smooth sweep: one frame must NOT snap the light to the new aim
	player.set("aim_dir", Vector2.RIGHT)
	light.rotation = PI / 2.0
	player.set("velocity", Vector2.ZERO)
	player.call("_process", 0.016)
	if light.rotation > 1.0 and light.rotation < PI / 2.0:
		_ok("light sweeps smoothly, no snap in one frame (rot=" + str(light.rotation) + ")")
	else:
		_fail("light snapped or did not move (rot=" + str(light.rotation) + ")")
	# 3. Convergence: after many frames the light settles on the aim
	for i in range(30):
		player.call("_process", 0.016)
	if absf(angle_difference(light.rotation, 0.0)) < 0.05:
		_ok("light converges on aim after sustained frames")
	else:
		_fail("light did not converge (rot=" + str(light.rotation) + ")")
	# 4. Fade off: R toggle fades energy to 0 instead of cutting instantly
	player.set("flashlight_on", false)
	for i in range(5):
		player.call("_process", 0.1)
	if light.energy < 0.1 and not light.enabled:
		_ok("flashlight fades out and disables (energy=" + str(light.energy) + ")")
	else:
		_fail("flashlight did not fade out (energy=" + str(light.energy) + " enabled=" + str(light.enabled) + ")")
	# 5. Fade on: energy returns to full
	player.set("flashlight_on", true)
	for i in range(5):
		player.call("_process", 0.1)
	if light.energy > 2.4 and light.enabled:
		_ok("flashlight fades back in (energy=" + str(light.energy) + ")")
	else:
		_fail("flashlight did not fade back in (energy=" + str(light.energy) + ")")
	# 6. Boss searchlight sweeps smoothly too
	if boss == null:
		_fail("boss missing")
		_finish()
		return
	var blight: PointLight2D = boss.get("boss_light")
	if blight == null:
		_fail("boss searchlight node missing")
		_finish()
		return
	boss.set("facing", Vector2.RIGHT)
	blight.rotation = PI / 2.0
	boss.call("_process", 0.016)
	if blight.rotation > 1.0 and blight.rotation < PI / 2.0:
		_ok("boss searchlight sweeps smoothly (rot=" + str(blight.rotation) + ")")
	else:
		_fail("boss searchlight snapped or did not move (rot=" + str(blight.rotation) + ")")
	_finish()

func _finish() -> void:
	var passed := 0
	var failed := 0
	for r in results:
		if r.begins_with("OK:"):
			passed += 1
		else:
			failed += 1
	print("=== LIGHT TEST: " + str(passed) + " passed, " + str(failed) + " failed ===")
	quit(0 if failed == 0 else 1)
