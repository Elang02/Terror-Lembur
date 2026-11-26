extends Control
## Template cerita pembuka Terror Lembur (efek typewriter).
##
## CARA ISI CERITA (untuk Edward):
##   Ubah isi STORY_LINES di bawah dengan ceritamu sendiri.
##   Satu baris = satu layar ketikan. Baris kosong "" = jeda antar adegan.
##   Kalau mau cerita lebih panjang/pendek, tambah/hapus baris saja —
##   tidak ada kode lain yang perlu diubah.
##
## CARA MAIN: ketikan jalan sendiri (~30 huruf/detik).
##   - Tekan tombol apa saja / klik: selesaikan baris yang sedang diketik.
##   - Tekan lagi: lanjut ke baris berikutnya.
##   - ESC: lewati semua cerita, langsung mulai game.
## Setelah baris terakhir: tekan tombol apa saja untuk mulai main.

const STORY_LINES: Array[String] = [
	"Malam Jumat, pukul 23.47. Kantor sudah sepi — hanya tersisa kami berdua.",
	"Lembur lagi. Laporan harus selesai sebelum pagi, dan lift sudah mati sejak pukul sepuluh.",
	"Tapi malam ini ada yang berbeda. Lampu koridor berkedip sendiri. Dan langkah kaki itu... bukan langkah kami.",
	"Dia masih di sini. Penunggu kantor ini. Dan dia tidak suka ada yang lembur.",
	"Selesaikan semua tugas. Jangan sampai tertangkap. Dan kabur sebelum pagi.",
]
const CHARS_PER_SECOND: float = 30.0
const NEXT_SCENE: String = "res://scenes/level_1.tscn"

var _line: int = 0
var _shown: int = 0
var _char_accum: float = 0.0
var _waiting: bool = false  # baris sudah lengkap, menunggu input untuk lanjut

var _story_label: Label = null
var _hint_label: Label = null


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(760, 0)
	vbox.add_theme_constant_override("separation", 28)
	center.add_child(vbox)
	var title := Label.new()
	title.text = "TERROR LEMBUR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.85, 0.15, 0.15))
	vbox.add_child(title)
	_story_label = Label.new()
	_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_story_label.custom_minimum_size = Vector2(760, 220)
	_story_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_story_label.add_theme_font_size_override("font_size", 22)
	_story_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.85))
	vbox.add_child(_story_label)
	_hint_label = Label.new()
	_hint_label.text = "mengetik..."
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 15)
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	vbox.add_child(_hint_label)
	if STORY_LINES.is_empty():
		call_deferred("_start_game")
		return
	_story_label.text = ""


func _process(delta: float) -> void:
	if _waiting or _line >= STORY_LINES.size():
		return
	_char_accum += delta * CHARS_PER_SECOND
	var target: int = int(_char_accum)
	if target > _shown:
		_shown = mini(target, STORY_LINES[_line].length())
		_story_label.text = STORY_LINES[_line].substr(0, _shown)
		if _shown >= STORY_LINES[_line].length():
			_waiting = true
			_hint_label.text = "Tekan tombol apa saja untuk lanjut  »"


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k: InputEventKey = event
		if not k.pressed or k.echo:
			return
		if k.keycode == KEY_ESCAPE:
			_start_game()
			return
		_advance()
	elif event is InputEventMouseButton:
		var m: InputEventMouseButton = event
		if m.pressed and m.button_index == MOUSE_BUTTON_LEFT:
			_advance()


func _advance() -> void:
	if _line >= STORY_LINES.size():
		_start_game()
		return
	if not _waiting:
		# Baris masih diketik -> selesaikan langsung.
		_shown = STORY_LINES[_line].length()
		_story_label.text = STORY_LINES[_line]
		_waiting = true
		_hint_label.text = "Tekan tombol apa saja untuk lanjut  »"
		return
	_line += 1
	if _line >= STORY_LINES.size():
		_start_game()
		return
	_shown = 0
	_char_accum = 0.0
	_waiting = false
	_story_label.text = ""
	_hint_label.text = "mengetik..."


func _start_game() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE)
