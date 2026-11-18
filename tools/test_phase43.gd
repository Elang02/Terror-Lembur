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
	print("PHASE43 FAILS=" + str(fails))
	quit(0 if fails == 0 else 1)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	lvl.call("_dismiss_intro")
	var intro_dim: Node = lvl.get("intro_dim")
	if intro_dim != null:
		intro_dim.visible = false
	var intro_panel: Node = lvl.get("intro_panel")
	if intro_panel != null:
		intro_panel.visible = false
	for i in range(5):
		await process_frame
	# CODE-01: label kode terpisah dari label warning. Reveal digit 5 lalu
	# enrage (dulu menimpa pesan digit di frame yang sama) tidak boleh
	# menghapus digit.
	var digits: Array = lvl.get("code_digits")
	var d5 := int(digits[4])
	lvl.call("_reveal_code_digit", 4)
	lvl.call("_enrage_boss")
	for i in range(5):
		await process_frame
	var code_lbl: Label = lvl.get("hud_code_label")
	if code_lbl != null and code_lbl.visible and code_lbl.text.contains(str(d5)):
		_ok("digit 5 survives enrage: '" + code_lbl.text + "'")
	else:
		_fail("digit 5 lost after enrage (label: '" + ("" if code_lbl == null else code_lbl.text) + "')")
	# Warning lain (kejaran putus) tidak boleh menimpa label kode.
	lvl.call("on_boss_lost")
	for i in range(3):
		await process_frame
	if code_lbl != null and code_lbl.visible and code_lbl.text.contains(str(d5)):
		_ok("digit 5 survives a warning")
	else:
		_fail("digit 5 lost after warning")
	# Label kode hilang sendiri setelah 10 detik (memory-only tetap jalan).
	lvl.set("code_timer", 0.05)
	for i in range(5):
		await process_frame
	if code_lbl != null and not code_lbl.visible:
		_ok("code label hides after timer")
	else:
		_fail("code label still visible after timer")
	_report()
