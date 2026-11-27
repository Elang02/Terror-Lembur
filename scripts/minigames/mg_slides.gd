extends MinigameBase
## Susun Slide — tekan slide sesuai urutan nomor 1-2-3-4 (2 ronde).

const ROUNDS: int = 2

var _order: Array[int] = []
var _next: int = 1
var _round: int = 1
var _picked: Array[bool] = [false, false, false, false]

var _target_label: Label = null
var _slide_labels: Array[Label] = []
var _slide_boxes: Array[ColorRect] = []


func setup() -> void:
	game_title = "Susun Slide"
	instructions = "Presentasi berantakan! Tekan slide sesuai urutan nomor 1, 2, 3, 4 (tombol 1-4)."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	_target_label = _mk_label("", 26, Color(1, 0.9, 0.6))
	vbox.add_child(_target_label)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 14)
	vbox.add_child(hbox)
	for i: int in range(4):
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 4)
		var box := ColorRect.new()
		box.custom_minimum_size = Vector2(110, 80)
		box.color = Color(0.25, 0.4, 0.6)
		cell.add_child(box)
		_slide_boxes.append(box)
		var num := _mk_label("?", 34, Color.WHITE)
		num.position = Vector2(0, 22)
		num.size = Vector2(110, 40)
		box.add_child(num)
		_slide_labels.append(num)
		var key := _mk_label("[%d]" % (i + 1), 16, Color(0.7, 0.9, 1))
		cell.add_child(key)
		hbox.add_child(cell)
	_new_round()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 4:
		return
	var pos: int = n - 1
	if _picked[pos]:
		return
	if _order[pos] == _next:
		_picked[pos] = true
		_slide_boxes[pos].color = Color(0.2, 0.55, 0.3)
		_next += 1
		if _next > 4:
			if _round >= ROUNDS:
				_set_status("Slide rapi! Presentasi siap.", true)
				_finish()
			else:
				_round += 1
				_set_status("Ronde 1 beres! Acak lagi...", true)
				_new_round()
		else:
			_set_status("Bagus! Lanjut nomor %d." % _next, true)
			_refresh()
	else:
		_set_status("Bukan itu! Cari slide nomor %d." % _next, false)


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return (float(_round - 1) * 4.0 + float(_next - 1)) / float(ROUNDS * 4)


func debug_hint() -> Dictionary:
	for pos: int in range(4):
		if _order[pos] == _next:
			return {"keycode": KEY_1 + pos}
	return {}


func _new_round() -> void:
	_order = [1, 2, 3, 4]
	_order.shuffle()
	_next = 1
	_picked = [false, false, false, false]
	for i: int in range(4):
		_slide_labels[i].text = str(_order[i])
		_slide_boxes[i].color = Color(0.25, 0.4, 0.6)
	_refresh()


func _refresh() -> void:
	_target_label.text = "Ronde %d/%d — cari slide nomor: %d" % [_round, ROUNDS, _next]
