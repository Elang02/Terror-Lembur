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
	var astar: AStarGrid2D = lvl.get("astar")
	for y in range(14, 19):
		var row := "y=" + str(y) + ": "
		for x in range(18, 26):
			var solid := astar.is_point_solid(Vector2i(x, y))
			row += ("#" if solid else ".")
		print(row)
	var wall_layer: TileMapLayer = lvl.get("wall_layer_ref")
	for y in range(14, 19):
		var row := "wall y=" + str(y) + ": "
		for x in range(18, 26):
			var cell := wall_layer.get_cell_source_id(Vector2i(x, y))
			row += (str(cell) if cell >= 0 else ".")
		print(row)
	quit(0)
