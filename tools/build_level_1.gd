extends Node
## Generator Level 1 — JANGAN dijalankan dari dalam game.
## Cara pakai (dari folder project, Godot 4.4+):
##   godot --headless --import
##   godot --headless res://tools/build_level_1.tscn
## Dijalankan sebagai scene (bukan -s) supaya Autoload (NetworkManager /
## GameProgress) ikut dimuat dan semua script bisa dikompilasi.
##
## Membaca levels/level_1_grid.txt (64x40, sumber kebenaran layout),
## membuat assets/tiles/office_tileset.tres (TileSet + collision),
## lalu membangun scenes/level_1.tscn (3 TileMapLayer + node gameplay).
## Kalau layout diubah di file grid, jalankan ulang generator ini.
## Kalau layout diubah di editor (TileMap), TIDAK perlu generator lagi —
## scene hasil generator sepenuhnya bisa diedit di editor.

const GRID_PATH: String = "res://levels/level_1_grid.txt"
const ATLAS_PATH: String = "res://assets/tiles/office_atlas.png"
const TILESET_PATH: String = "res://assets/tiles/office_tileset.tres"
const SCENE_PATH: String = "res://scenes/level_1.tscn"
const TILE: int = 32

# Atlas office_atlas.png (8x2 tile @32px, dari aset itch.io — lihat
# docs/MAP_LEVEL_1.md dan tools/build_office_atlas.py).
const FLOOR_TILES: Dictionary = {
	".": Vector2i(0, 0),  # karpet kantor
	",": Vector2i(1, 0),  # koridor
	":": Vector2i(2, 0),  # ubin terang (pantry/toilet)
	";": Vector2i(3, 0),  # lantai server
}
const WALL_TILE: Vector2i = Vector2i(6, 0)
const WALL_OUTER_TILE: Vector2i = Vector2i(7, 0)
const PROP_TILES: Dictionary = {
	"D": Vector2i(0, 1),  # meja + monitor
	"S": Vector2i(1, 1),  # rak/lemari
	"T": Vector2i(2, 1),  # meja rapat
	"P": Vector2i(3, 1),  # tanaman
	"R": Vector2i(4, 1),  # rak server
	"F": Vector2i(5, 1),  # sofa
	"B": Vector2i(6, 1),  # tumpukan boks
	"C": Vector2i(7, 1),  # counter
	"H": Vector2i(0, 2),  # kursi kantor
	"W": Vector2i(1, 2),  # dispenser air
	"K": Vector2i(2, 2),  # printer
	"U": Vector2i(3, 2),  # whiteboard
	"N": Vector2i(4, 2),  # tanaman tinggi
	"V": Vector2i(5, 2),  # flip chart
	"G": Vector2i(6, 2),  # tempat sampah
	"M": Vector2i(7, 2),  # tumpukan kertas
}
const RUG_TILE: Vector2i = Vector2i(4, 0)


func _ready() -> void:
	var ok: bool = _run()
	if not ok:
		printerr("Generator Level 1 GAGAL.")
	get_tree().quit(0 if ok else 1)


func _run() -> bool:
	var atlas: Texture2D = load(ATLAS_PATH)
	if atlas == null:
		printerr("GAGAL: atlas tidak ditemukan: ", ATLAS_PATH, " (jalankan --import dulu)")
		return false
	var grid: Array[String] = _read_grid()
	if grid.is_empty():
		printerr("GAGAL: grid tidak terbaca: ", GRID_PATH)
		return false
	var tileset: TileSet = _build_tileset(atlas)
	var err: Error = ResourceSaver.save(tileset, TILESET_PATH)
	if err != OK:
		printerr("GAGAL menyimpan TileSet: ", err)
		return false
	tileset = load(TILESET_PATH)
	print("TileSet tersimpan: ", TILESET_PATH)
	var root: Node2D = _build_scene(tileset, grid)
	var packed := PackedScene.new()
	var pack_err: Error = packed.pack(root)
	if pack_err != OK:
		printerr("GAGAL pack scene: ", pack_err)
		return false
	err = ResourceSaver.save(packed, SCENE_PATH)
	if err != OK:
		printerr("GAGAL menyimpan scene: ", err)
		return false
	print("Scene tersimpan: ", SCENE_PATH)
	return true


func _read_grid() -> Array[String]:
	var out: Array[String] = []
	var f: FileAccess = FileAccess.open(GRID_PATH, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.is_empty() and f.eof_reached():
			break
		while line.length() < 64:
			line += " "
		out.append(line.left(64))
	f.close()
	print("Grid: %d baris x 64 kolom" % out.size())
	return out


func _build_tileset(atlas: Texture2D) -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)
	var source := TileSetAtlasSource.new()
	source.texture = atlas
	source.texture_region_size = Vector2i(TILE, TILE)
	# PENTING: source harus sudah masuk TileSet SEBELUM TileData diisi,
	# karena jumlah physics layer TileData mengikuti TileSet induknya.
	tileset.add_source(source, 0)
	var solid: Dictionary = {}
	for c: Vector2i in [WALL_TILE, WALL_OUTER_TILE]:
		solid[c] = true
	for c: Vector2i in PROP_TILES.values():
		solid[c] = true
	var all_coords: Array[Vector2i] = []
	for c: Vector2i in FLOOR_TILES.values():
		all_coords.append(c)
	all_coords.append(RUG_TILE)
	all_coords.append(WALL_TILE)
	all_coords.append(WALL_OUTER_TILE)
	for c: Vector2i in PROP_TILES.values():
		all_coords.append(c)
	for coord: Vector2i in all_coords:
		source.create_tile(coord)
		if solid.has(coord):
			var td: TileData = source.get_tile_data(coord, 0)
			td.set_collision_polygons_count(0, 1)
			# Poligon penuh 1 tile, origin di tengah tile.
			td.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
			]))
	return tileset


func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * TILE + Vector2(TILE, TILE) * 0.5


func _build_scene(tileset: TileSet, grid: Array[String]) -> Node2D:
	var root := Node2D.new()
	root.name = "Level1"
	root.set_script(load("res://scripts/level_1.gd"))

	var modulate := CanvasModulate.new()
	modulate.name = "CanvasModulate"
	modulate.color = Color(0.26, 0.26, 0.34)
	root.add_child(modulate)

	var floor_layer := TileMapLayer.new()
	floor_layer.name = "Floor"
	floor_layer.tile_set = tileset
	floor_layer.z_index = -10
	root.add_child(floor_layer)
	var walls_layer := TileMapLayer.new()
	walls_layer.name = "Walls"
	walls_layer.tile_set = tileset
	walls_layer.z_index = -5
	root.add_child(walls_layer)
	var props_layer := TileMapLayer.new()
	props_layer.name = "Props"
	props_layer.tile_set = tileset
	props_layer.z_index = 5
	root.add_child(props_layer)

	var counts: Dictionary = {"floor": 0, "walls": 0, "props": 0}
	for y: int in range(grid.size()):
		var row: String = grid[y]
		for x: int in range(64):
			var ch: String = row.substr(x, 1)
			var cell := Vector2i(x, y)
			if ch == " ":
				continue
			# Floor: semua cell playable kecuali dinding & prop murni.
			if FLOOR_TILES.has(ch):
				var ft: Vector2i = FLOOR_TILES[ch]
				# Karpet merah di tengah Lobby.
				if ch == "." and x >= 34 and x <= 38 and y == 34:
					ft = RUG_TILE
				floor_layer.set_cell(cell, 0, ft)
				counts["floor"] += 1
			elif ch == "A":
				floor_layer.set_cell(cell, 0, FLOOR_TILES["."])
				counts["floor"] += 1
			elif ch == "E":
				floor_layer.set_cell(cell, 0, FLOOR_TILES[","])
				counts["floor"] += 1
			elif ch == "#":
				floor_layer.set_cell(cell, 0, FLOOR_TILES["."])
				counts["floor"] += 1
				var wt: Vector2i = WALL_OUTER_TILE if (x == 0 or y == 0 or x == 63 or y == 39) else WALL_TILE
				walls_layer.set_cell(cell, 0, wt)
				counts["walls"] += 1
			elif PROP_TILES.has(ch):
				floor_layer.set_cell(cell, 0, FLOOR_TILES["."])
				counts["floor"] += 1
				props_layer.set_cell(cell, 0, PROP_TILES[ch])
				counts["props"] += 1
	print("Tile terpasang — Floor: %d, Walls: %d, Props: %d" % [counts["floor"], counts["walls"], counts["props"]])

	# Dekorasi overlay (nacl1234, tanpa collision) — menempel di atas
	# cell prop yang sudah solid, jadi tidak mengubah pathfinding.
	var decor := Node2D.new()
	decor.name = "Decor"
	root.add_child(decor)
	var decor_defs: Array = [
		["res://assets/decor/fridge.png", Vector2i(11, 2)],
		["res://assets/decor/copier.png", Vector2i(47, 15)],
		["res://assets/decor/ups.png", Vector2i(41, 16)],
		["res://assets/decor/tower.png", Vector2i(25, 33)],
		["res://assets/decor/palm.png", Vector2i(59, 36)],
		["res://assets/decor/partition.png", Vector2i(25, 22)],
	]
	for dd: Array in decor_defs:
		var tex: Texture2D = load(String(dd[0]))
		var sp := Sprite2D.new()
		sp.name = "Decor_" + String(dd[0]).get_file().get_basename()
		sp.texture = tex
		sp.z_index = 6
		# Dasar sprite menempel di dasar cell (+2px overlap).
		sp.position = _cell_center(dd[1]) + Vector2(0, 18.0 - tex.get_height() * 0.5)
		decor.add_child(sp)

	# Label nama ruangan (kosmetik).
	var labels := Node2D.new()
	labels.name = "Labels"
	root.add_child(labels)
	var room_labels: Array = [
		["Gudang", Vector2i(4, 4)], ["Pantry", Vector2i(14, 3)],
		["R. Istirahat", Vector2i(25, 3)], ["R. Rapat", Vector2i(36, 7)],
		["R. Manager", Vector2i(47, 4)], ["R. Keuangan", Vector2i(58, 3)],
		["Toilet", Vector2i(4, 15)], ["R. Arsip", Vector2i(4, 22)],
		["AREA KERJA", Vector2i(20, 13)], ["R. HR", Vector2i(59, 18)],
		["R. Serbaguna", Vector2i(14, 36)], ["R. Server", Vector2i(27, 33)],
		["Lobby", Vector2i(36, 33)], ["Resepsionis", Vector2i(52, 34)],
		["R. Fotokopi", Vector2i(47, 19)],
	]
	for row2: Array in room_labels:
		var lab := Label.new()
		lab.text = String(row2[0])
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.add_theme_font_size_override("font_size", 13)
		lab.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
		lab.position = _cell_center(row2[1]) + Vector2(-50, -8)
		lab.size = Vector2(100, 16)
		lab.z_index = 7
		labels.add_child(lab)

	# Lampu langit-langit (pojok tanpa lampu = gelap, sesuai desain).
	var lights := Node2D.new()
	lights.name = "Lights"
	root.add_child(lights)
	var light_tex: Texture2D = load("res://assets/sprites/light_soft.png")
	var light_defs: Array = [
		[Vector2i(20, 11), 0.9, 2.2], [Vector2i(40, 11), 0.9, 2.2],
		[Vector2i(20, 18), 0.8, 2.0], [Vector2i(35, 18), 0.8, 2.0],
		[Vector2i(50, 24), 0.8, 2.0], [Vector2i(36, 34), 0.9, 2.2],
		[Vector2i(36, 4), 0.8, 2.0], [Vector2i(25, 34), 0.8, 2.0],
		[Vector2i(14, 4), 0.7, 1.8], [Vector2i(4, 24), 0.7, 1.8],
		[Vector2i(59, 16), 0.7, 1.8], [Vector2i(48, 5), 0.6, 1.6],
	]
	for ld: Array in light_defs:
		var pl := PointLight2D.new()
		pl.position = _cell_center(ld[0])
		pl.texture = light_tex
		pl.color = Color(1, 0.88, 0.65)
		pl.energy = float(ld[1])
		pl.texture_scale = float(ld[2])
		lights.add_child(pl)

	# Marker spawn & patrol.
	var spawns := Node2D.new()
	spawns.name = "Spawns"
	root.add_child(spawns)
	_add_marker(spawns, "PlayerSpawn1", Vector2i(35, 34))
	_add_marker(spawns, "PlayerSpawn2", Vector2i(37, 34))
	var enemy_spawns: Array[Vector2i] = [Vector2i(4, 3), Vector2i(58, 4), Vector2i(4, 27), Vector2i(27, 36), Vector2i(59, 14), Vector2i(36, 7), Vector2i(12, 36), Vector2i(57, 34)]
	for i: int in range(enemy_spawns.size()):
		_add_marker(spawns, "EnemySpawn%d" % (i + 1), enemy_spawns[i])
	var patrol: Array[Vector2i] = [Vector2i(11, 11), Vector2i(30, 11), Vector2i(53, 11), Vector2i(53, 26), Vector2i(30, 27), Vector2i(11, 27), Vector2i(11, 18), Vector2i(53, 18)]
	for i: int in range(patrol.size()):
		_add_marker(spawns, "Patrol%d" % (i + 1), patrol[i])
	var revive_pts: Array[Vector2i] = [Vector2i(5, 6), Vector2i(58, 7), Vector2i(11, 35), Vector2i(57, 33), Vector2i(25, 12), Vector2i(49, 27), Vector2i(33, 7), Vector2i(4, 16)]
	for i: int in range(revive_pts.size()):
		_add_marker(spawns, "Revive%d" % (i + 1), revive_pts[i])

	# Tugas (7).
	var tasks := Node2D.new()
	tasks.name = "Tasks"
	root.add_child(tasks)
	var task_scene: PackedScene = load("res://scenes/task_station.tscn")
	var task_defs: Array = [
		["pc_koridor", "PC Koridor", Vector2i(15, 11), &"excel", false, Color(1, 0.85, 0.35)],
		["pc_barat", "PC Workspace Barat", Vector2i(15, 16), &"slides", false, Color(1, 0.85, 0.35)],
		["pc_tengah", "PC Workspace Tengah", Vector2i(25, 16), &"email", false, Color(1, 0.85, 0.35)],
		["pc_fotokopi", "PC Fotokopi", Vector2i(46, 16), &"copy", false, Color(1, 0.85, 0.35)],
		["arsip", "Arsip Dokumen", Vector2i(3, 24), &"archive", false, Color(1, 0.6, 0.3)],
		["listrik", "Panel Listrik", Vector2i(40, 18), &"simon", false, Color(0.4, 0.85, 1)],
		["server", "Server (Co-op)", Vector2i(23, 35), &"server", true, Color(0.75, 0.55, 1)],
	]
	for td: Array in task_defs:
		var st: Node2D = task_scene.instantiate()
		st.name = "Task_" + String(td[0])
		st.position = _cell_center(td[2])
		st.task_id = StringName(td[0])
		st.title = String(td[1])
		st.game_type = td[3]
		st.requires_two = bool(td[4])
		st.accent = td[5]
		tasks.add_child(st)

	# Tempat sembunyi (10).
	var spots := Node2D.new()
	spots.name = "HidingSpots"
	root.add_child(spots)
	var spot_scene: PackedScene = load("res://scenes/hiding_spot.tscn")
	var spot_cells: Array[Vector2i] = [Vector2i(6, 5), Vector2i(17, 7), Vector2i(28, 7), Vector2i(60, 6), Vector2i(19, 22), Vector2i(29, 24), Vector2i(49, 18), Vector2i(6, 26), Vector2i(11, 37), Vector2i(55, 34)]
	for i: int in range(spot_cells.size()):
		var sp: Node2D = spot_scene.instantiate()
		sp.name = "Hide_%d" % (i + 1)
		sp.position = _cell_center(spot_cells[i])
		sp.spot_id = StringName("hide_%d" % (i + 1))
		spots.add_child(sp)

	# Pintu terkunci (2) — posisi = tengah 2 cell.
	var doors := Node2D.new()
	doors.name = "Doors"
	root.add_child(doors)
	var door_scene: PackedScene = load("res://scenes/locked_door.tscn")
	var door_a: Node2D = door_scene.instantiate()
	door_a.name = "DoorA"
	door_a.position = (_cell_center(Vector2i(8, 24)) + _cell_center(Vector2i(8, 25))) * 0.5
	door_a.door_id = "A"
	door_a.door_cells = [Vector2i(8, 24), Vector2i(8, 25)] as Array[Vector2i]
	doors.add_child(door_a)
	var door_b: Node2D = door_scene.instantiate()
	door_b.name = "DoorB"
	door_b.position = (_cell_center(Vector2i(55, 24)) + _cell_center(Vector2i(55, 25))) * 0.5
	door_b.door_id = "B"
	door_b.door_cells = [Vector2i(55, 24), Vector2i(55, 25)] as Array[Vector2i]
	doors.add_child(door_b)

	# Pintu keluar, kurungan, item bangkit.
	var exit_door: Node2D = load("res://scenes/exit_door.tscn").instantiate()
	exit_door.name = "ExitDoor"
	exit_door.position = _cell_center(Vector2i(36, 37))
	root.add_child(exit_door)
	var cage: Node2D = load("res://scenes/cage.tscn").instantiate()
	cage.name = "Cage"
	cage.position = _cell_center(Vector2i(4, 5))
	root.add_child(cage)
	var revive_item: Node2D = load("res://scenes/revive_item.tscn").instantiate()
	revive_item.name = "ReviveItem"
	revive_item.position = _cell_center(Vector2i(25, 12))
	root.add_child(revive_item)

	var players := Node2D.new()
	players.name = "Players"
	root.add_child(players)

	var enemy: Node2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.name = "Enemy"
	enemy.position = _cell_center(Vector2i(4, 3))
	root.add_child(enemy)

	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	hud.name = "HUD"
	root.add_child(hud)

	_set_owners(root, root)
	return root


func _add_marker(parent: Node2D, marker_name: String, cell: Vector2i) -> void:
	var m := Marker2D.new()
	m.name = marker_name
	m.position = _cell_center(cell)
	parent.add_child(m)


func _set_owners(node: Node, owner: Node) -> void:
	# Semua turunan diberi owner = root supaya PackedScene.pack menyimpan
	# semuanya. Catatan: node hasil instantiate() akan tersimpan sebagai
	# salinan (baked) di level_1.tscn, bukan instance. Ini disengaja dan
	# aman di sini karena visual/logika sub-scene hidup di script-nya
	# (yang tetap dishare), bukan di struktur .tscn-nya. Player tidak
	# terpengaruh karena di-spawn saat runtime dari player.tscn.
	for child: Node in node.get_children():
		child.owner = owner
		_set_owners(child, owner)
