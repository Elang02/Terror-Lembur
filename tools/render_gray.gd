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
	_hide_layers(lvl)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	var p1 := pscene.instantiate() as Node2D
	p1.name = "1"
	ysort.add_child(p1, true)
	await process_frame
	await process_frame
	p1.global_position = Vector2(800, 760)
	var cam := Camera2D.new()
	cam.position = Vector2(800, 700)
	cam.zoom = Vector2(1.2, 1.2)
	lvl.add_child(cam)
	cam.make_current()
	for i in range(5):
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png("/home/hatch/workspace/user/files/terror-lembur-gray-test.png")
	print("RENDER OK: lobby saved")
	quit(0)
