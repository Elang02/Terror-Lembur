extends SceneTree
## Co-op: pintu keluar tidak boleh menutup permainan karena satu ketukan E.
##
## Di solo, satu ketukan E di pintu yang sudah terbuka langsung menyelesaikan
## level — itu wajar. Di co-op, ketukan yang sama dulu juga langsung
## menyelesaikan level, padahal rekan satu tim bisa masih di lantai lain.
## Sekarang harus ditahan EXIT_CONFIRM_TIME (1,5 detik).

var lvl: Node2D
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

func _reset() -> void:
	lvl.set("game_over", false)
	lvl.set("exit_confirm", 0.0)
	lvl.set("exit_open", true)

func _run() -> void:
	var tl = preload("res://tools/tlib.gd").new()
	await tl.wait(self, 0.5)

	# 1. Co-op, ketukan pendek: belum selesai.
	lvl.set_solo_mode(false)
	_reset()
	lvl.call("_exit_confirm_step", 0.5, true)
	var half: float = lvl.get("exit_confirm")
	if not bool(lvl.get("game_over")) and absf(half - 0.5) < 0.01:
		_ok("half a second of holding does not end the run (co-op)")
	else:
		_fail("half second ended the run or timer wrong: game_over=" + str(lvl.get("game_over")) + " t=" + str(half))

	# 2. Co-op, tahan sampai lewat 1,5 detik: selesai.
	lvl.call("_exit_confirm_step", 0.5, true)
	var nearly: float = lvl.get("exit_confirm")
	if not bool(lvl.get("game_over")) and nearly >= 0.99:
		_ok("one second of holding still waits")
	else:
		_fail("ended too early: game_over=" + str(lvl.get("game_over")) + " t=" + str(nearly))
	lvl.call("_exit_confirm_step", 0.6, true)
	if bool(lvl.get("game_over")):
		_ok("holding past 1.5 s finishes the level in co-op")
	else:
		_fail("still not finished after 1.6 s of holding")

	# 3. Lepas E membatalkan hitungan.
	lvl.set_solo_mode(false)
	_reset()
	lvl.call("_exit_confirm_step", 0.4, true)
	lvl.call("_exit_confirm_step", 0.1, false)
	if float(lvl.get("exit_confirm")) == 0.0 and not bool(lvl.get("game_over")):
		_ok("releasing E cancels the exit hold")
	else:
		_fail("holding state did not reset: t=" + str(lvl.get("exit_confirm")))

	# 4. Solo tetap satu ketukan (tidak diubah).
	lvl.set_solo_mode(true)
	_reset()
	lvl.call("_exit_confirm_step", 1.0, true)
	if float(lvl.get("exit_confirm")) == 0.0 and not bool(lvl.get("game_over")):
		_ok("solo mode is untouched by the co-op hold timer")
	else:
		_fail("co-op timer leaked into solo mode")

	print("=== EXITCOOP TEST: failed=" + str(failed) + " ===")
	quit(0 if failed == 0 else 1)
