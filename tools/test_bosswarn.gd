extends SceneTree

var lvl: Node2D
var player: Node2D
var results: Array[String] = []
var fails := 0

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _fail(msg: String) -> void:
	fails += 1
	results.append("FAIL: " + msg)
	print("TEST FAIL: " + msg)

func _ok(msg: String) -> void:
	results.append("OK: " + msg)
	print("TEST OK: " + msg)

func _report() -> void:
	print("RESULT: " + str(results.size() - fails) + "/" + str(results.size()) + " OK")
	quit()

func _pin_boss(pos: Vector2) -> void:
	var boss: Node = lvl.get("boss")
	boss.global_position = pos
	boss.set("teleport_timer", 99999.0)
	boss.set("state", 1)
	boss.set("state_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	await process_frame
	await process_frame
	player.global_position = Vector2(400, 400)
	player.set("interacting", true)
	player.set("interact_target", 1)
	lvl.call("try_open_task_popup", 1)
	await process_frame
	await process_frame
	var pop: Node = lvl.get("popup")
	if pop == null or not bool(pop.get("open")):
		_fail("popup did not open")
		_report()
		return
	var warn: Label = pop.get("boss_warn_label")
	if warn == null:
		_fail("boss_warn_label null")
		_report()
		return
	# 1. Boss jauh (ruang bos) -> warning sembunyi
	_pin_boss(Vector2(1008, 144))
	for i in range(3):
		await process_frame
	if not warn.visible:
		_ok("warning sembunyi pas bos jauh (~660px)")
	else:
		_fail("warning muncul padahal bos jauh: '" + warn.text + "'")
	# 2. Boss 250px -> amber "Bos mendekat..."
	_pin_boss(Vector2(400, 150))
	for i in range(3):
		await process_frame
	if warn.visible and warn.text == "Bos mendekat...":
		_ok("warning amber 'Bos mendekat...' pas bos 250px")
	else:
		_fail("warning amber salah: visible=" + str(warn.visible) + " text='" + warn.text + "'")
	# 3. Boss 100px -> merah "BOS SUDAH SANGAT DEKAT!"
	_pin_boss(Vector2(400, 300))
	for i in range(3):
		await process_frame
	if warn.visible and warn.text == "BOS SUDAH SANGAT DEKAT! Esc buat kabur!":
		_ok("warning merah pas bos 100px")
	else:
		_fail("warning merah salah: visible=" + str(warn.visible) + " text='" + warn.text + "'")
	# 4. Boss pergi lagi -> warning hilang
	_pin_boss(Vector2(1008, 144))
	for i in range(3):
		await process_frame
	if not warn.visible:
		_ok("warning hilang lagi pas bos menjauh")
	else:
		_fail("warning nempel padahal bos sudah jauh")
	_report()
