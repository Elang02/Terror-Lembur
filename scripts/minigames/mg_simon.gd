extends MinigameBase
## Panel Listrik — hafalkan urutan lampu lalu ulangi (Simon, 3 ronde).

const LENGTHS: Array[int] = [3, 4, 5]
const LAMP_COLORS: Array[Color] = [Color(0.9, 0.3, 0.3), Color(0.3, 0.7, 0.9), Color(0.3, 0.85, 0.4), Color(0.95, 0.8, 0.3)]
const LAMP_DIM: Array[Color] = [Color(0.35, 0.12, 0.12), Color(0.12, 0.28, 0.35), Color(0.12, 0.32, 0.16), Color(0.35, 0.3, 0.12)]

var _round: int = 1
var _seq: Array[int] = []
var _phase: String = "show"  # show | input | gap
var _phase_t: float = 0.0
var _show_idx: int = 0
var _show_on: bool = false
var _input_idx: int = 0
var _lit: int = -1
var _flash_t: float = 0.0

var _round_label: Label = null
var _hint_label: Label = null
var _lamps: Array[ColorRect] = []


func setup() -> void:
	game_title = "Panel Listrik"
	instructions = "Perhatikan urutan lampu menyala, lalu ulangi dengan tombol 1-4."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	add_child(vbox)
	_round_label = _mk_label("", 20, Color(1, 0.9, 0.6))
	vbox.add_child(_round_label)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)
	for i: int in range(4):
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var lamp := ColorRect.new()
		lamp.custom_minimum_size = Vector2(90, 90)
		lamp.color = LAMP_DIM[i]
		cell.add_child(lamp)
		_lamps.append(lamp)
		var key := _mk_label("[%d]" % (i + 1), 16, Color(0.7, 0.9, 1))
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
	_flash_t = 0.25
	_refresh_lamps()
	if idx == _seq[_input_idx]:
		_input_idx += 1
		if _input_idx >= _seq.size():
			if _round >= LENGTHS.size():
				_set_status("Panel stabil! Listrik aman.", true)
				_finish()
			else:
				_round += 1
				_phase = "gap"
				_phase_t = 0.0
				_set_status("Ronde beres! Siap-siap ronde %d..." % _round, true)
		else:
			_set_status("Lanjut...", true)
	else:
		_set_status("Salah urutan! Perhatikan lagi dari awal.", false)
		_phase = "show"
		_phase_t = 0.0
		_show_idx = 0
		_show_on = false
		_input_idx = 0
		_hint_label.text = "Perhatikan urutannya..."


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
		if _phase_t >= 0.7:
			_start_round()
		return
	if _phase != "show":
		return
	_phase_t += delta
	var step: float = 0.65
	var total: float = step * float(_seq.size())
	if _phase_t >= total + 0.3:
		_phase = "input"
		_input_idx = 0
		_lit = -1
		_hint_label.text = "Giliranmu! Ulangi urutannya."
		_refresh_lamps()
		return
	var pos: float = _phase_t / step
	_show_idx = int(pos)
	_show_on = fmod(_phase_t, step) < 0.42
	_lit = _seq[_show_idx] if _show_on and _show_idx < _seq.size() else -1
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


func _start_round() -> void:
	_seq.clear()
	for i: int in range(LENGTHS[_round - 1]):
		_seq.append(randi() % 4)
	_phase = "show"
	_phase_t = 0.0
	_show_idx = 0
	_show_on = false
	_input_idx = 0
	_lit = -1
	_round_label.text = "Ronde %d/%d — hafalkan %d lampu" % [_round, LENGTHS.size(), _seq.size()]
	_hint_label.text = "Perhatikan urutannya..."
	_refresh_lamps()


func _refresh_lamps() -> void:
	for i: int in range(4):
		_lamps[i].color = LAMP_COLORS[i] if i == _lit else LAMP_DIM[i]
