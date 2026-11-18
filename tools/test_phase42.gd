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
	print("PHASE42 FAILS=" + str(fails))
	quit(0 if fails == 0 else 1)

func _check(mult: float, expect: float) -> void:
	lvl.set("boss_speed_mult", mult)
	for i in range(5):
		await process_frame
	var v := float(lvl.get("hud_pressure_bar").value)
	if absf(v - expect) < 1.0:
		_ok("pressure " + str(mult) + "x -> " + str(v) + "% (expect " + str(expect) + "%)")
	else:
		_fail("pressure " + str(mult) + "x -> " + str(v) + "% (expect " + str(expect) + "%)")

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
	# PRESS-01: meter TEKANAN nunjukin eskalasi bos (speed_mult 1.0-1.8
	# dipetakan ke 0-100%), selalu kelihatan biar pemain tahu bos makin
	# agresif tiap tugas selesai.
	var lbl: Label = lvl.get("hud_pressure_label")
	if lbl != null and lbl.text == "TEKANAN":
		_ok("pressure label is TEKANAN")
	else:
		_fail("pressure label missing or wrong")
	await _check(1.0, 0.0)
	await _check(1.5, 62.5)
	await _check(1.8, 100.0)
	_report()
