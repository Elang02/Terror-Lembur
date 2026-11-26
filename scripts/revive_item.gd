extends Node2D
## ReviveItem — item pembangkit. Muncul di titik acak saat ada pemain
## yang terkurung. Partner mengambilnya (E), lalu menahan E di kurungan
## untuk membebaskan. Tersembunyi sampai Level memunculkannya.

var _bob: float = 0.0
var _sprite: Sprite2D = null
var _glow: PointLight2D = null

const TEX: Texture2D = preload("res://assets/sprites/revive_cross.png")


func _ready() -> void:
	z_index = 8
	visible = false
	_sprite = Sprite2D.new()
	_sprite.texture = TEX
	add_child(_sprite)
	# Cahaya suar hijau: revive terlihat dari jauh di area gelap,
	# supaya partner selalu bisa menemukan tempat penyelamatan.
	_glow = PointLight2D.new()
	_glow.texture = preload("res://assets/sprites/light_soft.png")
	_glow.color = Color(0.4, 1.0, 0.5)
	_glow.energy = 0.7
	_glow.texture_scale = 1.2
	add_child(_glow)
	var label := Label.new()
	label.text = "ITEM BANGKIT"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -32)
	label.size = Vector2(100, 14)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.5, 1, 0.6, 0.95))
	add_child(label)


func _process(delta: float) -> void:
	if not visible:
		return
	_bob += delta * 3.0
	if _sprite != null:
		_sprite.position.y = sin(_bob) * 3.0
		_sprite.scale = Vector2.ONE * (1.0 + 0.08 * sin(_bob * 2.0))
	if _glow != null:
		_glow.energy = 0.6 + 0.3 * sin(_bob * 2.0)


func show_at(pos: Vector2) -> void:
	global_position = pos
	visible = true


func hide_item() -> void:
	visible = false
