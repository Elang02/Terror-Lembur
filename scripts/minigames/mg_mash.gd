extends MinigameBase
## Tuas Sel — versi Elang. Tarik tuas yang macet dengan menekan SPASI
## berulang-ulang. Setiap tekan naik 0.07, tapi progres turun sendiri
## 0.12 per detik — jadi harus ditekan cepat dan terus-menerus.
## Sampai 100% -> tuas berhasil ditarik, tugas selesai.

const PER_PRESS: float = 0.07
const DECAY_PER_SEC: float = 0.12

var _prog: float = 0.0

var _handle: Panel = null
var _bar: ProgressBar = null
var _pct_label: Label = null


func setup() -> void:
	game_title = "Tuas Sel"
	instructions = "Tuas selnya macet. Tarik sekuat tenaga dengan menekan SPASI berulang, sebelum dia kembali."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	var frame := HBoxContainer.new()
	frame.alignment = BoxContainer.ALIGNMENT_CENTER
	frame.add_theme_constant_override("separation", 20)
	vbox.add_child(frame)
	var track_wrap := Control.new()
	track_wrap.custom_minimum_size = Vector2(60, 170)
	track_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(track_wrap)
	var track := Panel.new()
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color(0.1, 0.1, 0.11)
	track_style.border_color = Color(0.3, 0.24, 0.16)
	track_style.set_border_width_all(2)
	track_style.set_corner_radius_all(30)
	track.add_theme_stylebox_override("panel", track_style)
	track.position = Vector2(0, 0)
	track.custom_minimum_size = Vector2(60, 170)
	track_wrap.add_child(track)
	_handle = Panel.new()
	var handle_style := StyleBoxFlat.new()
	handle_style.bg_color = Color(0.45, 0.14, 0.1)
	handle_style.border_color = Color(0.25, 0.08, 0.06)
	handle_style.set_border_width_all(2)
	handle_style.set_corner_radius_all(22)
	_handle.add_theme_stylebox_override("panel", handle_style)
	_handle.position = Vector2(8, 8)
	_handle.custom_minimum_size = Vector2(44, 44)
	track_wrap.add_child(_handle)
	var side := VBoxContainer.new()
	side.add_theme_constant_override("separation", 8)
	frame.add_child(side)
	side.add_child(_mk_label("Tekan SPASI berulang", 18, Color(0.93, 0.89, 0.78)))
	side.add_child(_mk_label("buat narik tuasnya!", 18, Color(0.93, 0.89, 0.78)))
	_bar = ProgressBar.new()
	_bar.min_value = 0.0
	_bar.max_value = 100.0
	_bar.value = 0.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(300, 16)
	side.add_child(_bar)
	_pct_label = _mk_label("Tuas: 0%", 20, Color(1, 0.9, 0.6))
	side.add_child(_pct_label)
	var hint := _mk_label("Jangan berhenti menekan — tuasnya turun sendiri!", 13, Color(1, 1, 1, 0.6))
	vbox.add_child(hint)
	_refresh()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	if event.keycode != KEY_SPACE:
		return
	_prog = minf(1.0, _prog + PER_PRESS)
	_refresh()
	if _prog >= 1.0:
		_set_status("Tuas berhasil ditarik!", true)
		_finish()


func tick(delta: float) -> void:
	if _done:
		return
	var before: float = _prog
	_prog = maxf(0.0, _prog - DECAY_PER_SEC * delta)
	if not is_equal_approx(before, _prog):
		_refresh()


func get_progress() -> float:
	return _prog


func debug_hint() -> Dictionary:
	return {"type": "mash"}


func _refresh() -> void:
	if _handle != null:
		_handle.position = Vector2(8, 8.0 + _prog * 110.0)
	if _bar != null:
		_bar.value = _prog * 100.0
	if _pct_label != null:
		_pct_label.text = "Tuas: %d%%" % int(_prog * 100.0)
