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
	var calm: AudioStreamPlayer = lvl.get("music_calm")
	var tense: AudioStreamPlayer = lvl.get("music_tense")
	if calm == null or tense == null:
		_fail("music players missing")
		_report()
		return
	if calm.playing and tense.playing:
		_ok("both ambient loops playing")
	else:
		_fail("music not playing (calm=" + str(calm.playing) + " tense=" + str(tense.playing) + ")")
	if calm.stream != null and (calm.stream as AudioStreamOggVorbis).loop:
		_ok("calm loop enabled")
	else:
		_fail("calm loop not enabled")
	if tense.stream != null and (tense.stream as AudioStreamOggVorbis).loop:
		_ok("tense loop enabled")
	else:
		_fail("tense loop not enabled")
	# Drive the music crossfade directly: set the boss state and call
	# _update_music in a tight loop (no await, so boss physics cannot
	# override the state between calls). This tests the crossfade logic;
	# the boss FSM itself is covered by test_patrol/test_search/test_flow.
	boss.set("state", 2)
	for i in range(30):
		lvl.call("_update_music", 0.1)
	var lvl_tense := float(lvl.get("music_tense_level"))
	if lvl_tense > 0.8:
		_ok("tense level rises in CHASE (" + str(lvl_tense) + ")")
	else:
		_fail("tense level stuck low in CHASE (" + str(lvl_tense) + ")")
	if tense.volume_db < -60.0:
		_ok("tense loop ducked to silence in CHASE (" + str(tense.volume_db) + " dB)")
	else:
		_fail("tense loop still audible in CHASE (" + str(tense.volume_db) + " dB)")
	# Back to PATROL: tense level should fall toward 0.0
	boss.set("state", 0)
	boss.global_position = lvl.boss_room_center()
	for i in range(30):
		lvl.call("_update_music", 0.1)
	lvl_tense = float(lvl.get("music_tense_level"))
	if lvl_tense < 0.2:
		_ok("tense level falls back in PATROL (" + str(lvl_tense) + ")")
	else:
		_fail("tense level stuck high in PATROL (" + str(lvl_tense) + ")")
	if calm.volume_db > -20.0:
		_ok("calm volume back up in PATROL (" + str(calm.volume_db) + " dB)")
	else:
		_fail("calm volume too quiet in PATROL (" + str(calm.volume_db) + " dB)")
	_report()

func _report() -> void:
	print("=== MUSIC TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== MUSIC TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
