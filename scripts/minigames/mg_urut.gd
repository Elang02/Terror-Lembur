extends MinigameBase
## Catatan Rapat — versi Elang. Urutkan 5 tanggal dari yang PALING LAMA.
## 5 tanggal diacak tampilannya (bulan Oktober). Tekan angka 1-5 untuk
## memilih tanggal berikutnya yang paling lama. Salah urutan -> mulai
## dari awal (semua tanda hijau dihapus). Benar 5/5 -> selesai.

const TOTAL: int = 5

var _dates: Array[int] = []  # terurut naik = paling lama dulu
var _display: Array[int] = []  # acakan dari _dates
var _next: int = 0

var _status_label: Label = null
var _slots: Array[PanelContainer] = []


func setup() -> void:
	game_title = "Catatan Rapat"
	instructions = "Catatan rapatnya berantakan. Urutkan dari tanggal paling lama, tekan angka 1-5. Salah urutan, ulang dari awal."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	add_child(vbox)
	_status_label = _mk_label("", 18, Color(1, 0.9, 0.6))
	vbox.add_child(_status_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)
	_gen_dates()
	for i: int in range(TOTAL):
		var slot := PanelContainer.new()
		slot.add_theme_stylebox_override("panel", _slot_style(false))
		slot.custom_minimum_size = Vector2(100, 84)
		var sv := VBoxContainer.new()
		sv.add_theme_constant_override("separation", 2)
		slot.add_child(sv)
		var num := _mk_label(str(i + 1), 16, Color(1, 0.8, 0.25))
		sv.add_child(num)
		var date := _mk_label("%d Okt" % _display[i], 22, Color(0.93, 0.89, 0.78))
		sv.add_child(date)
		row.add_child(slot)
		_slots.append(slot)
	_refresh_status()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var n: int = _pressed_number(event)
	if n == 0 and (event.keycode == KEY_5 or event.keycode == KEY_KP_5):
		n = 5
	if n < 1 or n > TOTAL:
		return
	var picked: int = _display[n - 1]
	if picked == _dates[_next]:
		_mark_done(n - 1)
		_next += 1
		if _next >= TOTAL:
			_set_status("Catatan rapi! (5/5)", true)
			_finish()
		else:
			_set_status("Benar! (%d/5)" % _next, true)
			_refresh_status()
	else:
		_set_status("Urutan salah! Mulai dari awal.", false)
		_report_mistake()
		_next = 0
		_reset_marks()
		_refresh_status()


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_next) / float(TOTAL)


func debug_hint() -> Dictionary:
	return {"type": "urut", "next_slot": _display.find(_dates[_next]) + 1}


func _gen_dates() -> void:
	var start: int = randi_range(3, 9)
	_dates.clear()
	# Naik kumulatif: tiap tanggal = tanggal sebelumnya + 2..4 hari,
	# jadi urutannya SELALU menaik (dulu randi_range baru per indeks
	# bisa membuat tanggal turun dan jawaban benar dinilai salah).
	var d: int = start
	for i in range(TOTAL):
		_dates.append(d)
		d += randi_range(2, 4)
	_display.clear()
	for v in _dates:
		_display.append(v)
	_display.shuffle()


func _slot_style(done: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if done:
		s.bg_color = Color(0.1, 0.3, 0.12)
		s.border_color = Color(0.45, 0.85, 0.45)
	else:
		s.bg_color = Color(0.16, 0.16, 0.18)
		s.border_color = Color(0.3, 0.24, 0.16)
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s


func _mark_done(pos: int) -> void:
	if pos < 0 or pos >= _slots.size():
		return
	_slots[pos].add_theme_stylebox_override("panel", _slot_style(true))


func _reset_marks() -> void:
	for slot in _slots:
		slot.add_theme_stylebox_override("panel", _slot_style(false))


func _refresh_status() -> void:
	_status_label.text = "Klik dari tanggal paling lama. Benar: %d/5" % _next
