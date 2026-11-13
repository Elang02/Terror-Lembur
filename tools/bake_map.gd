extends SceneTree

# One-off tool: bakes the code-built TileMapLayers (FloorLayer + WallLayer)
# into scenes/level_1.tscn as real nodes, so the map is editable in the
# Godot editor's TileMap editor. Run:
#   godot --headless --path . --script res://tools/bake_map.gd
# After baking, level_1.gd _ready() uses the baked layers and no longer
# rebuilds floor/walls/partitions at runtime.

const OUT_PATH := "res://scenes/level_1.tscn"

func _init() -> void:
	var level_script := load("res://scripts/level_1.gd") as GDScript
	if level_script == null:
		push_error("cannot load level_1.gd")
		quit(1)
		return
	var lvl := level_script.new() as Node2D
	lvl.name = "Level1"
	lvl._build_tilemap_layers()
	var floor_layer := lvl.get_node("FloorLayer") as TileMapLayer
	var wall_layer := lvl.get_node("WallLayer") as TileMapLayer
	if floor_layer == null or wall_layer == null:
		push_error("tilemap layers not built")
		quit(1)
		return
	print("floor cells: ", floor_layer.get_used_cells().size())
	print("wall cells: ", wall_layer.get_used_cells().size())

	var ysort := Node2D.new()
	ysort.name = "YSort"
	ysort.y_sort_enabled = true
	lvl.add_child(ysort)
	var spawner := MultiplayerSpawner.new()
	spawner.name = "Spawner"
	spawner.spawn_path = NodePath("../YSort")
	lvl.add_child(spawner)
	var network := Node.new()
	network.name = "Network"
	network.set_script(load("res://scripts/network.gd"))
	lvl.add_child(network)
	for child in lvl.get_children():
		child.owner = lvl

	var packed := PackedScene.new()
	var err := packed.pack(lvl)
	if err != OK:
		push_error("pack failed: " + str(err))
		quit(1)
		return
	err = ResourceSaver.save(packed, OUT_PATH)
	print("save: ", err, " -> ", OUT_PATH)
	quit()
