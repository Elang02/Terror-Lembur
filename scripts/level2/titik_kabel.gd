extends Node2D
## Titik kabel jaringan — Level 2 (tampilan saja).
##
## Saat komputer security error, level_2.gd memilih satu titik kabel secara
## acak lalu memanggil set_rusak(true) di semua PC: panel memercikkan api
## kecil (cahaya oranye berkedip). Pemain memperbaikinya dengan E +
## minigame sambung kabel.

const TEX_CAHAYA: Texture2D = preload("res://assets/sprites/light_soft.png")

## Nama area yang muncul di pesan error & layar komputer.
@export var nama_area: String = "Titik kabel"

var rusak: bool = false

var _panel: ColorRect = null
var _percik: PointLight2D = null
var _waktu: float = 0.0


func _ready() -> void:
	z_index = 6
	_panel = ColorRect.new()
	_panel.color = Color(0.3, 0.32, 0.36)
	_panel.size = Vector2(14, 10)
	_panel.position = Vector2(-7, -5)
	add_child(_panel)
	for i: int in range(4):
		var colok := ColorRect.new()
		colok.color = [Color(0.9, 0.25, 0.25), Color(0.3, 0.55, 1.0), Color(0.95, 0.85, 0.3), Color(0.35, 0.9, 0.4)][i]
		colok.size = Vector2(2, 3)
		colok.position = Vector2(-6 + i * 3.5, -2)
		add_child(colok)
	_percik = PointLight2D.new()
	_percik.name = "Percikan"
	_percik.texture = TEX_CAHAYA
	_percik.color = Color(1.0, 0.6, 0.2)
	_percik.texture_scale = 0.35
	_percik.enabled = false
	add_child(_percik)


func set_rusak(nilai: bool) -> void:
	if nilai == rusak:
		return
	rusak = nilai
	if _percik != null:
		_percik.enabled = rusak
	if _panel != null:
		_panel.color = Color(0.45, 0.15, 0.12) if rusak else Color(0.3, 0.32, 0.36)


func _process(delta: float) -> void:
	if not rusak or _percik == null:
		return
	_waktu += delta
	# Percikan acak.
	_percik.energy = 1.4 if randf() < 0.25 else 0.25
