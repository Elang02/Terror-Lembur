# Level 2 — Lobi Kantor "Gelap Gulita" (TileMap 72 × 46)

`scenes/level_2.tscn` adalah lobi kantor tempat pemain turun dari Level 1
lewat tangga darurat. Semua tile sudah dicat di `TileMapLayer`, jadi map
bisa diubah langsung pakai kuas TileMap di Godot.

![Posisi node di map](map_level2_node.png)

- Desain gameplay lengkap (gambar yang disetujui): `desain_map_level2.png`
- Asal tiap aset di map: `sumber_aset_level2.png`
- Map polos tanpa penanda: `map_preview_level2.png`
- Isi atlas props (buat mencari tile saat mengecat): `katalog_props_lobi.png`

## Cara mencoba

1. Buka `scenes/level_2.tscn`, tekan **F6** (Run Current Scene). Game jalan
   dalam mode solo (bawaan NetworkManager).
2. Di panel **Output** harus muncul satu baris
   `[Level 2] tugas: 7 | tempat sembunyi: 10 | lampu: 30 | titik cas: 6 | titik kabel: 4 | titik rute satpam: 12 | komputer: ada`.
   Kalau ada angka 0, berarti ada node yang namanya berubah atau pindah.
3. Cek otomatis: buka `tests/smoke_test_level2.tscn`, tekan **F6**, lalu cari
   `SMOKE L2: ALL PASS` di Output.

Main menu masih membuka Level 1 saja; tombol Level 2 menyusul.

## Struktur scene

```
Level2 (Node2D, level_2.gd, Y Sort Enabled ON)
├── CanvasModulate
├── Lantai          (TileMapLayer, z -10)  lantai, tanpa collision
├── karpet          (TileMapLayer, z -9)   karpet kolam + kertas/kardus yang jatuh di lantai (tanpa collision)
├── Dinding         (TileMapLayer, z -5)   wall top + wall face, ada collision
├── hiasan_dinding  (TileMapLayer, z -4)   poster, jam, papan, TV dinding (tanpa collision)
├── Props           (TileMapLayer, z 5, Y Sort ON)  bagian BAWAH furnitur yang menapak lantai, ADA collision
├── props_atas      (TileMapLayer, z 5, Y Sort ON)  bagian ATAS furnitur tinggi, TANPA collision
├── Props2          (TileMapLayer, z 6)    barang kecil di atas meja: monitor, gelas, laptop (tanpa collision)
├── NamaRuangan     (Label nama area, panduan editor, disembunyikan saat main)
├── Lampu           (30 PointLight2D, sebagian dikelompokkan per area)
│   ├── LampuTangga, PointLight2D, ExitSign, LayarCCTV, ...
│   ├── Resepsionis / Atrium / kafe / RuangRapat / Gudang   (Node2D berisi lampu)
├── Spawn
│   ├── PlayerSpawn1, PlayerSpawn2
│   ├── musuh       (EnemySpawn1–8)
│   └── Revive1–8
├── TitikCas        (6 instance titik_cas.tscn)
├── JalurSatpam     (Line2D Fase1, Fase2, Fase3; disembunyikan saat main)
├── Tugas           (7 TaskStation + Marker2D PanelPintu_RSecurity)
├── TempatSembunyi  (10 HidingSpot)
├── TitikKabel      (4 instance titik_kabel.tscn)
├── PintuKeluar, Kurungan, ItemBangkit
├── Pemain          (Node2D, Y Sort ON; pemain di-spawn di sini dengan z_index 5)
├── Satpam          (instance enemy.tscn; sprite diganti "Manager" bubbabba lewat script, z_index 5)
├── KomputerSecurity (instance komputer_security.tscn)
└── HUD
(dibuat script saat game jalan: MinigameLayer, HudMalam, LayarKomputer)
```

### Nama yang tidak boleh diganti

`level_2.gd` mencari node berikut berdasarkan nama, jadi namanya jangan
diubah: `Lantai`, `Dinding`, `Props`, `CanvasModulate`, `Lampu`, `Spawn`,
`Tugas`, `TempatSembunyi`, `Pemain`, `Satpam`, `PintuKeluar`, `Kurungan`,
`ItemBangkit`, `HUD`, `NamaRuangan`, `JalurSatpam` (+ `Fase1` di dalamnya),
`TitikCas`, `TitikKabel`. Marker di dalam `Spawn` juga harus tetap bernama
`PlayerSpawn1`, `EnemySpawn1`, `Revive1`, dst.

Isi di **dalam** grup boleh bebas: nama lampu, nama tugas, nama tempat
sembunyi, dan folder Node2D tambahan (misal `Lampu/Atrium`) tidak masalah,
karena script mencarinya rekursif.

## TileSet: `assets/tiles/lobi/tileset_lobi.tres`

| Source | Gambar | Isi |
|---|---|---|
| 0 – dinding lobi | `dinding_lobi.png` | 37 potongan dinding gelap bubbabba (wall top + 2 baris wall face) |
| 1 – lantai | `lantai_lobi.png` | 23 jenis lantai (marmer, terrazzo, karpet, kayu, beton, dll) |
| 2 – props lobi | `props_lobi.png` | Furnitur & dekorasi dipotong per 32×32. Lihat `katalog_props_lobi.png` |

Physics layer 0 = collision layer 1, sama seperti Level 1.

### Collision "telapak" + Y-Sort (revisi collision)

Dulu semua tile furnitur punya collision penuh 32×32, jadi pemain nyangkut
di daun tanaman, sandaran kursi, atau bagian atas lemari. Sekarang:

| Jenis benda | Contoh | Bagian yang padat |
|---|---|---|
| Benda tinggi | tanaman, rak, lemari, vending, kursi, loker, bilik telepon | setengah tinggi bagian bawah saja (1×2 → 1 baris bawah, 2×3 → 2 baris bawah) |
| Benda yang menutupi lantai | meja, kubikel, partisi, sofa, counter resepsionis, set meja rapat, tangga | semua baris |
| Benda datar | karpet kolam, kertas/kardus di lantai | tidak padat |

- Bentuk collision tiap tile = kotak yang membungkus piksel benda (bukan
  kotak penuh 32×32), jadi celah di samping pot/kaki meja bisa dilewati.
- Tile yang padat ada di layer `Props`; bagian atas benda tinggi ada di
  `props_atas` (tanpa collision). Satpam (pathfinding) hanya membaca `Props`.
- **Y-Sort**: `Level2`, `Pemain`, `Props`, `props_atas` sama-sama Y Sort
  Enabled, dan pemain + Satpam z_index 5 (sama dengan furnitur). Hasilnya:
  berdiri di bawah tanaman → pemain di depan; berjalan di belakang lemari →
  pemain tertutup lemari.
- Tiap tile furnitur punya **Y Sort Origin** (TileSet → tile → Rendering →
  Y Sort Origin) = jarak ke dasar benda. Contoh tanaman 1×2: tile atas 32,
  tile bawah 0. Jadi seluruh benda diurutkan dari titik kakinya.
- Cek visual: menu **Debug → Visible Collision Shapes**, lalu F5.
  Gambar semua kotak collision: `docs/collision_level2.png`, contoh
  depan/belakang: `docs/simulasi_ysort_level2.png`.

## Aturan waktu mengedit

1. **Satpam (pathfinding) membaca tile.** Cell bisa dilewati kalau ada tile
   di `Lantai` dan tidak ada tile di `Dinding` maupun `Props`. Bagian atas
   benda tinggi taruh di `props_atas`, barang kecil di meja di `Props2`,
   barang di lantai/karpet di `karpet`, hiasan tembok di `hiasan_dinding`.
2. **Rute patroli Satpam** = titik-titik Line2D `JalurSatpam/Fase1`. Pilih
   node `Fase1`, lalu geser titiknya di viewport. Titik harus berada di
   lantai yang bisa dilewati. `Fase2` dan `Fase3` belum dipakai script.
3. **Tugas & tempat sembunyi** dihitung dari jarak: pemain harus bisa
   berdiri dalam 62 px dari tugas dan 50 px dari tempat sembunyi. Jangan
   taruh keduanya terlalu dekat (kalau dekat, tombol E selalu membuka tugas).
4. Setelah mengubah map, jalankan `tests/smoke_test_level2.tscn` (F6). Kalau
   jumlah tile berubah, angka di test ikut disesuaikan.

## Alur malam (Tahap 1)

1. Spawn di Tangga Darurat, baterai HP **0%**, lobi hampir gelap total.
   Pandangan hanya lingkaran kecil bergradasi (jelas ±1,5 tile).
2. Cari **titik cas** (lampu hijau kecil). Tekan **E**, lalu diam 10 detik
   (0→100%). Bergerak = HP tercabut. Setelah dipakai, colokan **korslet
   90 detik** (1 jam game). Cas pertama **membangunkan Satpam**.
3. Pandangan **selalu** lingkaran 1,5 tile. Mau melihat lebih jauh =
   tekan **R** (senter HP, kerucut 7 tile, baterai turun 15%/detik).
   Selama baterai > 0%, HP hidup → posisimu terlihat di denah operator,
   baterai turun pelan (1% per 2 detik).
4. Ke **R. Security**, tekan **E** di komputer → jam mulai dari **21.00**
   dan layar denah terbuka (E/Esc untuk berdiri). Denah menampilkan posisi
   teman (kalau HP-nya menyala), laporan + batas waktu, status titik cas,
   titik kabel. Satpam tidak tampil.
5. Laporan gangguan muncul tiap jam (22.00 … 04.00). Batas waktu 1,5 jam
   game (fase 1), lalu 1 jam. Genset terlambat → semua titik cas padam
   sampai genset dibereskan.
6. Jam **23.30, 01.30, 03.30** komputer error: jam berhenti, satu titik
   kabel acak memercik. Tekan E di sana → minigame **Sambung Kabel**.
7. **05.00**: lampu lobi menyala, Satpam berhenti, pintu kaca terbuka kalau
   *Kunci Cadangan* dan *Pintu Kaca (berdua)* sudah beres. Berdiri berdua di
   pintu keluar = menang. Bintang: laporan tepat waktu + jumlah tertangkap.

Jam muncul tiap laporan diatur di Inspector node tugas → bagian
**Metadata** (`jam_laporan`, `area`, `wajib`). Titik cas yang tetap hidup
di fase 4 dicentang `aktif_saat_subuh` (sekarang: Resepsionis dan
R. Rapat Tamu). Angka-angka (baterai, cas, zoom kamera) ada di bagian atas
`scripts/level_2.gd`. Simulasi tampilan kamera: `simulasi_kamera_level2.png`.

## HUD Level 2 ("benda-benda kantor")

Semua digambar dari kode di `scripts/level2/hud_malam.gd` (tanpa gambar):

| Benda | Posisi | Isi |
|---|---|---|
| HP pemain | kiri bawah | baterai, jam + fase, notifikasi laporan, tombol senter (R). **Baterai 0% = layar HP mati** (jam & notifikasi hilang) |
| Sticky note | kanan atas | 7 laporan: titik-titik = belum muncul, dilingkari merah = aktif, centang biru = beres, dicoret merah = terlambat |
| ID card | kiri atas | P1/P2 + garis baterai; cap DIKURUNG / SEMBUNYI |
| Label Dymo | bawah tengah | tombol yang bisa ditekan sekarang |
| Baris log | atas tengah | kejadian besar (error, subuh, tertangkap) diketik huruf demi huruf |
| Penanda di lantai | di alat yang rusak | titik + gelombang bunyi (`penanda_laporan.gd`), cincin progres saat dikerjakan |
| Popup tugas | tengah | bingkai monitor CCTV "SECURA" (`minigame_layer.gd` → `pakai_gaya_monitor`, khusus Level 2) |

Font: Inter (layar HP) dan Latin Modern Mono (gaya mesin ketik), di `assets/fonts/`.

## Menu debug (Inspector)

Pilih node **Level2** di Scene Tree → Inspector → grup **Debug (khusus tes)**.
Centang **Debug Aktif** dulu; pilihan lain diabaikan kalau saklar ini mati.

| Pilihan | Gunanya |
|---|---|
| Debug Mulai Menit | mulai dari jam tertentu (60 = 22.00, 150 = 23.30, 420 = 04.00) |
| Debug Komputer Nyala | jam langsung berjalan tanpa ke R. Security |
| Debug Baterai Awal | baterai awal (%) |
| Debug Baterai Tak Habis | baterai tidak berkurang |
| Debug Kecepatan Jam | 1 = normal, 6 = semalam ±2 menit |
| Debug Tanpa Satpam | Satpam tidak pernah aktif |
| Debug Kebal | tidak bisa tertangkap |
| Debug Terang | lobi terang |
| Debug Tanpa Error Kabel | lewati error 23.30/01.30/03.30 |
| Debug Tampilkan Panduan | nama ruangan & rute Satpam terlihat saat main |
| Debug Kotak Info | kotak info kanan bawah (jam, komputer, satpam, baterai, cas, laporan, FPS) |
| Debug Tombol Cepat | F1 info · F2 +30 menit · F3 baterai 100% · F4 picu/perbaiki error · F9 terang · F10 lompat ke 04.59 |

Saat debug aktif, di atas layar muncul tanda kuning **DEBUG**. Matikan sebelum
game dikumpulkan; smoke test juga mengecek ini.

## Status mekanik

| Bagian | Status |
|---|---|
| Map, collision, tugas (minigame Level 1), sembunyi, kurungan, pintu keluar | Sudah jalan (sudah kamu tes) |
| Hampir gelap total, zoom kamera 4,5, lingkaran pandang tetap 1,5 tile, baterai, senter, titik cas + korslet | Sudah dibuat (Tahap 1), tunggu hasil tesmu |
| Komputer security + denah operator, jam 21.00–05.00, fase, laporan per jam + batas waktu, error kabel + minigame sambung kabel, pintu kaca jam 05.00 | Sudah dibuat (Tahap 1), tunggu hasil tesmu |
| Satpam | Sprite "Manager" bubbabba (asli, tanpa diedit). Sementara memakai AI musuh Level 1 (patroli + kejar + tangkap), aktif setelah cas pertama |
| Collision furnitur | Revisi: collision "telapak" + Y-Sort (lihat bagian TileSet) |
| Mantan Bos (kunci target, senter memancing, ganti target, menghilang), Satpam baru (kerucut pandang, lapor HT, kecepatan per fase), hukuman laporan selain genset, Bos mengejar saat Lari Subuh | Tahap berikutnya |
| Speaker panggung & lift | game_type sementara `email` dan `excel`; nanti diganti minigame tahan E dan keypad |

## Rumus posisi

posisi piksel = (kolom × 32 + 16, baris × 32 + 16) untuk tengah cell.
Ukuran map: 72 × 46 cell (2304 × 1472 px). Batas kamera diambil dari
`get_map_size_tiles()` di `level_2.gd`.

## Generator (arsip)

`tools/generate_tilemap_lobi.py` adalah script Python yang dulu dipakai
merakit map ini dari pack aslinya. Tidak perlu dijalankan; kalau dijalankan,
script itu menimpa `scenes/level_2.tscn` dan semua perubahan dari editor.
