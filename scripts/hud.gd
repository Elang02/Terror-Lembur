extends CanvasLayer
## HUD Level 1 — dibangun dari kode supaya mudah diubah tanpa mengotak-atik
## file .tscn. Menampilkan tugas, waktu, status pemain, prompt interaksi,
## pesan tengah layar, panel hasil (ending + bintang), dan panel putus koneksi.

var _tasks_label: Label = null
var _timer_label: Label = null
var _status_label: Label = null
var _prompt_label: Label = null
var _message_label: Label = null
var _flash_rect: ColorRect = null
var _result_panel: CenterContainer = null
var _result_title: Label = null
var _result_detail: Label = null
var _disconnect_panel: CenterContainer = null
var _disconnect_label: Label = null
var _message_timer: float = 0.0
var _flash_alpha: float = 0.0
var _task_total: int = 0
var _stamina_bar: ProgressBar = null
var _stamina_fill: StyleBoxFlat = null


func _ready() -> void:
	layer = 10
	_build_top_bar()
	_build_stamina_bar()
	_build_prompt_and_message()
	_build_result_panel()
	_build_disconnect_panel()
	_flash_rect = ColorRect.new()
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.color = Color(0, 0, 0, 0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)
	# Flash harus di bawah panel hasil: pindahkan panel ke depan.
	if _result_panel != null:
		move_child(_result_panel, -1)
	if _disconnect_panel != null:
		move_child(_disconnect_panel, -1)


func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0 and _message_label != null:
			_message_label.text = ""
	if _flash_alpha > 0.0:
		_flash_alpha = maxf(0.0, _flash_alpha - delta * 0.8)
		_flash_rect.color = Color(0, 0, 0, _flash_alpha)


func set_task_total(total: int) -> void:
	_task_total = total


func update_tasks(done: int, total: int, exit_open: bool) -> void:
	if _tasks_label == null:
		return
	var extra: String = " — PINTU TERBUKA!" if exit_open else ""
	_tasks_label.text = "Tugas: %d/%d%s" % [done, total, extra]


func update_timer(time_sec: float) -> void:
	if _timer_label == null:
		return
	var m: int = int(time_sec) / 60
	var s: int = int(time_sec) % 60
	_timer_label.text = "Waktu: %02d:%02d" % [m, s]


func update_status(lines: Array[String]) -> void:
	if _status_label == null:
		return
	_status_label.text = "\n".join(lines)


func show_prompt(text: String) -> void:
	if _prompt_label != null:
		_prompt_label.text = text

func set_stamina(ratio: float) -> void:
	if _stamina_bar == null:
		return
	_stamina_bar.value = clampf(ratio, 0.0, 1.0) * 100.0
	if _stamina_fill != null:
		_stamina_fill.bg_color = Color(0.9, 0.25, 0.2) if ratio < 0.25 else Color(0.55, 0.9, 0.35)


func _build_stamina_bar() -> void:
	var label := _mk_label("STAMINA", 12, Color(1, 1, 1, 0.75), Vector2.ZERO)
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 12
	label.offset_right = 80
	label.offset_top = -56
	label.offset_bottom = -36
	add_child(label)
	_stamina_fill = StyleBoxFlat.new()
	_stamina_fill.bg_color = Color(0.55, 0.9, 0.35)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.6)
	_stamina_bar = ProgressBar.new()
	_stamina_bar.min_value = 0.0
	_stamina_bar.max_value = 100.0
	_stamina_bar.value = 100.0
	_stamina_bar.show_percentage = false
	_stamina_bar.add_theme_stylebox_override("background", bg)
	_stamina_bar.add_theme_stylebox_override("fill", _stamina_fill)
	_stamina_bar.anchor_top = 1.0
	_stamina_bar.anchor_bottom = 1.0
	_stamina_bar.offset_left = 84
	_stamina_bar.offset_right = 284
	_stamina_bar.offset_top = -54
	_stamina_bar.offset_bottom = -34
	_stamina_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stamina_bar)

func show_message(text: String) -> void:
	if _message_label == null:
		return
	_message_label.text = text
	_message_timer = 3.5


func flash_blackout() -> void:
	_flash_alpha = 0.6


func show_result(success: bool, stars: int, ending: String, time_sec: float, deaths: int, done: int, total: int) -> void:
	if _result_panel == null:
		return
	var m: int = int(time_sec) / 60
	var s: int = int(time_sec) % 60
	_result_title.text = ending if success else "GAGAL — KEDUA PEMAIN TERTANGKAP"
	_result_title.add_theme_color_override("font_color", Color(0.6, 1, 0.65) if success and ending == "Happy Ending" else (Color(1, 0.8, 0.4) if success else Color(1, 0.45, 0.4)))
	var star_text: String = ""
	for i: int in range(3):
		star_text += "★" if i < stars else "☆"
	_result_detail.text = "Bintang: %s (%d/3)\nWaktu: %02d:%02d | Tertangkap: %d | Tugas: %d/%d" % [star_text, stars, m, s, deaths, done, total]
	_result_panel.visible = true


func show_disconnect(text: String) -> void:
	if _disconnect_panel == null:
		return
	_disconnect_label.text = text
	_disconnect_panel.visible = true


func _build_top_bar() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.position = Vector2(10, 10)
	bg.size = Vector2(320, 62)
	add_child(bg)
	_tasks_label = _mk_label("Tugas: 0/0", 16, Color.WHITE, Vector2(18, 16))
	_tasks_label.size = Vector2(304, 22)
	add_child(_tasks_label)
	_timer_label = _mk_label("Waktu: 00:00", 16, Color(1, 0.9, 0.6), Vector2(18, 42))
	_timer_label.size = Vector2(304, 22)
	add_child(_timer_label)
	_status_label = _mk_label("", 14, Color.WHITE, Vector2.ZERO)
	_status_label.anchor_left = 1.0
	_status_label.anchor_right = 1.0
	_status_label.offset_left = -320
	_status_label.offset_right = -14
	_status_label.offset_top = 12
	_status_label.offset_bottom = 60
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_status_label)
	var hint := _mk_label("WASD/Panah: Gerak  |  Shift: Lari (berisik!)  |  E: Interaksi  |  Esc: Batalkan tugas", 12, Color(1, 1, 1, 0.6), Vector2.ZERO)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.offset_left = 12
	hint.offset_right = 700
	hint.offset_top = -26
	hint.offset_bottom = -6
	add_child(hint)


func _build_prompt_and_message() -> void:
	var prompt_bg := ColorRect.new()
	prompt_bg.color = Color(0, 0, 0, 0.55)
	prompt_bg.anchor_left = 0.5
	prompt_bg.anchor_right = 0.5
	prompt_bg.anchor_top = 1.0
	prompt_bg.anchor_bottom = 1.0
	prompt_bg.offset_left = -320
	prompt_bg.offset_right = 320
	prompt_bg.offset_top = -58
	prompt_bg.offset_bottom = -30
	add_child(prompt_bg)
	_prompt_label = _mk_label("", 16, Color(1, 1, 0.7), Vector2.ZERO)
	_prompt_label.anchor_left = 0.5
	_prompt_label.anchor_right = 0.5
	_prompt_label.anchor_top = 1.0
	_prompt_label.anchor_bottom = 1.0
	_prompt_label.offset_left = -320
	_prompt_label.offset_right = 320
	_prompt_label.offset_top = -56
	_prompt_label.offset_bottom = -32
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_prompt_label)
	_message_label = _mk_label("", 17, Color(1, 0.85, 0.5), Vector2.ZERO)
	_message_label.anchor_left = 0.5
	_message_label.anchor_right = 0.5
	_message_label.offset_left = -400
	_message_label.offset_right = 400
	_message_label.offset_top = 78
	_message_label.offset_bottom = 104
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_message_label)


func _build_result_panel() -> void:
	_result_panel = CenterContainer.new()
	_result_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_panel.visible = false
	add_child(_result_panel)
	var panel := PanelContainer.new()
	_result_panel.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	_result_title = _mk_label("", 30, Color.WHITE, Vector2.ZERO)
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_result_title)
	_result_detail = _mk_label("", 16, Color.WHITE, Vector2.ZERO)
	_result_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_result_detail)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox)
	var retry := Button.new()
	retry.text = "Main Lagi"
	retry.custom_minimum_size = Vector2(140, 40)
	retry.pressed.connect(_on_retry_pressed)
	hbox.add_child(retry)
	var menu := Button.new()
	menu.text = "Menu Utama"
	menu.custom_minimum_size = Vector2(140, 40)
	menu.pressed.connect(_on_menu_pressed)
	hbox.add_child(menu)


func _build_disconnect_panel() -> void:
	_disconnect_panel = CenterContainer.new()
	_disconnect_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_disconnect_panel.visible = false
	add_child(_disconnect_panel)
	var panel := PanelContainer.new()
	_disconnect_panel.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	_disconnect_label = _mk_label("", 16, Color.WHITE, Vector2.ZERO)
	_disconnect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_disconnect_label)
	var menu := Button.new()
	menu.text = "Menu Utama"
	menu.custom_minimum_size = Vector2(140, 40)
	menu.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu)


func _mk_label(text: String, font_size: int, color: Color, pos: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	return l


func _level() -> Node:
	return get_tree().get_first_node_in_group("LevelManager")


func _on_retry_pressed() -> void:
	var lv: Node = _level()
	if lv != null:
		lv.request_restart()


func _on_menu_pressed() -> void:
	var lv: Node = _level()
	if lv != null:
		lv.request_menu()
	else:
		NetworkManager.disconnect_all()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
