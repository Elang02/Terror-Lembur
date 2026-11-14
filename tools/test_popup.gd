extends SceneTree

var lvl: Node2D
var player: Node2D
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

func _task(tp_id: int) -> Node:
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == tp_id:
			return tp
	return null

func _open_popup(tp_id: int, pos: Vector2) -> bool:
	player.global_position = pos
	player.set("interacting", true)
	player.set("interact_target", tp_id)
	lvl.call("try_open_task_popup", tp_id)
	await process_frame
	await process_frame
	var pop: Node = lvl.get("popup")
	if pop == null or not bool(pop.get("open")):
		_fail("popup did not open for task " + str(tp_id))
		return false
	return true

func _run() -> void:
	for i in range(5):
		await process_frame
	if lvl == null:
		_fail("level null")
		_report()
		return
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	await process_frame
	await process_frame
	player.global_position = Vector2(400, 400)
	var pop: Node = lvl.get("popup")
	if pop == null:
		_fail("popup node null")
		_report()
		return
	_ok("popup node exists")
	# Excel (Komputer, id 1): 5 soal, jawab benar semua
	if await _open_popup(1, Vector2(400, 400)):
		if str(pop.get("kind")) == "excel":
			_ok("Komputer opens Excel popup")
		else:
			_fail("Komputer kind is " + str(pop.get("kind")) + " expected excel")
		if str(pop.get("title_label").text) == "Laporan Excel":
			_ok("Excel title is Laporan Excel")
		else:
			_fail("Excel title is " + str(pop.get("title_label").text))
		for q in range(5):
			var correct: int = int(pop.get("excel_correct"))
			pop.call("press_number", correct + 1)
			await process_frame
		var komp: Node = _task(1)
		if komp != null and bool(komp.get("done")):
			_ok("Excel: 5 correct answers complete the Komputer task")
		else:
			_fail("Komputer not done after 5 correct answers")
		if not bool(pop.get("open")):
			_ok("popup closed after Excel completes")
		else:
			_fail("popup still open after Excel completes")
	# Simon (Generator, id 0): 3 ronde, ulangi urutan
	if await _open_popup(0, Vector2(736, 400)):
		if str(pop.get("kind")) == "simon":
			_ok("Generator opens Panel Listrik popup")
		else:
			_fail("Generator kind is " + str(pop.get("kind")) + " expected simon")
		for r in range(3):
			pop.set("simon_phase", "input")
			pop.set("simon_input_idx", 0)
			var seq: Array = pop.get("simon_seq")
			for n in seq:
				pop.call("press_number", int(n))
				await process_frame
		var gen: Node = _task(0)
		if gen != null and bool(gen.get("done")):
			_ok("Simon: 3 rounds complete the Generator task")
		else:
			_fail("Generator not done after 3 Simon rounds")
	# Fotokopi (Arsip, id 2): timing SPASI 5 lembar
	if await _open_popup(2, Vector2(190, 560)):
		if str(pop.get("kind")) == "fotokopi":
			_ok("Arsip opens Fotokopi popup")
		else:
			_fail("Arsip kind is " + str(pop.get("kind")) + " expected fotokopi")
		for s in range(5):
			pop.set("foto_marker", float(pop.get("foto_zone")))
			pop.call("press_space")
			await process_frame
		var arsip: Node = _task(2)
		if arsip != null and bool(arsip.get("done")):
			_ok("Fotokopi: 5 sheets complete the Arsip task")
		else:
			_fail("Arsip not done after 5 Fotokopi sheets")
	# Keypad (Pintu Keluar, id 3): kode 4 digit
	if await _open_popup(3, Vector2(800, 760)):
		if str(pop.get("kind")) == "keypad":
			_ok("Pintu Keluar opens Keypad popup")
		else:
			_fail("Pintu Keluar kind is " + str(pop.get("kind")) + " expected keypad")
		var code: Array = pop.get("key_code")
		for d in code:
			pop.call("press_number", int(d))
			await process_frame
		var ext: Node = _task(3)
		if ext != null and bool(ext.get("done")):
			_ok("Keypad: correct 4-digit code completes the Exit task")
		else:
			_fail("Exit not done after correct keypad code")
	# Esc cancels and resets progress (test on a fresh task: use Tuas Sel needs locked, so use a wrong-answer check instead)
	# Wrong Excel answer does not advance: reopen Komputer is done, so test cancel on a new level state via the popup directly
	# Instead: verify Esc closes an open popup and progress resets (open Fotokopi on a done task is blocked; use a direct open)
	pop.call("open_popup", lvl, 2, _task(2), "fotokopi", "Fotokopi", false)
	await process_frame
	await process_frame
	if bool(pop.get("open")):
		_ok("popup opens directly (Esc test setup)")
		pop.set("foto_sheets", 2)
		pop.call("_refresh_progress")
		await process_frame
		var arsip2: Node = _task(2)
		var prog_before := float(arsip2.get("progress"))
		pop.call("close_popup", false)
		await process_frame
		await process_frame
		if not bool(pop.get("open")):
			_ok("Esc path closes the popup")
		else:
			_fail("popup still open after close_popup(false)")
		var prog_after := float(arsip2.get("progress"))
		if prog_after < prog_before:
			_ok("cancel resets task progress (" + str(prog_before) + " -> " + str(prog_after) + ")")
		else:
			_fail("cancel did not reset progress (" + str(prog_before) + " -> " + str(prog_after) + ")")
	else:
		_fail("popup did not open directly for Esc test")
	# Mash (Tuas Sel, id 4): needs a locked player; simulate by setting a locked player
	lvl.call("on_player_caught", player)
	await process_frame
	await process_frame
	if player.get("locked") == true:
		_ok("player locked (Mash test setup)")
		# A second player is needed to open the lever in co-op, but solo self-rescue uses E; the lever popup in solo opens via _task_ready with 1 worker
		player.set("locked", false)
		# Directly open the mash popup to test the mechanic
		pop.call("open_popup", lvl, 4, _task(4), "mash", "Tuas Sel", false)
		await process_frame
		await process_frame
		if str(pop.get("kind")) == "mash":
			_ok("Tuas Sel opens Mash popup")
		else:
			_fail("Tuas Sel kind is " + str(pop.get("kind")) + " expected mash")
		for i in range(14):
			pop.call("press_space")
			await process_frame
		var lever: Node = _task(4)
		if lever != null and bool(lever.get("done")):
			_ok("Mash: 14 SPACE presses complete the Tuas Sel task")
		else:
			_fail("Tuas Sel not done after 14 mash presses (progress=" + str(lever.get("progress")) + ")")
	else:
		_fail("player not locked for Mash test setup")
	_report()

func _report() -> void:
	print("=== POPUP TEST RESULTS ===")
	for r in results:
		print(r)
	var fails := 0
	for r in results:
		if r.begins_with("FAIL"):
			fails += 1
	print("=== POPUP TEST: " + str(results.size() - fails) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
