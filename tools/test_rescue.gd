extends SceneTree

var lvl: Node2D
var player: Node2D
var boss: Node2D
var failed := 0

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _fail(msg: String) -> void:
	failed += 1
	print("TEST FAIL: " + msg)

func _ok(msg: String) -> void:
	print("TEST OK: " + msg)

func _run() -> void:
	var tl = preload("res://tools/tlib.gd").new()
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	if ysort == null:
		_fail("YSort null")
		quit(1)
		return
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	await process_frame
	await process_frame
	boss = lvl.get("boss")
	if boss == null:
		_fail("boss null")
		quit(1)
		return
	# Lock the player in the cell, boss far away. Hold E so the worker sets
	# interacting=true / interact_target=99 itself (like a real player).
	player.global_position = Vector2(1080, 140)
	player.set("locked", true)
	boss.global_position = Vector2(400, 400)
	boss.set("teleport_timer", 99999.0)
	boss.set("state", 0)
	Input.action_press("interact")
	var p0: float = float(lvl.get("self_rescue_progress"))
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var p1: float = float(lvl.get("self_rescue_progress"))
	if p1 > p0:
		_ok("progress advances when boss is far (%.3f -> %.3f)" % [p0, p1])
	else:
		_fail("progress did not advance when boss is far (%.3f -> %.3f)" % [p0, p1])
	# Boss comes to guard the cell: progress must crawl (30% speed),
	# not freeze and not run at full speed.
	boss.global_position = Vector2(1080, 200)
	boss.set("state", 0)
	var p2: float = float(lvl.get("self_rescue_progress"))
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var p3: float = float(lvl.get("self_rescue_progress"))
	var guarded_gain: float = p3 - p2
	var far_gain: float = p1 - p0
	if guarded_gain > 0.0 and guarded_gain < far_gain * 0.6:
		_ok("progress crawls while boss guards the cell (far +%.3f, guarded +%.3f)" % [far_gain, guarded_gain])
	else:
		_fail("progress while boss guards should crawl, not freeze or run full (far +%.3f, guarded +%.3f)" % [far_gain, guarded_gain])
	# Boss leaves again: progress must resume.
	boss.global_position = Vector2(400, 400)
	boss.set("state", 0)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var p4: float = float(lvl.get("self_rescue_progress"))
	if p4 > p3:
		_ok("progress resumes after boss leaves (%.3f -> %.3f)" % [p3, p4])
	else:
		_fail("progress did not resume after boss leaves (%.3f -> %.3f)" % [p3, p4])
	# Force progress to near-complete and let it finish: player unlocks.
	lvl.set("self_rescue_progress", 0.99)
	await tl.wait(self, 0.5)
	if player.get("locked") == false:
		_ok("player unlocked after rescue completes")
	else:
		_fail("player still locked after rescue completes")
	quit(0 if failed == 0 else 1)
