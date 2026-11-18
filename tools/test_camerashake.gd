extends SceneTree

var results: Array = []
var lvl: Node2D
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
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var cam: Camera2D = pscene.instantiate().get_node_or_null("Camera2D") as Camera2D
	if cam != null and cam.limit_smoothed:
		_ok("camera limit_smoothed is true")
	else:
		_fail("camera limit_smoothed is false (GDAS camera skill: never forget limit_smoothed)")
	if cam != null:
		cam.queue_free()
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(10):
		await process_frame
	player.global_position = Vector2(740, 760)
	lvl.call("show_hud")
	for i in range(5):
		await process_frame
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		_fail("player has no Camera2D")
		_finish()
		return
	if not camera.position_smoothing_enabled:
		_fail("camera position smoothing is off")
	else:
		_ok("camera position smoothing enabled")
	lvl.call("add_shake", 10.0)
	if absf(float(lvl.get("_shake_trauma")) - 1.0) < 0.001:
		_ok("add_shake(10) fills trauma to 1.0")
	else:
		_fail("add_shake(10) trauma is " + str(lvl.get("_shake_trauma")) + ", expected 1.0")
	lvl.call("add_shake", 3.0)
	if absf(float(lvl.get("_shake_trauma")) - 1.0) < 0.001:
		_ok("add_shake keeps max, does not stack (3.0 after 10.0 stays 1.0)")
	else:
		_fail("add_shake stacked instead of max: trauma=" + str(lvl.get("_shake_trauma")))
	var saw_offset := false
	var max_mag := 0.0
	for i in range(60):
		lvl.call("_process", 0.016)
		var m := camera.offset.length()
		max_mag = maxf(max_mag, m)
		if m > 0.5:
			saw_offset = true
	if saw_offset:
		_ok("trauma shake moves camera offset (max=" + str(max_mag) + ")")
	else:
		_fail("camera offset never moved after add_shake(10)")
	if max_mag <= 11.0:
		_ok("shake peak stays within old 10px amplitude")
	else:
		_fail("shake peak exceeds old 10px amplitude (max=" + str(max_mag) + ")")
	if float(lvl.get("_shake_trauma")) <= 0.0 and camera.offset == Vector2.ZERO:
		_ok("shake decays back to zero trauma and zero offset")
	else:
		_fail("shake did not fully decay: trauma=" + str(lvl.get("_shake_trauma")) + " offset=" + str(camera.offset))
	_finish()

func _finish() -> void:
	print("=== CAMERA SHAKE TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("=== CAMERA SHAKE TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0)
