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
	# Excel (Komputer, id 1): 7 soal, jawab benar semua
	if await _open_popup(1, Vector2(400, 400)):
		if str(pop.get("kind")) == "excel":
			_ok("Komputer opens Excel popup")
		else:
			_fail("Komputer kind is " + str(pop.get("kind")) + " expected excel")
		if str(pop.get("title_label").text) == "Laporan Excel":
			_ok("Excel title is Laporan Excel")
		else:
			_fail("Excel title is " + str(pop.get("title_label").text))
		for q in range(7):
			var answer: int = int(pop.get("excel_answer"))
			for ch in str(answer):
				pop.call("press_digit", int(ch))
				await process_frame
			pop.call("_submit_excel")
			await process_frame
		var komp: Node = _task(1)
		if komp != null and bool(komp.get("done")):
			_ok("Excel: 7 correct answers complete the Komputer task")
		else:
			_fail("Komputer not done after 7 correct answers")
		if not bool(pop.get("open")):
			_ok("popup closed after Excel completes")
		else:
			_fail("popup still open after Excel completes")
	# Simon (Generator, id 0): 4 ronde, ulangi urutan
	if await _open_popup(0, Vector2(736, 400)):
		if str(pop.get("kind")) == "simon":
			_ok("Generator opens Panel Listrik popup")
		else:
			_fail("Generator kind is " + str(pop.get("kind")) + " expected simon")
		for r in range(4):
			pop.set("simon_phase", "input")
			pop.set("simon_input_idx", 0)
			var seq: Array = pop.get("simon_seq")
			for n in seq:
				pop.call("press_number", int(n))
				await process_frame
		var gen: Node = _task(0)
		if gen != null and bool(gen.get("done")):
			_ok("Simon: 4 rounds complete the Generator task")
		else:
			_fail("Generator not done after 4 Simon rounds")
	# Fotokopi (Arsip, id 2): timing SPASI 7 lembar
	if await _open_popup(2, Vector2(190, 560)):
		if str(pop.get("kind")) == "fotokopi":
			_ok("Arsip opens Fotokopi popup")
		else:
			_fail("Arsip kind is " + str(pop.get("kind")) + " expected fotokopi")
		for s in range(7):
			pop.set("foto_marker", float(pop.get("foto_zone")))
			pop.call("press_space")
			await process_frame
		var arsip: Node = _task(2)
		if arsip != null and bool(arsip.get("done")):
			_ok("Fotokopi: 7 sheets complete the Arsip task")
		else:
			_fail("Arsip not done after 7 Fotokopi sheets")
	# Cari (Gudang, id 5): 3 ronde cari berkas
	if await _open_popup(5, Vector2(128, 176)):
		if str(pop.get("kind")) == "cari":
			_ok("Gudang opens Cari Berkas popup")
		else:
			_fail("Gudang kind is " + str(pop.get("kind")) + " expected cari")
		for r in range(3):
			var tpage: int = int(pop.get("cari_target_page"))
			var tslot: int = int(pop.get("cari_target_slot"))
			while int(pop.get("cari_page")) != tpage:
				pop.call("_cari_flip", 1 if tpage > int(pop.get("cari_page")) else -1)
				await process_frame
			if int(pop.get("cari_page")) != tpage:
				_fail("Cari: page flip did not reach target page")
			pop.call("press_number", tslot)
			await process_frame
		var gudang: Node = _task(5)
		if gudang != null and bool(gudang.get("done")):
			_ok("Cari: 3 rounds complete the Gudang task")
		else:
			_fail("Gudang not done after 3 Cari rounds")
	# Urut (Rapat, id 6): urutkan 5 tanggal
	if await _open_popup(6, Vector2(700, 128)):
		if str(pop.get("kind")) == "urut":
			_ok("Rapat opens Catatan Rapat popup")
		else:
			_fail("Rapat kind is " + str(pop.get("kind")) + " expected urut")
		for p in range(5):
			var dates: Array = pop.get("urut_dates")
			var disp: Array = pop.get("urut_display")
			var nxt: int = int(pop.get("urut_next"))
			var target_date: int = int(dates[nxt])
			var pos := disp.find(target_date) + 1
			pop.call("press_number", pos)
			await process_frame
		var rapat: Node = _task(6)
		if rapat != null and bool(rapat.get("done")):
			_ok("Urut: 5 dates in order complete the Rapat task")
		else:
			_fail("Rapat not done after 5 Urut picks")
	# Keypad (Pintu Keluar, id 3): kode 5 digit
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
			_ok("Keypad: correct 5-digit code completes the Exit task")
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
		for i in range(20):
			pop.call("press_space")
			await process_frame
		var lever: Node = _task(4)
		if lever != null and bool(lever.get("done")):
			_ok("Mash: 20 SPACE presses complete the Tuas Sel task")
		else:
			_fail("Tuas Sel not done after 20 mash presses (progress=" + str(lever.get("progress")) + ")")
	else:
		_fail("player not locked for Mash test setup")
	# Code digits: keypad code comes from the tasks, not random
	var digits: Array = lvl.get("code_digits")
	var found: Array = lvl.get("code_found")
	if digits.size() == 5:
		_ok("code has 5 digits")
	else:
		_fail("code has " + str(digits.size()) + " digits, expected 5")
	var all_in_range := true
	for d in digits:
		if int(d) < 1 or int(d) > 4:
			all_in_range = false
	if all_in_range:
		_ok("all code digits are 1-4")
	else:
		_fail("code digit out of range: " + str(digits))
	# All 5 main tasks are done by now, so all 5 digits must be revealed
	var all_found := true
	for f in found:
		if not bool(f):
			all_found = false
	if all_found:
		_ok("all 5 code digits revealed after the 5 main tasks")
	else:
		_fail("code_found not all true after main tasks: " + str(found))
	# CODE-01 (Phase 43): the code label shows ONLY the latest revealed
	# digit for 10 s, then hides. Memory-only is preserved: no full code,
	# no re-check.
	var code_label: Label = lvl.get("hud_code_label")
	if code_label != null and code_label.text.contains("Digit ke-"):
		_ok("code label shows a single latest digit")
	else:
		_fail("code label wrong (label: '" + ("" if code_label == null else code_label.text) + "')")
	lvl.set("code_timer", 0.05)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	if code_label != null and not code_label.visible:
		_ok("code label hides after timer (no re-check)")
	else:
		_fail("code label still visible after timer")
	# Keypad uses the level code (reopen exit popup and compare)
	pop.call("open_popup", lvl, 3, _task(3), "keypad", "Keypad Pintu", false)
	await process_frame
	await process_frame
	var kcode: Array = pop.get("key_code")
	var same := kcode.size() == 5
	for i in range(5):
		if int(kcode[i]) != int(digits[i]):
			same = false
	if same:
		_ok("keypad code equals the level code from tasks")
	else:
		_fail("keypad code " + str(kcode) + " != level code " + str(digits))
	# Wrong code does NOT regenerate the code (player must remember it)
	var wrong_digit := 1
	if int(kcode[0]) == 1:
		wrong_digit = 2
	for i in range(5):
		pop.call("press_number", wrong_digit)
		await process_frame
	var kcode_after: Array = pop.get("key_code")
	var unchanged := true
	for i in range(5):
		if int(kcode_after[i]) != int(digits[i]):
			unchanged = false
	if unchanged:
		_ok("wrong code does not regenerate the code")
	else:
		_fail("code changed after wrong entry: " + str(kcode_after))
	pop.call("close_popup", false)
	await process_frame
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
