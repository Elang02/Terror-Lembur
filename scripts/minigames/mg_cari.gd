extends MinigameBase
## Cari Berkas — versi Elang. 3 ronde. Tiap ronde 12 nama berkas diacak
## dan dibagi ke 3 halaman (4 berkas per halaman). Satu berkas target
## ditunjuk di atas — bolak-balik halaman dengan panah kiri/kanan, lalu
## tekan 1-4 untuk memilih berkasnya. Salah pilih -> ronde yang sama
## diulang (target tetap). Ketemu 3 ronde -> selesai.

const POOL: Array[String] = ["LAPORAN KEUANGAN Q3", "SURAT PEMECATAN", "NOTULEN RAPAT", "DAFTAR GAJI", "MEMO DIREKSI", "INVOICE KLIEN", "KONTRAK KERJA", "ABSENSI OKTOBER", "SURAT CUTI", "LAPORAN AUDIT", "RENCANA ANGGARAN", "BERKAS PAJAK", "SURAT PERINGATAN", "DAFTAR INVENTARIS", "PROPOSAL PROYEK", "SLIP GAJI"]
const TOTAL_ROUNDS: int = 3

var _round: int = 1
var _pages: Array = []  # 3 halaman x 4 nama
var _page: int = 0
var _target: String = ""
var _target_page: int = 0
var _target_slot: int = 1

var _status_label: Label = null
var _page_label: Label = null
var _rows: VBoxContainer = null


func setup() -> void:
	game_title = "Cari Berkas"
	instructions = "Berkas penting buat laporan lemburmu ada di tumpukan arsip ini. Bolak-balik halamannya pakai tombol panah kiri-kanan, tekan angka 1-4 buat milih berkas. Salah, dia dengar."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)
	_status_label = _mk_label("", 20, Color(1, 0.9, 0.6))
	vbox.add_child(_status_label)
	_page_label = _mk_label("", 15, Color(0.85, 0.85, 0.9))
	vbox.add_child(_page_label)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 6)
	vbox.add_child(_rows)
	var foot := _mk_label("← → ganti halaman  |  1-4 pilih berkas", 14, Color(1, 1, 1, 0.6))
	vbox.add_child(foot)
	_next_round()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	if event.keycode == KEY_LEFT:
		_flip(-1)
		return
	if event.keycode == KEY_RIGHT:
		_flip(1)
		return
	var n: int = _pressed_number(event)
	if n < 1 or n > 4:
		return
	var picked: String = str(_pages[_page][n - 1])
	if picked == _target:
		_set_status("Ketemu! (%d/3)" % _round, true)
		_round += 1
		if _round > TOTAL_ROUNDS:
			_finish()
		else:
			_next_round()
	else:
		_set_status("Bukan itu! Cari lagi.", false)


func tick(_delta: float) -> void:
	pass


func get_progress() -> float:
	return float(_round - 1) / float(TOTAL_ROUNDS)


func debug_hint() -> Dictionary:
	return {"type": "cari", "target_page": _target_page, "target_slot": _target_slot}


func _next_round() -> void:
	var pool: Array = POOL.duplicate()
	pool.shuffle()
	_pages.clear()
	for p in range(3):
		var page: Array = []
		for i in range(4):
			page.append(pool[p * 4 + i])
		_pages.append(page)
	var flat: int = randi_range(0, 11)
	_target = str(pool[flat])
	_target_page = flat / 4
	_target_slot = flat % 4 + 1
	_page = 0
	_build_page()


func _flip(dir: int) -> void:
	var np: int = clampi(_page + dir, 0, 2)
	if np == _page:
		return
	_page = np
	_build_page()


func _build_page() -> void:
	_status_label.text = "Ronde %d/3  -  Cari: %s" % [_round, _target]
	_page_label.text = "Tumpukan arsip gudang - Halaman %d/3" % [_page + 1]
	for ch in _rows.get_children():
		ch.queue_free()
	var page: Array = _pages[_page]
	for i in range(4):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var num := _mk_label("%d." % (i + 1), 18, Color(1, 0.6, 0.55))
		row.add_child(num)
		var fname := _mk_label(str(page[i]), 18, Color(1, 1, 1))
		fname.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_child(fname)
		_rows.add_child(row)
