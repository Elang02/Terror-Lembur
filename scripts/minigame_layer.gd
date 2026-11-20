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
}
const CLOSE_RANGE: float = 102.0

var _open: bool = false
var _task_id: StringName = StringName("")
var _game: MinigameBase = null
var _report_timer: float = 0.0
var _last_reported: float = -1.0

var _root: Control = null
var _title_label: Label = null
var _instructions_label: Label = null
var _game_holder: Control = null
var _status_label: Label = null
var _progress_bar: ProgressBar = null


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


func open_minigame(task_id: StringName, game_type: StringName) -> bool:
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
	_game_holder.add_child(_game)
	_game.setup()
	_title_label.text = _game.game_title
	_instructions_label.text = _game.instructions
	_status_label.text = ""
	_progress_bar.value = 0.0
	_game.finished.connect(_on_game_finished)
	_game.status_changed.connect(_on_game_status)
	_open = true
	_report_timer = 0.0
	_last_reported = -1.0
	_root.visible = true
	level.set_local_minigame_open(true)
	return true


func close_minigame(cancelled: bool) -> void:
	if not _open:
		return
	var tid: StringName = _task_id
	_open = false
	_task_id = StringName("")
	if _game != null:
		_game.queue_free()
		_game = null
	_root.visible = false
	var level: Node = _level()
	if level != null:
		level.set_local_minigame_open(false)
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
		if _game != null:
			_game.handle_key(event)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if not _open or _game == null:
		return
	_game.tick(delta)
	var prog: float = clampf(_game.get_progress(), 0.0, 1.0)
	_progress_bar.value = prog * 100.0
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
	_status_label.add_theme_color_override("font_color", Color(0.5, 1, 0.55) if good else Color(1, 0.6, 0.55))


func _level() -> Node:
	return get_tree().get_first_node_in_group("LevelManager")


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	var panel := PanelContainer.new()
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
	_title_label = _mk_label("", 28, Color(1, 0.9, 0.55))
	vbox.add_child(_title_label)
	_instructions_label = _mk_label("", 16, Color(0.9, 0.9, 0.95))
	_instructions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_instructions_label)
	_game_holder = Control.new()
	_game_holder.custom_minimum_size = Vector2(560, 240)
	_game_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_game_holder)
	_status_label = _mk_label("", 17, Color.WHITE)
	_status_label.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(_status_label)
	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	_progress_bar.value = 0.0
	_progress_bar.show_percentage = true
	_progress_bar.custom_minimum_size = Vector2(0, 22)
	vbox.add_child(_progress_bar)
	var hint := _mk_label("Esc = batalkan tugas (progres hilang)  |  Musuh tetap bergerak selagi kamu kerja!", 13, Color(1, 1, 1, 0.6))
	vbox.add_child(hint)


func _mk_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	return l
