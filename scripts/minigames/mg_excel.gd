extends MinigameBase
## Laporan Excel — versi Elang. 7 soal rumus dari tabel 4x3 (A2:C5).
## Baca rumusnya di formula bar, hitung dari tabel, ketik hasilnya di
## sel HASIL lalu tekan ENTER (atau SPASI). Salah -> input dikosongkan,
## soal yang sama diulang. Rumus berurutan: SUM, SUM, AVERAGE, MAX, MIN,
## A4*B4, A5+B5+C5 (persis urutan di Elang).

const TOTAL: int = 7

var _q: int = 0
var _data: Array = []  # 4 baris x 3 kolom, _data[baris][kolom]
var _formula_text: String = ""
var _answer: int = 0
var _input: String = ""
var _cursor_visible: bool = true
var _cursor_timer: float = 0.0

var _count_label: Label = null
var _formula_label: Label = null
var _grid: GridContainer = null
var _input_label: Label = null


func setup() -> void:
	game_title = "Laporan Excel"
	instructions = "Baca rumusnya di formula bar, hitung dari tabel, ketik hasilnya di sel HASIL, lalu tekan ENTER. 7 soal."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)
	_count_label = _mk_label("", 16, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	var frow := HBoxContainer.new()
	frow.alignment = BoxContainer.ALIGNMENT_CENTER
	frow.add_theme_constant_override("separation", 10)
	vbox.add_child(frow)
	var fx := _mk_label("fx", 18, Color(0.25, 0.55, 0.28))
	frow.add_child(fx)
	_formula_label = _mk_label("", 24, Color(0.45, 0.85, 0.45))
	frow.add_child(_formula_label)
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 0)
	_grid.add_theme_constant_override("v_separation", 0)
	vbox.add_child(_grid)
	var arow := HBoxContainer.new()
	arow.alignment = BoxContainer.ALIGNMENT_CENTER
	arow.add_theme_constant_override("separation", 12)
	vbox.add_child(arow)
	var alabel := _mk_label("HASIL", 20, Color(0.45, 0.85, 0.45))
	arow.add_child(alabel)
	var answer_cell := PanelContainer.new()
	var cell_style := StyleBoxFlat.new()
	cell_style.bg_color = Color(0.05, 0.12, 0.05)
	cell_style.border_color = Color(0.45, 0.85, 0.45)
	cell_style.set_border_width_all(2)
	answer_cell.add_theme_stylebox_override("panel", cell_style)
	answer_cell.custom_minimum_size = Vector2(200, 44)
	_input_label = _mk_label("", 26, Color(0.45, 0.85, 0.45))
	_input_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	answer_cell.add_child(_input_label)
	arow.add_child(answer_cell)
	var hint := _mk_label("Ketik angka 0-9  |  Backspace hapus  |  ENTER / SPASI kirim", 13, Color(1, 1, 1, 0.6))
	vbox.add_child(hint)
	_next_question()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var kc: int = event.keycode
	if kc >= KEY_0 and kc <= KEY_9:
		_press_digit(kc - KEY_0)
		return
	if kc >= KEY_KP_0 and kc <= KEY_KP_9:
		_press_digit(kc - KEY_KP_0)
		return
	if kc == KEY_BACKSPACE:
		if _input.length() > 0:
			_input = _input.substr(0, _input.length() - 1)
			_refresh_input()
		return
	if kc == KEY_ENTER or kc == KEY_KP_ENTER or kc == KEY_SPACE:
		_submit()


func tick(delta: float) -> void:
	if _done:
		return
	_cursor_timer += delta
	if _cursor_timer >= 0.45:
		_cursor_timer = 0.0
		_cursor_visible = not _cursor_visible
		_refresh_input()


func get_progress() -> float:
	return float(_q - 1) / float(TOTAL) if _q > 0 else 0.0


func debug_hint() -> Dictionary:
	return {"answer": _answer}


func _cell(col: int, row: int) -> int:
	return int(_data[row][col])


func _gen_grid() -> void:
	_data.clear()
	for r in range(4):
		var row_arr: Array = []
		for c in range(3):
			row_arr.append(randi_range(2, 9))
		_data.append(row_arr)
	# Trik Elang: A3 dibuat berdekatan dengan A2 supaya AVERAGE tidak jauh.
	var a2: int = int(_data[0][0])
	var a3: int = a2 + randi_range(0, 3) * 2
	if a3 > 9:
		a3 = a2 - randi_range(0, 3) * 2
		if a3 < 2:
			a3 = a2
	_data[1][0] = a3


func _formula_for(idx: int) -> Dictionary:
	match idx:
		0:
			return {"text": "=SUM(A2:A5)", "answer": _cell(0, 0) + _cell(0, 1) + _cell(0, 2) + _cell(0, 3)}
		1:
			return {"text": "=SUM(A2:C2)", "answer": _cell(0, 0) + _cell(1, 0) + _cell(2, 0)}
		2:
			return {"text": "=AVERAGE(A2:A3)", "answer": (_cell(0, 0) + _cell(0, 1)) / 2}
		3:
			var m: int = _cell(2, 0)
			for r in range(1, 4):
				m = maxi(m, _cell(2, r))
			return {"text": "=MAX(C2:C5)", "answer": m}
		4:
			var mn: int = _cell(1, 0)
			for r in range(1, 4):
				mn = mini(mn, _cell(1, r))
			return {"text": "=MIN(B2:B5)", "answer": mn}
		5:
			return {"text": "=A4*B4", "answer": _cell(0, 2) * _cell(1, 2)}
		_:
			return {"text": "=A5+B5+C5", "answer": _cell(0, 3) + _cell(1, 3) + _cell(2, 3)}


func _next_question() -> void:
	if _q >= TOTAL:
		_finish()
		return
	if _q == 0:
		_gen_grid()
		_build_grid()
	_q += 1
	_input = ""
	_cursor_visible = true
	_cursor_timer = 0.0
	_count_label.text = "Soal %d/%d" % [_q, TOTAL]
	var f: Dictionary = _formula_for(_q - 1)
	_formula_text = str(f["text"])
	_answer = int(f["answer"])
	_formula_label.text = _formula_text
	_refresh_input()


func _build_grid() -> void:
	for ch in _grid.get_children():
		ch.queue_free()
	_grid.add_child(_grid_cell("", 14, 40.0))
	for col in ["A", "B", "C"]:
		_grid.add_child(_grid_cell(col, 14, 168.0))
	for r in range(4):
		_grid.add_child(_grid_cell(str(r + 2), 14, 40.0))
		for c in range(3):
			_grid.add_child(_grid_cell(str(_cell(c, r)), 22, 168.0))


func _grid_cell(text: String, font_size: int, min_w: float) -> PanelContainer:
	var cell := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.07, 0.03)
	style.border_color = Color(0.15, 0.3, 0.15)
	style.set_border_width_all(1)
	cell.add_theme_stylebox_override("panel", style)
	cell.custom_minimum_size = Vector2(min_w, 30)
	var l := _mk_label(text, font_size, Color(0.45, 0.85, 0.45))
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(l)
	return cell


func _press_digit(d: int) -> void:
	if _input.length() >= 3:
		return
	_input += str(d)
	_refresh_input()


func _refresh_input() -> void:
	if _input_label == null:
		return
	var shown: String = _input
	if _cursor_visible:
		shown += "▌"
	_input_label.text = shown


func _submit() -> void:
	if _input == "":
		return
	if int(_input) == _answer:
		_set_status("Benar! Rumus cocok.", true)
		_next_question()
	else:
		_set_status("Salah! Coba lagi.", false)
		_input = ""
		_refresh_input()
