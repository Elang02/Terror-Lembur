extends Node2D
## Titik cas HP (colokan di dinding/meja) — Level 2.
##
## Node ini hanya tampilan. Logika ngecas (siapa yang ngecas, korslet,
## mati karena genset) dimiliki level_2.gd di host, lalu level memanggil
## set_status() di semua PC. Lampu indikator kecil tetap menyala di gelap
## supaya colokan bisa ditemukan kalau pemain sudah cukup dekat.

enum Status { SIAP, DIPAKAI, KORSLET, MATI }

const TEX_CAHAYA: Texture2D = preload("res://assets/sprites/light_soft.png")
const WARNA: Dictionary = {
	Status.SIAP: Color(0.35, 1.0, 0.45),
	Status.DIPAKAI: Color(1.0, 0.85, 0.25),
	Status.KORSLET: Color(1.0, 0.25, 0.2),
	Status.MATI: Color(0.25, 0.25, 0.25),
}

## Nama area yang muncul di pesan & layar komputer.
@export var nama_area: String = "Titik cas"
## Fase 4 (Subuh, 04.00–05.00) hanya titik cas yang dicentang ini yang masih berfungsi.
@export var aktif_saat_subuh: bool = false

var status: int = Status.SIAP

var _led: ColorRect = null
var _indikator: PointLight2D = null
var _waktu: float = 0.0


func _ready() -> void:
	z_index = 6
	var pelat := ColorRect.new()
	pelat.color = Color(0.82, 0.82, 0.78)
	pelat.size = Vector2(12, 16)
	pelat.position = Vector2(-6, -8)
	add_child(pelat)
	for i: int in range(2):
		var lubang := ColorRect.new()
		lubang.color = Color(0.15, 0.15, 0.15)
		lubang.size = Vector2(2, 4)
		lubang.position = Vector2(-3 + i * 4, -5)
		add_child(lubang)
	_led = ColorRect.new()
	_led.size = Vector2(4, 3)
	_led.position = Vector2(-2, 3)
	add_child(_led)
	_indikator = PointLight2D.new()
	_indikator.name = "Indikator"
	_indikator.texture = TEX_CAHAYA
	_indikator.texture_scale = 0.22
	add_child(_indikator)
	_terapkan()


func set_status(baru: int) -> void:
	if baru == status:
		return
	status = baru
	_terapkan()


func _terapkan() -> void:
	if _led == null:
		return
	var w: Color = WARNA.get(status, Color.WHITE)
	_led.color = w
	_indikator.color = w
	_indikator.enabled = status != Status.MATI


func _process(delta: float) -> void:
	_waktu += delta
	if _indikator == null:
		return
	match status:
		Status.SIAP:
			_indikator.energy = 0.55
		Status.DIPAKAI:
			# Saat ngecas lampunya terang & berdenyut (bisa terlihat Satpam).
			_indikator.energy = 1.3 + 0.4 * sin(_waktu * 6.0)
			_indikator.texture_scale = 0.4
		Status.KORSLET:
			_indikator.energy = 0.9 if fmod(_waktu, 0.5) < 0.25 else 0.15
			_indikator.texture_scale = 0.22
		_:
			_indikator.energy = 0.0
	if status != Status.DIPAKAI:
		_indikator.texture_scale = 0.22
