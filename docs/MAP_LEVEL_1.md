# Map Level 1 — Lantai Kantor, Sayap Utama

Adaptasi dari gambar referensi "Desain Map – Level 1 (Revisi)".
Ukuran: **64 × 40 tile**, tile **32px** (dunia 2048 × 1280 px).
Preview: [map_preview.png](map_preview.png).

## Ruangan (15)

| Ruangan | Posisi | Isi / catatan |
|---|---|---|
| Gudang | Barat laut | Boks & rak; spawn awal enemy; 1 tempat sembunyi |
| Pantry | Utara 1 | Counter & meja; ubin terang |
| R. Istirahat | Utara 2 | Sofa, meja, tanaman |
| R. Rapat | Utara 3 | Meja rapat besar |
| R. Manager | Utara 4 | Meja, sofa, rak |
| R. Keuangan | Timur laut | Meja & rak; pojok gelap |
| Toilet | Barat tengah | Wastafel; ubin terang |
| R. Arsip | Barat daya | Rak arsip; tugas Arsip; pintu terkunci A |
| Area Kerja (Workspace) | Tengah | Kubikel meja; rute patrol; 2 tempat sembunyi |
| R. IT | Tengah timur | Rak server; tugas Panel Listrik |
| R. Fotokopi | Tengah timur | Counter; tugas PC Fotokopi |
| R. HR | Timur tengah | Meja & rak; pintu terkunci B di dekatnya |
| R. Serbaguna | Selatan 1 | Meja proyek & boks |
| R. Server | Selatan 2 | Rak server; tugas co-op 2 pemain |
| Lobby | Selatan 3 | Spawn pemain + **pintu keluar** |
| Resepsionis | Selatan 4 | Counter & sofa |

Semua ruangan atas saling terhubung (celah antar dinding), semua ruangan
bawah juga saling terhubung, sesuai "koneksi ruangan (lebih dari satu jalur)"
di referensi. Tidak ada ruangan buntu.

## TileMap: 3 layer

| Layer | Z | Isi | Collision |
|---|---|---|---|
| Floor | -10 | Semua lantai (karpet/koridor/ubin/server) | Tidak ada |
| Walls | -5 | Dinding dalam & luar | Penuh 1 tile (physics layer 0) |
| Props | 5 | Meja, rak, sofa, tanaman, boks, counter, rak server | Penuh 1 tile |

TileSet: `assets/tiles/office_tileset.tres`, atlas
`assets/tiles/office_atlas.png` (8×3 tile @32px) yang dibangun dari
paket itch.io oleh `tools/build_office_atlas.py` (di luar project, di
workspace Muse — jalankan ulang script itu kalau mau mengubah isi
atlas, lalu jalankan generator):

```
Baris 0: [0]karpet [1]koridor [2]ubin [3]lantai-server [4]karpet-merah [5]kayu(lobby, cadangan) [6]dinding [7]dinding-luar
Baris 1: [0]meja+monitor [1]rak [2]meja-rapat [3]tanaman [4]rak-server [5]sofa [6]boks [7]counter
Baris 2: [0]kursi [1]dispenser [2]printer [3]whiteboard [4]tanaman-tinggi [5]flip-chart [6]sampah [7]kertas
```

Sumber per cell: lantai/dinding/meja rapat/tanaman/rak-server dari
Imersa (32px, langsung); ubin/lantai-server/meja+monitor/rak/sofa/boks/
counter dari RubberStudio (16px, upscale 2×). Baris 2: kursi/dispenser/
printer/whiteboard dari RubberStudio, tanaman tinggi/flip-chart/sampah/
kertas dari Imersa. Kolom `(5,0)` (lantai kayu) belum dipakai —
cadangan untuk variasi Lobby.

Karakter pemain & enemy memakai sprite Imersa (`office_worker`, 4 arah
idle/jalan) via `AnimatedSprite2D`; P2 dibedakan dengan tint biru,
enemy dengan tint gelap. 6 dekorasi overlay (nacl1234, tanpa collision)
menempel di cell prop yang sudah solid — daftarnya ada di
`tools/build_level_1.gd` (node `Decor`).

## Gameplay di map ini

### Tugas (7) — minigame kantor

Tekan **E** di dekat stasiun tugas untuk membuka minigamenya (musuh
tetap bergerak selagi kamu kerja; **Esc** membatalkan, progres
percobaan hilang). Tiap tugas punya aktivitas sendiri:

| ID | Nama | Minigame | Cara main |
|---|---|---|---|
| `pc_koridor` | PC Koridor | Laporan Excel | Jawab 5 soal hitung cepat (tombol 1/2/3) |
| `pc_barat` | PC Workspace Barat | Susun Slide | Tekan slide sesuai urutan 1-2-3-4 (tombol 1-4), 2 ronde |
| `pc_tengah` | PC Workspace Tengah | Balas Email | Ketik 4 kata yang tampil + Enter |
| `pc_fotokopi` | PC Fotokopi | Fotokopi | Tekan Spasi saat penanda di zona hijau, 5 lembar |
| `arsip` | Arsip Dokumen | Sortir Arsip | Tekan 1/2/3 sesuai folder dokumen, 6 dokumen. Membuka **Pintu A** |
| `listrik` | Panel Listrik | Panel Listrik | Hafalkan & ulangi urutan lampu (Simon, 3 ronde). Membuka **Pintu B** |
| `server` | Server (Co-op) | Sinkronisasi Server | Tekan lampu yang menyala (1-4) secepatnya, 8x. **Wajib 2 pemain**: tiap pemain menyelesaikan bagiannya sendiri, dan tugas selesai saat kedua bagian beres + keduanya berada di dekat server. Mode solo: 1 pemain cukup. |

### Tempat sembunyi (10)

Gudang, Pantry, R. Istirahat, R. Keuangan, Area Kerja (×2), R. Fotokopi,
R. Arsip, R. Serbaguna, Resepsionis. Tekan E untuk sembunyi/keluar.
Enemy tidak bisa mendeteksi pemain sembunyi kecuali jarak < 42px.

### Pintu terkunci (2, hanya pintas)

- **Pintu A** — dinding barat (cell `(8,24)`–`(8,25)`), Arsip ↔ Area Kerja.
- **Pintu B** — dinding timur (cell `(55,24)`–`(55,25)`), Area Kerja ↔
  koridor timur/HR.
- Cell-nya kosong di layer Walls; soliditas dari node `LockedDoor`.
  Konektivitas map sudah dicek dengan BFS (Python) dan A* (smoke test):
  semua tugas terjangkau saat kedua pintu tertutup, dan jalur A* tidak
  pernah lewat pintu tertutup.

### Enemy: patrol, spawn, blink

- **Patrol loop** (8 waypoint, searah jarum jam): koridor atas →
  sisi timur workspace → koridor bawah workspace → sisi barat.
- **Spawn awal**: Gudang. **8 titik blink**: Gudang, R. Keuangan,
  R. Arsip, R. Server, R. HR, R. Rapat, R. Serbaguna, Resepsionis.
- Blink tiap 16–26 detik saat patrol/search: hilang 0,6 dtk + lampu
  padam, teleport ke titik berjarak 350–950px dari pemain terdekat,
  lalu buta 2,5 detik (jalan pelan, tidak mendeteksi).
- Kecepatan: patrol 95, chase 205 (jalan pemain 170, lari 235),
  jangkauan pandang 430px + line-of-sight raycast, waktu reaksi 0,8 dtk,
  lari (Shift) terdengar sampai 330px.

### Titik Item Bangkit (8, acak)

Gudang, R. Keuangan, R. Serbaguna, Resepsionis, koridor workspace atas,
workspace tenggara, R. Rapat, Toilet. Marker-nya ada di node `Spawns`
(`Revive1`–`Revive8`) dan bisa digeser di editor.

### Cahaya & kegelapan

- `CanvasModulate` dasar `(0.26, 0.26, 0.34)`; saat blackout `(0.07, 0.07, 0.10)`.
- 12 lampu langit-langit (PointLight2D) yang berkedip pelan; pojok
  Gudang, Keuangan, Toilet, dan Serbaguna sengaja tanpa lampu.
- Tiap pemain membawa cahaya hangat (radius ~180px); enemy membawa
  cahaya merah redup supaya masih bisa dilihat di gelap.
- **Keterbatasan base**: cahaya menembus dinding (tanpa shadow/
  LightOccluder2D). Kalau mau bayangan dinding yang benar, tambahkan
  `LightOccluder2D` di dinding dan aktifkan `shadow_enabled` di lampu —
  dicatat sebagai peningkatan, bukan bug.

## Tuning cepat

Semua angka penting ada sebagai konstanta di awal script:

- `scripts/level_1.gd` — `PAR_TIME` (360 dtk), jarak interaksi, waktu
  exit/rescue, warna gelap, aturan bintang (di `_finish_level`).
- `scripts/enemy.gd` — kecepatan, jangkauan, waktu blink/buta/reaksi.
- `scripts/player.gd` — kecepatan jalan/lari.
- `scripts/task_station.gd` — `game_type` per tugas diatur di scene
  (properti node di `Tasks/`), bukan di script. Minigamenya ada di
  `scripts/minigames/`; lapisannya `scripts/minigame_layer.gd`.

## Membuat Level 2+ (rencana)

Duplikasi `scenes/level_1.tscn` → `level_2.tscn`, edit TileMap-nya,
ubah `LEVEL_ID` dan daftar tugas di script level (saat ini `LEVEL_ID`
masih hardcode di `level_1.gd` — pindahkan ke Resource/konfigurasi
sebelum menambah level agar tidak menduplikasi logika). Status per level
(Happy/Bad + bintang) sudah didukung `GameProgress` per `level_id`.
