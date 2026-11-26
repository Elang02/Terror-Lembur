extends MinigameBase
## Keypad Pintu — versi Elang, diadaptasi untuk Terror Lembur.
## ADAPTASI: di Elang kodenya diambil dari level.code_digits (dikumpulkan
## dari tugas lain) — Terror Lembur tidak punya mekanik itu. Di sini kode
## 5 digit (angka 1-4) diacak di setup(), DITAMPILKAN besar-besar selama
## 4 detik untuk dihafal, lalu disembunyikan dan pemain mengetiknya.
## Salah -> seluruh input dihapus, ketik ulang dari awal.

const CODE_LEN: int = 5
const SHOW_TIME: float = 4.0

var _code: Array[int] = []
var _entered: Array[int] = []
var _phase: String = "show"  # show | input
var _show_t: float = 0.0

var _status_label: Label = null
var _lcd_label: Label = null
var _hint_label: Label = null


func setup() -> void:
	game_title = "Keypad Pintu"
	instructions = "Pintu keluar terkunci. Hafalkan kode 5 digitnya, lalu ketik dengan tombol 1-4."
	custom_minimum_size = Vector2(560, 240)
	for i: int in range(CODE_LEN):
		_code.append(randi_range(1, 4))
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	_status_label = _mk_label("Hafalkan kodenya!", 22, Color(1, 0.9, 0.6))
	vbox.add_child(_status_label)
	var lcd := PanelContainer.new()
	var lcd_style := StyleBoxFlat.new()
	lcd_style.bg_color = Color(0.02, 0.07, 0.02)
	lcd_style.border_color = Color(0.15, 0.3, 0.15)
	lcd_style.set_border_width_all(2)
	lcd.add_theme_stylebox_override("panel", lcd_style)
	lcd.custom_minimum_size = Vector2(0, 64)
	vbox.add_child(lcd)
	_lcd_label = _mk_label("", 40, Color(0.45, 0.85, 0.45))
	_lcd_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lcd.add_child(_lcd_label)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 16)
	vbox.add_child(btns)
	for i: int in range(4):
		var b := PanelContainer.new()
		var bstyle := StyleBoxFlat.new()
		bstyle.bg_color = Color(0.2, 0.18, 0.15)
		bstyle.border_color = Color(0.4, 0.34, 0.26)
		bstyle.set_border_width_all(2)
		bstyle.set_corner_radius_all(6)
		b.add_theme_stylebox_override("panel", bstyle)
		b.custom_minimum_size = Vector2(72, 52)
		var bl := _mk_label(str(i + 1), 26, Color(0.93, 0.89, 0.78))
		bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(bl)
		btns.add_child(b)
	_hint_label = _mk_label("Kode itu cuma ditampilkan sebentar. Jangan sampai lupa.", 15, Color(1, 1, 1, 0.6))
	vbox.add_child(_hint_label)
	_phase = "show"
	_show_t = SHOW_TIME
	_refresh_lcd()


func handle_key(event: InputEventKey) -> void:
	if _done or _phase != "input":
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 4:
		return
	_entered.append(n)
	SfxManager.play_local(&"keypad_click")
	_refresh_lcd()
	if _entered.size() >= CODE_LEN:
		var ok: bool = true
		for i: int in range(CODE_LEN):
			if _entered[i] != _code[i]:
				ok = false
		if ok:
			SfxManager.play_local(&"keypad_beep")
			_set_status("Kode benar! Pintu terbuka.", true)
			_finish()
		else:
			_set_status("Kode salah! Coba lagi, ingat kodenya.", false)
			_report_mistake()
			_entered.clear()
			_refresh_lcd()


func tick(delta: float) -> void:
	if _done or _phase != "show":
		return
	_show_t -= delta
	_status_label.text = "Hafalkan kodenya! (%.0f)" % ceilf(maxf(_show_t, 0.0))
	if _show_t <= 0.0:
		_phase = "input"
		_status_label.text = "Masukkan 5 digit kodenya."
		_refresh_lcd()


func get_progress() -> float:
	return float(_entered.size()) / float(CODE_LEN)


func debug_hint() -> Dictionary:
	if _phase != "input" or _entered.size() >= CODE_LEN:
		return {"type": "keypad"}
	return {"keycode": KEY_1 + (_code[_entered.size()] - 1)}


func _code_text() -> String:
	var parts: Array[String] = []
	for d in _code:
		parts.append(str(d))
	return " ".join(parts)


func _refresh_lcd() -> void:
	if _lcd_label == null:
		return
	if _phase == "show":
		_lcd_label.text = _code_text()
		return
	var txt: String = ""
	for i: int in range(CODE_LEN):
		if i < _entered.size():
			txt += str(_entered[i]) + " "
		else:
			txt += "_ "
	_lcd_label.text = txt.strip_edges()
