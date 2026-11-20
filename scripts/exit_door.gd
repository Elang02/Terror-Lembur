extends Node2D
## ExitDoor — pintu keluar di Lobby. Terkunci sampai semua tugas selesai,
## lalu butuh 2 pemain berdiri di zona keluar bersamaan untuk kabur.

var is_locked: bool = true
var _sign: ColorRect = null
var _label: Label = null
var _bar_fill: ColorRect = null


func _ready() -> void:
	z_index = 6
	_sign = ColorRect.new()
	_sign.color = Color(0.75, 0.2, 0.2, 0.95)
	_sign.size = Vector2(44, 22)
	_sign.position = Vector2(-22, -11)
	add_child(_sign)
	_label = Label.new()
	_label.text = "KELUAR 🔒"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-50, -32)
	_label.size = Vector2(100, 16)
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 0.95))
	add_child(_label)
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0, 0, 0, 0.7)
	bar_bg.size = Vector2(44, 5)
	bar_bg.position = Vector2(-22, 14)
	add_child(bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(0.4, 0.95, 0.45)
	_bar_fill.size = Vector2(0, 5)
	_bar_fill.position = Vector2(-22, 14)
	add_child(_bar_fill)


func set_locked(locked: bool) -> void:
	is_locked = locked
	if _sign != null:
		_sign.color = Color(0.75, 0.2, 0.2, 0.95) if locked else Color(0.15, 0.7, 0.3, 0.95)
	if _label != null:
		_label.text = "KELUAR 🔒" if locked else "KELUAR — KABUR!"
		_label.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 0.95) if locked else Color(0.6, 1, 0.65, 0.95))


func set_progress(value: float) -> void:
	if _bar_fill != null:
		_bar_fill.size.x = 44.0 * clampf(value, 0.0, 1.0)
