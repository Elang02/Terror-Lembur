@tool
extends Node2D

const ROOM_W := 48
const ROOM_H := 28
const TILESET_PATH := "res://office_tileset.tres"
const BOSS_SCENE := "res://scenes/boss.tscn"
const THROWABLE_SCENE := "res://scenes/throwable.tscn"
const TASK_SCENE := "res://scenes/task_point.tscn"
const PICKUP_SCENE := "res://scenes/pickup_item.tscn"

const TASK_DEFS := [
	{"id": 0, "label": "GENERATOR", "pos": Vector2(736, 400), "need": 2, "time": 8.0, "noise": 400.0},
	{"id": 1, "label": "KOMPUTER", "pos": Vector2(400, 400), "need": 1, "time": 10.0, "noise": 150.0},
	{"id": 2, "label": "ARSIP", "pos": Vector2(190, 560), "need": 1, "time": 6.0, "noise": 150.0},
	{"id": 3, "label": "PINTU KELUAR", "pos": Vector2(800, 760), "need": 2, "time": 5.0, "noise": 400.0},
	{"id": 4, "label": "TUAS SEL", "pos": Vector2(960, 140), "need": 1, "time": 3.0, "noise": 150.0},
]
const CELL_POS := Vector2(1080, 140)
const GUDANG_ROOM := Rect2(32, 64, 192, 224)
const TOILET_ROOM := Rect2(32, 288, 192, 192)
const ARSIP_ROOM := Rect2(32, 480, 192, 192)
const PANTRY_ROOM := Rect2(224, 64, 192, 160)
const ISTIRAHAT_ROOM := Rect2(416, 64, 192, 160)
const RAPAT_ROOM := Rect2(608, 64, 288, 160)
const MANAGER_ROOM := Rect2(896, 64, 224, 160)
const KEUANGAN_ROOM := Rect2(1120, 64, 224, 160)
const SERBAGUNA_ROOM := Rect2(224, 672, 224, 192)
const SERVER_ROOM := Rect2(448, 672, 224, 192)
const LOBBY_ROOM := Rect2(672, 672, 256, 192)
const RESEPSIONIS_ROOM := Rect2(928, 672, 416, 192)
const IT_ROOM := Rect2(640, 288, 192, 192)
const FOTOKOPI_ROOM := Rect2(832, 288, 160, 192)
const HR_ROOM := Rect2(992, 288, 192, 192)
const BOSS_ROOM := MANAGER_ROOM
const ALL_ROOMS := [GUDANG_ROOM, TOILET_ROOM, ARSIP_ROOM, PANTRY_ROOM, ISTIRAHAT_ROOM, RAPAT_ROOM, MANAGER_ROOM, KEUANGAN_ROOM, SERBAGUNA_ROOM, SERVER_ROOM, LOBBY_ROOM, RESEPSIONIS_ROOM, IT_ROOM, FOTOKOPI_ROOM, HR_ROOM]
const PATROL_LOOP := [
	Vector2(272, 272), Vector2(800, 360), Vector2(1328, 272),
	Vector2(1328, 448), Vector2(1328, 624), Vector2(800, 624),
	Vector2(272, 624), Vector2(272, 448),
]
const INTERACT_RANGE := 80.0
const LOCKED_DOORS := [[Vector2i(3, 15), Vector2i(4, 15)], [Vector2i(42, 23), Vector2i(42, 24)]]
const _HIDE_SPOT_POSITIONS := [
	Vector2(320, 320), Vector2(420, 320), Vector2(320, 520), Vector2(420, 520),
	Vector2(1150, 320), Vector2(1250, 320), Vector2(1150, 520), Vector2(1250, 520),
	Vector2(560, 560), Vector2(660, 560), Vector2(800, 260), Vector2(900, 260),
	Vector2(320, 140), Vector2(940, 110), Vector2(1200, 140), Vector2(320, 760),
	Vector2(720, 720), Vector2(1000, 760), Vector2(1060, 350), Vector2(752, 160),
	Vector2(80, 100), Vector2(120, 100), Vector2(80, 180), Vector2(80, 520),
	Vector2(120, 520), Vector2(80, 600), Vector2(500, 700), Vector2(580, 700),
]
const PROP_SCENES := {
	"Desks/office_desk/office_desk_front.png": "res://scenes/props/meja.tscn",
	"Seating/office_chair/office_chair_front.png": "res://scenes/props/kursi_depan.tscn",
	"Seating/office_chair/office_chair_back.png": "res://scenes/props/kursi_belakang.tscn",
	"Seating/office_chair/office_chair_left.png": "res://scenes/props/kursi_kiri.tscn",
	"Seating/office_chair/office_chair_right.png": "res://scenes/props/kursi_kanan.tscn",
	"Tech/computer/computer_front.png": "res://scenes/props/komputer.tscn",
	"Tech/laptop/laptop_front.png": "res://scenes/props/laptop.tscn",
	"Storage/filing_cabinet/filing_cabinet_front.png": "res://scenes/props/lemari.tscn",
	"Decor/office_plant/office_plant_front.png": "res://scenes/props/tanaman.tscn",
	"Decor/tall_plant/tall_plant_front.png": "res://scenes/props/tanaman_tinggi.tscn",
	"Decor/wall_clock/wall_clock_front.png": "res://scenes/props/jam_dinding.tscn",
	"Kitchen/water_cooler/water_cooler_left.png": "res://scenes/props/dispenser.tscn",
	"Kitchen/trash_bin/trash_bin_front.png": "res://scenes/props/tempat_sampah.tscn",
	"Desk_Items/desk_lamp/desk_lamp_front.png": "res://scenes/props/lampu_meja.tscn",
	"Desk_Items/coffee_mug/coffee_mug_front.png": "res://scenes/props/mug.tscn",
	"Desk_Items/paper_stack/paper_stack_front.png": "res://scenes/props/tumpukan_kertas.tscn",
	"Meeting/conference_table/conference_table_front.png": "res://scenes/props/meja_rapat.tscn",
	"Meeting/flip_chart/flip_chart_right.png": "res://scenes/props/flipchart.tscn",
	"Meeting/projector_screen/projector_screen_front.png": "res://scenes/props/layar_proyektor.tscn",
	"whiteboard.png": "res://scenes/props/papan_tulis.tscn",
	"sofa.png": "res://scenes/props/sofa.tscn",
	"bookshelf.png": "res://scenes/props/rak_buku.tscn",
}
const WALL_TILE := {
	0: Vector2i(0, 0), 1: Vector2i(1, 0), 4: Vector2i(2, 0), 5: Vector2i(3, 0),
	7: Vector2i(4, 0), 16: Vector2i(5, 0), 17: Vector2i(6, 0), 20: Vector2i(7, 0),
	21: Vector2i(0, 1), 23: Vector2i(1, 1), 28: Vector2i(2, 1), 29: Vector2i(3, 1),
	31: Vector2i(4, 1), 64: Vector2i(5, 1), 65: Vector2i(6, 1), 68: Vector2i(7, 1),
	69: Vector2i(0, 2), 71: Vector2i(1, 2), 80: Vector2i(2, 2), 81: Vector2i(3, 2),
	84: Vector2i(4, 2), 85: Vector2i(5, 2), 87: Vector2i(6, 2), 92: Vector2i(7, 2),
	93: Vector2i(0, 3), 95: Vector2i(1, 3), 112: Vector2i(2, 3), 113: Vector2i(3, 3),
	116: Vector2i(4, 3), 117: Vector2i(5, 3), 119: Vector2i(6, 3), 124: Vector2i(7, 3),
	125: Vector2i(0, 4), 127: Vector2i(1, 4), 193: Vector2i(2, 4), 197: Vector2i(3, 4),
	199: Vector2i(4, 4), 209: Vector2i(5, 4), 213: Vector2i(6, 4), 215: Vector2i(7, 4),
	221: Vector2i(0, 5), 223: Vector2i(1, 5), 241: Vector2i(2, 5), 245: Vector2i(3, 5),
	247: Vector2i(4, 5), 253: Vector2i(5, 5), 255: Vector2i(6, 5),
}

var locked_door_cells: Array[Vector2i] = []
var locked_door_marks: Array[Polygon2D] = []
var wall_layer_ref: TileMapLayer = null
var astar: AStarGrid2D = null

var ysort: Node2D
var spawner: MultiplayerSpawner
var boss: CharacterBody2D
var music_calm: AudioStreamPlayer
var music_tense: AudioStreamPlayer
var music_tense_level := 0.0
var muted := false
var mute_fade := 1.0
const SETTINGS_CFG := "user://settings.cfg"
var tasks: Array = []
var pickups: Array = []
var desk_positions: Array[Vector2] = []
var noise_queue: Array = []
var lit_areas: Array[Vector2] = []
var game_over := false
var game_result := ""
var stars := 0
var ever_caught := false
var boss_speed_mult := 1.0
var solo_mode := false
var solo_catches := 0
const SOLO_MAX_CATCHES := 3
var self_rescue_progress := 0.0
const SELF_RESCUE_TIME := 15.0
var self_rescue_noise_timer := 0.0
var warn_timer := 0.0
var noise_emit_timer := 0.0
var debug_timer := 0.0

var flicker_lights: Array[PointLight2D] = []
var flicker_base: Array[float] = []
var flicker_timer := 0.0
var _name_counts: Dictionary = {}

func _indo_name(rel: String) -> String:
	if rel.begins_with("Desks/office_desk"):
		return "Meja"
	if rel.begins_with("Seating/office_chair"):
		return "Kursi"
	if rel.begins_with("Tech/computer"):
		return "Komputer"
	if rel.begins_with("Tech/laptop"):
		return "Laptop"
	if rel.begins_with("Storage/filing_cabinet"):
		return "Lemari"
	if rel.begins_with("Decor/office_plant"):
		return "Tanaman"
	if rel.begins_with("Decor/tall_plant"):
		return "Tanaman_Tinggi"
	if rel.begins_with("Decor/wall_clock"):
		return "Jam_Dinding"
	if rel.begins_with("Kitchen/water_cooler"):
		return "Dispenser"
	if rel.begins_with("Kitchen/trash_bin"):
		return "Tempat_Sampah"
	if rel.begins_with("Desk_Items/desk_lamp"):
		return "Lampu_Meja"
	if rel.begins_with("Desk_Items/coffee_mug"):
		return "Mug"
	if rel.begins_with("Desk_Items/paper_stack"):
		return "Tumpukan_Kertas"
	if rel.begins_with("Meeting/conference_table"):
		return "Meja_Rapat"
	if rel.begins_with("Meeting/flip_chart"):
		return "Flipchart"
	if rel.begins_with("Meeting/projector_screen"):
		return "Layar_Proyektor"
	if rel == "whiteboard.png":
		return "Papan_Tulis"
	if rel == "sofa.png":
		return "Sofa"
	if rel == "bookshelf.png":
		return "Rak_Buku"
	return "Prop"

func _prop_name(base: String) -> String:
	var n := int(_name_counts.get(base, 0)) + 1
	_name_counts[base] = n
	return base + "_%02d" % n

var hud_layer: CanvasLayer = null
var hud_task_bars: Array[ProgressBar] = []
var hud_task_rows: Array[Label] = []
var hud_task_count: Label
var hud_timer_label: Label
var hud_boss_label: Label
var hud_boss_row: HBoxContainer
var hud_boss_dot: PanelContainer
var hud_prompt_label: Label
var hud_prompt_pill: PanelContainer
var hud_prompt_bar: ProgressBar
var hud_warn_label: Label
var hud_status_label: Label
var hud_status_pill: PanelContainer
var hud_edge_rects: Array[ColorRect] = []
var hud_pulse_t := 0.0
var flash_rect: ColorRect
var flash_a := 0.0
var hud_stamina_bar: ProgressBar
var hud_tutorial_panel: PanelContainer
var hud_tutorial_label: Label
var tutorial_step := 0
var tutorial_spawn_pos := Vector2.ZERO
const TUTORIAL_CFG := "user://tutorial.cfg"
var sfx: SFX
var heartbeat_timer := 0.0
var tick_timer := 0.0
var task_done_sounded: Dictionary = {}
var end_dim: ColorRect
var end_center: CenterContainer
var elapsed := 0.0
var times_caught := 0
var shake_strength := 0.0
var local_camera: Camera2D = null
var end_panel: PanelContainer
var end_title: Label
var end_detail: Label
var end_stars: Array[Label] = []

func _ready() -> void:
	if has_node("FloorLayer") and has_node("WallLayer"):
		wall_layer_ref = $"WallLayer"
	else:
		_build_tilemap_layers()
	for cells in LOCKED_DOORS:
		for c in cells:
			locked_door_cells.append(c)
	if not Engine.is_editor_hint():
		_create_locked_door_markers()
	ysort = $"YSort"
	spawner = $"Spawner"
	var baked_props := ysort.get_child_count() > 0
	if not baked_props:
		_build_props()
		_build_horror_static()
		_build_cell()
	_build_horror_lights()
	_init_desk_positions()
	_build_astar()
	_build_tasks()
	if Engine.is_editor_hint():
		return
	sfx = SFX.new()
	add_child(sfx)
	_setup_music()
	_load_muted()
	_build_darkness()
	_build_pickups()
	_build_hud()
	if not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		show_hud()
	elif "--host" in OS.get_cmdline_user_args() or "--join" in OS.get_cmdline_user_args():
		show_hud()
	lit_areas.append(Vector2(800, 760))
	spawner.add_spawnable_scene(BOSS_SCENE)
	spawner.add_spawnable_scene(THROWABLE_SCENE)
	spawner.add_spawnable_scene(TASK_SCENE)
	if multiplayer.is_server():
		var boss_scene := load(BOSS_SCENE) as PackedScene
		boss = boss_scene.instantiate() as CharacterBody2D
		boss.global_position = boss_room_center()
		boss.speed_mult = boss_speed_mult
		ysort.add_child(boss, true)

func set_solo_mode(value: bool) -> void:
	solo_mode = value
	if solo_mode:
		boss_speed_mult = 0.9
		if boss != null:
			boss.speed_mult = boss_speed_mult

const MUSIC_CALM := preload("res://assets/audio/ambient_calm.ogg")
const MUSIC_TENSE := preload("res://assets/audio/ambient_tense.ogg")

func _setup_music() -> void:
	music_calm = AudioStreamPlayer.new()
	music_calm.stream = MUSIC_CALM
	music_calm.stream.loop = true
	music_calm.volume_db = -18.0
	add_child(music_calm)
	music_calm.play()
	music_tense = AudioStreamPlayer.new()
	music_tense.stream = MUSIC_TENSE
	music_tense.stream.loop = true
	music_tense.volume_db = -60.0
	add_child(music_tense)
	music_tense.play()

func _update_music(delta: float) -> void:
	if music_calm == null or music_tense == null:
		return
	var target := 0.0
	if boss != null and not game_over:
		var st: int = boss.get("state")
		if st == 2:
			target = 1.0
		elif st == 1 or st == 3:
			target = 0.6
		var d := _boss_distance()
		if d >= 0.0 and d < 150.0:
			target = maxf(target, 0.8)
	music_tense_level = move_toward(music_tense_level, target, delta / 1.5)
	mute_fade = move_toward(mute_fade, 0.0 if muted else 1.0, delta / 0.3)
	var tense_db := lerpf(-60.0, -12.0, music_tense_level)
	var calm_db := lerpf(-18.0, -26.0, music_tense_level)
	music_tense.volume_db = lerpf(-80.0, tense_db, mute_fade)
	music_calm.volume_db = lerpf(-80.0, calm_db, mute_fade)

func _load_muted() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_CFG) == OK:
		muted = bool(cfg.get_value("audio", "muted", false))
	mute_fade = 0.0 if muted else 1.0
	if sfx != null:
		sfx.set_muted(muted)

func _toggle_mute() -> void:
	muted = not muted
	if sfx != null:
		sfx.set_muted(muted)
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "muted", muted)
	cfg.save(SETTINGS_CFG)
	hud_warn_label.text = "SUARA MATI  (M buat nyalain)" if muted else "SUARA NYALA"
	warn_timer = 1.5

const TUTORIAL_TEXTS := {
	1: "1/4  Gerak pakai WASD  (T: lewati tutorial)",
	2: "2/4  Jalan ke Komputer, tahan E buat ngerjain  (T: lewati)",
	3: "3/4  Tekan C di dekat meja buat ngumpet  (T: lewati)",
	4: "4/4  Selesaikan semua tugas, lalu kabur lewat Pintu Keluar  (T: lewati)",
}

func _tutorial_is_done() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(TUTORIAL_CFG) != OK:
		return false
	return bool(cfg.get_value("tutorial", "done", false))

func _refresh_tutorial_label() -> void:
	if hud_tutorial_panel == null:
		return
	if tutorial_step >= 1 and tutorial_step <= 4:
		hud_tutorial_label.text = TUTORIAL_TEXTS[tutorial_step]
		hud_tutorial_panel.visible = true
	else:
		hud_tutorial_panel.visible = false

func _finish_tutorial() -> void:
	tutorial_step = 5
	var cfg := ConfigFile.new()
	cfg.set_value("tutorial", "done", true)
	cfg.save(TUTORIAL_CFG)
	if hud_tutorial_panel != null:
		hud_tutorial_panel.visible = false

func _task_done(task_id: int) -> bool:
	for tp in tasks:
		if int(tp.get("task_id")) == task_id:
			return bool(tp.get("done"))
	return false

func _update_tutorial() -> void:
	if tutorial_step == 5:
		return
	if tutorial_step == 0:
		if _tutorial_is_done():
			tutorial_step = 5
			return
		var me0 := _my_player()
		if me0 == null or game_over:
			return
		if hud_layer == null or not hud_layer.visible:
			return
		tutorial_step = 1
		tutorial_spawn_pos = me0.global_position
		_refresh_tutorial_label()
		return
	var me := _my_player()
	if me == null:
		return
	if Input.is_action_just_pressed("skip_tutorial"):
		_finish_tutorial()
		return
	match tutorial_step:
		1:
			if me.global_position.distance_to(tutorial_spawn_pos) > 120.0:
				tutorial_step = 2
				_refresh_tutorial_label()
		2:
			if (bool(me.get("interacting")) and int(me.get("interact_target")) == 1) or _task_done(1):
				tutorial_step = 3
				_refresh_tutorial_label()
		3:
			if bool(me.get("hiding")):
				tutorial_step = 4
				_refresh_tutorial_label()
		4:
			if _main_tasks_done():
				_finish_tutorial()

func _build_tilemap_layers() -> void:
	var tile_set := load(TILESET_PATH) as TileSet
	var floor_layer := TileMapLayer.new()
	floor_layer.name = "FloorLayer"
	floor_layer.tile_set = tile_set
	floor_layer.z_index = -2
	add_child(floor_layer)
	var wall_layer := TileMapLayer.new()
	wall_layer.name = "WallLayer"
	wall_layer.tile_set = tile_set
	wall_layer.collision_enabled = true
	wall_layer.z_index = -1
	add_child(wall_layer)
	for y in range(ROOM_H):
		for x in range(ROOM_W):
			floor_layer.set_cell(Vector2i(x, y), 0, _floor_tile_for(x, y))
	for x in range(ROOM_W):
		_set_wall(wall_layer, x, 0, Vector2i(1, 0) if x == 0 else (Vector2i(5, 0) if x == ROOM_W - 1 else Vector2i(2, 0)))
		_set_wall(wall_layer, x, 1, Vector2i(6, 0) if x == 0 else (Vector2i(2, 1) if x == ROOM_W - 1 else Vector2i(7, 0)))
		_set_wall(wall_layer, x, ROOM_H - 1, Vector2i(4, 2) if x == 0 else (Vector2i(0, 3) if x == ROOM_W - 1 else Vector2i(7, 2)))
	for y in range(2, ROOM_H - 1):
		_set_wall(wall_layer, 0, y, Vector2i(3, 1))
		_set_wall(wall_layer, ROOM_W - 1, y, Vector2i(5, 1))
	_build_partitions(wall_layer)

func _set_wall(layer: TileMapLayer, x: int, y: int, atlas: Vector2i) -> void:
	layer.set_cell(Vector2i(x, y), 1, atlas)

func _wall_bitmask(cells: Dictionary, x: int, y: int) -> int:
	var n := cells.has(Vector2i(x, y - 1))
	var e := cells.has(Vector2i(x + 1, y))
	var s := cells.has(Vector2i(x, y + 1))
	var w := cells.has(Vector2i(x - 1, y))
	var bm := 0
	if n:
		bm |= 1
	if e:
		bm |= 4
	if s:
		bm |= 16
	if w:
		bm |= 64
	if n and e and cells.has(Vector2i(x + 1, y - 1)):
		bm |= 2
	if s and e and cells.has(Vector2i(x + 1, y + 1)):
		bm |= 8
	if s and w and cells.has(Vector2i(x - 1, y + 1)):
		bm |= 32
	if n and w and cells.has(Vector2i(x - 1, y - 1)):
		bm |= 128
	return bm

func _autotile_walls(layer: TileMapLayer) -> void:
	var cells := {}
	for c in layer.get_used_cells():
		cells[c] = true
	for c in cells.keys():
		var bm := _wall_bitmask(cells, c.x, c.y)
		var atlas: Vector2i = WALL_TILE.get(bm, Vector2i(6, 5))
		layer.set_cell(c, 1, atlas)

func _floor_tile_for(tx: int, ty: int) -> Vector2i:
	var c := Vector2(tx * 32 + 16, ty * 32 + 16)
	if MANAGER_ROOM.has_point(c):
		return Vector2i(0, 0)
	if TOILET_ROOM.has_point(c) or SERVER_ROOM.has_point(c) or LOBBY_ROOM.has_point(c):
		return Vector2i(2, 0)
	if ty == 7 or ty == 20 or tx == 42:
		return Vector2i(2, 0)
	return Vector2i(1, 0)

func _wall_h(layer: TileMapLayer, x0: int, x1: int, y: int, gaps: Array = []) -> void:
	for x in range(x0, x1 + 1):
		if gaps.has(x):
			continue
		_set_wall(layer, x, y, Vector2i(7, 0))

func _wall_v(layer: TileMapLayer, y0: int, y1: int, x: int, gaps: Array = []) -> void:
	for y in range(y0, y1 + 1):
		if gaps.has(y):
			continue
		_set_wall(layer, x, y, Vector2i(3, 1))

func _lock_door(layer: TileMapLayer, cells: Array[Vector2i], atlas: Vector2i) -> void:
	for c in cells:
		_set_wall(layer, c.x, c.y, atlas)

func _create_locked_door_markers() -> void:
	for cells in LOCKED_DOORS:
		var cx := 0.0
		var cy := 0.0
		for c in cells:
			cx += float(c.x)
			cy += float(c.y)
		cx = cx / float(cells.size()) * 32.0 + 16.0
		cy = cy / float(cells.size()) * 32.0 + 16.0
		var mark := Polygon2D.new()
		mark.name = _prop_name("Pintu_Terkunci")
		mark.color = Color(0.85, 0.1, 0.1, 0.95)
		mark.polygon = PackedVector2Array([Vector2(-9, -11), Vector2(9, -11), Vector2(9, 11), Vector2(-9, 11)])
		mark.position = Vector2(cx, cy)
		mark.z_index = 0
		add_child(mark)
		locked_door_marks.append(mark)

func _init_desk_positions() -> void:
	desk_positions.clear()
	for n in get_tree().get_nodes_in_group("hide_spot"):
		if n is Node2D:
			desk_positions.append((n as Node2D).global_position)

func _build_astar() -> void:
	if wall_layer_ref == null or ysort == null:
		return
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, ROOM_W, ROOM_H)
	astar.cell_size = Vector2(32, 32)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.update()
	for cell in wall_layer_ref.get_used_cells():
		astar.set_point_solid(cell, true)
	for child in ysort.get_children():
		if not (child is Prop):
			continue
		var rect := _prop_collision_aabb(child as Node2D)
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			continue
		_mark_rect_solid(rect)

func _prop_collision_aabb(prop: Node2D) -> Rect2:
	var col := prop.get_node_or_null("Collision")
	if col == null:
		return Rect2()
	var shape_node := col.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return Rect2()
	var size := (shape_node.shape as RectangleShape2D).size
	var local_rect := Rect2(-size / 2.0, size)
	var xf := shape_node.get_global_transform()
	var a: Vector2 = xf * local_rect.position
	var b: Vector2 = xf * (local_rect.position + Vector2(local_rect.size.x, 0.0))
	var c: Vector2 = xf * (local_rect.position + Vector2(0.0, local_rect.size.y))
	var d: Vector2 = xf * local_rect.end
	var min_x := minf(minf(a.x, b.x), minf(c.x, d.x))
	var max_x := maxf(maxf(a.x, b.x), maxf(c.x, d.x))
	var min_y := minf(minf(a.y, b.y), minf(c.y, d.y))
	var max_y := maxf(maxf(a.y, b.y), maxf(c.y, d.y))
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func _mark_rect_solid(rect: Rect2) -> void:
	var x0 := int(floor(rect.position.x / 32.0))
	var y0 := int(floor(rect.position.y / 32.0))
	var x1 := int(floor((rect.position.x + rect.size.x - 1.0) / 32.0))
	var y1 := int(floor((rect.position.y + rect.size.y - 1.0) / 32.0))
	for y in range(maxi(y0, 0), mini(y1, ROOM_H - 1) + 1):
		for x in range(maxi(x0, 0), mini(x1, ROOM_W - 1) + 1):
			astar.set_point_solid(Vector2i(x, y), true)

func _nearest_walkable(cell: Vector2i) -> Vector2i:
	if astar == null:
		return cell
	var c := Vector2i(clampi(cell.x, 0, ROOM_W - 1), clampi(cell.y, 0, ROOM_H - 1))
	if not astar.is_point_solid(c):
		return c
	for r in range(1, 6):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var n := Vector2i(c.x + dx, c.y + dy)
				if n.x < 0 or n.y < 0 or n.x >= ROOM_W or n.y >= ROOM_H:
					continue
				if not astar.is_point_solid(n):
					return n
	return c

func find_path(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	if astar == null:
		return PackedVector2Array()
	var from_cell := _nearest_walkable(Vector2i(int(from_world.x / 32.0), int(from_world.y / 32.0)))
	var to_cell := _nearest_walkable(Vector2i(int(to_world.x / 32.0), int(to_world.y / 32.0)))
	var cells := astar.get_id_path(from_cell, to_cell)
	var out := PackedVector2Array()
	for cell in cells:
		out.append(Vector2(cell.x * 32 + 16, cell.y * 32 + 16))
	return out

func _open_locked_doors() -> void:
	if wall_layer_ref == null:
		return
	for c in locked_door_cells:
		wall_layer_ref.erase_cell(c)
	locked_door_cells.clear()
	for m in locked_door_marks:
		m.queue_free()
	locked_door_marks.clear()
	_autotile_walls(wall_layer_ref)
	_build_astar()

func _build_partitions(layer: TileMapLayer) -> void:
	wall_layer_ref = layer
	_wall_h(layer, 7, 41, 7, [9, 10, 15, 16, 22, 23, 30, 31, 37, 38])
	_wall_h(layer, 1, 6, 9, [3, 4])
	_wall_h(layer, 1, 6, 15, [])
	_wall_h(layer, 1, 41, 21, [9, 10, 16, 17, 24, 25, 34, 35])
	_wall_h(layer, 20, 25, 9, [])
	_wall_h(layer, 20, 25, 15, [22, 23])
	_wall_h(layer, 26, 30, 9, [])
	_wall_h(layer, 26, 30, 15, [27, 28])
	_wall_h(layer, 31, 36, 9, [])
	_wall_h(layer, 31, 36, 15, [33, 34])
	_wall_v(layer, 2, 20, 7, [5, 6, 11, 12, 17, 18])
	_wall_v(layer, 2, 6, 13, [4, 5])
	_wall_v(layer, 2, 6, 19, [4, 5])
	_wall_v(layer, 2, 6, 28, [4, 5])
	_wall_v(layer, 2, 6, 35, [4, 5])
	_wall_v(layer, 9, 14, 20, [])
	_wall_v(layer, 9, 14, 26, [11, 12])
	_wall_v(layer, 9, 14, 31, [11, 12])
	_wall_v(layer, 9, 14, 37, [11, 12])
	_wall_v(layer, 2, 26, 42, [4, 5, 11, 12, 17, 18])
	_wall_v(layer, 21, 26, 14, [23, 24])
	_wall_v(layer, 21, 26, 21, [23, 24])
	_wall_v(layer, 21, 26, 29, [23, 24])
	_lock_door(layer, [Vector2i(3, 15), Vector2i(4, 15)], Vector2i(7, 0))
	_lock_door(layer, [Vector2i(42, 23), Vector2i(42, 24)], Vector2i(3, 1))
	_autotile_walls(layer)

func _build_darkness() -> void:
	var mod := CanvasModulate.new()
	mod.color = Color(0.35, 0.35, 0.4)
	add_child(mod)

func _blood_spot(pos: Vector2, s: float) -> void:
	var b := Polygon2D.new()
	b.name = _prop_name("Darah")
	b.color = Color(0.35, 0.02, 0.02, 0.75)
	b.z_index = -1
	var pts := PackedVector2Array()
	var n := 9
	for i in range(n):
		var a := TAU * float(i) / float(n)
		var r := s * (0.7 + 0.6 * absf(sin(a * 2.3 + pos.x)))
		pts.append(Vector2(cos(a), sin(a)) * r)
	b.polygon = pts
	b.position = pos
	add_child(b)

func _paper(pos: Vector2, rot: float) -> void:
	var p := Polygon2D.new()
	p.name = _prop_name("Kertas")
	p.color = Color(0.85, 0.85, 0.8, 0.9)
	p.z_index = -1
	p.polygon = PackedVector2Array([Vector2(-9, -6), Vector2(9, -6), Vector2(9, 6), Vector2(-9, 6)])
	p.position = pos
	p.rotation = rot
	add_child(p)

func _rug(center: Vector2, size: Vector2, color: Color) -> void:
	var rug_name := _prop_name("Karpet")
	var border := Polygon2D.new()
	border.name = rug_name + "_Tepi"
	border.color = Color(0.1, 0.07, 0.07, 0.9)
	border.z_index = -1
	border.polygon = PackedVector2Array([Vector2(-size.x / 2 - 6, -size.y / 2 - 6), Vector2(size.x / 2 + 6, -size.y / 2 - 6), Vector2(size.x / 2 + 6, size.y / 2 + 6), Vector2(-size.x / 2 - 6, size.y / 2 + 6)])
	border.position = center
	add_child(border)
	var fill := Polygon2D.new()
	fill.name = rug_name + "_Isi"
	fill.color = color
	fill.z_index = -1
	fill.polygon = PackedVector2Array([Vector2(-size.x / 2, -size.y / 2), Vector2(size.x / 2, -size.y / 2), Vector2(size.x / 2, size.y / 2), Vector2(-size.x / 2, size.y / 2)])
	fill.position = center
	add_child(fill)

func _build_horror_static() -> void:
	_blood_spot(Vector2(400, 320), 26.0)
	_blood_spot(Vector2(440, 340), 14.0)
	_blood_spot(Vector2(900, 560), 30.0)
	_blood_spot(Vector2(940, 590), 12.0)
	_blood_spot(Vector2(1300, 500), 22.0)
	_blood_spot(Vector2(300, 620), 18.0)
	_blood_spot(Vector2(760, 300), 16.0)
	_blood_spot(Vector2(600, 300), 15.0)
	_blood_spot(Vector2(1200, 600), 20.0)
	_blood_spot(Vector2(1400, 250), 13.0)
	_blood_spot(Vector2(500, 700), 17.0)
	_blood_spot(Vector2(100, 200), 15.0)
	_paper(Vector2(500, 380), 0.4)
	_paper(Vector2(540, 400), -0.7)
	_paper(Vector2(700, 580), 1.1)
	_paper(Vector2(1100, 300), 0.2)
	_paper(Vector2(1140, 340), -1.2)
	_paper(Vector2(400, 660), 0.9)
	_paper(Vector2(1300, 300), -0.4)
	_paper(Vector2(800, 700), 0.6)
	_paper(Vector2(450, 550), 1.4)
	_paper(Vector2(1000, 200), -0.5)
	_paper(Vector2(1350, 550), 0.8)
	_paper(Vector2(300, 500), -1.0)
	_paper(Vector2(900, 260), 0.3)
	_rug(Vector2(1008, 180), Vector2(150, 60), Color(0.35, 0.08, 0.1, 0.85))
	_rug(Vector2(752, 160), Vector2(260, 120), Color(0.15, 0.18, 0.28, 0.85))
	_rug(Vector2(800, 780), Vector2(180, 80), Color(0.4, 0.28, 0.15, 0.85))
	_rug(Vector2(1100, 780), Vector2(200, 90), Color(0.2, 0.2, 0.3, 0.85))
	var chair_scene := load("res://scenes/props/kursi_depan.tscn") as PackedScene
	if chair_scene != null:
		var root := chair_scene.instantiate() as Prop
		root.name = "Kursi_Terbalik"
		root.position = Vector2(1200, 500)
		root.rotation = PI / 2.0
		ysort.add_child(root)


func _build_horror_lights() -> void:
	for pos in [Vector2(500, 360), Vector2(1100, 420), Vector2(800, 700)]:
		var fl := PointLight2D.new()
		fl.name = _prop_name("Lampu_Kedip")
		fl.position = pos
		fl.color = Color(1, 0.85, 0.6, 1)
		fl.energy = 0.9
		fl.texture_scale = 2.5
		add_child(fl)
		flicker_lights.append(fl)
		flicker_base.append(0.9)
	var red := PointLight2D.new()
	red.name = "Lampu_Merah_Bos"
	red.position = Vector2(1008, 142)
	red.color = Color(0.9, 0.1, 0.1, 1)
	red.energy = 0.5
	red.texture_scale = 2.0
	add_child(red)
func _build_cell() -> void:
	var room := Polygon2D.new()
	room.name = "Bayangan_Ruang_Bos"
	room.color = Color(0, 0, 0, 0.35)
	room.polygon = PackedVector2Array([
		BOSS_ROOM.position, Vector2(BOSS_ROOM.end.x, BOSS_ROOM.position.y),
		BOSS_ROOM.end, Vector2(BOSS_ROOM.position.x, BOSS_ROOM.end.y),
	])
	room.z_index = 5
	add_child(room)
	var cell := Node2D.new()
	cell.name = "Sel"
	cell.position = CELL_POS
	ysort.add_child(cell)
	for i in range(5):
		var bar := Polygon2D.new()
		bar.name = "Jeruji_%02d" % (i + 1)
		var bx := -30.0 + float(i) * 15.0
		bar.color = Color(0.15, 0.15, 0.15, 1)
		bar.polygon = PackedVector2Array([
			Vector2(bx - 2, -24), Vector2(bx + 2, -24),
			Vector2(bx + 2, 24), Vector2(bx - 2, 24),
		])
		cell.add_child(bar)
	var frame := Polygon2D.new()
	frame.name = "Jeruji_Atas"
	frame.color = Color(0.15, 0.15, 0.15, 1)
	frame.polygon = PackedVector2Array([
		Vector2(-32, -26), Vector2(32, -26), Vector2(32, -22), Vector2(-32, -22),
	])
	cell.add_child(frame)
	var frame2 := Polygon2D.new()
	frame2.name = "Jeruji_Bawah"
	frame2.color = Color(0.15, 0.15, 0.15, 1)
	frame2.polygon = PackedVector2Array([
		Vector2(-32, 22), Vector2(32, 22), Vector2(32, 26), Vector2(-32, 26),
	])
	cell.add_child(frame2)

func _build_tasks() -> void:
	var scene := load(TASK_SCENE) as PackedScene
	for def in TASK_DEFS:
		var tp := scene.instantiate() as Node2D
		tp.name = "Task_" + str(def["label"]).replace(" ", "_")
		tp.setup(def["id"], def["label"], def["need"], def["time"], def["noise"])
		tp.position = def["pos"]
		add_child(tp)
		tasks.append(tp)

func _build_pickups() -> void:
	var scene := load(PICKUP_SCENE) as PackedScene
	var spots := [
		Vector2(320, 300), Vector2(420, 300), Vector2(1150, 300),
		Vector2(1250, 300), Vector2(560, 540), Vector2(1150, 500),
	]
	for s in spots:
		var pk := scene.instantiate() as Node2D
		pk.name = _prop_name("Mug_Lempar")
		pk.position = s
		add_child(pk)
		pickups.append(pk)

func _update_pickups() -> void:
	for pk in pickups:
		if pk.taken:
			continue
		for child in ysort.get_children():
			if not _is_player(child):
				continue
			if child.get("locked") or child.get("hiding"):
				continue
			if child.get("has_throwable"):
				continue
			if child.global_position.distance_to(pk.global_position) < 30.0:
				pk.taken = true
				child.rpc_id(int(child.name), "give_throwable")
				break

func show_hud() -> void:
	if hud_layer != null:
		hud_layer.visible = true

func play_sfx(sound_name: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if sfx != null:
		sfx.play(sound_name, volume_db, pitch)

func flash_red(amount: float = 0.35) -> void:
	flash_a = maxf(flash_a, amount)

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	hud_layer = hud
	hud.visible = false
	add_child(hud)
	var task_panel := PanelContainer.new()
	UITheme.apply_panel(task_panel, Color(0.05, 0.05, 0.06, 0.85), Color(0.42, 0.36, 0.3), 1, 8)
	task_panel.position = Vector2(12, 10)
	task_panel.custom_minimum_size = Vector2(264, 0)
	hud.add_child(task_panel)
	var tvb := VBoxContainer.new()
	tvb.add_theme_constant_override("separation", 5)
	task_panel.add_child(tvb)
	var head_row := HBoxContainer.new()
	tvb.add_child(head_row)
	var task_head := UITheme.make_label("TUGAS", UITheme.body_font(), 16, UITheme.COL_GOLD)
	head_row.add_child(task_head)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(spacer)
	hud_task_count = UITheme.make_label("0/3", UITheme.body_font(), 14, UITheme.COL_GREY)
	head_row.add_child(hud_task_count)
	var divider := ColorRect.new()
	divider.color = Color(0.62, 0.5, 0.22, 0.9)
	divider.custom_minimum_size = Vector2(0, 2)
	tvb.add_child(divider)
	hud_task_bars.clear()
	hud_task_rows.clear()
	for tp in tasks:
		if tp.task_id == 4:
			continue
		var row := UITheme.make_label("\u2610 " + tp.label_text, UITheme.body_font(), 15, UITheme.COL_PAPER)
		tvb.add_child(row)
		hud_task_rows.append(row)
		var bar := ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = 1.0
		bar.value = 0.0
		bar.custom_minimum_size = Vector2(232, 9)
		bar.show_percentage = false
		UITheme.apply_progress_bar(bar)
		tvb.add_child(bar)
		hud_task_bars.append(bar)
	var status_panel := PanelContainer.new()
	UITheme.apply_panel(status_panel, Color(0.05, 0.05, 0.06, 0.85), Color(0.42, 0.36, 0.3), 1, 8)
	status_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	status_panel.position = Vector2(-268, 10)
	status_panel.custom_minimum_size = Vector2(256, 0)
	hud.add_child(status_panel)
	var svb := VBoxContainer.new()
	svb.add_theme_constant_override("separation", 4)
	status_panel.add_child(svb)
	var timer_row := HBoxContainer.new()
	svb.add_child(timer_row)
	timer_row.add_child(UITheme.make_label("WAKTU", UITheme.body_font(), 13, UITheme.COL_GREY))
	var tspacer := Control.new()
	tspacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_row.add_child(tspacer)
	hud_timer_label = UITheme.make_label("0:00", UITheme.body_font(), 20, UITheme.COL_PAPER)
	timer_row.add_child(hud_timer_label)
	hud_boss_row = HBoxContainer.new()
	hud_boss_row.add_theme_constant_override("separation", 8)
	hud_boss_row.visible = false
	svb.add_child(hud_boss_row)
	hud_boss_dot = PanelContainer.new()
	UITheme.apply_panel(hud_boss_dot, UITheme.COL_BLOOD, UITheme.COL_BLOOD_BRIGHT, 1, 14)
	hud_boss_dot.custom_minimum_size = Vector2(28, 28)
	var dot_lbl := UITheme.make_label("!", UITheme.body_font(), 16, Color.WHITE)
	dot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dot_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_boss_dot.add_child(dot_lbl)
	hud_boss_row.add_child(hud_boss_dot)
	hud_boss_label = UITheme.make_label("", UITheme.body_font(), 15, UITheme.COL_BLOOD_BRIGHT)
	hud_boss_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_boss_row.add_child(hud_boss_label)
	hud_warn_label = UITheme.make_label("", UITheme.title_font(), 30, UITheme.COL_BLOOD_BRIGHT)
	hud_warn_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_warn_label.offset_top = 16
	hud_warn_label.offset_bottom = 60
	hud_warn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_warn_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	hud_warn_label.add_theme_constant_override("outline_size", 8)
	hud_warn_label.visible = false
	hud.add_child(hud_warn_label)
	hud_tutorial_panel = PanelContainer.new()
	UITheme.apply_panel(hud_tutorial_panel, Color(0.05, 0.08, 0.05, 0.92), UITheme.COL_GREEN, 1, 10)
	hud_tutorial_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hud_tutorial_panel.offset_top = 68
	hud_tutorial_panel.offset_bottom = 112
	hud_tutorial_panel.offset_left = -320
	hud_tutorial_panel.offset_right = 320
	hud_tutorial_panel.visible = false
	hud.add_child(hud_tutorial_panel)
	hud_tutorial_label = UITheme.make_label("", UITheme.body_font(), 16, UITheme.COL_PAPER)
	hud_tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_tutorial_panel.add_child(hud_tutorial_label)
	hud_status_pill = PanelContainer.new()
	UITheme.apply_panel(hud_status_pill, Color(0.2, 0.12, 0.02, 0.9), UITheme.COL_GOLD, 1, 14)
	hud_status_pill.position = Vector2(16, 226)
	hud_status_pill.custom_minimum_size = Vector2(0, 0)
	hud_status_pill.visible = false
	hud.add_child(hud_status_pill)
	hud_status_label = UITheme.make_label("", UITheme.body_font(), 15, UITheme.COL_GOLD)
	hud_status_pill.add_child(hud_status_label)
	var prompt_center := CenterContainer.new()
	prompt_center.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	prompt_center.offset_top = -96
	prompt_center.offset_bottom = -8
	prompt_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(prompt_center)
	var prompt_outer_vb := VBoxContainer.new()
	prompt_outer_vb.add_theme_constant_override("separation", 6)
	prompt_center.add_child(prompt_outer_vb)
	var stamina_row := HBoxContainer.new()
	stamina_row.alignment = BoxContainer.ALIGNMENT_CENTER
	prompt_outer_vb.add_child(stamina_row)
	hud_stamina_bar = ProgressBar.new()
	hud_stamina_bar.min_value = 0.0
	hud_stamina_bar.max_value = 100.0
	hud_stamina_bar.value = 100.0
	hud_stamina_bar.custom_minimum_size = Vector2(220, 8)
	hud_stamina_bar.show_percentage = false
	hud_stamina_bar.add_theme_stylebox_override("background", UITheme.bar_bg_style())
	hud_stamina_bar.add_theme_stylebox_override("fill", UITheme.bar_fill_style(Color(0.35, 0.85, 0.6)))
	stamina_row.add_child(hud_stamina_bar)
	hud_prompt_pill = PanelContainer.new()
	UITheme.apply_panel(hud_prompt_pill, Color(0.05, 0.05, 0.06, 0.88), UITheme.COL_GOLD, 1, 16)
	hud_prompt_pill.custom_minimum_size = Vector2(640, 0)
	hud_prompt_pill.visible = false
	prompt_outer_vb.add_child(hud_prompt_pill)
	var prompt_vb := VBoxContainer.new()
	prompt_vb.add_theme_constant_override("separation", 4)
	hud_prompt_pill.add_child(prompt_vb)
	hud_prompt_label = UITheme.make_label("", UITheme.body_font(), 16, UITheme.COL_PAPER)
	hud_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_vb.add_child(hud_prompt_label)
	hud_prompt_bar = ProgressBar.new()
	hud_prompt_bar.min_value = 0.0
	hud_prompt_bar.max_value = 1.0
	hud_prompt_bar.value = 0.0
	hud_prompt_bar.custom_minimum_size = Vector2(460, 8)
	hud_prompt_bar.show_percentage = false
	hud_prompt_bar.visible = false
	UITheme.apply_progress_bar(hud_prompt_bar)
	prompt_vb.add_child(hud_prompt_bar)
	for i in range(4):
		var edge := ColorRect.new()
		edge.color = Color(0.9, 0.1, 0.1, 0.0)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == 0:
			edge.set_anchors_preset(Control.PRESET_TOP_WIDE)
			edge.offset_bottom = 22
		elif i == 1:
			edge.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
			edge.offset_top = -22
		elif i == 2:
			edge.set_anchors_preset(Control.PRESET_LEFT_WIDE)
			edge.offset_right = 22
		else:
			edge.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
			edge.offset_left = -22
		hud.add_child(edge)
		hud_edge_rects.append(edge)
	flash_rect = ColorRect.new()
	flash_rect.color = Color(0.9, 0.05, 0.05, 0.0)
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(flash_rect)
	end_dim = ColorRect.new()
	end_dim.color = Color(0, 0, 0, 0.65)
	end_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_dim.visible = false
	hud.add_child(end_dim)
	end_center = CenterContainer.new()
	end_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_center.visible = false
	hud.add_child(end_center)
	end_panel = PanelContainer.new()
	UITheme.apply_panel(end_panel, Color(0.07, 0.05, 0.05, 0.95), UITheme.COL_BLOOD, 2, 12)
	end_panel.custom_minimum_size = Vector2(580, 0)
	end_center.add_child(end_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	end_panel.add_child(vb)
	end_title = UITheme.make_label("", UITheme.title_font(), 44, UITheme.COL_BLOOD_BRIGHT)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(end_title)
	var star_row := HBoxContainer.new()
	star_row.alignment = BoxContainer.ALIGNMENT_CENTER
	star_row.add_theme_constant_override("separation", 10)
	vb.add_child(star_row)
	end_stars.clear()
	for i in range(3):
		var s := UITheme.make_label("\u2605", UITheme.title_font(), 56, Color(0.3, 0.3, 0.3, 1))
		s.pivot_offset = Vector2(28, 28)
		star_row.add_child(s)
		end_stars.append(s)
	end_detail = UITheme.make_label("", UITheme.body_font(), 17, UITheme.COL_PAPER)
	end_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(end_detail)
	var again_btn := Button.new()
	again_btn.text = "Main Lagi (R)"
	again_btn.custom_minimum_size = Vector2(0, 44)
	UITheme.apply_button(again_btn, 18)
	again_btn.pressed.connect(func() -> void: rpc("_restart_game"))
	vb.add_child(again_btn)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not game_over:
		elapsed += delta
	if warn_timer > 0.0:
		warn_timer -= delta
		if warn_timer <= 0.0:
			hud_warn_label.text = ""
	hud_pulse_t += delta
	if flash_a > 0.0:
		flash_a = maxf(0.0, flash_a - delta * 1.4)
		flash_rect.color = Color(0.9, 0.05, 0.05, flash_a)
	if boss != null and not game_over:
		var bd := _boss_distance()
		if bd >= 0.0 and bd < 320.0:
			heartbeat_timer -= delta
			if heartbeat_timer <= 0.0:
				heartbeat_timer = lerpf(0.45, 1.0, clampf(bd / 320.0, 0.0, 1.0))
				play_sfx("heartbeat", -8.0)
	if Input.is_action_just_pressed("mute"):
		_toggle_mute()
	_update_music(delta)
	_update_tutorial()
	var me2 := _my_player()
	if me2 != null and me2.get("interacting") and not game_over:
		tick_timer -= delta
		if tick_timer <= 0.0:
			tick_timer = 0.4
			play_sfx("tick", -10.0)
	hud_warn_label.visible = hud_warn_label.text != ""
	if hud_warn_label.visible:
		hud_warn_label.modulate.a = 0.75 + 0.25 * sin(hud_pulse_t * 8.0)
	var boss_d := _boss_distance()
	var edge_alpha := 0.0
	if boss_d >= 0.0 and boss_d < 150.0:
		edge_alpha = 0.22 + 0.12 * sin(hud_pulse_t * 7.0)
	elif boss_d >= 0.0 and boss_d < 260.0:
		edge_alpha = 0.1
	for edge in hud_edge_rects:
		edge.color = Color(0.9, 0.1, 0.1, edge_alpha)
	if hud_boss_row.visible:
		hud_boss_dot.modulate.a = 0.6 + 0.4 * sin(hud_pulse_t * 6.0)
	flicker_timer += delta
	if flicker_timer > 0.12:
		flicker_timer = 0.0
		for i in range(flicker_lights.size()):
			var f := flicker_lights[i]
			if randf() < 0.12:
				f.energy = flicker_base[i] * randf_range(0.15, 0.5)
			else:
				f.energy = flicker_base[i] * randf_range(0.85, 1.05)
	if local_camera == null:
		var me := _my_player()
		if me != null:
			local_camera = me.get_node_or_null("Camera2D") as Camera2D
	if shake_strength > 0.0:
		shake_strength = maxf(0.0, shake_strength - delta * 22.0)
		if local_camera != null:
			local_camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
	elif local_camera != null and local_camera.offset != Vector2.ZERO:
		local_camera.offset = Vector2.ZERO
	if multiplayer.is_server() and not game_over:
		_update_tasks(delta)
		_update_self_rescue(delta)
		_update_pickups()
		_check_endings()
	_update_hud()
	if "--bot" in OS.get_cmdline_user_args():
		debug_timer += delta
		if debug_timer >= 2.0:
			debug_timer = 0.0
			if ysort != null:
				for child in ysort.get_children():
					if child is CharacterBody2D:
						print("POS peer=", multiplayer.get_unique_id(), " player=", child.name, " pos=", child.position, " vel=", child.velocity)

func _is_player(node: Node) -> bool:
	return node is CharacterBody2D and node.has_method("set_locked")

func _update_tasks(delta: float) -> void:
	for tp in tasks:
		if tp.done:
			continue
		var id: int = tp.task_id
		if id == 3 and not _main_tasks_done():
			continue
		if id == 4 and not _any_locked():
			tp.progress = maxf(0.0, tp.progress - delta * 0.05)
			continue
		var workers := 0
		for child in ysort.get_children():
			if not _is_player(child):
				continue
			if child.get("locked"):
				continue
			if child.get("interacting") and child.get("interact_target") == id:
				if child.global_position.distance_to(tp.global_position) < INTERACT_RANGE + 20.0:
					workers += 1
		var advancing := false
		if id == 0:
			if workers >= 2:
				tp.progress += delta / tp.time_needed
				advancing = true
			elif workers == 1 and solo_mode:
				tp.progress += delta / (tp.time_needed * 2.0)
				advancing = true
		elif id == 3:
			if workers >= 2:
				tp.progress += delta / 5.0
				advancing = true
			elif workers == 1 and (_any_locked() or solo_mode):
				tp.progress += delta / 10.0
				advancing = true
		elif id == 4:
			if workers >= 1:
				tp.progress += delta / tp.time_needed
				advancing = true
			else:
				tp.progress = maxf(0.0, tp.progress - delta * 0.05)
		else:
			if workers >= 1:
				tp.progress += delta / tp.time_needed
				advancing = true
		if advancing:
			noise_emit_timer += delta
			if noise_emit_timer > 0.5:
				noise_emit_timer = 0.0
				report_noise(tp.global_position, tp.noise_radius)
		if tp.progress >= 1.0:
			tp.progress = 1.0
			tp.done = true
			_on_task_done(tp)

func _update_self_rescue(delta: float) -> void:
	if not solo_mode:
		return
	var locked_player: Node2D = null
	for child in ysort.get_children():
		if not _is_player(child):
			continue
		if child.get("locked"):
			locked_player = child
			break
	if locked_player == null:
		self_rescue_progress = 0.0
		return
	if locked_player.get("interacting") and locked_player.get("interact_target") == 99:
		self_rescue_progress += delta / SELF_RESCUE_TIME
		self_rescue_noise_timer += delta
		if self_rescue_noise_timer >= 1.0:
			self_rescue_noise_timer = 0.0
			report_noise(locked_player.global_position, 400.0)
		if self_rescue_progress >= 1.0:
			self_rescue_progress = 0.0
			locked_player.rpc_id(int(locked_player.name), "set_locked", false)
			if boss != null:
				boss.send_back_to_room()
			hud_warn_label.text = "Kamu berhasil kabur dari sel!"
			warn_timer = 2.0
	else:
		self_rescue_progress = maxf(0.0, self_rescue_progress - delta * 0.1)

func _on_task_done(tp) -> void:
	if tp.task_id == 4:
		_unlock_all()
		return
	boss_speed_mult += 0.1
	if boss != null:
		boss.speed_mult = boss_speed_mult
	if _main_tasks_done():
		_open_locked_doors()
		_enrage_boss()
	lit_areas.append(tp.global_position)
	var light := PointLight2D.new()
	light.position = tp.global_position
	light.color = Color(1, 0.9, 0.7, 1)
	light.energy = 1.0
	light.texture_scale = 3.0
	add_child(light)
	if tp.task_id == 3:
		_finish_level()

func _enrage_boss() -> void:
	boss_speed_mult += 0.3
	if boss != null:
		boss.speed_mult = boss_speed_mult
		boss.teleport_mult = 0.6
	hud_warn_label.text = "BOS MARAH! Pintu keluar terbuka, dia tidak mau kamu pulang!"
	warn_timer = 3.0
	play_sfx("alarm", -4.0)

func _unlock_all() -> void:
	for child in ysort.get_children():
		if not _is_player(child):
			continue
		if child.get("locked"):
			child.rpc_id(int(child.name), "set_locked", false)

func _main_tasks_done() -> bool:
	for tp in tasks:
		if tp.task_id < 3 and not tp.done:
			return false
	return true

func _any_locked() -> bool:
	for child in ysort.get_children():
		if not _is_player(child):
			continue
		if child.get("locked"):
			return true
	return false

func _locked_count() -> int:
	var n := 0
	for child in ysort.get_children():
		if not _is_player(child):
			continue
		if child.get("locked"):
			n += 1
	return n

func _player_count() -> int:
	var n := 0
	for child in ysort.get_children():
		if _is_player(child):
			n += 1
	return n

func _check_endings() -> void:
	var total := _player_count()
	if total >= 2 and _locked_count() >= 2:
		rpc("_show_end", "GAME OVER", "Keduanya dikurung di ruang bos. Tidak ada yang bisa membebaskan siapa-siapa.", 0)

func _finish_level() -> void:
	if _any_locked():
		rpc("_show_end", "ENDING PAHIT", "Pintu terbuka, tapi satu teman masih dikurung di ruang bos. Yang bebas kabur sendiri. Yang dikurung kena nerf di level berikut.", 1)
	else:
		var s := 3 if not ever_caught else 2
		if solo_mode:
			rpc("_show_end", "HAPPY ENDING", "Kamu kabur sendiri lewat pintu keluar. Akhirnya bisa pulang.", s)
		else:
			rpc("_show_end", "HAPPY ENDING", "Keduanya kabur bareng lewat pintu keluar. Gotong royong berhasil.", s)

@rpc("any_peer", "call_local")
func _show_end(title: String, detail: String, s: int) -> void:
	if game_over:
		return
	game_over = true
	game_result = title
	stars = s
	end_title.text = title
	if title == "HAPPY ENDING":
		end_title.add_theme_color_override("font_color", UITheme.COL_GREEN)
	else:
		end_title.add_theme_color_override("font_color", UITheme.COL_BLOOD_BRIGHT)
	for i in range(end_stars.size()):
		if i < s:
			end_stars[i].add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
		else:
			end_stars[i].add_theme_color_override("font_color", Color(0.3, 0.3, 0.3, 1))
		end_stars[i].scale = Vector2(0.01, 0.01)
	var mins := int(elapsed) / 60
	var secs := int(elapsed) % 60
	var time_txt := "%d:%02d" % [mins, secs]
	end_detail.text = detail + "\n\nWaktu: " + time_txt + "   |   Ketangkep: " + str(times_caught) + "x"
	end_dim.visible = true
	end_center.visible = true
	end_panel.visible = true
	for i in range(end_stars.size()):
		var tw := create_tween()
		tw.tween_interval(0.12 * float(i))
		tw.tween_property(end_stars[i], "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if game_over and event.is_action_pressed("flashlight"):
		rpc("_restart_game")

@rpc("any_peer", "call_local")
func _restart_game() -> void:
	get_tree().reload_current_scene()

func _update_hud() -> void:
	var bi := 0
	var done_count := 0
	for tp in tasks:
		if tp.task_id == 4:
			continue
		if tp.done:
			done_count += 1
		if bi < hud_task_rows.size():
			var mark := "\u2611" if tp.done else "\u2610"
			var extra := ""
			if tp.task_id == 3 and not _main_tasks_done():
				extra = " (terkunci)"
			hud_task_rows[bi].text = mark + " " + tp.label_text + extra
			if tp.done:
				hud_task_rows[bi].add_theme_color_override("font_color", UITheme.COL_GREEN)
			else:
				hud_task_rows[bi].add_theme_color_override("font_color", UITheme.COL_PAPER)
		if bi < hud_task_bars.size():
			hud_task_bars[bi].value = tp.progress
			if tp.done:
				hud_task_bars[bi].add_theme_stylebox_override("fill", UITheme.bar_fill_style(UITheme.COL_GREEN))
		bi += 1
	if hud_task_count != null:
		hud_task_count.text = str(done_count) + "/3"
	for tp2 in tasks:
		if tp2.done and not task_done_sounded.get(tp2.task_id, false):
			task_done_sounded[tp2.task_id] = true
			play_sfx("complete", -4.0)
	var me_st := _my_player()
	if me_st != null:
		hud_stamina_bar.value = float(me_st.get("stamina"))
	var mins := int(elapsed) / 60
	var secs := int(elapsed) % 60
	hud_timer_label.text = "%d:%02d" % [mins, secs]
	var boss_d := _boss_distance()
	var boss_txt := ""
	if boss_d >= 0.0 and boss_d < 400.0:
		if boss_d < 150.0:
			boss_txt = "BOS SANGAT DEKAT!"
		elif boss_d < 260.0:
			boss_txt = "Bos dekat..."
		else:
			boss_txt = "Ada yang mengawasi..."
	hud_boss_label.text = boss_txt
	hud_boss_row.visible = boss_txt != ""
	var locked_names := ""
	for child in ysort.get_children():
		if not _is_player(child):
			continue
		if child.get("locked"):
			var disp := "Pemain 1" if str(child.name) == "1" else "Pemain 2"
			locked_names += disp + " DIKURUNG di ruang bos! "
	if locked_names != "":
		if solo_mode:
			hud_status_label.text = locked_names + "Tahan E buat kabur dari sel (15 detik, berisik!)."
		else:
			hud_status_label.text = locked_names + "Tahan E di TUAS SEL buat bebaskan (3 detik)."
		hud_status_pill.visible = true
	else:
		hud_status_label.text = ""
		hud_status_pill.visible = false
	var prompt_txt := ""
	var prompt_prog := -1.0
	var me := _my_player()
	if me != null and not game_over:
		if me.get("interacting") and me.get("interact_target") >= 0:
			var tid: int = me.get("interact_target")
			if tid == 99:
				prompt_txt = "Kabur dari sel... " + str(int(self_rescue_progress * 100.0)) + "% (berisik!)"
				prompt_prog = self_rescue_progress
			else:
				var tp = tasks[tid] if tid < tasks.size() else null
				if tp != null:
					prompt_txt = "Mengerjakan " + tp.label_text + "... " + str(int(tp.progress * 100.0)) + "%"
					prompt_prog = tp.progress
		else:
			var nid := nearest_interactable(me.global_position)
			if nid >= 0:
				var tp = tasks[nid]
				var need_txt := ""
				if tp.task_id == 0:
					need_txt = " (sendiri: 16 detik)" if solo_mode else " (butuh 2 orang)"
				elif tp.task_id == 3:
					need_txt = " (sendiri: 10 detik)" if solo_mode else " (butuh 2 orang, atau 1 orang 10 detik kalau teman dikurung)"
				prompt_txt = "Tahan E: " + tp.label_text + need_txt
			elif me.get("hiding"):
				prompt_txt = "NGUMPET, gerak atau tekan C buat keluar"
			elif nearest_desk(me.global_position) != Vector2.INF:
				prompt_txt = "C: ngumpet di bawah meja"
			elif me.get("has_throwable"):
				prompt_txt = "Q: lempar barang  |  F: teriak  |  R: senter  |  C: ngumpet  |  SHIFT: lari  |  M: bisukan"
			else:
				prompt_txt = "E: interaksi  |  F: teriak  |  R: senter  |  C: ngumpet  |  SHIFT: lari  |  M: bisukan"
	hud_prompt_label.text = prompt_txt
	hud_prompt_pill.visible = prompt_txt != ""
	if prompt_prog >= 0.0:
		hud_prompt_bar.visible = true
		hud_prompt_bar.value = prompt_prog
	else:
		hud_prompt_bar.visible = false
func _boss_distance() -> float:
	var me := _my_player()
	if me == null or boss == null:
		return -1.0
	return me.global_position.distance_to(boss.global_position)

func add_shake(amount: float) -> void:
	shake_strength = maxf(shake_strength, amount)

func _my_player() -> Node2D:
	var my_id := multiplayer.get_unique_id()
	for child in ysort.get_children():
		if _is_player(child) and int(child.name) == my_id:
			return child
	return null

func nearest_interactable(pos: Vector2) -> int:
	var best := -1
	var best_d := INTERACT_RANGE
	for tp in tasks:
		if tp.done:
			continue
		if tp.task_id == 3 and not _main_tasks_done():
			continue
		if tp.task_id == 4 and not _any_locked():
			continue
		var d := pos.distance_to(tp.global_position)
		if d < best_d:
			best_d = d
			best = tp.task_id
	return best

func nearest_desk(pos: Vector2) -> Vector2:
	var best := Vector2.INF
	var best_d := 60.0
	for d in desk_positions:
		var dist := pos.distance_to(d)
		if dist < best_d:
			best_d = dist
			best = d
	return best

func is_lit(pos: Vector2) -> bool:
	for a in lit_areas:
		if pos.distance_to(a) < 130.0:
			return true
	return false

func boss_room_center() -> Vector2:
	return BOSS_ROOM.get_center()

func teleport_destination() -> Vector2:
	var players: Array[Vector2] = []
	for child in ysort.get_children():
		if _is_player(child) and not child.get("locked"):
			players.append(child.global_position)
	if players.is_empty():
		return boss_room_center()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for attempt in range(8):
		var base: Vector2 = players[rng.randi() % players.size()]
		var dest := base + Vector2(rng.randf_range(-260, 260), rng.randf_range(-260, 260))
		dest.x = clampf(dest.x, 80, 1450)
		dest.y = clampf(dest.y, 100, 830)
		var ok := true
		for p in players:
			if dest.distance_to(p) < 150.0:
				ok = false
				break
		if ok:
			return dest
	return boss_room_center()

@rpc("any_peer", "call_local")
func report_noise(pos: Vector2, radius: float) -> void:
	if not multiplayer.is_server():
		return
	noise_queue.append({"pos": pos, "radius": radius})

func consume_noise() -> Vector2:
	if noise_queue.is_empty():
		return Vector2.ZERO
	var bp: Vector2 = boss.global_position if boss != null else Vector2.ZERO
	var best := Vector2.ZERO
	var best_d := 1e9
	var best_i := -1
	for i in range(noise_queue.size()):
		var n = noise_queue[i]
		var d: float = bp.distance_to(n["pos"])
		if d <= n["radius"] and d < best_d:
			best_d = d
			best = n["pos"]
			best_i = i
	if best_i >= 0:
		noise_queue.remove_at(best_i)
	return best

func on_player_caught(player: Node2D) -> void:
	ever_caught = true
	times_caught += 1
	player.global_position = CELL_POS
	player.rpc_id(int(player.name), "set_locked", true)
	rpc("_fx_caught")
	if solo_mode:
		solo_catches += 1
		if solo_catches >= SOLO_MAX_CATCHES:
			rpc("_show_end", "GAME OVER", "Kamu ketangkep 3 kali. Bos menang, kamu nggak jadi pulang.", 0)

@rpc("any_peer", "call_local")
func _fx_caught() -> void:
	add_shake(10.0)
	flash_red(0.4)
	if solo_mode:
		hud_warn_label.text = "KAMU DITANGKAP! Tahan E buat kabur dari sel."
	else:
		hud_warn_label.text = "TEMANMU DITANGKAP!"
	warn_timer = 3.0
	play_sfx("sting", -2.0)

@rpc("any_peer", "call_local")
func on_boss_chase() -> void:
	add_shake(3.0)
	hud_warn_label.text = "BOS MENGEJAR!"
	warn_timer = 2.0
	play_sfx("alarm", -6.0)

@rpc("any_peer", "call_local")
func on_boss_telegraph() -> void:
	hud_warn_label.text = "Bisikan... bos mau pindah!"
	warn_timer = 1.2
	play_sfx("whisper", -4.0)

@rpc("any_peer", "call_local")
func on_boss_teleported(dest: Vector2) -> void:
	add_shake(6.0)
	hud_warn_label.text = "Bos muncul di dekatmu!"
	warn_timer = 2.0
	play_sfx("thud", -4.0)

@rpc("any_peer", "call_local")
func spawn_throwable(pos: Vector2, dir: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var scene := load(THROWABLE_SCENE) as PackedScene
	var th := scene.instantiate() as Node2D
	ysort.add_child(th, true)
	th.launch(pos + dir * 24.0, dir)

const PROP_BASE := "res://assets/office_assets/main/Office_Pixel_Art_Free_v1.0/Props/"
const MODERN_BASE := "res://assets/office_assets/modern/objects/"

func _build_props() -> void:
	var desk := "Desks/office_desk/office_desk_front.png"
	var chair_f := "Seating/office_chair/office_chair_front.png"
	var chair_b := "Seating/office_chair/office_chair_back.png"
	var chair_l := "Seating/office_chair/office_chair_left.png"
	var chair_r := "Seating/office_chair/office_chair_right.png"
	var pc := "Tech/computer/computer_front.png"
	var lap := "Tech/laptop/laptop_front.png"
	var cab := "Storage/filing_cabinet/filing_cabinet_front.png"
	var plant := "Decor/office_plant/office_plant_front.png"
	var tplant := "Decor/tall_plant/tall_plant_front.png"
	var cooler := "Kitchen/water_cooler/water_cooler_left.png"
	var trash := "Kitchen/trash_bin/trash_bin_front.png"
	var lamp := "Desk_Items/desk_lamp/desk_lamp_front.png"
	var mug := "Desk_Items/coffee_mug/coffee_mug_front.png"
	var paper := "Desk_Items/paper_stack/paper_stack_front.png"
	var conf := "Meeting/conference_table/conference_table_front.png"
	var flip := "Meeting/flip_chart/flip_chart_right.png"
	var clock := "Decor/wall_clock/wall_clock_front.png"
	var screen := "Meeting/projector_screen/projector_screen_front.png"
	_place_prop(clock, Vector2(752, 40), false, Vector2.ZERO)
	_place_prop(screen, Vector2(752, 40), false, Vector2.ZERO)
	_place_prop(conf, Vector2(752, 160), true, Vector2(96, 40))
	_place_prop(chair_f, Vector2(700, 90), true, Vector2(26, 20))
	_place_prop(chair_f, Vector2(752, 90), true, Vector2(26, 20))
	_place_prop(chair_f, Vector2(804, 90), true, Vector2(26, 20))
	_place_prop(chair_b, Vector2(700, 210), true, Vector2(26, 20))
	_place_prop(chair_b, Vector2(752, 210), true, Vector2(26, 20))
	_place_prop(chair_b, Vector2(804, 210), true, Vector2(26, 20))
	_place_prop(chair_r, Vector2(640, 160), true, Vector2(26, 20))
	_place_prop(chair_l, Vector2(864, 160), true, Vector2(26, 20))
	_place_prop(lap, Vector2(730, 140), false, Vector2.ZERO)
	_place_prop(paper, Vector2(780, 145), false, Vector2.ZERO)
	_place_prop(flip, Vector2(620, 220), true, Vector2(24, 14))
	_place_modern("whiteboard.png", Vector2(860, 80), false, Vector2.ZERO)
	_place_prop(desk, Vector2(320, 320), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(320, 390), true, Vector2(26, 20))
	_place_prop(pc, Vector2(305, 302), false, Vector2.ZERO)
	_place_prop(lamp, Vector2(345, 304), false, Vector2.ZERO)
	_place_prop(desk, Vector2(420, 320), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(420, 390), true, Vector2(26, 20))
	_place_prop(lap, Vector2(415, 302), false, Vector2.ZERO)
	_place_prop(mug, Vector2(440, 306), false, Vector2.ZERO)
	_place_prop(desk, Vector2(320, 520), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(320, 590), true, Vector2(26, 20))
	_place_prop(pc, Vector2(305, 502), false, Vector2.ZERO)
	_place_prop(paper, Vector2(345, 504), false, Vector2.ZERO)
	_place_prop(desk, Vector2(420, 520), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(420, 590), true, Vector2(26, 20))
	_place_prop(lap, Vector2(415, 502), false, Vector2.ZERO)
	_place_prop(lamp, Vector2(440, 504), false, Vector2.ZERO)
	_place_prop(desk, Vector2(1150, 320), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1150, 390), true, Vector2(26, 20))
	_place_prop(pc, Vector2(1135, 302), false, Vector2.ZERO)
	_place_prop(mug, Vector2(1175, 306), false, Vector2.ZERO)
	_place_prop(desk, Vector2(1250, 320), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1250, 390), true, Vector2(26, 20))
	_place_prop(lap, Vector2(1245, 302), false, Vector2.ZERO)
	_place_prop(paper, Vector2(1270, 304), false, Vector2.ZERO)
	_place_prop(desk, Vector2(1150, 520), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1150, 590), true, Vector2(26, 20))
	_place_prop(pc, Vector2(1135, 502), false, Vector2.ZERO)
	_place_prop(lamp, Vector2(1175, 504), false, Vector2.ZERO)
	_place_prop(desk, Vector2(1250, 520), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1250, 590), true, Vector2(26, 20))
	_place_prop(lap, Vector2(1245, 502), false, Vector2.ZERO)
	_place_prop(mug, Vector2(1270, 506), false, Vector2.ZERO)
	_place_prop(desk, Vector2(560, 560), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(560, 630), true, Vector2(26, 20))
	_place_prop(pc, Vector2(545, 542), false, Vector2.ZERO)
	_place_prop(desk, Vector2(660, 560), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(660, 630), true, Vector2(26, 20))
	_place_prop(lap, Vector2(655, 542), false, Vector2.ZERO)
	_place_prop(desk, Vector2(800, 260), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(800, 330), true, Vector2(26, 20))
	_place_prop(pc, Vector2(785, 242), false, Vector2.ZERO)
	_place_prop(desk, Vector2(900, 260), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(900, 330), true, Vector2(26, 20))
	_place_prop(lap, Vector2(895, 242), false, Vector2.ZERO)
	_place_prop(desk, Vector2(320, 140), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(320, 210), true, Vector2(26, 20))
	_place_prop(cooler, Vector2(400, 200), true, Vector2(20, 16))
	_place_prop(plant, Vector2(240, 200), true, Vector2(26, 16))
	_place_prop(trash, Vector2(400, 100), true, Vector2(16, 12))
	_place_modern("sofa.png", Vector2(500, 160), true, Vector2(44, 20))
	_place_prop(plant, Vector2(430, 200), true, Vector2(26, 16))
	_place_prop(chair_f, Vector2(580, 200), true, Vector2(26, 20))
	_place_modern("bookshelf.png", Vector2(590, 80), true, Vector2(30, 20))
	_place_prop(desk, Vector2(940, 110), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(940, 180), true, Vector2(26, 20))
	_place_prop(lap, Vector2(935, 92), false, Vector2.ZERO)
	_place_prop(plant, Vector2(1100, 200), true, Vector2(26, 16))
	_place_modern("bookshelf.png", Vector2(900, 80), true, Vector2(30, 20))
	_place_prop(desk, Vector2(1200, 140), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1200, 210), true, Vector2(26, 20))
	_place_prop(pc, Vector2(1185, 122), false, Vector2.ZERO)
	_place_prop(cab, Vector2(1240, 88), true, Vector2(28, 24))
	_place_prop(cab, Vector2(1280, 88), true, Vector2(28, 24))
	_place_prop(plant, Vector2(1330, 200), true, Vector2(26, 16))
	_place_prop(cab, Vector2(80, 100), true, Vector2(28, 24))
	_place_prop(cab, Vector2(120, 100), true, Vector2(28, 24))
	_place_prop(cab, Vector2(160, 100), true, Vector2(28, 24))
	_place_prop(cab, Vector2(80, 180), true, Vector2(28, 24))
	_place_prop(cab, Vector2(120, 180), true, Vector2(28, 24))
	_place_prop(plant, Vector2(200, 260), true, Vector2(26, 16))
	_place_prop(trash, Vector2(60, 260), true, Vector2(16, 12))
	_place_prop(plant, Vector2(60, 320), true, Vector2(26, 16))
	_place_prop(plant, Vector2(200, 440), true, Vector2(26, 16))
	_place_prop(trash, Vector2(180, 440), true, Vector2(16, 12))
	_place_prop(cab, Vector2(80, 520), true, Vector2(28, 24))
	_place_prop(cab, Vector2(120, 520), true, Vector2(28, 24))
	_place_prop(cab, Vector2(160, 520), true, Vector2(28, 24))
	_place_prop(cab, Vector2(80, 600), true, Vector2(28, 24))
	_place_prop(cab, Vector2(120, 600), true, Vector2(28, 24))
	_place_prop(paper, Vector2(180, 560), false, Vector2.ZERO)
	_place_prop(paper, Vector2(190, 580), false, Vector2.ZERO)
	_place_prop(plant, Vector2(200, 640), true, Vector2(26, 16))
	_place_prop(desk, Vector2(320, 760), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(320, 830), true, Vector2(26, 20))
	_place_prop(pc, Vector2(305, 742), false, Vector2.ZERO)
	_place_prop(chair_f, Vector2(400, 700), true, Vector2(26, 20))
	_place_modern("whiteboard.png", Vector2(420, 700), false, Vector2.ZERO)
	_place_prop(plant, Vector2(240, 840), true, Vector2(26, 16))
	_place_prop(cab, Vector2(500, 700), true, Vector2(28, 24))
	_place_prop(cab, Vector2(540, 700), true, Vector2(28, 24))
	_place_prop(cab, Vector2(580, 700), true, Vector2(28, 24))
	_place_prop(cab, Vector2(620, 700), true, Vector2(28, 24))
	_place_prop(cab, Vector2(500, 820), true, Vector2(28, 24))
	_place_prop(cab, Vector2(540, 820), true, Vector2(28, 24))
	_place_prop(desk, Vector2(720, 720), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(720, 790), true, Vector2(26, 20))
	_place_prop(pc, Vector2(705, 702), false, Vector2.ZERO)
	_place_modern("sofa.png", Vector2(880, 800), true, Vector2(44, 20))
	_place_prop(plant, Vector2(690, 840), true, Vector2(26, 16))
	_place_prop(plant, Vector2(910, 700), true, Vector2(26, 16))
	_place_prop(desk, Vector2(1000, 760), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1000, 830), true, Vector2(26, 20))
	_place_prop(pc, Vector2(985, 742), false, Vector2.ZERO)
	_place_prop(plant, Vector2(1300, 700), true, Vector2(26, 16))
	_place_prop(plant, Vector2(1300, 840), true, Vector2(26, 16))
	_place_modern("bookshelf.png", Vector2(950, 700), true, Vector2(30, 20))
	_place_prop(pc, Vector2(700, 340), false, Vector2.ZERO)
	_place_prop(pc, Vector2(760, 340), false, Vector2.ZERO)
	_place_prop(cab, Vector2(660, 310), true, Vector2(28, 24))
	_place_prop(cab, Vector2(800, 310), true, Vector2(28, 24))
	_place_prop(cab, Vector2(880, 350), true, Vector2(28, 24))
	_place_prop(paper, Vector2(900, 400), false, Vector2.ZERO)
	_place_prop(plant, Vector2(970, 450), true, Vector2(26, 16))
	_place_prop(trash, Vector2(850, 450), true, Vector2(16, 12))
	_place_prop(desk, Vector2(1060, 350), true, Vector2(64, 24))
	_place_prop(chair_b, Vector2(1060, 420), true, Vector2(26, 20))
	_place_prop(pc, Vector2(1045, 332), false, Vector2.ZERO)
	_place_prop(cab, Vector2(1120, 320), true, Vector2(28, 24))
	_place_prop(plant, Vector2(1160, 450), true, Vector2(26, 16))
	_place_prop(plant, Vector2(70, 100), true, Vector2(26, 16))
	_place_prop(tplant, Vector2(1450, 100), true, Vector2(18, 16))
	_place_prop(plant, Vector2(70, 860), true, Vector2(26, 16))
	_place_prop(tplant, Vector2(1450, 860), true, Vector2(18, 16))
	_place_prop(trash, Vector2(1400, 620), true, Vector2(16, 12))
	_place_prop(trash, Vector2(1400, 300), true, Vector2(16, 12))

func _place_prop(rel: String, pos: Vector2, solid: bool, col_size: Vector2) -> void:
	_place_prop_scene(rel, pos)

func _place_modern(rel: String, pos: Vector2, solid: bool, col_size: Vector2) -> void:
	_place_prop_scene(rel, pos)

func _place_prop_scene(rel: String, pos: Vector2) -> void:
	var scene_path: String = PROP_SCENES.get(rel, "")
	if scene_path == "":
		return
	var scene := load(scene_path) as PackedScene
	if scene == null:
		return
	var inst := scene.instantiate() as Prop
	inst.name = _prop_name(_indo_name(rel))
	inst.position = pos
	if _HIDE_SPOT_POSITIONS.has(pos):
		inst.is_hide_spot = true
	ysort.add_child(inst)
