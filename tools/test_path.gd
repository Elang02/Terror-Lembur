extends SceneTree

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	var lvl := scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run", lvl)

func _run(lvl: Node2D) -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var from := Vector2(190, 560)
	var to := Vector2(736, 400)
	var path: PackedVector2Array = lvl.call("find_path", from, to)
	print("PATH archive->generator: " + str(path.size()) + " points")
	for i in range(mini(path.size(), 20)):
		print("  [" + str(i) + "] " + str(path[i]))
	var from2 := Vector2(1050, 550)
	var path2: PackedVector2Array = lvl.call("find_path", from2, to)
	print("PATH (1050,550)->generator: " + str(path2.size()) + " points")
	for i in range(mini(path2.size(), 20)):
		print("  [" + str(i) + "] " + str(path2[i]))
	quit(0)
