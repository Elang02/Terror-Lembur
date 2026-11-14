class_name TaskPopup
extends CanvasLayer

const COL_GOLD := Color(1.0, 0.85, 0.4)
const COL_GREEN := Color(0.2, 0.9, 0.3)
const COL_RED := Color(1.0, 0.3, 0.3)
const COL_PANEL := Color(0.08, 0.08, 0.1, 0.97)

var level: Node = null
var task_id := -1
var task_node: Node = null
var kind := ""
var open := false
var demo := false

var dim: ColorRect
var panel: PanelContainer
var title_label: Label
var instr_label: Label
var status_label: Label
var content: VBoxContainer
var feedback_label: Label
var progress_bar: ProgressBar
var progress_label: Label

var rng := RandomNumberGenerator.new()

var excel_q := 0
var excel_a := 0
var excel_b := 0
var excel_opts: Array = []
var excel_correct := 0

var simon_round := 1
var simon_seq: Array = []
var simon_phase := "show"
var simon_show_idx := 0
var simon_show_timer := 0.0
var simon_input_idx := 0
var simon_flash_idx := -1
var simon_flash_timer := 0.0
var simon_lamps: Array = []
var simon_lamp_colors: Array = [Color(0.85, 0.2, 0.2), Color(0.15, 0.45, 0.75), Color(0.15, 0.7, 0.25), Color(0.85, 0.7, 0.15)]

var foto_sheets := 0
var foto_marker := 0.0
var foto_dir := 1.0
var foto_speed := 1.1
var foto_zone := 0.5
var foto_zone_size := 0.3
var foto_bar: Control = null

var key_code: Array = []
var key_entered: Array = []
var key_label: Label = null

var mash_prog := 0.0
var mash_bar: ProgressBar = null

var demo_timer := 0.0

func _ready() -> void:
	rng.seed = 1234567 + Time.get_ticks_msec() % 100000
	layer = 20
	visible = false
	_build_ui()

func _build_ui() -> void:
	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(760, 520)
	panel.offset_left = -380
	panel.offset_top = -260
	panel.offset_right = 380
	panel.offset_bottom = 260
	var style := StyleBoxFlat.new()
	style.bg_color = COL_PANEL
	style.border_color = Color(0.5, 0.45, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)
	title_label = _make_label("", 34, COL_GOLD, true)
	vb.add_child(title_label)
	instr_label = _make_label("", 17, Color(0.92, 0.92, 0.92), true)
	instr_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(instr_label)
	status_label = _make_label("", 20, COL_GOLD, true)
	vb.add_child(status_label)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.custom_minimum_size = Vector2(700, 190)
	vb.add_child(content)
	feedback_label = _make_label("", 18, COL_GREEN, true)
	vb.add_child(feedback_label)
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(700, 14)
	progress_bar.show_percentage = false
	vb.add_child(progress_bar)
	progress_label = _make_label("0%", 18, Color(0.92, 0.92, 0.92), true)
	vb.add_child(progress_label)
	var foot := _make_label("Esc = batalkan tugas (progres hilang)  |  Musuh tetap bergerak selagi kamu kerja!", 14, Color(0.7, 0.7, 0.7), true)
	vb.add_child(foot)

func _make_label(text: String, size: int, color: Color, center: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _clear_content() -> void:
	for c in content.get_children():
		c.queue_free()
	simon_lamps.clear()
	foto_bar = null
	key_label = null
	mash_bar = null

func open_popup(p_level: Node, p_task_id: int, p_task_node: Node, p_kind: String, p_title: String, p_demo: bool) -> void:
	level = p_level
	task_id = p_task_id
	task_node = p_task_node
	kind = p_kind
	demo = p_demo
	open = true
	visible = true
	feedback_label.text = ""
	title_label.text = p_title
	demo_timer = 0.0
	match kind:
		"excel":
			instr_label.text = "Hitung cepat! Jawab 5 soal dengan tombol 1, 2, atau 3."
			excel_q = 0
			_next_excel()
		"simon":
			instr_label.text = "Perhatikan urutan lampu menyala, lalu ulangi dengan tombol 1-4."
			simon_round = 1
			_start_simon_round()
		"fotokopi":
			instr_label.text = "Tekan SPASI tepat saat penanda masuk zona hijau. Salin 5 lembar!"
			foto_sheets = 0
			foto_marker = 0.0
			foto_dir = 1.0
			foto_speed = 1.1
			foto_zone = 0.5
			_build_foto()
		"keypad":
			instr_label.text = "Ketik kode pintu 4 digit dengan tombol 1-4."
			key_code.clear()
			key_entered.clear()
			for i in range(4):
				key_code.append(rng.randi_range(1, 4))
			_build_keypad()
		"mash":
			instr_label.text = "Tarik tuasnya! Tekan SPASI berulang kali secepat mungkin."
			mash_prog = 0.0
			_build_mash()
	_refresh_progress()

func close_popup(finished: bool) -> void:
	if not open:
		return
	open = false
	visible = false
	_clear_content()
	if finished:
		if level != null and level.has_method("popup_task_done"):
			level.rpc_id(1, "popup_task_done", task_id)
	else:
		if level != null and level.has_method("popup_task_cancel"):
			level.rpc_id(1, "popup_task_cancel", task_id)
	if level != null and level.has_method("_on_popup_closed"):
		level.call("_on_popup_closed")
	level = null
	task_node = null
	task_id = -1

func _refresh_progress() -> void:
	var p := 0.0
	match kind:
		"excel":
			p = float(excel_q) / 5.0
		"simon":
			p = float(simon_round - 1) / 3.0
		"fotokopi":
			p = float(foto_sheets) / 5.0
		"keypad":
			p = float(key_entered.size()) / 4.0
		"mash":
			p = mash_prog
	progress_bar.value = p * 100.0
	progress_label.text = str(int(p * 100.0)) + "%"
	if task_node != null:
		task_node.set("progress", p)
		if level != null and level.has_method("popup_set_progress"):
			level.rpc_id(1, "popup_set_progress", task_id, p)

func _wrong(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.add_theme_color_override("font_color", COL_RED)
	if level != null:
		var me: Node = level.call("_my_player")
		if me != null:
			level.rpc_id(1, "report_noise", me.global_position, 400.0)
		if level.has_method("play_sfx"):
			level.play_sfx("thud", -4.0, 0.8)

func _right(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.add_theme_color_override("font_color", COL_GREEN)
	if level != null and level.has_method("play_sfx"):
		level.play_sfx("tick", -8.0, 1.4)

func _next_excel() -> void:
	if excel_q >= 5:
		close_popup(true)
		return
	excel_q += 1
	status_label.text = "Soal " + str(excel_q) + "/5"
	excel_a = rng.randi_range(2, 9)
	excel_b = rng.randi_range(2, 9)
	var correct: int = excel_a * excel_b
	excel_opts.clear()
	excel_opts.append(correct)
	while excel_opts.size() < 3:
		var wrong: int = correct + rng.randi_range(-6, 6)
		if wrong > 0 and not excel_opts.has(wrong):
			excel_opts.append(wrong)
	excel_opts.shuffle()
	excel_correct = excel_opts.find(correct)
	_clear_content()
	var q := _make_label(str(excel_a) + " x " + str(excel_b) + " = ?", 44, Color(1, 1, 1), true)
	content.add_child(q)
	var opts := _make_label("[1] " + str(excel_opts[0]) + "    [2] " + str(excel_opts[1]) + "    [3] " + str(excel_opts[2]), 26, Color(0.6, 0.85, 1.0), true)
	content.add_child(opts)
	_refresh_progress()

func _start_simon_round() -> void:
	status_label.text = "Ronde " + str(simon_round) + "/3 — hafalkan " + str(simon_round + 2) + " lampu"
	simon_seq.clear()
	for i in range(simon_round + 2):
		simon_seq.append(rng.randi_range(1, 4))
	simon_phase = "show"
	simon_show_idx = 0
	simon_show_timer = 0.8
	simon_input_idx = 0
	_clear_content()
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	content.add_child(row)
	for i in range(4):
		var lamp := ColorRect.new()
		lamp.custom_minimum_size = Vector2(110, 110)
		lamp.color = simon_lamp_colors[i] * 0.45
		row.add_child(lamp)
		simon_lamps.append(lamp)
	var keys := _make_label("[1]        [2]        [3]        [4]", 18, Color(0.8, 0.8, 0.8), true)
	content.add_child(keys)
	feedback_label.text = "Perhatikan lampunya..."
	feedback_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))

func _simon_light(idx: int, on: bool) -> void:
	if idx < 0 or idx >= simon_lamps.size():
		return
	var lamp: ColorRect = simon_lamps[idx]
	lamp.color = simon_lamp_colors[idx] if on else simon_lamp_colors[idx] * 0.45

func _build_foto() -> void:
	status_label.text = "Lembar: " + str(foto_sheets) + "/5"
	_clear_content()
	foto_bar = Control.new()
	foto_bar.custom_minimum_size = Vector2(700, 44)
	foto_bar.draw.connect(_draw_foto_bar)
	content.add_child(foto_bar)

func _draw_foto_bar() -> void:
	if foto_bar == null:
		return
	var w := foto_bar.size.x
	var h := foto_bar.size.y
	foto_bar.draw_rect(Rect2(0, 0, w, h), Color(0.12, 0.12, 0.2, 1.0))
	var zx0 := (foto_zone - foto_zone_size * 0.5) * w
	foto_bar.draw_rect(Rect2(zx0, 0, foto_zone_size * w, h), Color(0.2, 0.9, 0.3, 1.0))
	var mx := foto_marker * w
	foto_bar.draw_rect(Rect2(mx - 2, -4, 4, h + 8), Color(1.0, 0.85, 0.2, 1.0))

func _build_keypad() -> void:
	var code_txt := ""
	for d in key_code:
		code_txt += str(d)
	status_label.text = "Kode: " + code_txt
	_clear_content()
	key_label = _make_label("_ _ _ _", 44, Color(1, 1, 1), true)
	content.add_child(key_label)
	var hint := _make_label("Ketik 4 digit kodenya.", 18, Color(0.8, 0.8, 0.8), true)
	content.add_child(hint)
	_refresh_keypad()

func _refresh_keypad() -> void:
	if key_label == null:
		return
	var txt := ""
	for i in range(4):
		if i < key_entered.size():
			txt += str(key_entered[i]) + " "
		else:
			txt += "_ "
	key_label.text = txt.strip_edges()
	_refresh_progress()

func _build_mash() -> void:
	status_label.text = "Tarik tuasnya!"
	_clear_content()
	mash_bar = ProgressBar.new()
	mash_bar.min_value = 0
	mash_bar.max_value = 100
	mash_bar.value = 0
	mash_bar.custom_minimum_size = Vector2(700, 30)
	mash_bar.show_percentage = false
	content.add_child(mash_bar)
	var hint := _make_label("SPASI SPASI SPASI!", 26, Color(1, 1, 1), true)
	content.add_child(hint)

func press_number(n: int) -> void:
	if not open:
		return
	match kind:
		"excel":
			if n >= 1 and n <= 3:
				if n - 1 == excel_correct:
					_right("Benar! Rumus cocok.")
					_next_excel()
				else:
					_wrong("Salah! Coba lagi.")
		"simon":
			if simon_phase != "input":
				return
			if n >= 1 and n <= 4:
				_simon_light(n - 1, true)
				simon_flash_idx = n - 1
				simon_flash_timer = 0.15
				if n == simon_seq[simon_input_idx]:
					simon_input_idx += 1
					if simon_input_idx >= simon_seq.size():
						_right("Ronde selesai!")
						simon_round += 1
						if simon_round > 3:
							_refresh_progress()
							close_popup(true)
						else:
							_refresh_progress()
							_start_simon_round()
				else:
					_wrong("Salah urutan! Ulangi rondenya.")
					_start_simon_round()
		"keypad":
			if n >= 1 and n <= 4:
				key_entered.append(n)
				_refresh_keypad()
				if key_entered.size() >= 4:
					var ok := true
					for i in range(4):
						if key_entered[i] != key_code[i]:
							ok = false
					if ok:
						_right("Kode benar! Pintu terbuka.")
						close_popup(true)
					else:
						_wrong("Kode salah! Kode baru dibuat.")
						key_code.clear()
						key_entered.clear()
						for i in range(4):
							key_code.append(rng.randi_range(1, 4))
						_build_keypad()

func press_space() -> void:
	if not open:
		return
	match kind:
		"fotokopi":
			var half := foto_zone_size * 0.5
			if foto_marker >= foto_zone - half and foto_marker <= foto_zone + half:
				foto_sheets += 1
				_right("Lembar tersalin! (" + str(foto_sheets) + "/5)")
				foto_zone = randf_range(half + 0.05, 1.0 - half - 0.05)
				status_label.text = "Lembar: " + str(foto_sheets) + "/5"
				_refresh_progress()
				if foto_sheets >= 5:
					close_popup(true)
			else:
				_wrong("Miss! Penanda di luar zona hijau.")
		"mash":
			mash_prog = minf(1.0, mash_prog + 0.09)
			if mash_bar != null:
				mash_bar.value = mash_prog * 100.0
			_refresh_progress()
			if mash_prog >= 1.0:
				_right("Tuas berhasil ditarik!")
				close_popup(true)

func _process(delta: float) -> void:
	if not open:
		return
	match kind:
		"simon":
			if simon_flash_idx >= 0:
				simon_flash_timer -= delta
				if simon_flash_timer <= 0.0:
					_simon_light(simon_flash_idx, false)
					simon_flash_idx = -1
			if simon_phase == "show":
				simon_show_timer -= delta
				if simon_show_timer <= 0.0:
					if simon_show_idx < simon_seq.size():
						var idx: int = simon_seq[simon_show_idx] - 1
						_simon_light(idx, true)
						simon_show_timer = 0.55
						simon_show_idx += 1
						if simon_show_idx > 0:
							_simon_light(simon_seq[simon_show_idx - 1] - 1, false)
					else:
						for i in range(4):
							_simon_light(i, false)
						simon_phase = "input"
						simon_input_idx = 0
						feedback_label.text = "Giliranmu! Ulangi urutannya."
						feedback_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
		"fotokopi":
			foto_marker += foto_dir * foto_speed * delta
			if foto_marker >= 1.0:
				foto_marker = 1.0
				foto_dir = -1.0
			elif foto_marker <= 0.0:
				foto_marker = 0.0
				foto_dir = 1.0
			if foto_bar != null:
				foto_bar.queue_redraw()
		"mash":
			mash_prog = maxf(0.0, mash_prog - 0.12 * delta)
			if mash_bar != null:
				mash_bar.value = mash_prog * 100.0
	if demo:
		_demo_step(delta)

func _demo_step(delta: float) -> void:
	demo_timer -= delta
	if demo_timer > 0.0:
		return
	match kind:
		"excel":
			press_number(excel_correct + 1)
			demo_timer = 0.5
		"simon":
			if simon_phase == "input" and simon_input_idx < simon_seq.size():
				press_number(int(simon_seq[simon_input_idx]))
				demo_timer = 0.4
			else:
				demo_timer = 0.3
		"fotokopi":
			var half := foto_zone_size * 0.5
			if foto_marker >= foto_zone - half and foto_marker <= foto_zone + half:
				press_space()
			demo_timer = 0.05
		"keypad":
			if key_entered.size() < 4:
				press_number(int(key_code[key_entered.size()]))
				demo_timer = 0.35
		"mash":
			press_space()
			demo_timer = 0.12

func _unhandled_input(event: InputEvent) -> void:
	if not open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: InputEventKey = event
		match k.keycode:
			KEY_ESCAPE:
				get_viewport().set_input_as_handled()
				close_popup(false)
			KEY_1:
				get_viewport().set_input_as_handled()
				press_number(1)
			KEY_2:
				get_viewport().set_input_as_handled()
				press_number(2)
			KEY_3:
				get_viewport().set_input_as_handled()
				press_number(3)
			KEY_4:
				get_viewport().set_input_as_handled()
				press_number(4)
			KEY_SPACE:
				get_viewport().set_input_as_handled()
				press_space()
