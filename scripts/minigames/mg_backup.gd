extends MinigameBase
## Backup Data — progres backup jalan sendiri (100% dalam ~25 detik).
## Sesekali muncul "sektor rusak" dengan angka 1-4: tekan angka itu
## sebelum waktunya habis (2 detik). Kalau telat ATAU salah tekan,
## progres mundur 12%. Sampai 100% -> backup selesai.

const FILL_PER_SEC: float = 4.0  # 100% dalam 25 detik
const SECTOR_TIME: float = 2.0  # waktu memperbaiki satu sektor rusak
const MISS_PENALTY: float = 12.0  # progres hilang kalau sektor terlewat

const FILES: Array[String] = [
	"arsip_2024.zip",
	"foto_kantor.rar",
	"laporan_q3.xlsx",
	"database.db",
	"dokumen_legal.pdf",
]

var _prog: float = 0.0
var _sector_active: bool = false
var _sector_digit: int = 0
var _sector_timer: float = 0.0
var _next_sector: float = 5.0
var _fixed: int = 0

var _bar: ProgressBar = null
var _pct_label: Label = null
var _sector_label: Label = null
var _file_label: Label = null


func supports_shared() -> bool:
	return true


func get_shared_state() -> Dictionary:
	return {
		"prog": _prog,
		"sector_active": _sector_active,
		"sector_digit": _sector_digit,
		"sector_timer": _sector_timer,
		"next_sector": _next_sector,
		"fixed": _fixed,
		"done": _done,
		"status": _last_status,
		"status_good": _last_status_good,
	}


func apply_shared_state(s: Dictionary) -> void:
	_prog = float(s.get("prog", 0.0))
	_sector_active = bool(s.get("sector_active", false))
	_sector_digit = int(s.get("sector_digit", 0))
	_sector_timer = float(s.get("sector_timer", 0.0))
	_next_sector = float(s.get("next_sector", 5.0))
	_fixed = int(s.get("fixed", 0))
	_done = bool(s.get("done", false))
	_refresh()
	if _sector_active and _sector_label != null:
		_sector_label.text = "SEKTOR RUSAK — TEKAN [%d]! (%.1f dtk)" % [_sector_digit, _sector_timer]


func setup() -> void:
	game_title = "Backup Data"
	instructions = "Backup berjalan sendiri. Kalau muncul SEKTOR RUSAK dengan angka, tekan angka itu sebelum waktunya habis — kalau telat ATAU salah tekan, progres mundur 12%."
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	vbox.add_child(_mk_label("Menyalin data ke server backup...", 18, Color(0.93, 0.89, 0.78)))
	_file_label = _mk_label("Menyalin: arsip_2024.zip", 15, Color(1, 1, 1, 0.6))
	vbox.add_child(_file_label)
	_bar = ProgressBar.new()
	_bar.min_value = 0.0
	_bar.max_value = 100.0
	_bar.value = 0.0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(480, 18)
	vbox.add_child(_bar)
	_pct_label = _mk_label("Backup: 0%", 20, Color(1, 0.9, 0.6))
	vbox.add_child(_pct_label)
	_sector_label = _mk_label("Semua sektor aman.", 18, Color(0.5, 1, 0.6))
	vbox.add_child(_sector_label)


func handle_key(event: InputEventKey) -> void:
	if _done or not _sector_active:
		return
	var n: int = _pressed_number(event)
	if n == 0:
		return
	if n == _sector_digit:
		_sector_active = false
		_fixed += 1
		_next_sector = randf_range(4.0, 7.0)
		_set_status("Sektor diperbaiki! (%d diperbaiki)" % _fixed, true)
		_refresh()
	else:
		# Salah tekan: backup mundur seperti sektor terlewat.
		_prog = maxf(0.0, _prog - MISS_PENALTY)
		_sector_active = false
		_next_sector = randf_range(4.0, 7.0)
		_set_status("Salah tekan! Backup mundur 12%.", false)
		_report_mistake()
		_refresh()


func tick(delta: float) -> void:
	if _done:
		return
	if _sector_active:
		_sector_timer -= delta
		if _sector_timer <= 0.0:
			_sector_active = false
			_prog = maxf(0.0, _prog - MISS_PENALTY)
			_next_sector = randf_range(4.0, 7.0)
			_set_status("Sektor rusak terlewat! Progres -12%.", false)
			_report_mistake()
			_refresh()
		else:
			_sector_label.text = "SEKTOR RUSAK — TEKAN [%d]! (%.1f dtk)" % [_sector_digit, _sector_timer]
		return
	_prog += FILL_PER_SEC * delta
	_next_sector -= delta
	if _next_sector <= 0.0:
		_sector_digit = randi_range(1, 4)
		_sector_timer = SECTOR_TIME
		_sector_active = true
		_set_status("Sektor rusak! Tekan [%d] cepat!" % _sector_digit, false)
		_refresh()
		return
	if _prog >= 100.0:
		_prog = 100.0
		_refresh()
		_set_status("Backup selesai!", true)
		_finish()
		return
	_refresh()


func get_progress() -> float:
	return _prog / 100.0


func debug_hint() -> Dictionary:
	return {"type": "backup", "sector": _sector_digit if _sector_active else 0}


func _refresh() -> void:
	if _bar != null:
		_bar.value = _prog
	if _pct_label != null:
		_pct_label.text = "Backup: %d%%" % int(_prog)
	if _file_label != null:
		var idx: int = mini(int(_prog / 20.0), FILES.size() - 1)
		_file_label.text = "Menyalin: %s" % FILES[idx]
	if _sector_label != null and not _sector_active:
		_sector_label.text = "Semua sektor aman. (diperbaiki: %d)" % _fixed
		_sector_label.add_theme_color_override("font_color", Color(0.5, 1, 0.6))
	elif _sector_label != null:
		_sector_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
