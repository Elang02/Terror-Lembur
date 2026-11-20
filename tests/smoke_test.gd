extends Node
## Smoke test Level 1 — dijalankan headless:
##   godot --headless --path . res://tests/smoke_test.tscn
## Keluar 0 jika semua cek lolos, 1 jika ada yang gagal.
## Mencakup: load scene, jumlah tile, collision TileMap (raycast + point),
## konektivitas A* (semua tugas & exit terjangkau, pintu tertutup = pintas),
## spawn pemain/enemy, minigame tiap tugas (buka -> selesaikan via input
## asli -> pintu & exit terbuka, batal via Esc), tertangkap -> kurungan
## + item bangkit -> revive, blink enemy -> BLIND.

var _failures: Array[String] = []
var _checks: int = 0


func _ready() -> void:
	await _run()
	print("SMOKE: %d cek, %d gagal" % [_checks, _failures.size()])
	for f: String in _failures:
		print("SMOKE FAIL: ", f)
	if _failures.is_empty():
		print("SMOKE: ALL PASS")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check(cond: bool, label: String) -> void:
	_checks += 1
	if cond:
		print("SMOKE OK: ", label)
	else:
		_failures.append(label)
		print("SMOKE FAIL: ", label)


func _cell(cell: Vector2i) -> Vector2:
	return Vector2(cell) * 32.0 + Vector2(16, 16)


func _solve_minigame(level: Node, layer: Node, tid: StringName, budget: int) -> bool:
	# Menyelesaikan minigame yang sedang terbuka dengan membaca debug_hint()
	# game-nya dan menyuntikkan tombol yang benar, seperti pemain sungguhan.
	var frames: int = 0
	while frames < budget:
		if level.is_task_completed(tid):
			return true
		var game: Node = layer.current_game()
		if game == null or not layer.is_open():
			return level.is_task_completed(tid)
		var hint: Dictionary = game.debug_hint()
		if hint.has("keycode"):
			layer.simulate_key(int(hint["keycode"]))
			await get_tree().physics_frame
		elif hint.has("text"):
			var word: String = String(hint["text"])
			for i: int in range(word.length()):
				layer.simulate_key(0, word.unicode_at(i))
			layer.simulate_key(KEY_ENTER)
			await get_tree().physics_frame
		elif String(hint.get("type", "")) == "zone":
			if game.marker_in_zone():
				layer.simulate_key(KEY_SPACE)
			await get_tree().physics_frame
		elif String(hint.get("type", "")) == "simon":
			if game.awaiting_input():
				for k: int in game.remaining_sequence():
					layer.simulate_key(KEY_1 + k)
					await get_tree().physics_frame
					if not layer.is_open():
						break
			else:
				await get_tree().physics_frame
		else:
			# "wait" (server): lampu belum menyala, tunggu frame berikutnya.
			await get_tree().physics_frame
		frames += 1
	return level.is_task_completed(tid)


func _run() -> void:
	NetworkManager.start_solo()
	var scene: PackedScene = load("res://scenes/level_1.tscn")
	_check(scene != null, "level_1.tscn termuat")
	if scene == null:
		return
	var level: Node2D = scene.instantiate()
	add_child(level)
	for i: int in range(3):
		await get_tree().physics_frame

	# --- Struktur & tile ---
	var floor_layer: TileMapLayer = level.get_node_or_null("Floor")
	var walls_layer: TileMapLayer = level.get_node_or_null("Walls")
	var props_layer: TileMapLayer = level.get_node_or_null("Props")
	_check(floor_layer != null and walls_layer != null and props_layer != null, "3 TileMapLayer ada (Floor/Walls/Props)")
	if floor_layer == null:
		return
	_check(floor_layer.get_used_cells().size() == 2504, "Floor cells = 2504 (dapat %d)" % floor_layer.get_used_cells().size())
	_check(walls_layer.get_used_cells().size() == 445, "Walls cells = 445 (dapat %d)" % walls_layer.get_used_cells().size())
	_check(props_layer.get_used_cells().size() == 308, "Props cells = 308 (dapat %d)" % props_layer.get_used_cells().size())
	var tileset: TileSet = floor_layer.tile_set
	_check(tileset != null, "TileSet terpasang")
	var source: TileSetAtlasSource = tileset.get_source(0) if tileset != null else null
	var td: TileData = source.get_tile_data(Vector2i(6, 0), 0) if source != null else null
	_check(td != null and td.get_collision_polygons_count(0) == 1, "Tile dinding punya 1 poligon collision")

	# --- Collision fisik: raycast menembus dinding harus kena, point query ---
	var space: PhysicsDirectSpaceState2D = level.get_world_2d().direct_space_state
	var ray := PhysicsRayQueryParameters2D.create(_cell(Vector2i(16, 11)), _cell(Vector2i(16, 4)), 1)
	_check(not space.intersect_ray(ray).is_empty(), "Raycast koridor->Pantry terhalang dinding (y=9)")
	var ray2 := PhysicsRayQueryParameters2D.create(_cell(Vector2i(11, 11)), _cell(Vector2i(30, 11)), 1)
	_check(space.intersect_ray(ray2).is_empty(), "Raycast sepanjang koridor tidak terhalang")
	var pq := PhysicsPointQueryParameters2D.new()
	pq.collision_mask = 1
	pq.position = _cell(Vector2i(16, 9))
	_check(not space.intersect_point(pq).is_empty(), "Point query di tengah tile dinding kena collision")
	pq.position = _cell(Vector2i(16, 11))
	_check(space.intersect_point(pq).is_empty(), "Point query di lantai koridor tidak kena collision")
	# Cakupan poligon: 4 titik dekat sudut tile dinding harus kena (origin tengah tile).
	var corner_hits: int = 0
	for off: Vector2 in [Vector2(-13, -13), Vector2(13, -13), Vector2(-13, 13), Vector2(13, 13)]:
		pq.position = _cell(Vector2i(16, 9)) + off
		if not space.intersect_point(pq).is_empty():
			corner_hits += 1
	_check(corner_hits == 4, "Poligon dinding menutup penuh tile (sudut kena %d/4)" % corner_hits)

	# --- A* ---
	var pf: GridPathfinder = level._pathfinder
	_check(pf != null, "GridPathfinder terbentuk")
	if pf != null:
		_check(pf.walkable_point_count() >= 1700, "Titik walkable A* >= 1700 (dapat %d)" % pf.walkable_point_count())
		var spawn: Vector2 = _cell(Vector2i(36, 34))
		var targets: Dictionary = {
			"arsip": _cell(Vector2i(3, 24)), "listrik": _cell(Vector2i(40, 18)),
			"server": _cell(Vector2i(23, 35)), "gudang": _cell(Vector2i(4, 3)),
			"keuangan": _cell(Vector2i(58, 4)), "hr": _cell(Vector2i(58, 16)),
			"exit": _cell(Vector2i(36, 37)),
		}
		for key: String in targets.keys():
			var path: PackedVector2Array = pf.find_path_world(spawn, targets[key])
			_check(not path.is_empty(), "A* spawn->%s ada jalur" % key)
			var through_door: bool = false
			for pt: Vector2 in path:
				var c: Vector2i = Vector2i((pt / 32.0).floor())
				if c in [Vector2i(8, 24), Vector2i(8, 25), Vector2i(55, 24), Vector2i(55, 25)]:
					through_door = true
			_check(not through_door, "A* spawn->%s tidak lewat pintu terkunci" % key)

	# --- Pemain & enemy ---
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	_check(players.size() == 1, "Solo: 1 pemain ter-spawn (dapat %d)" % players.size())
	var player: Node = players[0] if not players.is_empty() else null
	var enemy: Node = level.get_node_or_null("Enemy")
	_check(enemy != null, "Enemy ada di scene")
	if enemy != null:
		_check(enemy.patrol_points.size() == 8, "Patrol points = 8")
		_check(enemy.spawn_points.size() == 8, "Enemy spawn points = 8")
	_check(level._tasks.size() == 7, "Task stations = 7 (dapat %d)" % level._tasks.size())
	_check(level._doors.size() == 2, "Pintu terkunci = 2")
	_check(level._spots.size() == 10, "Tempat sembunyi = 10")

	# --- Minigame tugas -> pintu & exit ---
	# Bekukan enemy supaya tidak menangkap pemain selama tes tugas.
	if enemy != null:
		enemy.set_physics_process(false)
	var layer: Node = level.get_node_or_null("MinigameLayer")
	_check(layer != null, "MinigameLayer ada di level")
	var expected_games: Dictionary = {
		"pc_koridor": "excel", "pc_barat": "slides", "pc_tengah": "email",
		"pc_fotokopi": "copy", "arsip": "archive", "listrik": "simon",
		"server": "server",
	}
	if player != null and layer != null:
		for tid_str: String in expected_games.keys():
			var tid := StringName(tid_str)
			player.global_position = level.task_position(tid)
			await get_tree().physics_frame
			# Tes batal (Esc) sekali, di tugas pertama.
			if tid_str == "pc_koridor":
				level._handle_press(player.peer_id)
				_check(layer.is_open(), "Minigame terbuka saat tekan E di stasiun")
				_check(player.minigame_open, "Gerakan pemain terkunci saat minigame terbuka")
				var esc := InputEventKey.new()
				esc.pressed = true
				esc.keycode = KEY_ESCAPE
				layer._input(esc)
				_check(not layer.is_open(), "Esc menutup minigame")
				_check(not level.is_task_completed(tid), "Tugas belum selesai setelah batal")
				_check(not player.minigame_open, "Gerakan pemain kembali setelah batal")
				player.global_position = level.task_position(tid)
				await get_tree().physics_frame
			level._handle_press(player.peer_id)
			_check(layer.is_open(), "Minigame %s terbuka" % tid_str)
			var game: Node = layer.current_game()
			_check(game != null and String(game.get_script().resource_path).ends_with("mg_%s.gd" % String(expected_games[tid_str])), "Minigame %s memakai mg_%s.gd" % [tid_str, String(expected_games[tid_str])])
			var solved: bool = await _solve_minigame(level, layer, tid, 3000)
			_check(solved and level.is_task_completed(tid), "Minigame %s selesai -> tugas selesai" % tid_str)
	_check(level._doors["A"].is_open, "Tugas Arsip membuka Pintu A")
	_check(level._doors["B"].is_open, "Tugas Listrik membuka Pintu B")
	_check(level._exit_open, "Semua tugas selesai -> pintu keluar terbuka")
	_check(level.exit_door != null and not level.exit_door.is_locked, "Visual ExitDoor tidak terkunci")

	# --- Kabur: pemain di zona exit selama 2 dtk -> level selesai ---
	if player != null:
		player.global_position = _cell(Vector2i(36, 37))
		var frames: int = 0
		while not level._level_ended and frames < 180:
			await get_tree().physics_frame
			frames += 1
		_check(level._level_ended, "Berdiri di exit -> level selesai (frame %d)" % frames)

	# --- Tertangkap -> kurungan -> revive (uji di instance level baru) ---
	# Level pertama dihapus dulu supaya grup LevelManager/Player tidak ganda.
	level.queue_free()
	for i: int in range(3):
		await get_tree().physics_frame
	var level2: Node2D = scene.instantiate()
	add_child(level2)
	for i: int in range(3):
		await get_tree().physics_frame
	var players2: Array[Node] = get_tree().get_nodes_in_group("Player")
	var p2: Node = players2[0] if not players2.is_empty() else null
	_check(p2 != null, "Level kedua punya pemain")
	if p2 != null:
		level2.on_player_caught(p2.peer_id)
		_check(p2.is_downed, "Pemain tertangkap -> downed")
		_check(level2.cage != null and level2.cage.visible, "Kurungan muncul")
		_check(level2.revive_item != null and level2.revive_item.visible, "Item Bangkit muncul")
		level2._revive_player(p2.peer_id)
		_check(not p2.is_downed, "Revive -> pemain aktif lagi")
		_check(not level2.cage.visible, "Kurungan hilang setelah revive")

	# --- Blink enemy -> BLIND di spawn point ---
	var enemy2: Node = level2.get_node_or_null("Enemy")
	if enemy2 != null:
		var before: Vector2 = enemy2.global_position
		enemy2._start_blink()
		_check(enemy2.state == 4, "Blink -> state VANISH")
		var waited: float = 0.0
		while enemy2.state == 4 and waited < 2.0:
			await get_tree().physics_frame
			waited += 1.0 / 60.0
		_check(enemy2.state == 3, "Setelah blink -> state BLIND")
		var at_spawn: bool = false
		for sp: Vector2 in enemy2.spawn_points:
			if enemy2.global_position.distance_to(sp) < 1.0:
				at_spawn = true
		_check(at_spawn, "Blink mendarat tepat di spawn point")
		_check(enemy2.global_position.distance_to(before) > 50.0, "Blink berpindah posisi jauh")
