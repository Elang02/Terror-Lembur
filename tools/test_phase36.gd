extends SceneTree

var results: Array = []
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
	print("PHASE36 FAILS=" + str(fails))
	quit()

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
	for i in range(5):
		await process_frame
	# BAL-08: chase 240 (DbD: killer cuma ~15% lebih cepat dari survivor lari;
	# 240 = 20% lebih cepat dari jalan 200, 20% lebih lambat dari sprint 300).
	if absf(float(boss.get("SPEED_CHASE")) - 240.0) < 0.01:
		_ok("chase speed 240 (was 270)")
	else:
		_fail("chase speed is " + str(boss.get("SPEED_CHASE")))
	# LOS-02: kejaran putus karena LOS hilang -> "Dia kehilangan jejakmu!".
	# Boss di (400,180), pemain di (400,400): tembok y=7 (y=224) di antara mereka.
	player.global_position = Vector2(400, 400)
	player.set("locked", false)
	player.set("hiding", false)
	player.set("velocity", Vector2.ZERO)
	boss.global_position = Vector2(400, 180)
	boss.set("state", 2)
	boss.set("chase_timer", 0.0)
	boss.set("state_timer", 0.0)
	boss.set("speed_mult", 0.0)
	boss.set("teleport_timer", 99999.0)
	boss.set("telegraph_timer", 0.0)
	boss.set("blind_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)
	var warn_label: Label = lvl.get("hud_warn_label")
	warn_label.text = ""
	lvl.set("warn_timer", 0.0)
	for i in range(5):
		await process_frame
	if warn_label.text == "Dia kehilangan jejakmu!":
		_ok("LOS break shows \"Dia kehilangan jejakmu!\"")
	else:
		_fail("no lost-trail cue, warn text is \"" + warn_label.text + "\"")
	# MUG-02: prompt ajarin lempar barang buat mancing bos.
	# Pindah ke koridor terbuka (400,656): jauh dari tugas + meja, bos >400px.
	player.global_position = Vector2(400, 656)
	player.set("has_throwable", true)
	for i in range(5):
		await process_frame
	var prompt_label: Label = lvl.get("hud_prompt_label")
	if prompt_label.text.contains("mancing bos"):
		_ok("mug prompt teaches the lure: \"" + prompt_label.text + "\"")
	else:
		_fail("mug prompt does not teach the lure: \"" + prompt_label.text + "\"")
	_report()
