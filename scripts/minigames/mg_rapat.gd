extends MinigameBase
## Rapikan Ruang Rapat — 5 barang harus diletakkan di zona yang benar.
## Tekan angka 1-4 sesuai zona (1 Depan, 2 Tengah, 3 Belakang, 4 Samping).
## Salah letak -> barang kembali ke antrean, coba lagi setelah barang lain.
## Semua barang terletakkan -> ruang rapat rapi, tugas selesai.

const ZONES: Array[String] = [
	"1 Depan\n(papan)",
	"2 Tengah\n(meja)",
	"3 Belakang\n(kursi)",
	"4 Samping\n(proyektor)",
]

# [nama barang, zona benar 0-3]
const ITEMS: Array = [
	["Papan Tulis", 0],
	["Meja Rapat", 1],
	["Kursi", 2],
	["Proyektor", 3],
	["Layar Presentasi", 0],
]

var _queue: Array[int] = []
var _placed: int = 0

var _item_label: Label = null
var _count_label: Label = null


func supports_shared() -> bool:
	return true


func get_shared_state() -> Dictionary:
	return {
		"queue": _queue.duplicate(),
		"placed": _placed,
		"done": _done,
		"status": _last_status,
		"status_good": _last_status_good,
	}


func apply_shared_state(s: Dictionary) -> void:
	_queue.clear()
	for v in (s.get("queue", []) as Array):
		_queue.append(int(v))
	_placed = int(s.get("placed", 0))
	_done = bool(s.get("done", false))
	_count_label.text = "Ditempatkan: %d/5" % _placed
	_refresh()


func setup() -> void:
	game_title = "Rapikan Ruang Rapat"
	instructions = "Ruang rapat berantakan. Letakkan tiap barang di zona yang benar dengan menekan 1-4. Salah zona -> barang kembali ke antrean."
	custom_minimum_size = Vector2(560, 240)
	_queue = [0, 1, 2, 3, 4]
	_queue.shuffle()
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	vbox.add_child(_mk_label("Letakkan barang berikut di zona yang benar:", 16, Color(0.93, 0.89, 0.78)))
	_item_label = _mk_label("", 26, Color(1, 0.9, 0.6))
	vbox.add_child(_item_label)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)
	for z in range(ZONES.size()):
		var card := Panel.new()
		card.custom_minimum_size = Vector2(120, 64)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.13)
		style.border_color = Color(0.35, 0.35, 0.38)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		card.add_theme_stylebox_override("panel", style)
		hbox.add_child(card)
		var lbl := Label.new()
		lbl.text = ZONES[z]
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(lbl)
	_count_label = _mk_label("Ditempatkan: 0/5", 18, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	_refresh()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var n: int = _pressed_number(event)
	if n == 0 or _queue.is_empty():
		return
	var zone: int = n - 1
	var cur: int = _queue[0]
	if int(ITEMS[cur][1]) == zone:
		_placed += 1
		_queue.remove_at(0)
		_count_label.text = "Ditempatkan: %d/5" % _placed
		if _queue.is_empty():
			_set_status("Ruang rapat rapi!", true)
			_finish()
			return
		_set_status("Benar! %s sudah di tempatnya. (%d/5)" % [String(ITEMS[cur][0]), _placed], true)
	else:
		_queue.remove_at(0)
		_queue.append(cur)
		_set_status("Salah zona! %s bukan di %s — kembali ke antrean." % [String(ITEMS[cur][0]), ZONES[zone].split("\n")[0]], false)
		_report_mistake()
	_refresh()


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_placed) / float(ITEMS.size())


func debug_hint() -> Dictionary:
	if _queue.is_empty():
		return {"type": "rapat"}
	return {"type": "rapat", "next_zone": int(ITEMS[_queue[0]][1]) + 1}


func _refresh() -> void:
	if _item_label == null:
		return
	if _queue.is_empty():
		_item_label.text = "Semua barang sudah di tempatnya!"
	else:
		_item_label.text = "Letakkan: %s" % String(ITEMS[_queue[0]][0])
