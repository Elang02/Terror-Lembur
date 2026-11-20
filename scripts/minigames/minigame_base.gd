class_name MinigameBase
extends Control
## Base class untuk minigame tugas Terror Lembur.
##
## Setiap game membangun UI-nya sendiri di setup(), menerima input keyboard
## lewat handle_key(), dan berjalan lewat tick() yang dipanggil layer dari
## _physics_process (60 Hz, deterministik, ramah smoke test headless).
## Game selesai -> _finish() -> signal finished -> layer melapor ke Level.
## debug_hint() mengembalikan input benar berikutnya (dipakai smoke test
## dan debugging; tidak dipakai saat bermain normal).

signal finished
signal status_changed(text: String, good: bool)

var game_title: String = "Tugas"
var instructions: String = ""

var _done: bool = false


func setup() -> void:
	pass


func handle_key(_event: InputEventKey) -> void:
	pass


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return 0.0


func is_finished() -> bool:
	return _done


func debug_hint() -> Dictionary:
	return {}


func _finish() -> void:
	if _done:
		return
	_done = true
	finished.emit()


func _set_status(text: String, good: bool) -> void:
	status_changed.emit(text, good)


func _mk_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	return l


func _num_key(event: InputEventKey, n: int) -> bool:
	# Tombol angka 1..4 (baris atas maupun numpad).
	var kc: int = event.keycode
	if kc == KEY_1 + (n - 1):
		return true
	if kc == KEY_KP_1 + (n - 1):
		return true
	return false


func _pressed_number(event: InputEventKey) -> int:
	for n: int in range(1, 5):
		if _num_key(event, n):
			return n
	return 0
