extends SceneTree

var lvl: Node2D
var player: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	player.global_position = Vector2(400, 400)
	var net: Node = lvl.get_node_or_null("Network")
	if net != null:
		var m: CanvasLayer = net.get("menu")
		if m != null:
			m.visible = false
	if lvl.has_method("show_hud"):
		lvl.call("show_hud")
	if lvl.has_method("_dismiss_intro"):
		lvl.call("_dismiss_intro")
	var intro_dim: Node = lvl.get("intro_dim")
	if intro_dim != null:
		intro_dim.visible = false
	var intro_panel: Node = lvl.get("intro_panel")
	if intro_panel != null:
		intro_panel.visible = false
	var pop: Node = lvl.get("popup")
	# Cari (Gudang) page 1
	pop.call("open_popup", lvl, 5, _task(5), "cari", "Cari Berkas", false)
	for i in range(10):
		await process_frame
	await _shot("/tmp/pop_cari.png")
	# Cari page 2 (flip once to show the page turn works)
	pop.call("_cari_flip", 1)
	for i in range(5):
		await process_frame
	await _shot("/tmp/pop_cari_p2.png")
	pop.call("close_popup", false)
	for i in range(5):
		await process_frame
	quit(0)

func _task(task_id: int) -> Node:
	for tp in lvl.get("tasks"):
		if int(tp.get("task_id")) == task_id:
			return tp
	return null

func _shot(path: String) -> void:
	for i in range(3):
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png(path)
	print("SHOT: " + path)
