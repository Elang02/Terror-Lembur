extends Control
## Main Menu — pilih Host (PC 1), Join (PC 2, isi IP LAN host), atau
## Solo (tes sendiri). Dibangun dari kode supaya mudah diubah.

var _ip_edit: LineEdit = null
var _status_label: Label = null
var _joining: bool = false
var _join_timer: float = -1.0


func _ready() -> void:
	# Backsound main menu (Ghost Story) — mulai dengan fade-in,
	# lalu loop crossfade sendiri di MusicManager.
	MusicManager.play_menu()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	NetworkManager.connected_to_host.connect(_on_connected_to_host)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	_build_ui()


func _process(delta: float) -> void:
	if _joining and _join_timer > 0.0:
		_join_timer -= delta
		if _join_timer <= 0.0:
			_joining = false
			NetworkManager.disconnect_all()
			_status_label.text = "Tidak bisa terhubung. Cek IP host & pastikan 2 PC di Wi-Fi/LAN yang sama (UDP 7777)."


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.05, 0.09)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	center.add_child(vbox)
	var title := Label.new()
	title.text = "TERROR LEMBUR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.95, 0.25, 0.2))
	vbox.add_child(title)
	var sub := Label.new()
	sub.text = "Selesaikan tugas lembur. Hindari sosok itu. Kabur berdua."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.85, 0.82, 0.9))
	vbox.add_child(sub)
	var stars: int = GameProgress.get_stars("level_1")
	var best: float = GameProgress.get_best_time("level_1")
	var star_text: String = ""
	for i: int in range(3):
		star_text += "★" if i < stars else "☆"
	var progress := Label.new()
	progress.text = "Level 1 — Lantai Kantor: %s  %s" % [star_text, ("| Terbaik: %02d:%02d" % [int(best) / 60, int(best) % 60]) if best > 0.0 else "| Belum selesai"]
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 15)
	progress.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	vbox.add_child(progress)
	var ip_row := HBoxContainer.new()
	ip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ip_row.add_theme_constant_override("separation", 8)
	vbox.add_child(ip_row)
	var ip_label := Label.new()
	ip_label.text = "IP Host:"
	ip_label.add_theme_font_size_override("font_size", 15)
	ip_row.add_child(ip_label)
	_ip_edit = LineEdit.new()
	_ip_edit.text = "127.0.0.1"
	_ip_edit.custom_minimum_size = Vector2(180, 36)
	_ip_edit.add_theme_font_size_override("font_size", 15)
	ip_row.add_child(_ip_edit)
	var host_btn := _mk_button("Buat Game (Host — PC 1)")
	host_btn.pressed.connect(_on_host_pressed)
	vbox.add_child(host_btn)
	var join_btn := _mk_button("Gabung Game (Join — PC 2)")
	join_btn.pressed.connect(_on_join_pressed)
	vbox.add_child(join_btn)
	var solo_btn := _mk_button("Tes Sendiri (Solo)")
	solo_btn.pressed.connect(_on_solo_pressed)
	vbox.add_child(solo_btn)
	_status_label = Label.new()
	_status_label.text = "2 PC: Host buka game dulu, lalu Join dari PC 2 dengan IP LAN host.\nTes di 1 PC: jalankan 2 window, Host + Join ke 127.0.0.1."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 13)
	_status_label.add_theme_color_override("font_color", Color(0.75, 0.72, 0.8))
	vbox.add_child(_status_label)
	var controls := Label.new()
	controls.text = "Kontrol: WASD / Panah = Gerak  •  Shift = Lari  •  E = Interaksi (tahan untuk tugas)"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 13)
	controls.add_theme_color_override("font_color", Color(0.65, 0.62, 0.72))
	vbox.add_child(controls)


func _mk_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 44)
	b.add_theme_font_size_override("font_size", 16)
	return b


func _on_host_pressed() -> void:
	var err: Error = NetworkManager.host_game()
	if err != OK:
		_status_label.text = "Gagal membuat game (port 7777 mungkin dipakai). Coba tutup game lain / jalankan ulang."
		return
	get_tree().change_scene_to_file("res://scenes/story_intro.tscn")


func _on_join_pressed() -> void:
	_joining = true
	_join_timer = 5.0
	_status_label.text = "Menghubungi host..."
	var err: Error = NetworkManager.join_game(_ip_edit.text)
	if err != OK:
		_joining = false
		_status_label.text = "Gagal memulai koneksi. Cek IP yang dimasukkan."


func _on_solo_pressed() -> void:
	NetworkManager.start_solo()
	get_tree().change_scene_to_file("res://scenes/story_intro.tscn")


func _on_connected_to_host() -> void:
	if not _joining:
		return
	_joining = false
	get_tree().change_scene_to_file("res://scenes/story_intro.tscn")


func _on_connection_failed() -> void:
	_joining = false
	NetworkManager.disconnect_all()
	_status_label.text = "Koneksi gagal. Pastikan host sudah menekan 'Buat Game' dan IP-nya benar."
