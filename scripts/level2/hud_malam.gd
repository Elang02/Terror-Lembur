class_name HudMalam
extends CanvasLayer
## HUD Level 2 — dibuat dari "benda-benda kantor", semuanya digambar dari
## kode (bentuk sederhana, tanpa gambar tambahan):
## - HP pemain (kiri bawah): baterai, jam, fase, notifikasi laporan,
##   tombol senter (R). Kalau baterai 0% layar HP mati -> jam & notifikasi
##   ikut hilang.
## - Sticky note (kanan atas): daftar laporan malam ini.
## - ID card (kiri atas): status P1/P2 + garis baterai, cap DIKURUNG.
## - Label Dymo (bawah tengah): tombol yang bisa ditekan sekarang.
## - Baris log merah (atas tengah): kejadian besar, diketik huruf demi huruf.
## - Kotak debug (kanan bawah): hanya kalau debug di node Level2 dinyalakan.
## Dibuat oleh level_2.gd saat game mulai; datanya dibaca dari level.

const F_INTER_LIGHT: Font = preload("res://assets/fonts/Inter-Light.otf")
const F_INTER: Font = preload("res://assets/fonts/Inter-Medium.otf")
const F_INTER_TEBAL: Font = preload("res://assets/fonts/Inter-SemiBold.otf")
const F_MONO: Font = preload("res://assets/fonts/lmmono10-regular.otf")
const F_MONO_TEBAL: Font = preload("res://assets/fonts/lmmonolt10-bold.otf")

const KUNING := Color(1.0, 0.745, 0.333)
const MERAH := Color(0.92, 0.31, 0.27)
const HIJAU := Color(0.47, 0.87, 0.55)
const TINTA := Color(0.925, 0.91, 0.88)
const REDUP := Color(0.59, 0.59, 0.635)

var level: Node = null
# Font disimpan juga sebagai variabel supaya bisa dipakai kelas-kelas di bawah.
var f_light: Font = F_INTER_LIGHT
var f_inter: Font = F_INTER
var f_tebal: Font = F_INTER_TEBAL
var f_mono: Font = F_MONO
var f_mono_tebal: Font = F_MONO_TEBAL

var notif: Array = []  # [{warna, app, judul, isi, waktu}] terbaru di depan
var prompt: String = ""
var debug_teks: String = ""
var debug_tag: bool = false
var log_antrian: Array = []  # [[teks, warna]]


func _ready() -> void:
	layer = 11
	_tambah(_KartuPemain.new(), "KartuPemain")
	_tambah(_StickyNote.new(), "StickyNote")
	_tambah(_HpPemain.new(), "HpPemain")
	_tambah(_LabelDymo.new(), "LabelDymo")
	_tambah(_LogLayar.new(), "LogLayar")
	_tambah(_KotakDebug.new(), "KotakDebug")


func _tambah(w: Control, nama: String) -> void:
	w.name = nama
	w.set("hud", self)
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(w)


# ------------------------------------------------------------ API untuk level
func kabar(jenis: String, judul: String, isi: String = "") -> void:
	match jenis:
		"laporan":
			_notif(KUNING, "SISTEM GEDUNG", judul, isi)
		"beres":
			_notif(HIJAU, "SISTEM GEDUNG", "Beres: " + judul, isi)
		"bahaya":
			_notif(MERAH, "SISTEM GEDUNG", judul, isi)
			tulis_log(judul + ("  —  " + isi if isi != "" else ""), MERAH)
		"info":
			tulis_log(judul + ("  —  " + isi if isi != "" else ""), TINTA)
		_:
			# Pesan pribadi: muncul di HP; kalau HP mati jadi baris log abu-abu.
			if hp_hidup():
				_notif(REDUP, "HP", judul, isi)
			else:
				tulis_log(judul, REDUP)


func set_prompt(teks: String) -> void:
	prompt = teks


func set_debug(teks: String, tampil_tag: bool) -> void:
	debug_teks = teks
	debug_tag = tampil_tag


func tulis_log(teks: String, warna: Color) -> void:
	var jam: String = ""
	if level != null:
		jam = level.get_teks_jam()
	log_antrian.append(["> %s  %s" % [jam, teks.to_upper()], warna])
	while log_antrian.size() > 4:
		log_antrian.pop_front()


func hp_hidup() -> bool:
	if level == null:
		return false
	return level.get_baterai(NetworkManager.local_peer_id()) > 0.0


func _notif(warna: Color, app: String, judul: String, isi: String) -> void:
	notif.push_front({"warna": warna, "app": app, "judul": judul, "isi": isi, "waktu": Time.get_ticks_msec()})
	while notif.size() > 4:
		notif.pop_back()


# =========================================================== kelas dasar
class _Widget extends Control:
	var hud: Node = null

	func _process(_delta: float) -> void:
		_atur_posisi(get_viewport().get_visible_rect().size)
		queue_redraw()

	func _atur_posisi(_vp: Vector2) -> void:
		pass

	func kotak(r: Rect2, warna: Color, radius: float, tebal_garis: float = 0.0, warna_garis: Color = Color(0, 0, 0, 0)) -> void:
		var sb := StyleBoxFlat.new()
		sb.bg_color = warna
		sb.set_corner_radius_all(int(radius))
		if tebal_garis > 0.0:
			sb.set_border_width_all(int(tebal_garis))
			sb.border_color = warna_garis
		sb.anti_aliasing = true
		draw_style_box(sb, r)

	func teks(f: Font, pos: Vector2, s: String, ukuran: int, warna: Color) -> void:
		draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran, warna)

	func lebar_teks(f: Font, s: String, ukuran: int) -> float:
		return f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran).x

	func teks_tengah(f: Font, pusat: Vector2, s: String, ukuran: int, warna: Color) -> void:
		var x: float = pusat.x - lebar_teks(f, s, ukuran) * 0.5
		draw_string(f, Vector2(x, pusat.y + f.get_ascent(ukuran) * 0.38), s, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran, warna)

	func teks_kanan(f: Font, kanan: Vector2, s: String, ukuran: int, warna: Color) -> void:
		draw_string(f, Vector2(kanan.x - lebar_teks(f, s, ukuran), kanan.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran, warna)

	func pendekkan(f: Font, s: String, ukuran: int, lebar_maks: float) -> String:
		if lebar_teks(f, s, ukuran) <= lebar_maks:
			return s
		var t: String = s
		while t.length() > 1 and lebar_teks(f, t + "…", ukuran) > lebar_maks:
			t = t.substr(0, t.length() - 1)
		return t + "…"

	func goyang(titik: Array, warna: Color, tebal: float, benih: int) -> void:
		# Garis "tulisan tangan": tiap titik digeser sedikit (acak, tapi sama
		# tiap frame karena benihnya tetap).
		var rng := RandomNumberGenerator.new()
		rng.seed = benih
		var hasil := PackedVector2Array()
		for p: Vector2 in titik:
			hasil.append(p + Vector2(rng.randf_range(-0.6, 0.6), rng.randf_range(-0.6, 0.6)))
		draw_polyline(hasil, warna, tebal, true)


# ================================================================ HP
class _HpPemain extends _Widget:
	var _t: float = 0.0

	func _ready() -> void:
		size = Vector2(168, 262)
		pivot_offset = size * 0.5
		rotation = deg_to_rad(-4.0)

	func _atur_posisi(vp: Vector2) -> void:
		position = Vector2(22.0, vp.y - 250.0)

	func _process(delta: float) -> void:
		_t += delta
		super._process(delta)

	func _draw() -> void:
		var lv: Node = hud.level
		if lv == null:
			return
		var w: float = size.x
		var h: float = size.y
		kotak(Rect2(5, 7, w, h), Color(0, 0, 0, 0.45), 26)
		kotak(Rect2(0, 0, w, h), Color(0.07, 0.07, 0.086), 26, 2, Color(0.27, 0.27, 0.31))
		var layar := Rect2(9, 9, w - 18, h - 18)
		var pid: int = NetworkManager.local_peer_id()
		var b: float = lv.get_baterai(pid)
		if b <= 0.0:
			_layar_mati(layar)
		else:
			_layar_hidup(layar, lv, pid, b)
		kotak(Rect2(w * 0.5 - 22, 14, 44, 6), Color(0.04, 0.04, 0.05), 3)

	func _layar_mati(r: Rect2) -> void:
		kotak(r, Color(0.024, 0.024, 0.03), 18)
		# pantulan kaca
		draw_colored_polygon(PackedVector2Array([
			r.position + Vector2(r.size.x * 0.55, 2), r.position + Vector2(r.size.x * 0.72, 2),
			r.position + Vector2(r.size.x * 0.25, r.size.y - 2), r.position + Vector2(r.size.x * 0.08, r.size.y - 2)]),
			Color(1, 1, 1, 0.025))
		var kedip: float = 1.0 if fmod(_t, 1.2) < 0.7 else 0.25
		var m := Color(0.92, 0.31, 0.27, kedip)
		var bx: float = r.position.x + r.size.x * 0.5 - 17.0
		var by: float = r.position.y + r.size.y * 0.34
		kotak(Rect2(bx, by, 30, 15), Color(0, 0, 0, 0), 3, 2, m)
		draw_rect(Rect2(bx + 31, by + 5, 3, 5), m)
		draw_rect(Rect2(bx + 3, by + 3, 3, 9), m)
		teks_tengah(hud.f_tebal, Vector2(r.position.x + r.size.x * 0.5, by + 33), "0%", 12, m)
		teks_tengah(hud.f_inter, Vector2(r.position.x + r.size.x * 0.5, by + 51), "colokkan pengisi daya", 9, Color(0.47, 0.47, 0.51))

	func _layar_hidup(r: Rect2, lv: Node, pid: int, b: float) -> void:
		kotak(r, Color(0.05, 0.063, 0.11), 18)
		kotak(Rect2(r.position, Vector2(r.size.x, r.size.y * 0.42)), Color(0.15, 0.2, 0.34, 0.35), 18)
		var x0: float = r.position.x
		var y0: float = r.position.y
		var lw: float = r.size.x
		var putih := Color(0.86, 0.87, 0.92)
		# --- status bar
		teks(hud.f_inter, Vector2(x0 + 10, y0 + 15), "WiFi Kantor", 9, putih)
		var bx: float = x0 + lw - 30.0
		kotak(Rect2(bx, y0 + 7, 18, 9), Color(0, 0, 0, 0), 2, 1, putih)
		draw_rect(Rect2(bx + 19, y0 + 9.5, 1.5, 4), putih)
		var warna_b: Color = Color(0.47, 0.87, 0.55) if b >= 20.0 else Color(0.92, 0.31, 0.27)
		draw_rect(Rect2(bx + 1.5, y0 + 8.5, 15.0 * clampf(b / 100.0, 0.0, 1.0), 6), warna_b)
		teks_kanan(hud.f_tebal, Vector2(bx - 3, y0 + 15), "%d%%" % int(ceil(b)), 9, putih)
		var ngecas: bool = lv.get_area_cas(pid) != ""
		if ngecas:
			draw_colored_polygon(PackedVector2Array([Vector2(bx + 10, y0 + 6), Vector2(bx + 6, y0 + 12), Vector2(bx + 9, y0 + 12),
				Vector2(bx + 8, y0 + 17), Vector2(bx + 12, y0 + 11), Vector2(bx + 9, y0 + 11)]), Color.WHITE)
		# --- jam (titik di tengah berkedip saat jam berjalan)
		var menit: float = lv.get_jam_menit()
		var berhenti: bool = not lv.is_jam_berjalan()
		var warna_jam: Color = Color(0.94, 0.94, 0.97)
		if lv.get_teks_error() != "":
			warna_jam = Color(0.92, 0.31, 0.27)
		elif not lv.is_komputer_pernah():
			warna_jam = Color(0.55, 0.57, 0.65)
		var total: int = int(menit)
		var hh: String = "%02d" % ((21 + int(total / 60.0)) % 24)
		var mm: String = "%02d" % (total % 60)
		var uk: int = 38
		var w_hh: float = lebar_teks(hud.f_light, hh, uk)
		var w_tt: float = lebar_teks(hud.f_light, ".", uk)
		var w_mm: float = lebar_teks(hud.f_light, mm, uk)
		var xj: float = x0 + (lw - (w_hh + w_tt + w_mm)) * 0.5
		var yj: float = y0 + 62.0
		teks(hud.f_light, Vector2(xj, yj), hh, uk, warna_jam)
		var a_titik: float = 1.0 if (berhenti or fmod(_t, 1.0) < 0.5) else 0.15
		teks(hud.f_light, Vector2(xj + w_hh, yj), ".", uk, Color(warna_jam, a_titik))
		teks(hud.f_light, Vector2(xj + w_hh + w_tt, yj), mm, uk, warna_jam)
		teks_tengah(hud.f_inter, Vector2(x0 + lw * 0.5, y0 + 76), lv.get_teks_sub_hp(), 9, Color(0.67, 0.69, 0.77))
		var y: float = y0 + 88.0
		if ngecas:
			kotak(Rect2(x0 + lw * 0.5 - 40, y0 + 81, 80, 14), Color(0.24, 0.63, 0.35, 0.35), 7)
			teks_tengah(hud.f_tebal, Vector2(x0 + lw * 0.5, y0 + 88), "mengisi daya", 8, Color(0.67, 0.94, 0.75))
			y += 12.0
		# --- notifikasi (paling baru di atas, maks 2)
		var sekarang: int = Time.get_ticks_msec()
		var n: int = 0
		for d: Dictionary in hud.notif:
			if n >= 2:
				break
			kotak(Rect2(x0 + 7, y, lw - 14, 44), Color(1, 1, 1, 0.12), 10)
			var wi: Color = d["warna"]
			kotak(Rect2(x0 + 13, y + 7, 12, 12), wi, 3)
			teks_tengah(hud.f_tebal, Vector2(x0 + 19, y + 13), "!", 8, Color(0.08, 0.08, 0.1))
			teks(hud.f_tebal, Vector2(x0 + 30, y + 16), str(d["app"]), 7, Color(0.75, 0.76, 0.82))
			var umur: float = (sekarang - int(d["waktu"])) / 1000.0
			teks_kanan(hud.f_inter, Vector2(x0 + lw - 13, y + 16), "baru saja" if umur < 20.0 else "tadi", 7, Color(0.59, 0.61, 0.67))
			teks(hud.f_tebal, Vector2(x0 + 13, y + 30), pendekkan(hud.f_tebal, str(d["judul"]), 10, lw - 28), 10, Color(0.96, 0.96, 0.98))
			if str(d["isi"]) != "":
				teks(hud.f_inter, Vector2(x0 + 13, y + 40), pendekkan(hud.f_inter, str(d["isi"]), 8, lw - 28), 8, Color(0.73, 0.75, 0.8))
			y += 50.0
			n += 1
		# --- tombol senter (seperti di lock screen HP)
		var nyala: bool = lv.is_senter_nyala(pid)
		var c := Vector2(x0 + 24, r.end.y - 24)
		draw_circle(c, 15.0, Color(1.0, 0.745, 0.333) if nyala else Color(1, 1, 1, 0.15))
		var ikon: Color = Color(0.12, 0.09, 0.04) if nyala else Color(0.88, 0.88, 0.92)
		draw_rect(Rect2(c.x - 3, c.y - 2, 6, 11), ikon)
		draw_colored_polygon(PackedVector2Array([c + Vector2(-5, -9), c + Vector2(5, -9), c + Vector2(3, -2), c + Vector2(-3, -2)]), ikon)
		teks(hud.f_tebal, Vector2(c.x + 21, c.y + 4), "R", 10, Color(0.67, 0.69, 0.77))


# ========================================================== sticky note
class _StickyNote extends _Widget:
	func _ready() -> void:
		size = Vector2(176, 214)
		pivot_offset = size * 0.5
		rotation = deg_to_rad(2.5)

	func _atur_posisi(vp: Vector2) -> void:
		position = Vector2(vp.x - size.x - 18.0, 22.0)

	func _draw() -> void:
		var lv: Node = hud.level
		if lv == null:
			return
		var w: float = size.x
		var h: float = size.y
		var kertas := PackedVector2Array([Vector2(0, 4), Vector2(w, 0), Vector2(w, h - 6), Vector2(w - 14, h), Vector2(0, h - 2)])
		var bayang := PackedVector2Array()
		for p: Vector2 in kertas:
			bayang.append(p + Vector2(4, 6))
		draw_colored_polygon(bayang, Color(0, 0, 0, 0.4))
		draw_colored_polygon(kertas, Color(0.957, 0.827, 0.369))
		draw_colored_polygon(PackedVector2Array([Vector2(w, h - 6), Vector2(w - 14, h), Vector2(w - 12, h - 10)]), Color(0.84, 0.7, 0.27))
		# selotip
		var pusat := Vector2(w * 0.5, -2)
		var sel := PackedVector2Array()
		for p: Vector2 in [Vector2(-29, -9), Vector2(29, -9), Vector2(29, 9), Vector2(-29, 9)]:
			sel.append(pusat + p.rotated(deg_to_rad(-9.0)))
		draw_colored_polygon(sel, Color(0.94, 0.91, 0.82, 0.6))
		var coklat := Color(0.27, 0.2, 0.08)
		teks(hud.f_mono_tebal, Vector2(14, 26), "LAPORAN MALAM INI", 11, coklat)
		goyang([Vector2(14, 31), Vector2(80, 31.5), Vector2(150, 30)], coklat, 1.2, 11)
		var y: float = 50.0
		var i: int = 0
		for l: Dictionary in lv.get_info_laporan_semua():
			var st: String = str(l["status"])
			draw_line(Vector2(10, y + 9), Vector2(w - 10, y + 9), Color(0.84, 0.72, 0.31), 1.0)
			teks(hud.f_mono, Vector2(14, y + 4), str(l["jam"]), 10, Color(0.35, 0.27, 0.12))
			if st == "belum":
				teks(hud.f_mono, Vector2(60, y + 4), ". . . . . .", 10, Color(0.67, 0.55, 0.24))
			else:
				var nama: String = str(l["nama"]) + ("*" if bool(l["wajib"]) else "")
				teks(hud.f_mono_tebal, Vector2(60, y + 4), nama, 10, Color(0.16, 0.125, 0.06))
				var bx: float = w - 30.0
				goyang([Vector2(bx, y - 6), Vector2(bx + 11, y - 6.5), Vector2(bx + 11.5, y + 5), Vector2(bx, y + 5.5), Vector2(bx, y - 6)], Color(0.24, 0.18, 0.08), 1.3, 100 + i)
				if st == "aktif":
					var lingkar: Array = []
					for k: int in range(31):
						var a: float = 0.3 + (TAU + 0.3) * k / 30.0
						lingkar.append(Vector2(30 + 19 * cos(a), y + 0.5 + 8 * sin(a)))
					goyang(lingkar, Color(0.78, 0.16, 0.14), 1.4, 200 + i)
				elif st == "beres":
					goyang([Vector2(bx + 1, y - 1), Vector2(bx + 5, y + 4), Vector2(bx + 15, y - 10)], Color(0.14, 0.27, 0.59), 2.2, 300 + i)
				elif st == "telat":
					goyang([Vector2(56, y + 1), Vector2(bx - 6, y - 1)], Color(0.78, 0.16, 0.14), 2.0, 400 + i)
					teks(hud.f_mono_tebal, Vector2(bx + 15, y + 4), "!", 11, Color(0.78, 0.16, 0.14))
			y += 22.0
			i += 1
		teks(hud.f_mono, Vector2(14, h - 10), "* wajib sebelum 05.00", 8, Color(0.47, 0.37, 0.16))


# =========================================================== ID card
class _KartuPemain extends _Widget:
	func _ready() -> void:
		size = Vector2(220, 120)

	func _atur_posisi(_vp: Vector2) -> void:
		position = Vector2.ZERO

	func _draw() -> void:
		var lv: Node = hud.level
		if lv == null:
			return
		var i: int = 0
		for p: Dictionary in lv.get_info_pemain():
			var cx: float = 40.0 + i * 62.0
			var pusat := Vector2(cx, 64)
			var sudut: float = deg_to_rad(-4.0 if i == 0 else 3.0)
			var tali := Color(0.16, 0.16, 0.19)
			draw_line(Vector2(cx - 10, 0), pusat + Vector2(0, -33).rotated(sudut), tali, 3.0, true)
			draw_line(Vector2(cx + 10, 0), pusat + Vector2(0, -33).rotated(sudut), tali, 3.0, true)
			draw_set_transform(pusat, sudut, Vector2.ONE)
			_kartu(p, i)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			var status: String = str(p["status"])
			if status == "kurung" or status == "sembunyi":
				# Cap stempel miring di atas foto.
				var warna_cap: Color = Color(0.78, 0.16, 0.14, 0.92) if status == "kurung" else Color(0.3, 0.4, 0.6, 0.9)
				var kata: String = "DIKURUNG" if status == "kurung" else "SEMBUNYI"
				draw_set_transform(pusat + Vector2(0, -3).rotated(sudut), sudut - 0.3, Vector2.ONE)
				var lebar: float = lebar_teks(hud.f_mono_tebal, kata, 9) + 8.0
				draw_rect(Rect2(-lebar * 0.5, -8, lebar, 16), warna_cap, false, 1.6)
				teks_tengah(hud.f_mono_tebal, Vector2.ZERO, kata, 9, warna_cap)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			i += 1

	func _kartu(p: Dictionary, i: int) -> void:
		var w: float = 54.0
		var h: float = 70.0
		var o := Vector2(-w * 0.5, -h * 0.5)
		var warna: Color = Color(0.31, 0.75, 0.67) if i == 0 else Color(0.43, 0.59, 0.94)
		var redup: float = 0.55 if str(p["status"]) == "sembunyi" else 1.0
		kotak(Rect2(o + Vector2(3, 4), Vector2(w, h)), Color(0, 0, 0, 0.4), 5)
		kotak(Rect2(o, Vector2(w, h)), Color(0.91 * redup, 0.9 * redup, 0.87 * redup), 5)
		draw_rect(Rect2(o + Vector2(0, 6), Vector2(w, 11)), Color(warna.r * redup, warna.g * redup, warna.b * redup))
		kotak(Rect2(o + Vector2(w * 0.5 - 7, 2), Vector2(14, 4)), Color(0.24, 0.24, 0.26), 2)
		var abu := Color(0.59 * redup, 0.59 * redup, 0.62 * redup)
		draw_circle(o + Vector2(w * 0.5, 28), 7.0, abu)
		draw_colored_polygon(PackedVector2Array([o + Vector2(w * 0.5 - 13, 50), o + Vector2(w * 0.5 - 10, 40), o + Vector2(w * 0.5, 37),
			o + Vector2(w * 0.5 + 10, 40), o + Vector2(w * 0.5 + 13, 50)]), abu)
		teks_tengah(hud.f_mono_tebal, o + Vector2(w * 0.5, 58), str(p["nama"]), 9, Color(0.16, 0.16, 0.18))
		var b: float = clampf(float(p["baterai"]) / 100.0, 0.0, 1.0)
		draw_rect(Rect2(o + Vector2(6, 63), Vector2((w - 12) * b, 2.5)), warna)


# =========================================================== label Dymo
class _LabelDymo extends _Widget:
	var _teks: String = ""

	func _atur_posisi(vp: Vector2) -> void:
		var t: String = str(hud.prompt).to_upper()
		_teks = t
		visible = t != ""
		var w: float = lebar_teks(hud.f_mono_tebal, t, 13) + 38.0
		size = Vector2(w, 32)
		pivot_offset = size * 0.5
		rotation = deg_to_rad(-1.2)
		position = Vector2(vp.x * 0.5 - w * 0.5, vp.y - 66.0)

	func _draw() -> void:
		if _teks == "":
			return
		var w: float = size.x
		var h: float = size.y
		var pita := PackedVector2Array([Vector2(6, 0), Vector2(w - 6, 0), Vector2(w, h * 0.5), Vector2(w - 6, h), Vector2(6, h), Vector2(0, h * 0.5)])
		var bayang := PackedVector2Array()
		for p: Vector2 in pita:
			bayang.append(p + Vector2(2, 4))
		draw_colored_polygon(bayang, Color(0, 0, 0, 0.5))
		draw_colored_polygon(pita, Color(0.086, 0.086, 0.1))
		teks_tengah(hud.f_mono_tebal, Vector2(w * 0.5 + 1, h * 0.5 + 1), _teks, 13, Color(0, 0, 0))
		teks_tengah(hud.f_mono_tebal, Vector2(w * 0.5, h * 0.5), _teks, 13, Color(0.93, 0.93, 0.94))


# ======================================================== log atas tengah
class _LogLayar extends _Widget:
	var _baris: String = ""
	var _warna: Color = Color.WHITE
	var _t: float = 0.0

	func _atur_posisi(vp: Vector2) -> void:
		size = Vector2(vp.x, 40)
		position = Vector2(0, 80)

	func _process(delta: float) -> void:
		if _baris == "" and not hud.log_antrian.is_empty():
			var item: Array = hud.log_antrian.pop_front()
			_baris = str(item[0])
			_warna = item[1]
			_t = 0.0
		if _baris != "":
			_t += delta
			if _t > _baris.length() / 45.0 + 4.5:
				_baris = ""
		super._process(delta)

	func _draw() -> void:
		if _baris == "":
			return
		var tampak: int = mini(_baris.length(), int(_t * 45.0))
		var s: String = _baris.substr(0, tampak)
		var lama_ketik: float = _baris.length() / 45.0
		var a: float = 1.0
		if _t > lama_ketik + 3.9:
			a = clampf(1.0 - (_t - lama_ketik - 3.9) / 0.6, 0.0, 1.0)
		var uk: int = 13
		var lebar_penuh: float = lebar_teks(hud.f_mono_tebal, _baris, uk)
		var x: float = size.x * 0.5 - lebar_penuh * 0.5
		draw_rect(Rect2(x - 12, 4, lebar_penuh + 34, 26), Color(0.04, 0, 0, 0.67 * a))
		teks(hud.f_mono_tebal, Vector2(x, 22), s, uk, Color(_warna, a))
		if fmod(_t, 0.8) < 0.5:
			var xk: float = x + lebar_teks(hud.f_mono_tebal, s, uk) + 4.0
			draw_rect(Rect2(xk, 9, 8, 16), Color(_warna, a))


# ============================================================ kotak debug
class _KotakDebug extends _Widget:
	func _atur_posisi(vp: Vector2) -> void:
		size = vp
		position = Vector2.ZERO

	func _draw() -> void:
		if hud.debug_tag:
			kotak(Rect2(size.x * 0.5 - 34, 6, 68, 18), Color(1.0, 0.8, 0.2, 0.9), 4)
			teks_tengah(hud.f_mono_tebal, Vector2(size.x * 0.5, 15), "DEBUG", 11, Color(0.1, 0.08, 0.02))
		if str(hud.debug_teks) == "":
			return
		var baris: PackedStringArray = str(hud.debug_teks).split("\n")
		var lebar: float = 0.0
		for b: String in baris:
			lebar = maxf(lebar, lebar_teks(hud.f_mono, b, 11))
		var tinggi: float = baris.size() * 14.0 + 12.0
		var x: float = size.x - lebar - 30.0
		var y: float = size.y - tinggi - 14.0
		kotak(Rect2(x - 8, y - 4, lebar + 24, tinggi), Color(0, 0, 0, 0.72), 6, 1, Color(1.0, 0.8, 0.2, 0.6))
		var yy: float = y + 10.0
		for b: String in baris:
			teks(hud.f_mono, Vector2(x + 4, yy), b, 11, Color(1.0, 0.9, 0.55))
			yy += 14.0
