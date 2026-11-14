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
	# Excel (Komputer) - CRT terminal
	pop.call("open_popup", lvl, 1, _task(1), "excel", "Laporan Excel", false)
	for i in range(10):
		await process_frame
	await _shot("/tmp/pop_excel.png")
	pop.call("close_popup", false)
	for i in range(5):
		await process_frame
	# Simon (Generator) - rusted panel, show phase with a lit lamp
	pop.call("open_popup", lvl, 0, _task(0), "simon", "Panel Listrik", false)
	for i in range(30):
		await process_frame
	await _shot("/tmp/pop_simon.png")
	pop.call("close_popup", false)
	for i in range(5):
		await process_frame
	# Fotokopi (Arsip)
	pop.call("open_popup", lvl, 2, _task(2), "fotokopi", "Fotokopi", false)
	for i in range(10):
		await process_frame
	await _shot("/tmp/pop_foto.png")
	pop.call("close_popup", false)
	for i in range(5):
		await process_frame
	# Keypad (Pintu Keluar)
	lvl.set("code_digits", [2, 3, 2, 4])
	lvl.set("code_found", [true, true, true, true])
	pop.call("open_popup", lvl, 3, _task(3), "keypad", "Keypad Pintu", false)
	for i in range(10):
		await process_frame
	await _shot("/tmp/pop_keypad.png")
	pop.call("close_popup", false)
	for i in range(5):
		await process_frame
	# Mash (Tuas Sel)
	player.set("locked", true)
	pop.call("open_popup", lvl, 4, _task(4), "mash", "Tuas Sel", false)
	for i in range(10):
		await process_frame
	await _shot("/tmp/pop_mash.png")
	print("POPSHOTS done")
	quit(0)

func _task(task_id: int) -> Node:
	for tp in lvl.get("tasks"):
		if tp.get("task_id") == task_id:
			return tp
	return null

func _shot(path: String) -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	cam.zoom = Vector2(1, 1)
	root.add_child(cam)
	cam.make_current()
	for i in range(5):
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png(path)
	print("saved " + path)
	cam.queue_free()
