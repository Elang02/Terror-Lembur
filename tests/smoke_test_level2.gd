extends Node
## Smoke test Level 2 (Lobi Kantor "Gelap Gulita").
## Cara pakai paling gampang: buka tests/smoke_test_level2.tscn lalu tekan F6,
## kemudian baca panel Output. Bisa juga headless:
##   godot --headless --path . res://tests/smoke_test_level2.tscn
## Keluar 0 kalau semua cek lolos, 1 kalau ada yang gagal.
## Yang dicek: scene termuat, jumlah tile, collision dinding, A* (semua tugas,
## tempat sembunyi, titik cas, titik kabel & pintu keluar bisa dicapai dari
## spawn), jumlah node gameplay, pemain & Satpam ter-spawn, batas kamera,
## lalu simulasi malam: gelap total, ngecas, senter, komputer + jam,
## laporan muncul, error kabel, dan pintu kaca terbuka jam 05.00.

const T: float = 32.0
const TASK_RANGE: float = 62.0
const HIDE_RANGE: float = 50.0

var _failures: Array[String] = []
var _checks: int = 0


func _ready() -> void:
	await _run()
	print("SMOKE L2: %d cek, %d gagal" % [_checks, _failures.size()])
	for f: String in _failures:
		print("SMOKE L2 FAIL: ", f)
	if _failures.is_empty():
		print("SMOKE L2: ALL PASS")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check(cond: bool, label: String) -> void:
	_checks += 1
	if cond:
		print("SMOKE L2 OK: ", label)
	else:
		_failures.append(label)
		print("SMOKE L2 FAIL: ", label)


func _cell(cell: Vector2i) -> Vector2:
	return Vector2(cell) * T + Vector2(16, 16)


func _children_of(level: Node, path: String) -> Array[Node]:
	var out: Array[Node] = []
	var root: Node = level.get_node_or_null(path)
	if root == null:
		return out
	for c: Node in root.get_children():
		out.append(c)
		for cc: Node in c.get_children():
			out.append(cc)
	return out


func _run() -> void:
	NetworkManager.start_solo()
	var scene: PackedScene = load("res://scenes/level_2.tscn")
	_check(scene != null, "level_2.tscn termuat")
	if scene == null:
		return
	var level: Node2D = scene.instantiate()
	add_child(level)
	for i: int in range(3):
		await get_tree().physics_frame

	# --- Struktur & tile ---
	var lantai: TileMapLayer = level.get_node_or_null("Lantai")
	var dinding: TileMapLayer = level.get_node_or_null("Dinding")
	var props: TileMapLayer = level.get_node_or_null("Props")
	_check(lantai != null and dinding != null and props != null, "3 TileMapLayer ada (Lantai/Dinding/Props)")
	if lantai == null or dinding == null or props == null:
		return
	_check(lantai.get_used_cells().size() == 2740, "Lantai = 2740 sel (dapat %d)" % lantai.get_used_cells().size())
	_check(dinding.get_used_cells().size() == 750, "Dinding = 750 sel (dapat %d)" % dinding.get_used_cells().size())
	_check(props.get_used_cells().size() == 577, "Props (bagian telapak, ada collision) = 577 sel (dapat %d)" % props.get_used_cells().size())
	var props_atas: TileMapLayer = level.get_node_or_null("props_atas")
	var karpet: TileMapLayer = level.get_node_or_null("karpet")
	var props2: TileMapLayer = level.get_node_or_null("Props2")
	_check(props_atas != null and props_atas.get_used_cells().size() == 147, "props_atas (tanpa collision) = 147 sel")
	_check(karpet != null and karpet.get_used_cells().size() == 87, "karpet + barang di lantai = 87 sel")
	_check(props2 != null and props2.get_used_cells().size() == 21, "Props2 (barang di atas meja) = 21 sel")
	_check(level.y_sort_enabled and props.y_sort_enabled and props_atas != null and props_atas.y_sort_enabled, "Y-Sort aktif (Level2, Props, props_atas)")
	_check(props.z_index == 5 and props_atas != null and props_atas.z_index == 5, "Props & props_atas z_index 5")
	var pemain_node: Node2D = level.get_node_or_null("Pemain")
	_check(pemain_node != null and pemain_node.y_sort_enabled, "Node Pemain Y-Sort aktif")
	_check(dinding.get_used_rect() == Rect2i(0, 0, 72, 46), "Ukuran map 72 x 46 (dapat %s)" % str(dinding.get_used_rect()))

	# --- Collision ---
	var space: PhysicsDirectSpaceState2D = level.get_world_2d().direct_space_state
	var pq := PhysicsPointQueryParameters2D.new()
	pq.collision_mask = 1
	pq.position = _cell(Vector2i(22, 17))
	_check(not space.intersect_point(pq).is_empty(), "Tiang atrium (22,17) punya collision")
	pq.position = _cell(Vector2i(30, 29))
	_check(space.intersect_point(pq).is_empty(), "Lantai lorong atrium (30,29) bebas collision")
	var ray := PhysicsRayQueryParameters2D.create(_cell(Vector2i(5, 10)), _cell(Vector2i(12, 10)), 1)
	_check(not space.intersect_ray(ray).is_empty(), "Tangga Darurat -> Ruang Surat terhalang dinding")
	var ray2 := PhysicsRayQueryParameters2D.create(_cell(Vector2i(17, 29)), _cell(Vector2i(60, 29)), 1)
	_check(space.intersect_ray(ray2).is_empty(), "Lorong bawah atrium (baris 29) bebas halangan")
	# Collision "telapak": tanaman lidah mertua di (51,9)-(51,10).
	pq.position = _cell(Vector2i(51, 10))
	_check(not space.intersect_point(pq).is_empty(), "Pot tanaman (51,10) padat")
	pq.position = _cell(Vector2i(51, 9))
	_check(space.intersect_point(pq).is_empty(), "Daun atas tanaman (51,9) bisa dilewati (di belakangnya)")

	# --- A* ---
	var pf: GridPathfinder = level._pathfinder
	_check(pf != null, "GridPathfinder terbentuk")
	if pf != null:
		_check(pf.walkable_point_count() == 1872, "Titik walkable A* = 1872 (dapat %d)" % pf.walkable_point_count())
		var spawn: Vector2 = level.get_node("Spawn/PlayerSpawn1").global_position
		var targets: Array = []  # [label, posisi, jarak maksimal]
		for n: Node in _children_of(level, "Tugas"):
			if "task_id" in n:
				targets.append(["tugas " + n.name, (n as Node2D).global_position, TASK_RANGE])
		for n: Node in _children_of(level, "TempatSembunyi"):
			targets.append(["sembunyi " + n.name, (n as Node2D).global_position, HIDE_RANGE])
		for grp: String in ["TitikCas", "TitikKabel"]:
			for n: Node in _children_of(level, grp):
				targets.append([grp + " " + n.name, (n as Node2D).global_position, 40.0])
		targets.append(["PintuKeluar", level.get_node("PintuKeluar").global_position, 72.0])
		targets.append(["KomputerSecurity", level.get_node("KomputerSecurity").global_position, 40.0])
		for t: Array in targets:
			var path: PackedVector2Array = pf.find_path_world(spawn, t[1])
			var ok: bool = not path.is_empty() and path[path.size() - 1].distance_to(t[1]) <= float(t[2])
			_check(ok, "A* spawn -> %s bisa dicapai" % t[0])

	# --- Node gameplay ---
	_check(level._tasks.size() == 7, "7 tugas (dapat %d)" % level._tasks.size())
	_check(level._spots.size() == 10, "10 tempat sembunyi (dapat %d)" % level._spots.size())
	_check(level._lights.size() == 30, "30 lampu (dapat %d)" % level._lights.size())
	_check(level._cas_nodes.size() == 6, "6 titik cas (dapat %d)" % level._cas_nodes.size())
	_check(level._kabel_nodes.size() == 4, "4 titik kabel (dapat %d)" % level._kabel_nodes.size())
	_check(level.get_node_or_null("KomputerSecurity") != null, "Komputer security ada")
	_check(level.hud_malam != null and level.hud_malam.get_node_or_null("HpPemain") != null, "HUD malam (HP, sticky note, ID card) terpasang")
	_check(level.minigame_layer != null, "MinigameLayer terpasang")
	_check(level._penanda.size() == 7, "7 penanda laporan di lantai (dapat %d)" % level._penanda.size())
	_check(not level.debug_aktif, "Mode debug MATI (jangan lupa dimatikan sebelum dikumpulkan)")
	var nama_ruangan: CanvasItem = level.get_node_or_null("NamaRuangan")
	_check(nama_ruangan != null and not nama_ruangan.visible, "NamaRuangan disembunyikan saat main")

	# --- Pemain, Satpam, kamera ---
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	_check(players.size() == 1, "Solo: 1 pemain ter-spawn (dapat %d)" % players.size())
	if not players.is_empty():
		var p: Node2D = players[0]
		var cam: Camera2D = p.get_node_or_null("Camera2D")
		_check(cam != null and cam.limit_right == 72 * 32 and cam.limit_bottom == 46 * 32, "Batas kamera 2304 x 1472")
		var lampu: PointLight2D = p.get_node_or_null("Light")
		_check(lampu != null and is_equal_approx(lampu.texture_scale, 0.55), "Lingkaran pandang bergradasi (skala 0.55)")
		_check(cam != null and is_equal_approx(cam.zoom.x, 4.5), "Zoom kamera 4.5")
		_check(p.get_node_or_null("Senter") != null, "Pemain punya lampu Senter")
		_check(p.z_index == 5, "Pemain z_index 5 (ikut Y-Sort dengan furnitur)")
	var satpam: Node = level.get_node_or_null("Satpam")
	_check(satpam != null, "Satpam ada di scene")
	if satpam != null:
		_check(satpam.patrol_points.size() == 12, "Rute Fase1 = 12 titik (dapat %d)" % satpam.patrol_points.size())
		_check(satpam.pathfinder != null, "Satpam memakai pathfinder")
		var spr: AnimatedSprite2D = satpam.get_node_or_null("AnimatedSprite2D")
		_check(spr != null and spr.sprite_frames != null and spr.sprite_frames.resource_path.ends_with("satpam_frames.tres"), "Sprite Satpam = Manager (satpam_frames.tres)")
		_check(spr != null and spr.offset == Vector2(0, -16), "Offset sprite Satpam (0, -16)")
		_check(satpam.z_index == 5 and satpam._base_tint == Color.WHITE, "Satpam z_index 5 & warna asli (tanpa tint)")
	if not players.is_empty() and satpam != null:
		await _uji_malam(level, players[0], satpam)


func _tunggu(frame: int) -> void:
	for i: int in range(frame):
		await get_tree().physics_frame


func _uji_malam(level: Node2D, p: Node, satpam: Node) -> void:
	var pid: int = NetworkManager.local_peer_id()
	var cm: CanvasModulate = level.get_node_or_null("CanvasModulate")
	_check(cm != null and cm.color.r < 0.06 and cm.color.b < 0.08, "Lobi hampir gelap total (CanvasModulate sangat gelap)")
	_check(not satpam.visible, "Satpam belum aktif sebelum cas pertama")
	_check(not bool(level._tasks[&"speaker"]["aktif"]), "Laporan belum muncul sebelum komputer menyala")
	_check(is_equal_approx(level.get_baterai(pid), 0.0), "Baterai awal 0%")
	# --- ngecas di Lobi Lift
	var cas: Node2D = level._cas_nodes["CasLobiLift"]
	p.global_position = cas.global_position
	p.velocity = Vector2.ZERO
	await _tunggu(2)
	level._handle_press(pid)
	_check(str(level._cas_dipakai.get(pid, "")) == "CasLobiLift", "E di titik cas = mulai ngecas")
	_check(level._musuh_aktif and satpam.visible, "Cas pertama membangunkan Satpam")
	level._set_musuh_aktif(false)  # supaya Satpam tidak mengganggu sisa tes
	await _tunggu(70)
	var b: float = level.get_baterai(pid)
	_check(b > 8.0 and b < 16.0, "Ngecas ±1 detik = ±10%% (dapat %.1f%%)" % b)
	level._hentikan_cas(pid)
	_check(float(level._cas_korslet["CasLobiLift"]) > 80.0, "Colokan korslet setelah dipakai")
	await _tunggu(30)
	var lampu: PointLight2D = p.get_node_or_null("Light")
	_check(lampu != null and is_equal_approx(lampu.texture_scale, 0.55), "Baterai > 0%% tapi lingkaran pandang tetap sama (skala %.3f)" % (lampu.texture_scale if lampu != null else 0.0))
	# --- senter
	level._toggle_senter(pid)
	await _tunggu(30)
	var senter: PointLight2D = p.get_node_or_null("Senter")
	_check(level.is_senter_nyala(pid) and senter != null and senter.enabled, "R = senter menyala")
	_check(level.get_baterai(pid) < b - 5.0, "Senter menguras baterai cepat (sisa %.1f%%)" % level.get_baterai(pid))
	level._toggle_senter(pid)
	# --- komputer security & jam
	var komp: Node2D = level.get_node("KomputerSecurity")
	p.global_position = komp.global_position
	await _tunggu(2)
	level._handle_press(pid)
	_check(level._komputer_pernah and level._komputer_nyala, "E di komputer = komputer menyala")
	_check(level.layar_komputer.is_terbuka(), "Layar denah operator terbuka")
	var jam_awal: float = level.get_jam_menit()
	await _tunggu(45)
	_check(level.get_jam_menit() > jam_awal + 0.2, "Jam berjalan saat komputer menyala")
	level.tutup_layar_komputer()
	await get_tree().create_timer(0.3).timeout
	_check(not level.layar_komputer.is_terbuka() and not p.minigame_open, "Layar denah tertutup & pemain bisa gerak lagi")
	# --- laporan muncul jam 22.00
	level._jam_menit = 59.9
	await _tunggu(10)
	_check(bool(level._tasks[&"speaker"]["aktif"]) and level._tasks[&"speaker"]["node"].visible, "Laporan 22.00 (speaker) muncul")
	# --- error kabel 23.30
	level._jam_menit = 149.95
	await _tunggu(10)
	_check(level._kabel_rusak != "" and not level._komputer_nyala, "23.30 komputer error, ada kabel putus")
	var jam_error: float = level.get_jam_menit()
	await _tunggu(30)
	_check(is_equal_approx(level.get_jam_menit(), jam_error), "Jam berhenti saat error")
	level._perbaiki_kabel()
	_check(level._komputer_nyala and level._kabel_rusak == "", "Kabel disambung = komputer nyala lagi")
	# --- subuh 05.00
	level._error_ke = 3
	level._complete_task(&"kunci_cadangan")
	level._complete_task(&"pintu_kaca")
	_check(not level._exit_open, "Pintu kaca belum terbuka sebelum 05.00")
	level._jam_menit = 479.9
	await _tunggu(20)
	_check(level._subuh and level._exit_open, "05.00: subuh & pintu kaca terbuka")
