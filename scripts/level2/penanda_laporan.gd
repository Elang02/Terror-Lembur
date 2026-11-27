extends Node2D
## Penanda alat yang rusak (laporan gangguan) di lantai — Level 2.
## Bentuknya titik kecil + gelombang bunyi di kiri-kanan (alatnya "berbunyi"),
## ditambah cincin progres saat dikerjakan. Merah kalau laporannya terlambat,
## centang hijau kalau sudah beres. Ditempel level_2.gd ke tiap node tugas
## dan menggantikan kotak bawaan task_station (khusus Level 2).
## Karena ada di dunia game, penanda ini hanya kelihatan kalau kena cahaya.

var warna: Color = Color(1.0, 0.8, 0.3)
var progres: float = 0.0
var selesai: bool = false
var terlambat: bool = false

var _t: float = 0.0


func _ready() -> void:
	z_index = 7


func set_keadaan(p: float, beres: bool, telat: bool) -> void:
	progres = p
	selesai = beres
	terlambat = telat


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	if selesai:
		draw_circle(Vector2.ZERO, 5.0, Color(0.47, 0.87, 0.55))
		draw_polyline(PackedVector2Array([Vector2(-2.5, 0), Vector2(-0.8, 2.0), Vector2(3.0, -2.2)]), Color(0.08, 0.16, 0.1), 1.2, true)
		return
	var w: Color = Color(0.92, 0.31, 0.27) if terlambat else warna
	draw_circle(Vector2.ZERO, 2.5, w)
	for k: int in range(2):
		var fase: float = fmod(_t * 1.1 + k * 0.5, 1.0)
		var r: float = 5.0 + fase * 8.0
		var a: float = (1.0 - fase) * 0.9
		draw_arc(Vector2.ZERO, r, -0.7, 0.7, 10, Color(w, a), 1.0, true)
		draw_arc(Vector2.ZERO, r, PI - 0.7, PI + 0.7, 10, Color(w, a), 1.0, true)
	if progres > 0.0:
		draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 32, Color(1, 1, 1, 0.18), 1.2, true)
		draw_arc(Vector2.ZERO, 15.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(progres, 0.0, 1.0), 32, w, 1.6, true)
