extends MinigameBase
## Balas Email — ketik 4 kata yang tampil, tekan Enter tiap kata.

const WORDS: Array[String] = ["rapat", "laporan", "deadline", "lembur", "revisi", "jadwal", "anggaran", "meeting", "dokumen", "arsip", "proyek", "presentasi"]
const TOTAL: int = 4

var _words: Array[String] = []
var _idx: int = 0
var _typed: String = ""

var _word_label: Label = null
var _typed_label: Label = null
var _count_label: Label = null


func setup() -> void:
	game_title = "Balas Email"
	instructions = "Ketik kata yang tampil persis seperti itu, lalu tekan Enter."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	_count_label = _mk_label("", 16, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	_word_label = _mk_label("", 44, Color(1, 1, 1))
	vbox.add_child(_word_label)
	_typed_label = _mk_label("", 28, Color(0.7, 0.95, 0.7))
	vbox.add_child(_typed_label)
	var pool: Array[String] = WORDS.duplicate()
	pool.shuffle()
	_words = pool.slice(0, TOTAL)
	_refresh()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var kc: int = event.keycode
	if kc == KEY_BACKSPACE:
		_typed = _typed.left(_typed.length() - 1)
		_refresh()
		return
	if kc == KEY_ENTER or kc == KEY_KP_ENTER:
		if _typed == _words[_idx]:
			_idx += 1
			_typed = ""
			if _idx >= TOTAL:
				_set_status("Semua email terbalas!", true)
				_finish()
			else:
				_set_status("Terkirim! Lanjut.", true)
				_refresh()
		else:
			_set_status("Typo! Ketik ulang kata ini.", false)
			_typed = ""
			_refresh()
		return
	if event.unicode == 0:
		return
	var ch: String = String.chr(event.unicode).to_lower()
	if ch >= "a" and ch <= "z" and _typed.length() < 16:
		_typed += ch
		_refresh()


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_idx) / float(TOTAL)


func debug_hint() -> Dictionary:
	if _idx < _words.size():
		return {"text": _words[_idx]}
	return {}


func _refresh() -> void:
	_count_label.text = "Email %d/%d" % [mini(_idx + 1, TOTAL), TOTAL]
	_word_label.text = _words[_idx] if _idx < _words.size() else ""
	_typed_label.text = "Ketik: %s_" % _typed
