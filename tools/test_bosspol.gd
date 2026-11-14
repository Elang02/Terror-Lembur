extends SceneTree

var lvl: Node2D
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
	boss = lvl.get("boss")
	var sprite: Sprite2D = boss.get("boss_sprite")
	if sprite == null:
		_fail("boss_sprite missing")
		_report()
		return
	# 1. Bobbing: while the boss patrols, sprite y oscillates around -22
	var min_y := 999.0
	var max_y := -999.0
	for i in range(180):
		var y := sprite.position.y
		if y < min_y:
			min_y = y
		if y > max_y:
			max_y = y
		await process_frame
	if max_y - min_y > 0.5:
		_ok("boss sprite bobs while walking (y range " + str(min_y) + " to " + str(max_y) + ")")
	else:
		_fail("boss sprite does not bob (y range " + str(min_y) + " to " + str(max_y) + ")")
	if min_y >= -24.5 and max_y <= -19.5:
		_ok("bob stays within 2px of rest pose (-22)")
	else:
		_fail("bob amplitude out of range (y " + str(min_y) + " to " + str(max_y) + ")")
	# 2. Rest: when the boss stops, sprite returns to y=-22 and no rotation
	# NOTE: SUSPICIOUS lasts 1.5s then auto-transitions to SEARCH (boss walks).
	# Wait only 10 frames (~0.95s sandbox game time) so it stays still.
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)
	for i in range(10):
		await process_frame
	if absf(sprite.position.y - (-22.0)) < 0.01 and absf(sprite.rotation) < 0.001:
		_ok("boss sprite returns to rest pose when still")
	else:
		_fail("boss sprite not at rest (y=" + str(sprite.position.y) + " rot=" + str(sprite.rotation) + ")")
	# 3. SEARCH desk-check: boss walks to a nearby desk and pauses there
	boss.set("teleport_timer", 99999.0)
	boss.call("_enter_search", Vector2(400, 400))
	boss.global_position = Vector2(400, 400)
	var paused := false
	var near_desk := false
	for i in range(900):
		if float(boss.get("search_desk_pause")) > 0.0:
			paused = true
		for d in lvl.get("desk_positions"):
			if boss.global_position.distance_to(d) < 45.0:
				near_desk = true
		if paused:
			break
		await process_frame
	if bool(boss.get("search_desk_checked")):
		_ok("boss checked a desk during SEARCH")
	else:
		_fail("boss never checked a desk during SEARCH")
	if near_desk:
		_ok("boss walked within 30px of a desk during SEARCH")
	else:
		_fail("boss never got near a desk during SEARCH")
	if paused:
		_ok("boss paused at the desk (search_desk_pause > 0)")
	else:
		_fail("boss never paused at a desk")
	_report()

func _report() -> void:
	print("=== BOSSPOL TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== BOSSPOL TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
