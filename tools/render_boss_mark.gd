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
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	_hide_layers(lvl)
	var boss: Node2D = null
	var ysort: Node = lvl.get_node_or_null("YSort")
	if ysort != null:
		for child in ysort.get_children():
			if child.name == "Boss":
				boss = child
				break
	if boss == null:
		print("RENDER FAIL: boss not found")
		quit(1)
		return
	boss.set("state", 2)
	boss.call("_refresh_mark")
	var mark: Label = boss.get_node_or_null("Tanda")
	print("MARK TEXT: '", mark.text if mark != null else "NULL", "'")
	var cam := Camera2D.new()
	cam.position = boss.global_position
	cam.zoom = Vector2(3, 3)
	lvl.add_child(cam)
	cam.make_current()
	for i in range(5):
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png("/home/hatch/workspace/user/files/terror-lembur-boss-mark.png")
	print("RENDER OK: mark saved")
	quit(0)
