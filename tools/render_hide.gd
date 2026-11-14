extends SceneTree

var lvl: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _hide_layers(node: Node) -> void:
	if node is CanvasLayer:
		node.visible = false
	for c in node.get_children():
		_hide_layers(c)

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var player := pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	# Put the player next to a desk, then hide (C)
	player.global_position = Vector2(320, 320)
	for i in range(5):
		await process_frame
	player.call("_toggle_hide")
	for i in range(5):
		await process_frame
	_hide_layers(lvl)
	# Camera close on the hiding player
	var cam := Camera2D.new()
	cam.position = player.global_position
	cam.zoom = Vector2(4.0, 4.0)
	root.add_child(cam)
	cam.make_current()
	for i in range(5):
		await process_frame
	var img := root.get_texture().get_image()
	var path := "/tmp/hide_under_desk.png"
	img.save_png(path)
	print("saved " + path + " hiding=" + str(player.get("hiding")) + " pos=" + str(player.global_position))
	quit(0)
