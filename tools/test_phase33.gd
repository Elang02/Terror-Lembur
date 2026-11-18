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
	print("PHASE33 FAILS=" + str(fails))
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
	for i in range(5):
		await process_frame
	# HEART-01: heartbeat makin kencang (volume makin besar) saat bos dekat.
	var vol_near: float = lvl.call("_heartbeat_volume", 50.0)
	var vol_far: float = lvl.call("_heartbeat_volume", 300.0)
	if vol_near > vol_far and vol_near > -6.0 and vol_far < -12.0:
		_ok("heartbeat volume scales with distance (near " + str(vol_near) + " dB, far " + str(vol_far) + " dB)")
	else:
		_fail("heartbeat volume wrong (near " + str(vol_near) + ", far " + str(vol_far) + ")")
	# HAUNT-01: event hantu muncul saat bos jauh (>350px).
	player.global_position = Vector2(400, 656)
	player.set("locked", false)
	player.set("hiding", false)
	boss.global_position = Vector2(1328, 272)
	boss.set("state", 0)
	boss.set("teleport_timer", 99999.0)
	boss.set("telegraph_timer", 99999.0)
	boss.set("blind_timer", 999.0)
	var warn_label: Label = lvl.get("hud_warn_label")
	warn_label.text = ""
	lvl.set("warn_timer", 0.0)
	lvl.set("haunt_timer", 0.01)
	for i in range(5):
		await process_frame
	if warn_label.text != "":
		_ok("haunting event fires when boss is far: \"" + warn_label.text + "\"")
	else:
		_fail("no haunting event with boss far")
	# HAUNT-01: event TIDAK muncul saat bos dekat.
	boss.global_position = Vector2(400, 600)
	boss.set("facing", Vector2.UP)
	warn_label.text = ""
	lvl.set("warn_timer", 0.0)
	lvl.set("haunt_timer", 0.01)
	for i in range(5):
		await process_frame
	if warn_label.text == "":
		_ok("no haunting event when boss is near")
	else:
		_fail("haunting event fired with boss near: \"" + warn_label.text + "\"")
	# SNIFF-01: bos PATROL yang lewat dekat pemain ngumpet jadi CURIGA.
	player.global_position = Vector2(400, 656)
	player.set("hiding", true)
	player.set("locked", false)
	boss.global_position = Vector2(400, 586)
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.set("speed_mult", 0.0)
	boss.set("teleport_timer", 99999.0)
	boss.set("telegraph_timer", 0.0)
	boss.set("blind_timer", 999.0)
	boss.set("velocity", Vector2.ZERO)
	for i in range(5):
		await process_frame
	if int(boss.get("state")) == 1:
		_ok("patrolling boss sniffs a hiding player within 100px (PATROL -> SUSPICIOUS)")
	else:
		_fail("boss did not sniff hiding player, state=" + str(boss.get("state")))
	_report()
