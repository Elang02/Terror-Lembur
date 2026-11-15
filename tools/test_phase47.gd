extends SceneTree

var results: Array = []
var lvl: Node2D
var pl: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _ok(msg: String) -> void:
	results.append("TEST OK: " + msg)

func _fail(msg: String) -> void:
	results.append("TEST FAIL: " + msg)

func _report() -> void:
	var fails := 0
	for r in results:
		print(r)
		if r.begins_with("TEST FAIL"):
			fails += 1
	print("PHASE47 FAILS=" + str(fails))
	quit()

func _mark_done(task_id: int) -> void:
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == task_id:
			tp.set("done", true)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	pl = pscene.instantiate() as Node2D
	pl.name = "1"
	ysort.add_child(pl, true)
	await process_frame
	await process_frame
	lvl.call("_dismiss_intro")
	var intro_dim: Node = lvl.get("intro_dim")
	if intro_dim != null:
		intro_dim.visible = false
	var intro_panel: Node = lvl.get("intro_panel")
	if intro_panel != null:
		intro_panel.visible = false
	for i in range(5):
		await process_frame
	var boss: Node = lvl.get("boss")
	# STORY-01: tiap digit datang dengan satu baris backstory bos.
	lvl.call("_reveal_code_digit", 0)
	for i in range(3):
		await process_frame
	var code_lbl: Label = lvl.get("hud_code_label")
	if code_lbl != null and code_lbl.text.contains("Digit ke-1") and code_lbl.text.contains("sampai jam 2 pagi"):
		_ok("Komputer digit carries the boss story")
	else:
		_fail("Komputer story missing (label: '" + ("" if code_lbl == null else code_lbl.text) + "')")
	lvl.call("_reveal_code_digit", 4)
	for i in range(3):
		await process_frame
	if code_lbl != null and code_lbl.text.contains("Digit ke-5") and code_lbl.text.contains("jangan lembur sendirian"):
		_ok("Rapat digit carries the boss story")
	else:
		_fail("Rapat story missing")
	# PULANG-01: papan di pintu keluar menunjukkan progres pulang.
	var sign: Label = lvl.get("exit_sign_label")
	_mark_done(1)
	_mark_done(2)
	for i in range(5):
		await process_frame
	if sign != null and sign.text.contains("2/5"):
		_ok("exit sign shows 2/5 tasks")
	else:
		_fail("exit sign wrong at 2/5 (label: '" + ("" if sign == null else sign.text) + "')")
	_mark_done(0)
	_mark_done(5)
	_mark_done(6)
	for i in range(5):
		await process_frame
	if sign != null and sign.text.contains("Semua tugas selesai"):
		_ok("exit sign flips when all tasks are done")
	else:
		_fail("exit sign wrong at 5/5 (label: '" + ("" if sign == null else sign.text) + "')")
	# SILENCE-01: musik hening saat kejaran, balik 2 detik setelah putus.
	pl.set("locked", false)
	pl.global_position = Vector2(400, 656)
	boss.global_position = Vector2(700, 656)
	boss.set("facing", Vector2(-1, 0))
	boss.set("teleport_timer", 99999.0)
	boss.set("slow_mult", 0.0)
	boss.set("path", PackedVector2Array())
	boss.set("path_index", 0)
	boss.set("repath_timer", 0.0)
	boss.set("state", 2)
	lvl.set("silence_fade", 1.0)
	var ducked := false
	for i in range(15):
		await process_frame
		if float(lvl.get("silence_fade")) < 0.5:
			ducked = true
			break
	if ducked:
		_ok("music ducks during a chase")
	else:
		_fail("music did not duck in chase (fade " + str(lvl.get("silence_fade")) + ")")
	var calm: Node = lvl.get("music_calm")
	var quiet := false
	for i in range(15):
		await process_frame
		if calm != null and float(calm.get("volume_db")) < -60.0:
			quiet = true
			break
	if quiet:
		_ok("calm loop near silent during a chase")
	else:
		_fail("calm loop still audible in chase (db " + str(calm.get("volume_db")) + ")")
	boss.global_position = Vector2(1328, 272)
	boss.set("slow_mult", 1.0)
	boss.set("state", 0)
	boss.set("telegraph_timer", 0.0)
	var returned := false
	for i in range(30):
		await process_frame
		if float(lvl.get("silence_fade")) > 0.8:
			returned = true
			break
	if returned:
		_ok("music returns after the chase breaks")
	else:
		_fail("music did not return (fade " + str(lvl.get("silence_fade")) + ")")
	# Telegraph juga membungkam musik.
	boss.set("telegraph_timer", 0.5)
	ducked = false
	for i in range(15):
		await process_frame
		if float(lvl.get("silence_fade")) < 0.5:
			ducked = true
			break
	if ducked:
		_ok("music ducks during the teleport telegraph")
	else:
		_fail("music did not duck on telegraph")
	_report()
