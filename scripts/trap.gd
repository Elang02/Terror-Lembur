extends Node2D
## Trap — perangkap lantai. Disebar di seluruh map (node Trap1..N di
## container "Traps" level, sejajar Tasks/Doors). Dua cara pakai:
##   - DIINJAK (pemain masuk radius 26): terpicu sendiri, musuh
##     dipancing ke posisi trap ini (jebakan buat pemain yang ceroboh).
##   - DITEKAN E (jarak <= 64, trap harus kelihatan): diaktifkan sengaja,
##     musuh dipancing menjauh dari pemain.
## Level yang memutuskan trigger-nya (lihat level_1.gd _tick_traps /
## _handle_press); file ini hanya visual + state. Sekali pakai: setelah
## terpicu, trap rusak dan tidak bisa dipakai lagi.

@export var trap_id: String = "T1"

var armed: bool = true

var _blink: float = 0.0
var _plate: ColorRect = null
var _dot: ColorRect = null
var _label: Label = null


func _ready() -> void:
	z_index = 7
	_plate = ColorRect.new()
	_plate.color = Color(0.16, 0.16, 0.18)
	_plate.size = Vector2(30, 20)
	_plate.position = Vector2(-15, -10)
	add_child(_plate)
	_dot = ColorRect.new()
	_dot.color = Color(0.9, 0.15, 0.15)
	_dot.size = Vector2(6, 6)
	_dot.position = Vector2(-3, -3)
	add_child(_dot)


func _process(delta: float) -> void:
	if not visible or not armed:
		return
	_blink += delta * 4.0
	if _dot != null:
		_dot.modulate.a = 0.45 + 0.55 * (0.5 + 0.5 * sin(_blink))


func set_spent() -> void:
	armed = false
	if _dot != null:
		_dot.visible = false
	if _plate != null:
		_plate.color = Color(0.08, 0.08, 0.09)
