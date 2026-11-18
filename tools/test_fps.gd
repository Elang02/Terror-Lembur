extends SceneTree

# TEST-06 FPS: measures real rendered frame rate of level_1 in solo mode.
# Runs the level headed under Xvfb, counts rendered frames over a fixed
# wall-clock window, reports average FPS + 1% low estimate.
# NOTE: sandbox runs ~0.4x real speed, so numbers are sandbox-only,
# not representative of a real PC. Report them as such.

const LEVEL := "res://scenes/level_1.tscn"
const WINDOW_SECS := 30.0

var frames := 0
var start_msec := 0
var frame_times: Array[int] = []
var last_msec := 0

func _init() -> void:
	var packed: PackedScene = load(LEVEL)
	var lvl: Node = packed.instantiate()
	root.add_child(lvl)
	lvl.call("_dismiss_intro")
	# spawn player so the scene is fully live
	var player: Node = load("res://scenes/worker_char.tscn").instantiate()
	player.name = "1"
	lvl.get_node("YSort").add_child(player)
	await create_timer(0.5).timeout
	player.global_position = Vector2(400, 656)
	await create_timer(1.0).timeout
	start_msec = Time.get_ticks_msec()
	last_msec = start_msec
	# count frames via process_frame signal
	process_frame.connect(_on_frame)
	await create_timer(WINDOW_SECS).timeout
	process_frame.disconnect(_on_frame)
	var elapsed := (Time.get_ticks_msec() - start_msec) / 1000.0
	var fps := frames / elapsed
	frame_times.sort()
	var p99_idx := int(frame_times.size() * 0.99)
	var p99_ms: float = frame_times[p99_idx] if frame_times.size() > 0 else 0.0
	print("=== FPS TEST ===")
	print("window_s=%.1f frames=%d avg_fps=%.1f p99_frame_ms=%.1f" % [elapsed, frames, fps, p99_ms])
	var ok := fps >= 20.0
	if not ok:
		print("TEST FAIL: avg fps %.1f below 20.0" % fps)
	print("RESULT: %s" % ("PASS" if ok else "LOW"))
	quit(0 if ok else 1)

func _on_frame() -> void:
	frames += 1
	var now := Time.get_ticks_msec()
	if last_msec > 0:
		frame_times.append(now - last_msec)
	last_msec = now
