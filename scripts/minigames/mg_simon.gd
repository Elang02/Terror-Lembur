extends MinigameBase
## Panel Listrik — versi Elang. Hafalkan urutan lampu lalu ulangi (Simon).
## 4 ronde, panjang urutan 3, 4, 5, 6 lampu. Lampu: MERAH/BIRU/HIJAU/
## KUNING, tombol 1-4. Salah urutan -> ronde yang sama diulang dari awal
## (urutan baru). Fase tunjuk: lampu menyala 0,45 dtk, jeda 0,55 dtk.

const LENGTHS: Array[int] = [3, 4, 5, 6]
const LAMP_COLORS: Array[Color] = [Color(0.55, 0.16, 0.14), Color(0.16, 0.32, 0.5), Color(0.16, 0.45, 0.22), Color(0.6, 0.48, 0.14)]
const LAMP_NAMES: Array[String] = ["MERAH", "BIRU", "HIJAU", "KUNING"]
const SHOW_FIRST_DELAY: float = 0.8
const SHOW_STEP: float = 0.55
const SHOW_ON: float = 0.45
const GAP_TIME: float = 0.7

var _round: int = 1
var _seq: Array[int] = []
var _phase: String = "show"  # show | input | gap
var _phase_t: float = 0.0
var _show_idx: int = 0
var _input_idx: int = 0
var _lit: int = -1
var _flash_t: float = 0.0

var _round_label: Label = null
var _hint_label: Label = null
var _lamps: Array[ColorRect] = []


func setup() -> void:
	game_title = "Panel Listrik"
	instructions = "Panel listriknya tua. Hafalkan urutan lampunya, lalu ulangi dengan tombol 1-4. Salah, dia dengar."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	_round_label = _mk_label("", 20, Color(1, 0.9, 0.6))
	vbox.add_child(_round_label)
	var warn := _mk_label("BAHAYA  -  TEGANGAN TINGGI", 15, Color(0.93, 0.89, 0.78))
	vbox.add_child(warn)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)
	for i: int in range(4):
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var lamp := ColorRect.new()
		lamp.custom_minimum_size = Vector2(90, 90)
		lamp.color = _dim_color(i)
		cell.add_child(lamp)
		_lamps.append(lamp)
		var key := _mk_label("[%d] %s" % [i + 1, LAMP_NAMES[i]], 16, Color(0.7, 0.9, 1))
		cell.add_child(key)
		hbox.add_child(cell)
	_hint_label = _mk_label("Perhatikan urutannya...", 18, Color(0.85, 0.85, 0.9))
	vbox.add_child(_hint_label)
	_start_round()


func handle_key(event: InputEventKey) -> void:
	if _done or _phase != "input":
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 4:
		return
	var idx: int = n - 1
	_lit = idx
	_flash_t = 0.15
	_refresh_lamps()
	if idx + 1 == _seq[_input_idx]:
		_input_idx += 1
		if _input_idx >= _seq.size():
			if _round >= LENGTHS.size():
				_set_status("Panel stabil! Listrik aman.", true)
				_finish()
			else:
				_round += 1
				_phase = "gap"
				_phase_t = 0.0
				_set_status("Ronde selesai! Siap-siap ronde %d..." % _round, true)
		else:
			_set_status("Lanjut...", true)
	else:
		_set_status("Salah urutan! Ulangi rondenya.", false)
		_start_round()


func tick(delta: float) -> void:
	if _done:
		return
	if _flash_t > 0.0:
		_flash_t -= delta
		if _flash_t <= 0.0 and _phase == "input":
			_lit = -1
			_refresh_lamps()
	if _phase == "gap":
		_phase_t += delta
		if _phase_t >= GAP_TIME:
			_start_round()
		return
	if _phase != "show":
		return
	_phase_t += delta
	if _phase_t < SHOW_FIRST_DELAY:
		return
	var t: float = _phase_t - SHOW_FIRST_DELAY
	var total: float = SHOW_STEP * float(_seq.size())
	if t >= total + 0.3:
		_phase = "input"
		_input_idx = 0
		_lit = -1
		_hint_label.text = "Giliranmu! Ulangi urutannya."
		_refresh_lamps()
		return
	var pos: int = int(t / SHOW_STEP)
	_show_idx = pos
	var within: float = fmod(t, SHOW_STEP)
	_lit = _seq[_show_idx] - 1 if _show_on(within) and _show_idx < _seq.size() else -1
	_refresh_lamps()


func get_progress() -> float:
	var within: float = 0.0
	if _phase == "input" and not _seq.is_empty():
		within = float(_input_idx) / float(_seq.size())
	return (float(_round - 1) + within) / float(LENGTHS.size())


func debug_hint() -> Dictionary:
	return {"type": "simon"}


func awaiting_input() -> bool:
	return _phase == "input" and not _done


func remaining_sequence() -> Array[int]:
	var out: Array[int] = []
	for i: int in range(_input_idx, _seq.size()):
		out.append(_seq[i])
	return out


func _show_on(within: float) -> bool:
	return within < SHOW_ON


func _dim_color(i: int) -> Color:
	return LAMP_COLORS[i] * 0.45


func _bright_color(i: int) -> Color:
	var c: Color = LAMP_COLORS[i] * 1.8
	c.r = minf(c.r, 1.0)
	c.g = minf(c.g, 1.0)
	c.b = minf(c.b, 1.0)
	return c


func _start_round() -> void:
	_seq.clear()
	for i: int in range(LENGTHS[_round - 1]):
		_seq.append(randi_range(1, 4))
	_phase = "show"
	_phase_t = 0.0
	_show_idx = 0
	_input_idx = 0
	_lit = -1
	_round_label.text = "Ronde %d/4 — hafalkan %d lampu" % [_round, _seq.size()]
	_hint_label.text = "Perhatikan urutannya..."
	_refresh_lamps()


func _refresh_lamps() -> void:
	for i: int in range(4):
		_lamps[i].color = _bright_color(i) if i == _lit else _dim_color(i)
