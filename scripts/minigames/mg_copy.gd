extends MinigameBase
## Fotokopi — tekan SPASI saat penanda di zona hijau. 5 lembar.

const TOTAL: int = 5

var _sheets: int = 0
var _marker: float = 0.0
var _dir: float = 1.0
var _zone_center: float = 0.5
var _zone_half: float = 0.14

var _count_label: Label = null


func setup() -> void:
	game_title = "Fotokopi"
	instructions = "Tekan SPASI tepat saat penanda masuk zona hijau. Salin 5 lembar!"
	custom_minimum_size = Vector2(560, 240)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	_count_label = _mk_label("", 22, Color(1, 0.9, 0.6))
	vbox.add_child(_count_label)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 130)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(spacer)
	_new_zone()
	_refresh()


func handle_key(event: InputEventKey) -> void:
	if _done:
		return
	if event.keycode != KEY_SPACE:
		return
	if marker_in_zone():
		_sheets += 1
		_set_status("Lembar %d tersalin!" % _sheets, true)
		if _sheets >= TOTAL:
			_finish()
		else:
			_new_zone()
			_refresh()
	else:
		_set_status("Meleset! Tunggu penandanya masuk zona.", false)


func tick(delta: float) -> void:
	if _done:
		return
	var speed: float = 0.85 + 0.12 * float(_sheets)
	_marker += _dir * speed * delta
	if _marker >= 1.0:
		_marker = 1.0
		_dir = -1.0
	elif _marker <= 0.0:
		_marker = 0.0
		_dir = 1.0
	queue_redraw()


func get_progress() -> float:
	return float(_sheets) / float(TOTAL)


func debug_hint() -> Dictionary:
	return {"type": "zone"}


func marker_in_zone() -> bool:
	return absf(_marker - _zone_center) <= _zone_half


func _new_zone() -> void:
	_zone_center = randf_range(0.3, 0.7)
	_zone_half = maxf(0.08, 0.14 - 0.012 * float(_sheets))


func _refresh() -> void:
	_count_label.text = "Lembar: %d/%d" % [_sheets, TOTAL]


func _draw() -> void:
	var bar := Rect2(20, 120, size.x - 40, 36)
	draw_rect(bar, Color(0.12, 0.12, 0.16))
	draw_rect(bar, Color(0.6, 0.6, 0.65, 0.5), false, 2.0)
	var zx0: float = bar.position.x + (_zone_center - _zone_half) * bar.size.x
	var zx1: float = bar.position.x + (_zone_center + _zone_half) * bar.size.x
	draw_rect(Rect2(zx0, bar.position.y, zx1 - zx0, bar.size.y), Color(0.25, 0.75, 0.35, 0.85))
	var mx: float = bar.position.x + _marker * bar.size.x
	draw_rect(Rect2(mx - 3, bar.position.y - 8, 6, bar.size.y + 16), Color(1, 0.9, 0.3))
