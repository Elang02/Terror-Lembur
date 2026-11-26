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
signal mistake_made

var game_title: String = "Tugas"
var instructions: String = ""

var _done: bool = false
var is_mirror: bool = false  # true = hanya menampilkan state dari server (task co-op bersama)

# Status terakhir (dipakai snapshot co-op supaya pemain lain ikut melihat
# pesan benar/salah dari otoritas server).
var _last_status: String = ""
var _last_status_good: bool = true


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


func _report_mistake() -> void:
	# Kesalahan pemain (jawaban salah, dsb.) — layer meneruskannya ke
	# level supaya musuh mendengar dan mendekat.
	mistake_made.emit()


func supports_shared() -> bool:
	# Task co-op bersama (satu puzzle dikerjakan berdua)? Hanya
	# mg_lan/mg_backup/mg_rapat yang meng-override ini jadi true.
	return false


func get_shared_state() -> Dictionary:
	# Snapshot state untuk dikirim dari otoritas server ke mirror pemain.
	return {}


func apply_shared_state(_state: Dictionary) -> void:
	# Terapkan snapshot dari server ke tampilan mirror. Hanya dipakai
	# game yang supports_shared().
	pass


func _set_status(text: String, good: bool) -> void:
	_last_status = text
	_last_status_good = good
	status_changed.emit(text, good)


func _mk_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	# Label minigame: mono sistem (UiTheme), tanpa outline. Semua label
	# duduk di dalam panel gelap, jadi outline hitam tebal tidak perlu.
	return UiTheme.mk_label(text, font_size, color, null, HORIZONTAL_ALIGNMENT_CENTER)


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
