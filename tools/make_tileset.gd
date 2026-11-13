extends SceneTree

# One-off tool: builds office_tileset.tres.
# Floor: Imersa office pack (3 tiles). Walls: Gridwright Modern Office & Home
# free sample, painted wall autotile set (47 tiles, 32x32, 2x sheet).
# Run: godot --headless --path . --script res://tools/make_tileset.gd
# Wall atlas: 256x192, 8 cols x 6 rows; cell (7,5) is empty.
# All wall tiles get a full-tile collision polygon on physics layer 0.
# Gridwright bitmask (N=1 NE=2 E=4 SE=8 S=16 SW=32 W=64 NW=128) is handled
# at runtime by level_1.gd _autotile_walls(); this tool only builds the atlas.

const FLOOR_TEX := "res://assets/office_assets/main/Office_Pixel_Art_Free_v1.0/Tilesets/Floors/office_floors_tileset.png"
const WALL_TEX := "res://assets/gridwright_walls_paint.png"
const OUT_PATH := "res://office_tileset.tres"
const TILE := Vector2i(32, 32)

func _init() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)

	var floor_tex := load(FLOOR_TEX) as Texture2D
	if floor_tex == null:
		push_error("cannot load floor texture")
		quit(1)
		return
	var floor_source := TileSetAtlasSource.new()
	floor_source.texture = floor_tex
	floor_source.texture_region_size = TILE
	var floor_id := tile_set.add_source(floor_source)
	for i in range(3):
		floor_source.create_tile(Vector2i(i, 0))

	var wall_tex := load(WALL_TEX) as Texture2D
	if wall_tex == null:
		push_error("cannot load wall texture")
		quit(1)
		return
	var wall_source := TileSetAtlasSource.new()
	wall_source.texture = wall_tex
	wall_source.texture_region_size = TILE
	var wall_id := tile_set.add_source(wall_source)
	var poly := PackedVector2Array([Vector2(0, 0), Vector2(32, 0), Vector2(32, 32), Vector2(0, 32)])
	var made := 0
	for y in range(6):
		for x in range(8):
			if x == 7 and y == 5:
				continue
			var coords := Vector2i(x, y)
			wall_source.create_tile(coords)
			var tile_data := wall_source.get_tile_data(coords, 0)
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(0, 0, poly)
			made += 1
	print("wall tiles made: ", made)

	print("floor source id: ", floor_id, " wall source id: ", wall_id)
	var err := ResourceSaver.save(tile_set, OUT_PATH)
	print("save: ", err, " -> ", OUT_PATH)
	quit()
