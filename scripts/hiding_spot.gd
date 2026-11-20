extends Node2D
## HidingSpot — lemari/rak/bawah meja. Tekan E di dekatnya untuk sembunyi,
## tekan E lagi untuk keluar. Pemain sembunyi tidak terlihat enemy
## kecuali enemy sangat dekat. Logika dimiliki Level (jarak).

@export var spot_id: StringName = &"hide"

var occupied: bool = false
var _outer: ColorRect = null


func _ready() -> void:
	z_index = 6
	_outer = ColorRect.new()
	_outer.color = Color(0.25, 0.6, 1.0, 0.35)
	_outer.size = Vector2(30, 30)
	_outer.position = Vector2(-15, -15)
	add_child(_outer)
	var inner := ColorRect.new()
	inner.color = Color(0.08, 0.1, 0.2, 0.9)
	inner.size = Vector2(24, 24)
	inner.position = Vector2(-12, -12)
	add_child(inner)
	var label := Label.new()
	label.text = "SEMBUNYI"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-40, -30)
	label.size = Vector2(80, 14)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 0.8))
	add_child(label)


func set_occupied(value: bool) -> void:
	occupied = value
	if _outer != null:
		_outer.color = Color(0.25, 0.6, 1.0, 0.7) if value else Color(0.25, 0.6, 1.0, 0.35)
