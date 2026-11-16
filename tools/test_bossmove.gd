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
	if boss == null:
		_fail("boss null")
		_report()
		return
	boss.set("teleport_timer", 99999.0)
	boss.set("blind_timer", 0.0)
	boss.set("slow_mult", 0.5)
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.global_position = Vector2(272, 624)
	boss.set("path", PackedVector2Array())
	boss.set("velocity", Vector2.ZERO)
	var start := boss.global_position
	var last_pos := start
	var total_moved := 0.0
	var stall_frames := 0
	var max_stall := 0
	var frames := 0
	while frames < 1200:
		await process_frame
		frames += 1
		var p: Vector2 = boss.global_position
		var step := p.distance_to(last_pos)
		total_moved += step
		if step < 0.05:
			stall_frames += 1
			max_stall = maxi(max_stall, stall_frames)
		else:
			stall_frames = 0
		last_pos = p
		if total_moved > 300.0:
			break
	print("BOSS_MOVE total_moved=" + str(total_moved) + " max_stall_frames=" + str(max_stall) + " frames=" + str(frames) + " end_pos=" + str(last_pos))
	if total_moved < 200.0:
		_fail("boss barely moved after teleport+path clear (total_moved=" + str(total_moved) + ")")
	else:
		_ok("boss moved " + str(total_moved) + "px after teleport+path clear")
	if max_stall > 120:
		_fail("boss stalled " + str(max_stall) + " frames after teleport+path clear")
	else:
		_ok("boss max stall " + str(max_stall) + " frames")
	_report()

func _report() -> void:
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("FAILS=" + str(fails) + " / " + str(results.size()))
	quit()
