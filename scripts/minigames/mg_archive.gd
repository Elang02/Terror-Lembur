extends MinigameBase
## Sortir Arsip — tekan 1/2/3 sesuai folder dokumen. 6 dokumen.

const FOLDERS: Array[String] = ["Keuangan", "HR", "Proyek"]
const FOLDER_COLORS: Array[Color] = [Color(0.3, 0.5, 0.9), Color(0.3, 0.75, 0.4), Color(0.9, 0.75, 0.3)]
const TOTAL: int = 6

var _count: int = 0
var _current: int = 0

var _doc_label: Label = null
var _doc_box: ColorRect = null
var _count_label: Label = null


func setup() -> void:
	game_title = "Sortir Arsip"
	instructions = "Arsip menumpuk! Tekan 1/2/3 sesuai folder tiap dokumen."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	add_child(vbox)
	_count_label = _mk_label("", 16, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	_doc_box = ColorRect.new()
	_doc_box.custom_minimum_size = Vector2(320, 64)
	_doc_box.color = Color(0.3, 0.5, 0.9)
	var center := CenterContainer.new()
	center.add_child(_doc_box)
	vbox.add_child(center)
	_doc_label = _mk_label("", 26, Color.WHITE)
	_doc_label.position = Vector2(0, 14)
	_doc_label.size = Vector2(320, 36)
	_doc_box.add_child(_doc_label)
	var folders := _mk_label("[1] Keuangan (biru)    [2] HR (hijau)    [3] Proyek (kuning)", 18, Color(0.85, 0.85, 0.9))
	vbox.add_child(folders)
	_new_doc()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 3:
		return
	if n - 1 == _current:
		_count += 1
		_set_status("Tersimpan di folder %s!" % FOLDERS[_current], true)
		if _count >= TOTAL:
			_finish()
		else:
			_new_doc()
	else:
		_set_status("Salah folder! Dokumennya %s." % FOLDERS[_current], false)
		_new_doc()


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_count) / float(TOTAL)


func debug_hint() -> Dictionary:
	return {"keycode": KEY_1 + _current}


func _new_doc() -> void:
	_current = randi() % 3
	_doc_box.color = FOLDER_COLORS[_current]
	_doc_label.text = "Dokumen: %s" % FOLDERS[_current]
	_count_label.text = "Dokumen %d/%d" % [_count + 1, TOTAL]
