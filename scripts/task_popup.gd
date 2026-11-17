class_name TaskPopup
extends CanvasLayer

const COL_GOLD := Color(1.0, 0.8, 0.25)
const COL_BLOOD := Color(0.78, 0.12, 0.12)
const COL_BLOOD_BRIGHT := Color(0.92, 0.18, 0.18)
const COL_PAPER := Color(0.93, 0.89, 0.78)
const COL_GREEN := Color(0.2, 0.9, 0.3)
const COL_RED := Color(1.0, 0.3, 0.3)
const COL_PANEL := Color(0.05, 0.05, 0.06, 0.98)
const COL_PANEL_BORDER := Color(0.55, 0.1, 0.1)
const COL_PHOSPHOR := Color(0.45, 0.85, 0.45)
const COL_PHOSPHOR_DIM := Color(0.25, 0.55, 0.28)
const COL_RUST := Color(0.32, 0.24, 0.16)
const COL_IRON := Color(0.16, 0.16, 0.18)
const COL_AMBER := Color(0.85, 0.62, 0.2)

const TITLE_FONT_PATH := "res://assets/fonts/Creepster-Regular.ttf"
const BODY_FONT_PATH := "res://assets/fonts/SpecialElite-Regular.ttf"

var _title_font: Font = null
var _body_font: Font = null

func _title_f() -> Font:
	if _title_font == null:
		_title_font = load(TITLE_FONT_PATH) as Font
	return _title_font

func _body_f() -> Font:
	if _body_font == null:
		_body_font = load(BODY_FONT_PATH) as Font
	return _body_font

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
var boss_warn_label: Label
var boss_warn_timer := 0.0

var rng := RandomNumberGenerator.new()

var excel_q := 0
var excel_data: Array = []
var excel_formula_text := ""
var excel_answer := 0
var excel_input := ""
var excel_input_label: Label = null
var excel_formula_label: Label = null
var excel_cursor_visible := true
var excel_cursor_timer := 0.0

var simon_round := 1
var simon_seq: Array = []
var simon_phase := "show"
var simon_show_idx := 0
var simon_show_timer := 0.0
var simon_input_idx := 0
var simon_flash_idx := -1
var simon_flash_timer := 0.0
var simon_lamps: Array = []
var simon_glows: Array = []
var simon_lamp_colors: Array = [Color(0.55, 0.16, 0.14), Color(0.16, 0.32, 0.5), Color(0.16, 0.45, 0.22), Color(0.6, 0.48, 0.14)]
var simon_lamp_names: Array = ["MERAH", "BIRU", "HIJAU", "KUNING"]

var foto_sheets := 0
var foto_marker := 0.0
var foto_dir := 1.0
var foto_speed := 1.1
var foto_zone := 0.5
var foto_zone_size := 0.3
var foto_bar: Control = null
var foto_papers: HBoxContainer = null

var key_code: Array = []
var key_entered: Array = []
var key_label: Label = null

var mash_prog := 0.0
var mash_bar: ProgressBar = null
var mash_handle: Panel = null
var mash_track: Control = null

var cari_round := 1
var cari_pages: Array = []
var cari_page := 0
var cari_target := ""
var cari_target_page := 0
var cari_target_slot := 1
var cari_boxes: Array = []
var cari_pool: Array = ["LAPORAN KEUANGAN Q3", "SURAT PEMECATAN", "NOTULEN RAPAT", "DAFTAR GAJI", "MEMO DIREKSI", "INVOICE KLIEN", "KONTRAK KERJA", "ABSENSI OKTOBER", "SURAT CUTI", "LAPORAN AUDIT", "RENCANA ANGGARAN", "BERKAS PAJAK", "SURAT PERINGATAN", "DAFTAR INVENTARIS", "PROPOSAL PROYEK", "SLIP GAJI"]

var urut_dates: Array = []
var urut_display: Array = []
var urut_next := 0
var urut_slots: Array = []

var demo_timer := 0.0

func _ready() -> void:
	rng.seed = 1234567 + Time.get_ticks_msec() % 100000
	layer = 20
	visible = false
	_build_ui()

func _stylebox(bg: Color, radius: int, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	if border_w > 0:
		s.border_color = border
		s.set_border_width_all(border_w)
	return s

func _panel(bg: Color, radius: int, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", _stylebox(bg, radius, border, border_w))
	return p

func _panelc(bg: Color, radius: int, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> PanelContainer:
	var s := _stylebox(bg, radius, border, border_w)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", s)
	return p

func _build_ui() -> void:
	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = COL_PANEL
	style.border_color = COL_PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	style.shadow_color = Color(0, 0, 0, 0.7)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	panel.add_child(vb)
	title_label = _make_label("", 38, COL_BLOOD_BRIGHT, true)
	title_label.add_theme_font_override("font", _title_f())
	vb.add_child(title_label)
	boss_warn_label = _make_label("", 22, COL_BLOOD_BRIGHT, true)
	boss_warn_label.add_theme_font_override("font", _title_f())
	boss_warn_label.visible = false
	vb.add_child(boss_warn_label)
	instr_label = _make_label("", 17, COL_PAPER, true)
	instr_label.add_theme_font_override("font", _body_f())
	instr_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(instr_label)
	status_label = _make_label("", 20, COL_GOLD, true)
	status_label.add_theme_font_override("font", _body_f())
	vb.add_child(status_label)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	vb.add_child(content)
	feedback_label = _make_label("", 18, COL_GREEN, true)
	feedback_label.add_theme_font_override("font", _body_f())
	vb.add_child(feedback_label)
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.custom_minimum_size = Vector2(720, 14)
	progress_bar.show_percentage = false
	progress_bar.add_theme_stylebox_override("background", _stylebox(Color(0.12, 0.08, 0.08), 2))
	progress_bar.add_theme_stylebox_override("fill", _stylebox(COL_BLOOD, 2))
	vb.add_child(progress_bar)
	progress_label = _make_label("0%", 18, COL_PAPER, true)
	progress_label.add_theme_font_override("font", _body_f())
	vb.add_child(progress_label)
	var foot := _make_label("Esc = batalkan tugas (progres hilang)  |  Dia tetap bergerak selagi kamu kerja!", 14, Color(0.55, 0.5, 0.45), true)
	foot.add_theme_font_override("font", _body_f())
	vb.add_child(foot)

func _make_label(text: String, size: int, color: Color, center: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _body_f())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _clear_content() -> void:
	for c in content.get_children():
		c.queue_free()
	simon_lamps.clear()
	simon_glows.clear()
	foto_bar = null
	foto_papers = null
	key_label = null
	excel_input_label = null
	excel_formula_label = null
	mash_bar = null
	mash_handle = null
	mash_track = null

func open_popup(p_level: Node, p_task_id: int, p_task_node: Node, p_kind: String, p_title: String, p_demo: bool) -> void:
	level = p_level
	task_id = p_task_id
	task_node = p_task_node
	kind = p_kind
	demo = p_demo
	open = true
	visible = true
	feedback_label.text = ""
	boss_warn_label.visible = false
	boss_warn_timer = 0.0
	title_label.text = p_title
	demo_timer = 0.0
	match kind:
		"excel":
			instr_label.text = "Baca rumusnya di formula bar, hitung dari tabel, ketik hasilnya di sel HASIL, lalu tekan ENTER. 7 soal."
			excel_q = 0
			excel_input = ""
			_next_excel()
		"simon":
			instr_label.text = "Panel listriknya tua. Hafalkan urutan lampunya, lalu ulangi. Salah, dia dengar."
			simon_round = 1
			_start_simon_round()
		"fotokopi":
			instr_label.text = "Arsip lama harus disalin. Tekan SPASI tepat saat penanda masuk zona. Salin 7 lembar!"
			foto_sheets = 0
			foto_marker = 0.0
			foto_dir = 1.0
			foto_speed = 1.1
			foto_zone = 0.5
			_build_foto()
		"keypad":
			instr_label.text = "Pintu keluar terkunci. Kode 5 digit itu ada di tugas-tugasmu. Ingat baik-baik!"
			key_code.clear()
			key_entered.clear()
			if level != null and level.get("code_digits") != null:
				for d in level.get("code_digits"):
					key_code.append(int(d))
			else:
				for i in range(5):
					key_code.append(rng.randi_range(1, 4))
			_build_keypad()
		"mash":
			instr_label.text = "Tuas selnya macet. Tarik sekuat tenaga, sebelum dia kembali."
			mash_prog = 0.0
			_build_mash()
		"cari":
			instr_label.text = "Berkas penting buat laporan lemburmu ada di tumpukan arsip ini. Bolak-balik halamannya pakai tombol panah kiri-kanan, tekan angka 1-4 buat milih berkas. Salah, dia dengar."
			cari_round = 1
			_next_cari()
		"urut":
			instr_label.text = "Catatan rapatnya berantakan. Urutkan dari tanggal paling lama, tekan angka 1-5. Salah urutan, ulang dari awal."
			urut_next = 0
			_gen_urut()
			_build_urut()
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
			p = float(excel_q) / 7.0
		"simon":
			p = float(simon_round - 1) / 4.0
		"fotokopi":
			p = float(foto_sheets) / 7.0
		"keypad":
			p = float(key_entered.size()) / 5.0
		"mash":
			p = mash_prog
		"cari":
			p = float(cari_round - 1) / 3.0
		"urut":
			p = float(urut_next) / 5.0
	progress_bar.value = p * 100.0
	progress_label.text = str(int(p * 100.0)) + "%"
	if task_node != null:
		task_node.set("progress", p)
		if level != null and level.has_method("popup_set_progress"):
			level.rpc_id(1, "popup_set_progress", task_id, p)

func _wrong(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.add_theme_color_override("font_color", COL_BLOOD_BRIGHT)
	if level != null:
		var me: Node = level.call("_my_player")
		if me != null:
			level.rpc_id(1, "report_noise", me.global_position, 400.0)
		if level.has_method("play_sfx"):
			level.play_sfx("thud", -4.0, 0.8)

func _right(msg: String) -> void:
	feedback_label.text = msg
	feedback_label.add_theme_color_override("font_color", COL_PHOSPHOR)
	if level != null and level.has_method("play_sfx"):
		level.play_sfx("tick", -8.0, 1.4)

func _grid_cell(text: String, size: int, bg: Color, fg: Color, min_w: float = 0.0) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.add_theme_stylebox_override("panel", _stylebox(bg, 0, Color(0.15, 0.3, 0.15), 1))
	var l := _make_label(text, size, fg, true)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(l)
	if min_w > 0.0:
		cell.custom_minimum_size = Vector2(min_w, 0)
	return cell

func _excel_cell(col: int, row: int) -> int:
	return int(excel_data[row][col])

func _excel_gen_grid() -> void:
	excel_data.clear()
	for r in range(4):
		var row_arr: Array = []
		for c in range(3):
			row_arr.append(rng.randi_range(2, 9))
		excel_data.append(row_arr)
	var a2: int = int(excel_data[0][0])
	var a3: int = a2 + rng.randi_range(0, 3) * 2
	if a3 > 9:
		a3 = a2 - rng.randi_range(0, 3) * 2
		if a3 < 2:
			a3 = a2
	excel_data[1][0] = a3

func _excel_formula_for(idx: int) -> Dictionary:
	match idx:
		0:
			return {"text": "=SUM(A2:A5)", "answer": _excel_cell(0, 0) + _excel_cell(0, 1) + _excel_cell(0, 2) + _excel_cell(0, 3)}
		1:
			return {"text": "=SUM(A2:C2)", "answer": _excel_cell(0, 0) + _excel_cell(1, 0) + _excel_cell(2, 0)}
		2:
			return {"text": "=AVERAGE(A2:A3)", "answer": (_excel_cell(0, 0) + _excel_cell(0, 1)) / 2}
		3:
			var m: int = _excel_cell(2, 0)
			for r in range(1, 4):
				m = maxi(m, _excel_cell(2, r))
			return {"text": "=MAX(C2:C5)", "answer": m}
		4:
			var mn: int = _excel_cell(1, 0)
			for r in range(1, 4):
				mn = mini(mn, _excel_cell(1, r))
			return {"text": "=MIN(B2:B5)", "answer": mn}
		5:
			return {"text": "=A4*B4", "answer": _excel_cell(0, 2) * _excel_cell(1, 2)}
		_:
			return {"text": "=A5+B5+C5", "answer": _excel_cell(0, 3) + _excel_cell(1, 3) + _excel_cell(2, 3)}

func _next_excel() -> void:
	if excel_q >= 7:
		close_popup(true)
		return
	if excel_q == 0:
		_excel_gen_grid()
	excel_q += 1
	excel_input = ""
	excel_cursor_visible = true
	excel_cursor_timer = 0.0
	status_label.text = "Soal " + str(excel_q) + "/7"
	var f: Dictionary = _excel_formula_for(excel_q - 1)
	excel_formula_text = str(f["text"])
	excel_answer = int(f["answer"])
	_clear_content()
	var crt := _panelc(Color(0.02, 0.05, 0.02), 4, Color(0.15, 0.3, 0.15), 2)
	crt.custom_minimum_size = Vector2(720, 36)
	content.add_child(crt)
	var hrow := HBoxContainer.new()
	hrow.add_theme_constant_override("separation", 10)
	crt.add_child(hrow)
	var hicon := _make_label("▣", 20, COL_PHOSPHOR_DIM, false)
	hrow.add_child(hicon)
	var htitle := _make_label("LAPORAN LEMBUR  -  TERMINAL", 17, COL_PHOSPHOR, false)
	hrow.add_child(htitle)
	var formula := _panelc(Color(0.03, 0.08, 0.03), 3, Color(0.15, 0.3, 0.15), 1)
	formula.custom_minimum_size = Vector2(720, 40)
	content.add_child(formula)
	var frow := HBoxContainer.new()
	frow.add_theme_constant_override("separation", 10)
	formula.add_child(frow)
	var fx := _make_label("fx", 18, COL_PHOSPHOR_DIM, false)
	frow.add_child(fx)
	excel_formula_label = _make_label(excel_formula_text, 24, COL_PHOSPHOR, false)
	frow.add_child(excel_formula_label)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)
	content.add_child(grid)
	grid.add_child(_grid_cell("", 14, Color(0.05, 0.1, 0.05), COL_PHOSPHOR_DIM, 40.0))
	for col in ["A", "B", "C"]:
		grid.add_child(_grid_cell(col, 14, Color(0.05, 0.1, 0.05), COL_PHOSPHOR_DIM, 226.0))
	for r in range(4):
		grid.add_child(_grid_cell(str(r + 2), 14, Color(0.05, 0.1, 0.05), COL_PHOSPHOR_DIM, 40.0))
		for c in range(3):
			grid.add_child(_grid_cell(str(_excel_cell(c, r)), 24, Color(0.03, 0.07, 0.03), COL_PHOSPHOR, 226.0))
	var arow := HBoxContainer.new()
	arow.add_theme_constant_override("separation", 12)
	arow.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(arow)
	var alabel := _make_label("HASIL", 20, COL_PHOSPHOR, false)
	arow.add_child(alabel)
	var answer_cell := PanelContainer.new()
	answer_cell.add_theme_stylebox_override("panel", _stylebox(Color(0.05, 0.12, 0.05), 0, COL_PHOSPHOR, 2))
	answer_cell.custom_minimum_size = Vector2(200, 52)
	excel_input_label = _make_label("", 26, COL_PHOSPHOR, true)
	excel_input_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	answer_cell.add_child(excel_input_label)
	arow.add_child(answer_cell)
	_refresh_excel_input()
	_refresh_progress()

func _refresh_excel_input() -> void:
	var shown := excel_input
	if excel_cursor_visible:
		shown += "▌"
	if excel_input_label != null:
		excel_input_label.text = shown

func press_digit(d: int) -> void:
	if not open or kind != "excel":
		return
	if excel_input.length() >= 3:
		return
	excel_input += str(d)
	_refresh_excel_input()

func press_backspace() -> void:
	if not open or kind != "excel":
		return
	if excel_input.length() > 0:
		excel_input = excel_input.substr(0, excel_input.length() - 1)
		_refresh_excel_input()

func _submit_excel() -> void:
	if not open or kind != "excel":
		return
	if excel_input == "":
		return
	var correct: int = excel_answer
	if int(excel_input) == correct:
		_right("Benar! Rumus cocok.")
		_next_excel()
	else:
		_wrong("Salah! Coba lagi.")
		excel_input = ""
		_refresh_excel_input()

func _start_simon_round() -> void:
	status_label.text = "Ronde " + str(simon_round) + "/4 - hafalkan " + str(simon_round + 2) + " lampu"
	simon_seq.clear()
	for i in range(simon_round + 2):
		simon_seq.append(rng.randi_range(1, 4))
	simon_phase = "show"
	simon_show_idx = 0
	simon_show_timer = 0.8
	simon_input_idx = 0
	_clear_content()
	var warn := _panelc(COL_BLOOD, 4)
	warn.custom_minimum_size = Vector2(720, 30)
	content.add_child(warn)
	var wrow := HBoxContainer.new()
	wrow.alignment = BoxContainer.ALIGNMENT_CENTER
	warn.add_child(wrow)
	var wlabel := _make_label("BAHAYA  -  TEGANGAN TINGGI", 15, COL_PAPER, true)
	wlabel.add_theme_font_override("font", _title_f())
	wrow.add_child(wlabel)
	var metal := _panelc(COL_RUST, 8, Color(0.2, 0.15, 0.1), 2)
	metal.custom_minimum_size = Vector2(720, 180)
	content.add_child(metal)
	var mrow := HBoxContainer.new()
	mrow.alignment = BoxContainer.ALIGNMENT_CENTER
	mrow.add_theme_constant_override("separation", 24)
	metal.add_child(mrow)
	for i in range(4):
		var slot := VBoxContainer.new()
		slot.add_theme_constant_override("separation", 6)
		mrow.add_child(slot)
		var lamp_wrap := Control.new()
		lamp_wrap.custom_minimum_size = Vector2(120, 120)
		slot.add_child(lamp_wrap)
		var glow := _panel(Color(simon_lamp_colors[i], 0.25), 70)
		glow.position = Vector2(-10, -10)
		glow.custom_minimum_size = Vector2(140, 140)
		glow.visible = false
		lamp_wrap.add_child(glow)
		simon_glows.append(glow)
		var lamp := _panel(simon_lamp_colors[i] * 0.45, 60, Color(0.12, 0.1, 0.08), 3)
		lamp.position = Vector2(0, 0)
		lamp.custom_minimum_size = Vector2(120, 120)
		lamp_wrap.add_child(lamp)
		simon_lamps.append(lamp)
		var num := _make_label("[" + str(i + 1) + "]", 16, Color(0.75, 0.7, 0.62), true)
		slot.add_child(num)
		var nm := _make_label(simon_lamp_names[i], 13, Color(0.55, 0.5, 0.44), true)
		slot.add_child(nm)
	feedback_label.text = "Perhatikan lampunya..."
	feedback_label.add_theme_color_override("font_color", COL_PAPER)

func _simon_light(idx: int, on: bool) -> void:
	if idx < 0 or idx >= simon_lamps.size():
		return
	var lamp: Panel = simon_lamps[idx]
	var glow: Panel = simon_glows[idx]
	if on:
		var bright: Color = simon_lamp_colors[idx] * 1.8
		bright.r = minf(bright.r, 1.0)
		bright.g = minf(bright.g, 1.0)
		bright.b = minf(bright.b, 1.0)
		lamp.add_theme_stylebox_override("panel", _stylebox(bright, 60, Color(1, 1, 1), 2))
		glow.visible = true
		glow.add_theme_stylebox_override("panel", _stylebox(Color(simon_lamp_colors[idx], 0.35), 70))
	else:
		lamp.add_theme_stylebox_override("panel", _stylebox(simon_lamp_colors[idx] * 0.45, 60, Color(0.12, 0.1, 0.08), 3))
		glow.visible = false

func _build_foto() -> void:
	status_label.text = "Lembar: " + str(foto_sheets) + "/7"
	_clear_content()
	var machine := _panelc(COL_IRON, 8, Color(0.3, 0.24, 0.16), 2)
	machine.custom_minimum_size = Vector2(720, 150)
	content.add_child(machine)
	var mvb := VBoxContainer.new()
	mvb.add_theme_constant_override("separation", 8)
	machine.add_child(mvb)
	var mhead := _make_label("MESIN FOTOKOPI  -  ARSIP LAMA", 16, COL_PAPER, true)
	mvb.add_child(mhead)
	foto_bar = Control.new()
	foto_bar.custom_minimum_size = Vector2(680, 44)
	foto_bar.draw.connect(_draw_foto_bar)
	mvb.add_child(foto_bar)
	foto_papers = HBoxContainer.new()
	foto_papers.alignment = BoxContainer.ALIGNMENT_CENTER
	foto_papers.add_theme_constant_override("separation", 6)
	mvb.add_child(foto_papers)
	_refresh_foto_papers()

func _refresh_foto_papers() -> void:
	if foto_papers == null:
		return
	for c in foto_papers.get_children():
		c.queue_free()
	for i in range(7):
		var sheet := _panel(COL_PAPER if i < foto_sheets else Color(0.22, 0.2, 0.17), 2, Color(0.45, 0.4, 0.3), 1)
		sheet.custom_minimum_size = Vector2(48, 32)
		foto_papers.add_child(sheet)

func _draw_foto_bar() -> void:
	if foto_bar == null:
		return
	var w := foto_bar.size.x
	var h := foto_bar.size.y
	foto_bar.draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.05, 0.06, 1.0))
	var zx0 := (foto_zone - foto_zone_size * 0.5) * w
	foto_bar.draw_rect(Rect2(zx0, 0, foto_zone_size * w, h), Color(COL_AMBER, 0.85))
	var mx := foto_marker * w
	foto_bar.draw_rect(Rect2(mx - 2, -4, 4, h + 8), Color(1.0, 0.85, 0.4, 1.0))

func _build_keypad() -> void:
	status_label.text = "Masukkan 5 digit kodenya."
	_clear_content()
	var body := _panelc(COL_IRON, 10, Color(0.3, 0.24, 0.16), 2)
	body.custom_minimum_size = Vector2(720, 170)
	content.add_child(body)
	var bvb := VBoxContainer.new()
	bvb.add_theme_constant_override("separation", 10)
	body.add_child(bvb)
	var lcd := _panelc(Color(0.02, 0.07, 0.02), 4, Color(0.15, 0.3, 0.15), 2)
	lcd.custom_minimum_size = Vector2(680, 56)
	bvb.add_child(lcd)
	key_label = _make_label("_ _ _ _ _", 36, COL_PHOSPHOR, true)
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lcd.add_child(key_label)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 16)
	bvb.add_child(btns)
	for i in range(4):
		var b := PanelContainer.new()
		b.add_theme_stylebox_override("panel", _stylebox(Color(0.2, 0.18, 0.15), 6, Color(0.4, 0.34, 0.26), 2))
		b.custom_minimum_size = Vector2(72, 52)
		var bl := _make_label(str(i + 1), 26, COL_PAPER, true)
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(bl)
		btns.add_child(b)
	var hint := _make_label("Kode itu ada di tugas-tugasmu. Jangan sampai lupa.", 18, COL_PAPER, true)
	content.add_child(hint)
	var hint2 := _make_label("Lupa? Tidak ada yang bisa mengingatkanmu.", 15, Color(0.55, 0.5, 0.45), true)
	content.add_child(hint2)
	_refresh_keypad()

func _refresh_keypad() -> void:
	if key_label == null:
		return
	var txt := ""
	for i in range(5):
		if i < key_entered.size():
			txt += str(key_entered[i]) + " "
		else:
			txt += "_ "
	key_label.text = txt.strip_edges()
	_refresh_progress()

func _build_mash() -> void:
	status_label.text = "Tarik tuasnya!"
	_clear_content()
	var frame := HBoxContainer.new()
	frame.alignment = BoxContainer.ALIGNMENT_CENTER
	frame.add_theme_constant_override("separation", 20)
	content.add_child(frame)
	var track_wrap := Control.new()
	track_wrap.custom_minimum_size = Vector2(60, 170)
	frame.add_child(track_wrap)
	mash_track = track_wrap
	var track := _panel(Color(0.1, 0.1, 0.11), 30, Color(0.3, 0.24, 0.16), 2)
	track.position = Vector2(0, 0)
	track.custom_minimum_size = Vector2(60, 170)
	track_wrap.add_child(track)
	mash_handle = _panel(Color(0.45, 0.14, 0.1), 22, Color(0.25, 0.08, 0.06), 2)
	mash_handle.position = Vector2(8, 8)
	mash_handle.custom_minimum_size = Vector2(44, 44)
	track_wrap.add_child(mash_handle)
	var side := VBoxContainer.new()
	side.add_theme_constant_override("separation", 8)
	frame.add_child(side)
	side.add_child(_make_label("Tekan SPASI berulang", 18, COL_PAPER, false))
	side.add_child(_make_label("buat narik tuasnya!", 18, COL_PAPER, false))
	mash_bar = ProgressBar.new()
	mash_bar.min_value = 0
	mash_bar.max_value = 100
	mash_bar.value = 0
	mash_bar.custom_minimum_size = Vector2(300, 16)
	mash_bar.show_percentage = false
	mash_bar.add_theme_stylebox_override("background", _stylebox(Color(0.12, 0.08, 0.08), 2))
	mash_bar.add_theme_stylebox_override("fill", _stylebox(COL_BLOOD, 2))
	side.add_child(mash_bar)

func _refresh_mash_handle() -> void:
	if mash_handle == null:
		return
	var y := 8.0 + mash_prog * 110.0
	mash_handle.position = Vector2(8, y)
	if mash_bar != null:
		mash_bar.value = mash_prog * 100.0

func _next_cari() -> void:
	var pool: Array = cari_pool.duplicate()
	pool.shuffle()
	cari_pages.clear()
	for p in range(3):
		var page: Array = []
		for i in range(4):
			page.append(pool[p * 4 + i])
		cari_pages.append(page)
	var flat := rng.randi_range(0, 11)
	cari_target = pool[flat]
	cari_target_page = flat / 4
	cari_target_slot = flat % 4 + 1
	cari_page = 0
	_build_cari()

func _cari_flip(dir: int) -> void:
	var np: int = clampi(cari_page + dir, 0, 2)
	if np == cari_page:
		return
	cari_page = np
	if level != null and level.has_method("play_sfx"):
		level.play_sfx("tick", -12.0, 1.0)
	_build_cari()

func _build_cari() -> void:
	status_label.text = "Ronde " + str(cari_round) + "/3  -  Cari: " + cari_target
	_clear_content()
	cari_boxes.clear()
	var paper := _panelc(Color(0.93, 0.89, 0.78), 4, Color(0.35, 0.28, 0.18), 2)
	paper.custom_minimum_size = Vector2(720, 0)
	content.add_child(paper)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 4)
	paper.add_child(pv)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	pv.add_child(head)
	var title := _make_label("BERKAS ARSIP KANTOR", 22, Color(0.16, 0.12, 0.08), true)
	title.add_theme_font_override("font", _title_f())
	head.add_child(title)
	var stamp := _make_label("RAHASIA", 16, COL_BLOOD, true)
	stamp.add_theme_font_override("font", _title_f())
	head.add_child(stamp)
	var sub := _make_label("Tumpukan arsip gudang - Halaman " + str(cari_page + 1) + "/3", 14, Color(0.35, 0.28, 0.18), false)
	pv.add_child(sub)
	var rule := HSeparator.new()
	pv.add_child(rule)
	var page: Array = cari_pages[cari_page]
	for i in range(4):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		pv.add_child(row)
		var num := _make_label(str(i + 1) + ".", 18, COL_BLOOD, true)
		row.add_child(num)
		var fname := _make_label(str(page[i]), 18, Color(0.16, 0.12, 0.08), false)
		fname.add_theme_font_override("font", _body_f())
		row.add_child(fname)
		cari_boxes.append(row)
	var foot := _make_label("← → ganti halaman  |  1-4 pilih berkas", 14, Color(0.35, 0.28, 0.18), false)
	pv.add_child(foot)
	_refresh_progress()

func _gen_urut() -> void:
	var start := rng.randi_range(3, 9)
	urut_dates.clear()
	for i in range(5):
		urut_dates.append(start + i * rng.randi_range(2, 4))
	urut_display.clear()
	for d in urut_dates:
		urut_display.append(d)
	urut_display.shuffle()

func _build_urut() -> void:
	status_label.text = "Klik dari tanggal paling lama. Benar: " + str(urut_next) + "/5"
	_clear_content()
	urut_slots.clear()
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	content.add_child(row)
	for i in range(5):
		var slot := _panelc(COL_IRON, 6, Color(0.3, 0.24, 0.16), 2)
		slot.custom_minimum_size = Vector2(132, 80)
		row.add_child(slot)
		var sv := VBoxContainer.new()
		sv.add_theme_constant_override("separation", 2)
		slot.add_child(sv)
		var num := _make_label(str(i + 1), 16, COL_GOLD, true)
		sv.add_child(num)
		var date := _make_label(str(urut_display[i]) + " Okt", 22, COL_PAPER, true)
		date.add_theme_font_override("font", _body_f())
		sv.add_child(date)
		urut_slots.append(slot)
	_refresh_progress()

func _urut_mark_done(pos: int) -> void:
	if pos < 0 or pos >= urut_slots.size():
		return
	var slot: PanelContainer = urut_slots[pos]
	slot.add_theme_stylebox_override("panel", _stylebox(Color(0.1, 0.3, 0.12), 6, COL_PHOSPHOR, 2))

func _urut_reset_marks() -> void:
	for slot in urut_slots:
		slot.add_theme_stylebox_override("panel", _stylebox(COL_IRON, 6, Color(0.3, 0.24, 0.16), 2))

func press_number(n: int) -> void:
	if not open:
		return
	match kind:
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
						if simon_round > 4:
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
				if key_entered.size() >= 5:
					var ok := true
					for i in range(5):
						if key_entered[i] != key_code[i]:
							ok = false
					if ok:
						_right("Kode benar! Pintu terbuka.")
						close_popup(true)
					else:
						_wrong("Kode salah! Coba lagi, ingat kodenya.")
						key_entered.clear()
						_refresh_keypad()
		"cari":
			if n >= 1 and n <= 4:
				var picked: String = str(cari_pages[cari_page][n - 1])
				if picked == cari_target:
					_right("Ketemu! (" + str(cari_round) + "/3)")
					cari_round += 1
					if cari_round > 3:
						_refresh_progress()
						close_popup(true)
					else:
						_refresh_progress()
						_next_cari()
				else:
					_wrong("Bukan itu! Cari lagi.")
		"urut":
			if n >= 1 and n <= 5:
				var picked: int = urut_display[n - 1]
				if picked == urut_dates[urut_next]:
					_urut_mark_done(n - 1)
					urut_next += 1
					if urut_next >= 5:
						_right("Catatan rapi! (5/5)")
						_refresh_progress()
						close_popup(true)
					else:
						_right("Benar! (" + str(urut_next) + "/5)")
						status_label.text = "Klik dari tanggal paling lama. Benar: " + str(urut_next) + "/5"
						_refresh_progress()
				else:
					_wrong("Urutan salah! Mulai dari awal.")
					urut_next = 0
					_urut_reset_marks()
					status_label.text = "Klik dari tanggal paling lama. Benar: 0/5"

func press_space() -> void:
	if not open:
		return
	match kind:
		"fotokopi":
			var half := foto_zone_size * 0.5
			if foto_marker >= foto_zone - half and foto_marker <= foto_zone + half:
				foto_sheets += 1
				_right("Lembar tersalin! (" + str(foto_sheets) + "/7)")
				foto_zone = randf_range(half + 0.05, 1.0 - half - 0.05)
				status_label.text = "Lembar: " + str(foto_sheets) + "/7"
				_refresh_foto_papers()
				_refresh_progress()
				if foto_sheets >= 7:
					close_popup(true)
			else:
				_wrong("Miss! Penanda di luar zona hijau.")
		"mash":
			mash_prog = minf(1.0, mash_prog + 0.07)
			_refresh_mash_handle()
			_refresh_progress()
			if mash_prog >= 1.0:
				_right("Tuas berhasil ditarik!")
				close_popup(true)

func _process(delta: float) -> void:
	if not open:
		return
	if level != null and bool(level.get("paused")):
		return
	boss_warn_timer += delta
	if level != null:
		var bd := float(level.call("_boss_distance"))
		if bd >= 0.0 and bd < 200.0:
			boss_warn_label.text = "BOS SUDAH SANGAT DEKAT! Esc buat kabur!"
			boss_warn_label.add_theme_color_override("font_color", COL_BLOOD_BRIGHT)
			boss_warn_label.visible = true
			boss_warn_label.modulate.a = 0.75 + 0.25 * sin(boss_warn_timer * 8.0)
		elif bd >= 0.0 and bd < 350.0:
			boss_warn_label.text = "Bos mendekat..."
			boss_warn_label.add_theme_color_override("font_color", COL_AMBER)
			boss_warn_label.visible = true
			boss_warn_label.modulate.a = 1.0
		else:
			boss_warn_label.visible = false
	match kind:
		"excel":
			excel_cursor_timer += delta
			if excel_cursor_timer >= 0.45:
				excel_cursor_timer = 0.0
				excel_cursor_visible = not excel_cursor_visible
				_refresh_excel_input()
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
						simon_flash_idx = idx
						simon_flash_timer = 0.45
						simon_show_timer = 0.55
						simon_show_idx += 1
					else:
						for i in range(4):
							_simon_light(i, false)
						simon_flash_idx = -1
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
			_refresh_mash_handle()
	if demo:
		_demo_step(delta)

func _demo_step(delta: float) -> void:
	if demo and level != null and level.has_method("_boss_distance"):
		var bd := float(level.call("_boss_distance"))
		if bd >= 0.0 and bd < 120.0:
			var me: Node = level.call("_my_player")
			if me != null:
				me.set("demo_fleeing", true)
			close_popup(false)
			return
	demo_timer -= delta
	if demo_timer > 0.0:
		return
	match kind:
		"excel":
			var answer: String = str(excel_answer)
			if excel_input.length() < answer.length():
				press_digit(int(answer.substr(excel_input.length(), 1)))
				demo_timer = 0.25
			else:
				_submit_excel()
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
			if key_entered.size() < 5:
				press_number(int(key_code[key_entered.size()]))
				demo_timer = 0.35
		"mash":
			press_space()
			demo_timer = 0.12
		"cari":
			if cari_page != cari_target_page:
				_cari_flip(1 if cari_target_page > cari_page else -1)
			else:
				press_number(cari_target_slot)
			demo_timer = 0.4
		"urut":
			var target_date: int = urut_dates[urut_next]
			var pos := urut_display.find(target_date) + 1
			if pos >= 1:
				press_number(pos)
			demo_timer = 0.4

func _unhandled_input(event: InputEvent) -> void:
	if not open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: InputEventKey = event
		if k.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close_popup(false)
			return
		if kind == "excel":
			match k.keycode:
				KEY_0, KEY_KP_0:
					get_viewport().set_input_as_handled()
					press_digit(0)
				KEY_1, KEY_KP_1:
					get_viewport().set_input_as_handled()
					press_digit(1)
				KEY_2, KEY_KP_2:
					get_viewport().set_input_as_handled()
					press_digit(2)
				KEY_3, KEY_KP_3:
					get_viewport().set_input_as_handled()
					press_digit(3)
				KEY_4, KEY_KP_4:
					get_viewport().set_input_as_handled()
					press_digit(4)
				KEY_5, KEY_KP_5:
					get_viewport().set_input_as_handled()
					press_digit(5)
				KEY_6, KEY_KP_6:
					get_viewport().set_input_as_handled()
					press_digit(6)
				KEY_7, KEY_KP_7:
					get_viewport().set_input_as_handled()
					press_digit(7)
				KEY_8, KEY_KP_8:
					get_viewport().set_input_as_handled()
					press_digit(8)
				KEY_9, KEY_KP_9:
					get_viewport().set_input_as_handled()
					press_digit(9)
				KEY_BACKSPACE:
					get_viewport().set_input_as_handled()
					press_backspace()
				KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
					get_viewport().set_input_as_handled()
					_submit_excel()
			return
		match k.keycode:
			KEY_LEFT:
				if kind == "cari":
					get_viewport().set_input_as_handled()
					_cari_flip(-1)
			KEY_RIGHT:
				if kind == "cari":
					get_viewport().set_input_as_handled()
					_cari_flip(1)
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
			KEY_5:
				get_viewport().set_input_as_handled()
				press_number(5)
			KEY_6:
				get_viewport().set_input_as_handled()
				press_number(6)
			KEY_7:
				get_viewport().set_input_as_handled()
				press_number(7)
			KEY_8:
				get_viewport().set_input_as_handled()
				press_number(8)
			KEY_9:
				get_viewport().set_input_as_handled()
				press_number(9)
			KEY_SPACE:
				get_viewport().set_input_as_handled()
				press_space()
