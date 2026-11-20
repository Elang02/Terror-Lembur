extends MinigameBase
## Laporan Excel — jawab 5 soal hitung cepat dengan tombol 1/2/3.

const TOTAL: int = 5

var _count: int = 0
var _options: Array[int] = []
var _correct_idx: int = 0

var _question_label: Label = null
var _options_label: Label = null
var _count_label: Label = null


func setup() -> void:
	game_title = "Laporan Excel"
	instructions = "Hitung cepat! Jawab 5 soal dengan tombol 1, 2, atau 3."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 18)
	add_child(vbox)
	_count_label = _mk_label("", 16, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	_question_label = _mk_label("", 40, Color(1, 1, 1))
	vbox.add_child(_question_label)
	_options_label = _mk_label("", 24, Color(0.7, 0.9, 1))
	vbox.add_child(_options_label)
	_new_question()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 3:
		return
	if n - 1 == _correct_idx:
		_count += 1
		_set_status("Benar! Rumus cocok.", true)
		if _count >= TOTAL:
			_finish()
		else:
			_new_question()
	else:
		_set_status("Salah hitung! Coba soal lain.", false)
		_new_question()


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_count) / float(TOTAL)


func debug_hint() -> Dictionary:
	return {"keycode": KEY_1 + _correct_idx}


func _new_question() -> void:
	var op: int = randi() % 3
	var a: int = randi_range(4, 18)
	var b: int = randi_range(3, 12)
	var answer: int = 0
	var text: String = ""
	if op == 0:
		answer = a + b
		text = "%d + %d = ?" % [a, b]
	elif op == 1:
		if b > a:
			var tmp: int = a
			a = b
			b = tmp
		answer = a - b
		text = "%d - %d = ?" % [a, b]
	else:
		a = randi_range(3, 9)
		b = randi_range(3, 9)
		answer = a * b
		text = "%d x %d = ?" % [a, b]
	_options = [answer]
	while _options.size() < 3:
		var d: int = answer + randi_range(-5, 5)
		if d > 0 and d != answer and not _options.has(d):
			_options.append(d)
	_options.shuffle()
	_correct_idx = _options.find(answer)
	_question_label.text = text
	var parts: Array[String] = []
	for i: int in range(3):
		parts.append("[%d] %d" % [i + 1, _options[i]])
	_options_label.text = "   ".join(parts)
	_count_label.text = "Soal %d/%d" % [_count + 1, TOTAL]
