class_name MinigameLayer
extends CanvasLayer
## Lapisan UI minigame tugas — berjalan LOKAL di layar pemain yang
## mengerjakan tugas. Level (host) yang memutuskan tugas selesai lewat
## submit_minigame_result(); layer ini hanya menampilkan game, mengunci
## gerakan pemain, dan melaporkan progres untuk bilah stasiun tugas.
## Esc membatalkan (progres percobaan hilang). Otomatis tertutup kalau
## pemain tertangkap, tugas sudah selesai, atau level berakhir.

signal minigame_finished(task_id: StringName)
signal minigame_cancelled(task_id: StringName)

const GAME_SCRIPTS: Dictionary = {
	&"excel": "res://scripts/minigames/mg_excel.gd",
	&"slides": "res://scripts/minigames/mg_slides.gd",
	&"email": "res://scripts/minigames/mg_email.gd",
	&"copy": "res://scripts/minigames/mg_copy.gd",
	&"archive": "res://scripts/minigames/mg_archive.gd",
	&"simon": "res://scripts/minigames/mg_simon.gd",
	&"server": "res://scripts/minigames/mg_server.gd",
	&"keypad": "res://scripts/minigames/mg_keypad.gd",
	&"mash": "res://scripts/minigames/mg_mash.gd",
	&"cari": "res://scripts/minigames/mg_cari.gd",
	&"urut": "res://scripts/minigames/mg_urut.gd",
	&"lan": "res://scripts/minigames/mg_lan.gd",
	&"backup": "res://scripts/minigames/mg_backup.gd",
	&"rapat": "res://scripts/minigames/mg_rapat.gd",
}
const CLOSE_RANGE: float = 102.0

var _open: bool = false
var _task_id: StringName = StringName("")
var _game: MinigameBase = null
var _is_mirror: bool = false  # true = mirror task co-op bersama (state dari server)
var _report_timer: float = 0.0
var _last_reported: float = -1.0

var _root: Control = null
var _title_label: Label = null
var _instructions_label: Label = null
var _game_holder: Control = null
var _status_label: Label = null
var _status_square: ColorRect = null
var _progress_bar: ProgressBar = null
var _pct_label: Label = null


func _ready() -> void:
	layer = 20
	add_to_group("MinigameLayer")
	_build_ui()
	_root.visible = false


func is_open() -> bool:
	return _open


func current_task() -> StringName:
	return _task_id


func current_game() -> MinigameBase:
	return _game


func open_minigame(task_id: StringName, game_type: StringName, shared: bool = false, snapshot: Dictionary = {}) -> bool:
	if _open:
		return false
	if not GAME_SCRIPTS.has(game_type):
		push_warning("MinigameLayer: tipe game tidak dikenal: %s" % game_type)
		return false
	var level: Node = _level()
	if level == null:
		return false
	var script: GDScript = load(GAME_SCRIPTS[game_type])
	_game = script.new() as MinigameBase
	if _game == null:
		return false
	_task_id = task_id
	_is_mirror = shared
	_game_holder.add_child(_game)
	_game.is_mirror = shared
	_game.setup()
	_title_label.text = _game.game_title.to_upper()
	_instructions_label.text = _game.instructions
	_status_label.text = ""
	_progress_bar.value = 0.0
	_game.finished.connect(_on_game_finished)
	_game.status_changed.connect(_on_game_status)
	_game.mistake_made.connect(_on_game_mistake)
	_open = true
	if shared and not snapshot.is_empty():
		# _open harus true dulu: apply_coop_snapshot menolak kalau
		# layer belum terbuka (snapshot awal langsung sinkron, tanpa
		# menunggu broadcast 0,1 dtk berikutnya).
		apply_coop_snapshot(task_id, snapshot)
	_report_timer = 0.0
	_last_reported = -1.0
	_root.visible = true
	level.set_local_minigame_open(true)
	return true


func apply_coop_snapshot(tid: StringName, snapshot: Dictionary) -> void:
	# Snapshot state dari otoritas server untuk mirror co-op bersama.
	if not _open or not _is_mirror or _task_id != tid or _game == null:
		return
	_game.apply_shared_state(snapshot)
	if snapshot.has("status"):
		_on_game_status(String(snapshot["status"]), bool(snapshot.get("status_good", true)))
	var prog: float = clampf(_game.get_progress(), 0.0, 1.0)
	_progress_bar.value = prog * 100.0
	_pct_label.text = "%d%%" % int(prog * 100.0)


func close_minigame(cancelled: bool) -> void:
	if not _open:
		return
	var tid: StringName = _task_id
	var was_mirror: bool = _is_mirror
	_open = false
	_is_mirror = false
	_task_id = StringName("")
	if _game != null:
		_game.queue_free()
		_game = null
	_root.visible = false
	var level: Node = _level()
	if level != null:
		level.set_local_minigame_open(false)
		if was_mirror:
			level.leave_coop_session(tid)
	if cancelled:
		minigame_cancelled.emit(tid)
	else:
		minigame_finished.emit(tid)


func force_close() -> void:
	close_minigame(true)


func simulate_key(keycode: int, unicode: int = 0) -> void:
	# Dipakai smoke test: menyuntikkan tombol ke game yang sedang terbuka.
	if _game == null:
		return
	var ev := InputEventKey.new()
	ev.pressed = true
	ev.keycode = keycode
	ev.unicode = unicode
	_game.handle_key(ev)


func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.is_action_pressed("ui_cancel"):
			close_minigame(true)
			get_viewport().set_input_as_handled()
			return
		if _is_mirror:
			# Mirror co-op bersama: tombol dikirim ke otoritas server,
			# game lokal tidak mengolah input sendiri.
			var level: Node = _level()
			if level != null:
				level.submit_coop_key(_task_id, event.keycode)
		elif _game != null:
			_game.handle_key(event)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if not _open or _game == null:
		return
	if not _is_mirror:
		_game.tick(delta)
		# tick() bisa menyelesaikan game (mis. Backup mencapai 100%) —
		# _finish() langsung menutup layer dan mengosongkan _game di tengah
		# frame ini; cek ulang sebelum membaca progres supaya tidak
		# memanggil method di _game yang sudah null.
		if not _open or _game == null:
			return
	var prog: float = clampf(_game.get_progress(), 0.0, 1.0)
	_progress_bar.value = prog * 100.0
	_pct_label.text = "%d%%" % int(prog * 100.0)
	_report_timer -= delta
	if _report_timer <= 0.0:
		_report_timer = 0.25
		if absf(prog - _last_reported) >= 0.05:
			_last_reported = prog
			var lv: Node = _level()
			if lv != null:
				lv.report_minigame_progress(_task_id, prog)
	_validate_open()


func _validate_open() -> void:
	var level: Node = _level()
	if level == null or not level.is_level_running():
		close_minigame(true)
		return
	if level.is_task_completed(_task_id):
		close_minigame(true)
		return
	var p: Node = level.get_local_player()
	if p == null or p.is_downed or p.is_hidden:
		close_minigame(true)
		return
	if p.global_position.distance_to(level.task_position(_task_id)) > CLOSE_RANGE:
		close_minigame(true)


func _on_game_finished() -> void:
	var tid: StringName = _task_id
	var level: Node = _level()
	close_minigame(false)
	if level != null:
		level.submit_minigame_result(tid)


func _on_game_status(text: String, good: bool) -> void:
	_status_label.text = text
	var c: Color = UiTheme.GREEN if good else UiTheme.RED
	_status_label.add_theme_color_override("font_color", c)
	_status_square.color = c


func _on_game_mistake() -> void:
	# Kesalahan di minigame: beri tahu level supaya musuh mendengar.
	var level: Node = _level()
	if level != null:
		level.report_mistake_noise()


func _level() -> Node:
	return get_tree().get_first_node_in_group("LevelManager")


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = UiTheme.DIM
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	panel.custom_minimum_size = Vector2(640, 470)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	_title_label = UiTheme.mk_title("", 32, UiTheme.INK)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vbox.add_child(_title_label)
	vbox.add_child(UiTheme.hairline())
	_instructions_label = UiTheme.mk_label("", 15, UiTheme.SOFT)
	_instructions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_instructions_label)
	_game_holder = Control.new()
	_game_holder.custom_minimum_size = Vector2(560, 240)
	_game_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_game_holder)
	var srow := HBoxContainer.new()
	srow.add_theme_constant_override("separation", 8)
	vbox.add_child(srow)
	_status_square = ColorRect.new()
	_status_square.custom_minimum_size = Vector2(10, 10)
	_status_square.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_status_square.color = UiTheme.MUTED
	srow.add_child(_status_square)
	_status_label = UiTheme.mk_label("", 16, UiTheme.INK)
	_status_label.custom_minimum_size = Vector2(0, 24)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	srow.add_child(_status_label)
	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", 10)
	vbox.add_child(prow)
	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	_progress_bar.value = 0.0
	_progress_bar.show_percentage = false
	_progress_bar.custom_minimum_size = Vector2(0, 8)
	_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_bar.add_theme_stylebox_override("background", UiTheme.bar_bg_style())
	_progress_bar.add_theme_stylebox_override("fill", UiTheme.bar_fill_style(UiTheme.AMBER))
	prow.add_child(_progress_bar)
	_pct_label = UiTheme.mk_label("0%", 14, UiTheme.MUTED, null, HORIZONTAL_ALIGNMENT_RIGHT)
	_pct_label.custom_minimum_size = Vector2(48, 0)
	prow.add_child(_pct_label)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 8)
	vbox.add_child(brow)
	var hint_left := UiTheme.mk_label("ESC: BATALKAN TUGAS, PROGRES HILANG", 12, UiTheme.MUTED)
	brow.add_child(hint_left)
	var hint_right := UiTheme.mk_label("MUSUH TETAP BERGERAK", 12, UiTheme.MUTED, null, HORIZONTAL_ALIGNMENT_RIGHT)
	hint_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brow.add_child(hint_right)
