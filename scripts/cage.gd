extends Node2D
## Cage — kurungan pemain yang tertangkap enemy. Muncul di posisi pemain
## saat tertangkap. Partner yang membawa Item Bangkit menahan E di sini
## untuk membebaskan. Tersembunyi sampai Level memunculkannya.

var _bar_fill: ColorRect = null


func _ready() -> void:
	z_index = 9
	visible = false
	for i: int in range(5):
		var bar := ColorRect.new()
		bar.color = Color(0.7, 0.7, 0.75, 0.95)
		bar.size = Vector2(4, 40)
		bar.position = Vector2(-18 + i * 9, -20)
		add_child(bar)
	var top := ColorRect.new()
	top.color = Color(0.7, 0.7, 0.75, 0.95)
	top.size = Vector2(40, 4)
	top.position = Vector2(-20, -22)
	add_child(top)
	var bottom := ColorRect.new()
	bottom.color = Color(0.7, 0.7, 0.75, 0.95)
	bottom.size = Vector2(40, 4)
	bottom.position = Vector2(-20, 18)
	add_child(bottom)
	var label := Label.new()
	label.text = "TERKURUNG!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -40)
	label.size = Vector2(100, 14)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 0.5, 0.45, 0.95))
	add_child(label)
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0, 0, 0, 0.7)
	bar_bg.size = Vector2(40, 5)
	bar_bg.position = Vector2(-20, 24)
	add_child(bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(0.4, 0.95, 0.45)
	_bar_fill.size = Vector2(0, 5)
	_bar_fill.position = Vector2(-20, 24)
	add_child(_bar_fill)


func show_at(pos: Vector2) -> void:
	global_position = pos
	set_rescue_progress(0.0)
	visible = true


func hide_cage() -> void:
	visible = false


func set_rescue_progress(value: float) -> void:
	if _bar_fill != null:
		_bar_fill.size.x = 40.0 * clampf(value, 0.0, 1.0)
