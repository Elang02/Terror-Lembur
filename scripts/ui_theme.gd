class_name UiTheme
extends RefCounted
## Sistem visual UI Terror Lembur: satu tempat untuk semua token UI.
## Dunia visual: kantor lembur, kertas kerja di bawah lampu meja. Dasar
## gelap hangat, garis rambut, tinta kertas, satu aksen amber. Judul pakai
## condensed berat, data dan label pakai mono. Sudut kotak, tanpa
## bayangan, tanpa gradasi, tanpa glyph unicode sebagai ikon.

const INK := Color(0.925, 0.898, 0.847)
const MUTED := Color(0.604, 0.569, 0.498)
const SOFT := Color(0.788, 0.753, 0.678)
const FAINT := Color(0.42, 0.39, 0.34)
const AMBER := Color(0.91, 0.639, 0.239)
const GREEN := Color(0.561, 0.71, 0.451)
const RED := Color(0.82, 0.376, 0.247)
const PANEL := Color(0.078, 0.067, 0.051)
const PANEL_BORDER := Color(0.227, 0.204, 0.173)
const TRACK := Color(0.141, 0.122, 0.098)
const DIM := Color(0, 0, 0, 0.74)

const FONT_DISPLAY := "res://assets/fonts/NotoSansDisplay-ExtraCondensedBold.ttf"
const FONT_MONO := "res://assets/fonts/DejaVuSansMono.ttf"
const FONT_MONO_BOLD := "res://assets/fonts/DejaVuSansMono-Bold.ttf"

static var _display: Font = null
static var _mono: Font = null
static var _mono_bold: Font = null


static func display_font() -> Font:
	if _display == null:
		_display = load(FONT_DISPLAY)
	return _display


static func mono_font() -> Font:
	if _mono == null:
		_mono = load(FONT_MONO)
	return _mono


static func mono_bold_font() -> Font:
	if _mono_bold == null:
		_mono_bold = load(FONT_MONO_BOLD)
	return _mono_bold


static func panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.set_corner_radius_all(0)
	return s


static func bar_bg_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = TRACK
	s.set_corner_radius_all(0)
	return s


static func bar_fill_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(0)
	return s


static func button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(0)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func style_button(b: Button) -> void:
	b.add_theme_font_override("font", mono_bold_font())
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", PANEL)
	b.add_theme_color_override("font_pressed_color", PANEL)
	b.add_theme_color_override("font_focus_color", AMBER)
	b.add_theme_stylebox_override("normal", button_style(Color(0, 0, 0, 0), MUTED))
	b.add_theme_stylebox_override("hover", button_style(AMBER, AMBER))
	b.add_theme_stylebox_override("pressed", button_style(Color(0.72, 0.49, 0.16), AMBER))
	b.add_theme_stylebox_override("focus", button_style(Color(0, 0, 0, 0), AMBER))
	b.add_theme_stylebox_override("disabled", button_style(Color(0, 0, 0, 0), FAINT))


static func hairline() -> ColorRect:
	var r := ColorRect.new()
	r.color = PANEL_BORDER
	r.custom_minimum_size = Vector2(0, 1)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func mk_label(text: String, font_size: int, color: Color, font: Font = null, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_override("font", font if font != null else mono_font())
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


static func mk_title(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text.to_upper()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", display_font())
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Ikon bintang digambar (bukan glyph unicode): poligon 5 ujung.
## Terisi = amber penuh, kosong = isi gelap dengan garis luar muted.
class StarIcon extends Control:
	var filled: bool = false:
		set(v):
			filled = v
			queue_redraw()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r_out: float = min(size.x, size.y) * 0.5
		var r_in: float = r_out * 0.42
		var pts := PackedVector2Array()
		for i in range(10):
			var ang := -PI / 2.0 + float(i) * PI / 5.0
			var r: float = r_out if i % 2 == 0 else r_in
			pts.append(c + Vector2(cos(ang), sin(ang)) * r)
		if filled:
			draw_colored_polygon(pts, UiTheme.AMBER)
		else:
			draw_colored_polygon(pts, UiTheme.TRACK)
			pts.append(pts[0])
			draw_polyline(pts, UiTheme.MUTED, 1.5)
