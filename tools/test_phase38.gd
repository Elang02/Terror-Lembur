extends SceneTree

var results: Array[String] = []
var lvl: Node2D
var boss: Node2D
var player: Node2D

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
	print("PHASE38 FAILS=" + str(fails))
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
	var ysort: Node = lvl.get_node_or_null("YSort")
	boss = lvl.get("boss")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	# OPEN-01: patroli pertama dari ujung jauh (index 2 = (1328,272)),
	# bukan (272,448) yang 137px dari Komputer. Dicek sebelum frame jalan:
	# _ready sudah memilih target pertama (loop[2]) dan menaikkan index.
	if boss.get("target") == Vector2(1328, 272):
		_ok("first patrol target is far end (1328,272), was (272,448)")
	else:
		_fail("first patrol target is " + str(boss.get("target")))
	for i in range(5):
		await process_frame
	# CHASE-01: kejaran punya wind-up 1 detik — bos diam dulu pas "!",
	# pemain dapat ancang-ancang buat putus pandangan.
	player.global_position = Vector2(700, 656)
	player.set("locked", false)
	player.set("hiding", false)
	player.set("velocity", Vector2.ZERO)
	player.set("flashlight_on", true)
	boss.global_position = Vector2(400, 656)
	boss.set("path", [])
	boss.set("path_index", 0)
	boss.set("facing", Vector2.RIGHT)
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.set("speed_mult", 0.0)
	boss.set("teleport_timer", 99999.0)
	boss.set("telegraph_timer", 0.0)
	boss.set("blind_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)
	for i in range(5):
		await process_frame
	if int(boss.get("state")) == 2 and float(boss.get("chase_windup_timer")) > 0.0 and absf(float(boss.get("CHASE_WINDUP")) - 1.0) < 0.01:
		_ok("chase starts with 1s wind-up (state CHASE, timer armed)")
	else:
		_fail("no chase wind-up: state=" + str(boss.get("state")) + " timer=" + str(boss.get("chase_windup_timer")))
	var start_x := float(boss.global_position.x)
	boss.set("speed_mult", 1.0)
	# Wind-up di-arm ulang ke 1.0 detik penuh: entry-nya sudah terbukti di
	# atas, pengukuran diam-vs-lari harus dari timer yang utuh.
	boss.set("chase_windup_timer", 1.0)
	for i in range(5):
		await process_frame
	var moved_during_windup := absf(float(boss.global_position.x) - start_x)
	if moved_during_windup < 5.0:
		_ok("boss stands still during wind-up (moved " + str(moved_during_windup) + "px)")
	else:
		_fail("boss moved " + str(moved_during_windup) + "px during wind-up")
	# Habis wind-up: paksa timer hampir habis biar nggak tergantung
	# hitungan frame, lalu pastikan bos langsung lari.
	boss.set("chase_windup_timer", 0.01)
	for i in range(5):
		await process_frame
	var moved_after := absf(float(boss.global_position.x) - start_x)
	if moved_after > 50.0 and not bool(player.get("locked")):
		_ok("boss runs after wind-up (moved " + str(moved_after) + "px, player not caught yet)")
	else:
		_fail("boss did not run after wind-up: moved " + str(moved_after) + "px, locked=" + str(player.get("locked")))
	# SHOUT-01: di solo, hint teriak jujur soal harganya.
	player.set("has_throwable", false)
	player.global_position = Vector2(400, 656)
	for i in range(5):
		await process_frame
	var prompt_label: Label = lvl.get("hud_prompt_label")
	if prompt_label.text.contains("bos datang ke kamu"):
		_ok("solo shout hint warns: \"" + prompt_label.text + "\"")
	else:
		_fail("solo shout hint does not warn: \"" + prompt_label.text + "\"")
	_report()
