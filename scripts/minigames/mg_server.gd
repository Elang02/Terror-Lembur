extends MinigameBase
## Sinkronisasi Server — tekan tombol lampu yang menyala secepatnya (8x).
## Tugas co-op: tiap pemain menyelesaikan bagiannya sendiri; host
## menggabungkan kedua bagian (lihat level_1.gd).

const TOTAL: int = 8
const TIMEOUT: float = 1.4
const GAP: float = 0.35

var _hits: int = 0
var _active: int = -1
var _timer: float = 0.0
var _in_gap: bool = true

var _hits_label: Label = null
var _lamps: Array[ColorRect] = []


func setup() -> void:
	game_title = "Sinkronisasi Server"
	instructions = "Server tidak stabil! Tekan tombol lampu yang menyala (1-4) sebelum padam."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	add_child(vbox)
	_hits_label = _mk_label("", 20, Color(1, 0.9, 0.6))
	vbox.add_child(_hits_label)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)
	for i: int in range(4):
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var lamp := ColorRect.new()
		lamp.custom_minimum_size = Vector2(90, 90)
		lamp.color = Color(0.12, 0.2, 0.3)
		cell.add_child(lamp)
		_lamps.append(lamp)
		var key := _mk_label("[%d]" % (i + 1), 16, Color(0.7, 0.9, 1))
		cell.add_child(key)
		hbox.add_child(cell)
	_timer = 0.5
	_refresh()


func handle_key(event: InputEventKey) -> void:
	if _done or _active < 0:
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 4:
		return
	if n - 1 == _active:
		_hits += 1
		_set_status("Sinkron %d/%d!" % [_hits, TOTAL], true)
		_active = -1
		_in_gap = true
		_timer = GAP
		if _hits >= TOTAL:
			_finish()
		else:
			_refresh()
	else:
		_set_status("Salah tombol! Lampu yang menyala yang ditekan.", false)


func tick(delta: float) -> void:
	if _done:
		return
	_timer -= delta
	if _in_gap:
		if _timer <= 0.0:
			_active = randi() % 4
			_in_gap = false
			_timer = TIMEOUT
			_refresh()
	else:
		if _timer <= 0.0:
			_set_status("Terlambat! Server makin tidak stabil...", false)
			_active = -1
			_in_gap = true
			_timer = GAP
			_refresh()


func get_progress() -> float:
	return float(_hits) / float(TOTAL)


func debug_hint() -> Dictionary:
	if _active >= 0:
		return {"keycode": KEY_1 + _active}
	return {"type": "wait"}


func active_light() -> int:
	return _active


func _refresh() -> void:
	_hits_label.text = "Sinkron: %d/%d" % [_hits, TOTAL]
	for i: int in range(4):
		_lamps[i].color = Color(0.4, 0.95, 0.6) if i == _active else Color(0.12, 0.2, 0.3)
