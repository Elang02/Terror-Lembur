extends Node2D
## TaskStation — titik tugas yang diselesaikan lewat minigame.
## Logika penyelesaian dimiliki Level (host). Node ini hanya visual +
## konfigurasi (minigame apa yang dibuka). Interaksi dihitung Level
## dari jarak pemain, tanpa Area2D.

@export var task_id: StringName = &"task"
@export var title: String = "Tugas"
@export var game_type: StringName = &"excel"
@export var requires_two: bool = false
@export var accent: Color = Color(1.0, 0.85, 0.35)

var progress: float = 0.0
var completed: bool = false

var _bar_fill: ColorRect = null
var _status_label: Label = null
var _base: ColorRect = null


func _ready() -> void:
	z_index = 6
	_base = ColorRect.new()
	_base.color = Color(0.1, 0.1, 0.14, 0.92)
	_base.size = Vector2(34, 34)
	_base.position = Vector2(-17, -17)
	add_child(_base)
	var icon := ColorRect.new()
	icon.color = accent
	icon.size = Vector2(24, 16)
	icon.position = Vector2(-12, -13)
	add_child(icon)
	var screen := ColorRect.new()
	screen.color = Color(0.15, 0.35, 0.55)
	screen.size = Vector2(18, 10)
	screen.position = Vector2(-9, -10)
	add_child(screen)
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0, 0, 0, 0.7)
	bar_bg.size = Vector2(34, 5)
	bar_bg.position = Vector2(-17, 12)
	add_child(bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(0.4, 0.95, 0.45)
	_bar_fill.size = Vector2(0, 5)
	_bar_fill.position = Vector2(-17, 12)
	add_child(_bar_fill)
	_status_label = Label.new()
	_status_label.text = title
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.position = Vector2(-50, -34)
	_status_label.size = Vector2(100, 16)
	_status_label.add_theme_font_size_override("font_size", 12)
	_status_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	add_child(_status_label)


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	if _bar_fill != null:
		_bar_fill.size.x = 34.0 * progress


func set_completed() -> void:
	completed = true
	progress = 1.0
	set_progress(1.0)
	if _status_label != null:
		_status_label.text = title + " ✓"
		_status_label.add_theme_color_override("font_color", Color(0.5, 1, 0.55, 0.95))
	if _base != null:
		_base.color = Color(0.08, 0.22, 0.1, 0.92)
