extends SceneTree

var lvl: Node2D
var results: Array[String] = []

func _init() -> void:
	DirAccess.remove_absolute("user://settings.cfg")
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
	var sfx: Node = lvl.get("sfx")
	if sfx == null:
		_fail("sfx node missing")
		_finish()
		return
	# 1. Default: not muted
	if bool(lvl.get("muted")) == false:
		_ok("not muted by default")
	else:
		_fail("muted by default, should start unmuted")
	# 2. Toggle mute: flag + sfx gate + music fades to silence
	lvl.call("_toggle_mute")
	if bool(lvl.get("muted")) == true:
		_ok("mute toggles on")
	else:
		_fail("mute did not toggle on")
	if bool(sfx.get("muted")) == true:
		_ok("sfx muted flag follows")
	else:
		_fail("sfx muted flag not set")
	sfx.call("play", "tick", -10.0, 1.0)
	var any_playing := false
	for p in sfx.get("_players"):
		if p.playing:
			any_playing = true
	if not any_playing:
		_ok("no sfx plays while muted")
	else:
		_fail("sfx played while muted")
	for i in range(10):
		lvl.call("_update_music", 0.1)
	var calm: AudioStreamPlayer = lvl.get("music_calm")
	var tense: AudioStreamPlayer = lvl.get("music_tense")
	if calm.volume_db < -70.0 and tense.volume_db < -70.0:
		_ok("music fades to silence when muted (calm=" + str(calm.volume_db) + " tense=" + str(tense.volume_db) + ")")
	else:
		_fail("music did not fade out (calm=" + str(calm.volume_db) + " tense=" + str(tense.volume_db) + ")")
	# 3. Persistence: settings.cfg stores the muted state
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK and bool(cfg.get_value("audio", "muted", false)) == true:
		_ok("muted state saved to settings.cfg")
	else:
		_fail("muted state not saved")
	# 4. Toggle back: unmute restores audio
	lvl.call("_toggle_mute")
	if bool(lvl.get("muted")) == false and bool(sfx.get("muted")) == false:
		_ok("mute toggles off")
	else:
		_fail("mute did not toggle off")
	for i in range(10):
		lvl.call("_update_music", 0.1)
	if calm.volume_db > -70.0:
		_ok("music fades back in when unmuted (calm=" + str(calm.volume_db) + ")")
	else:
		_fail("music did not fade back in (calm=" + str(calm.volume_db) + ")")
	if cfg.load("user://settings.cfg") == OK and bool(cfg.get_value("audio", "muted", true)) == false:
		_ok("unmuted state saved to settings.cfg")
	else:
		_fail("unmuted state not saved")
	_finish()

func _finish() -> void:
	var passed := 0
	var failed := 0
	for r in results:
		if r.begins_with("OK:"):
			passed += 1
		else:
			failed += 1
	print("=== MUTE TEST: " + str(passed) + " passed, " + str(failed) + " failed ===")
	quit(0 if failed == 0 else 1)
