extends SceneTree

var lvl: Node2D
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
	var calm: AudioStreamPlayer = lvl.get("music_calm")
	var tense: AudioStreamPlayer = lvl.get("music_tense")
	if AudioServer.get_bus_index("Music") >= 0:
		_ok("Music bus exists")
	else:
		_fail("Music bus missing")
	if AudioServer.get_bus_index("SFX") >= 0:
		_ok("SFX bus exists")
	else:
		_fail("SFX bus missing")
	if calm != null and calm.bus == "Music":
		_ok("calm routed to Music bus")
	else:
		_fail("calm not on Music bus (bus=" + str(calm.bus if calm != null else "null") + ")")
	if tense != null and tense.bus == "Music":
		_ok("tense routed to Music bus")
	else:
		_fail("tense not on Music bus (bus=" + str(tense.bus if tense != null else "null") + ")")
	var sfx: Node = lvl.get("sfx")
	var pool_ok := sfx != null
	if sfx != null:
		for p in sfx.get("_players"):
			if p.bus != "SFX":
				pool_ok = false
	if pool_ok:
		_ok("sfx pool routed to SFX bus")
	else:
		_fail("sfx pool not on SFX bus")
	var calm_src := load("res://assets/audio/ambient_calm.ogg") as AudioStreamOggVorbis
	var tense_src := load("res://assets/audio/ambient_tense.ogg") as AudioStreamOggVorbis
	if calm_src != null and not calm_src.loop:
		_ok("shared calm preload not mutated (loop stays false)")
	else:
		_fail("shared calm preload mutated (loop forced true)")
	if tense_src != null and not tense_src.loop:
		_ok("shared tense preload not mutated (loop stays false)")
	else:
		_fail("shared tense preload mutated (loop forced true)")
	if calm != null and calm.stream != null and calm.stream != calm_src and (calm.stream as AudioStreamOggVorbis).loop:
		_ok("calm player uses its own looping stream copy")
	else:
		_fail("calm player stream is not an independent looping copy")
	if tense != null and tense.stream != null and tense.stream != tense_src and (tense.stream as AudioStreamOggVorbis).loop:
		_ok("tense player uses its own looping stream copy")
	else:
		_fail("tense player stream is not an independent looping copy")
	await _test_limiter()
	await _test_steal()
	_report()

func _test_limiter() -> void:
	var sfx2: Node = load("res://scripts/sfx.gd").new()
	root.add_child(sfx2)
	await process_frame
	await process_frame
	for i in range(8):
		sfx2.call("play", "alarm", -6.0, 1.0)
	var alarm_stream: AudioStream = sfx2.get("_streams")["alarm"]
	var count := 0
	for p in sfx2.get("_players"):
		if p.playing and p.stream == alarm_stream:
			count += 1
	if count <= 5:
		_ok("identical sfx capped at 5 concurrent (" + str(count) + " alarms playing)")
	else:
		_fail("identical sfx not capped (" + str(count) + " alarms playing at once)")
	sfx2.queue_free()

func _test_steal() -> void:
	var sfx3: Node = load("res://scripts/sfx.gd").new()
	root.add_child(sfx3)
	await process_frame
	await process_frame
	var fill := ["whisper", "sting", "complete", "alarm", "thud", "shout", "pickup", "hide"]
	for s in fill:
		sfx3.call("play", s, -4.0, 1.0)
	var players: Array = sfx3.get("_players")
	var streams: Dictionary = sfx3.get("_streams")
	var started: PackedInt64Array = sfx3.get("_started")
	var tracked := true
	for v in started:
		if v <= 0:
			tracked = false
	if tracked:
		_ok("pool tracks start time per voice")
	else:
		_fail("pool does not track start time per voice")
	var busy := 0
	for p in players:
		if p.playing:
			busy += 1
	if busy == 8:
		_ok("pool filled with 8 distinct voices")
	else:
		_fail("pool fill incomplete (" + str(busy) + "/8 playing)")
	var ages := PackedInt64Array([5000, 5001, 5002, 1000, 5004, 5005, 5006, 5007])
	sfx3.set("_started", ages)
	sfx3.call("play", "step", -4.0, 1.0)
	if players[3].playing and players[3].stream == streams["step"]:
		_ok("pool steal takes oldest voice (slot 3)")
	else:
		_fail("pool steal did not take oldest voice")
	if players[0].playing and players[0].stream == streams["whisper"]:
		_ok("newest voice (slot 0 whisper) survives the steal")
	else:
		_fail("newest voice (slot 0 whisper) was cut by the steal")
	sfx3.queue_free()

func _report() -> void:
	print("=== AUDIO ROUTING TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== AUDIO ROUTING TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
