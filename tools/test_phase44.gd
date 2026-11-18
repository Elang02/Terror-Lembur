extends SceneTree

var results: Array[String] = []
var lvl: Node2D

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
	print("PHASE44 FAILS=" + str(fails))
	quit(0 if fails == 0 else 1)

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
	var pl := pscene.instantiate() as Node2D
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
	# FEED-01a: E di tugas yang belum siap memberi alasan, bukan diam.
	lvl.call("try_open_task_popup", 3)
	for i in range(3):
		await process_frame
	var warn_lbl: Label = lvl.get("hud_warn_label")
	if warn_lbl != null and warn_lbl.text == "Selesaikan semua tugas dulu!":
		_ok("exit before tasks done explains itself")
	else:
		_fail("no reason for unready exit (label: '" + ("" if warn_lbl == null else warn_lbl.text) + "')")
	if not bool(lvl.get("popup_open")):
		_ok("popup stays closed for unready task")
	else:
		_fail("popup opened for unready task")
	# FEED-01b: tutorial langkah 2 terima popup tugas apa pun.
	lvl.set("tutorial_step", 2)
	lvl.set("popup_open", true)
	lvl.set("popup_task_id", 5)
	for i in range(5):
		await process_frame
	if int(lvl.get("tutorial_step")) == 3:
		_ok("tutorial step 2 accepts any task popup")
	else:
		_fail("tutorial step 2 stuck (step " + str(lvl.get("tutorial_step")) + ")")
	lvl.set("popup_open", false)
	# FEED-01c: tutorial langkah 4 selesai saat tugas pertama selesai.
	lvl.set("tutorial_step", 4)
	_mark_done(5)
	for i in range(5):
		await process_frame
	if int(lvl.get("tutorial_step")) == 5:
		_ok("tutorial finishes on first task done")
	else:
		_fail("tutorial step 4 stuck (step " + str(lvl.get("tutorial_step")) + ")")
	# FEED-01d: prompt jujur soal sprint yang berisik.
	pl.global_position = Vector2(400, 656)
	for i in range(5):
		await process_frame
	var prompt_lbl: Label = lvl.get("hud_prompt_label")
	if prompt_lbl != null and prompt_lbl.text.contains("SHIFT: lari (berisik!)"):
		_ok("prompt warns sprint is noisy")
	else:
		_fail("prompt hides sprint noise (label: '" + ("" if prompt_lbl == null else prompt_lbl.text) + "')")
	# FEED-01e: pesan teleport jujur soal jarak.
	pl.global_position = Vector2(400, 400)
	for i in range(3):
		await process_frame
	lvl.call("on_boss_teleported", Vector2(420, 400))
	for i in range(3):
		await process_frame
	if warn_lbl != null and warn_lbl.text == "Bos muncul di dekatmu!":
		_ok("teleport near says near")
	else:
		_fail("teleport near message wrong (label: '" + ("" if warn_lbl == null else warn_lbl.text) + "')")
	lvl.call("on_boss_teleported", Vector2(1200, 100))
	for i in range(3):
		await process_frame
	if warn_lbl != null and warn_lbl.text == "Bos muncul di kejauhan...":
		_ok("teleport far says far")
	else:
		_fail("teleport far message wrong (label: '" + ("" if warn_lbl == null else warn_lbl.text) + "')")
	_report()
