extends SceneTree

var results: Array = []
var lvl: Node2D
var player: Node2D
var sprite: AnimatedSprite2D

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
	sprite = player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	player.global_position = Vector2(320, 320)
	for i in range(5):
		await process_frame
	# Hide under the desk
	player.call("_toggle_hide")
	for i in range(5):
		await process_frame
	if bool(player.get("hiding")):
		_ok("player is hiding after C")
	else:
		_fail("player did not hide")
	var spot: Vector2 = player.get("hide_spot")
	if spot != Vector2.ZERO and spot != Vector2.INF:
		_ok("hide spot is a real desk (" + str(spot) + ")")
	else:
		_fail("hide spot invalid: " + str(spot))
	# Player sits just above the desk centre, so the desk draws on top (YSort)
	if player.global_position.y < spot.y + 2.0:
		_ok("player sits above the desk centre (desk covers them)")
	else:
		_fail("player Y=" + str(player.global_position.y) + " vs desk Y=" + str(spot.y))
	if absf(sprite.scale.y - 0.6) < 0.01:
		_ok("sprite crouches (scale y 0.6)")
	else:
		_fail("sprite scale y is " + str(sprite.scale.y))
	if absf(sprite.modulate.a - 0.5) < 0.01:
		_ok("sprite semi-transparent (alpha 0.5)")
	else:
		_fail("sprite alpha is " + str(sprite.modulate.a))
	var lbl: Label = player.get("name_label")
	if lbl != null and absf(lbl.modulate.a) < 0.01:
		_ok("name label hidden while hiding")
	else:
		_fail("name label alpha is " + (str(lbl.modulate.a) if lbl != null else "null"))
	var light: PointLight2D = player.get_node("Flashlight") as PointLight2D
	if light != null and not light.enabled:
		_ok("flashlight off while hiding")
	else:
		_fail("flashlight still on while hiding")
	# Unhide restores everything
	player.call("_toggle_hide")
	for i in range(5):
		await process_frame
	if not bool(player.get("hiding")):
		_ok("player unhides on second C")
	else:
		_fail("player still hiding after second C")
	if sprite.scale == Vector2.ONE and absf(sprite.modulate.a - 1.0) < 0.01:
		_ok("sprite restored on unhide")
	else:
		_fail("sprite not restored (scale=" + str(sprite.scale) + " alpha=" + str(sprite.modulate.a) + ")")
	if lbl != null and absf(lbl.modulate.a - 1.0) < 0.01:
		_ok("name label restored on unhide")
	else:
		_fail("name label not restored")
	print("=== HIDE TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== HIDE TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
