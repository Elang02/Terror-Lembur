# LEVEL 2 — Desain Lantai 2 ("Ruang Direksi Lama")

**Status:** Desain selesai (Phase 40, 15 Nov 2026). **Implementasi DITUNDA sampai sesudah submit Gimersia 29 Nov 2026** — Gimersia cuma butuh 1 lantai. Dokumen ini yang bikin level berikut benar-benar sesuai konsep, bukan asal tambah map.

**Sumber konsep:** `~/workspace/lembur-game/KONSEP.md` §2 (Pulang), §4 (core loop), §6 (bos), §8 (menang/kalah, ending, nerf antar level), §13 (scope: level berikut + nerf ditunda, desainnya sudah ada).

---

## 1. Cerita: kenapa naik, bukan pulang

Pintu keluar lantai 1 ternyata bukan jalan pulang — itu pintu tangga. Pintu utama gedung di lantai dasar dikunci dari luar sama hantu bos. Satu-satunya jalan keluar gedung ada di lantai 2, ruang direksi lama: di sana ada kunci utama gedung (atau panel listrik utama yang bisa buka kunci pintu utama).

Tema **Pulang** tetap: pemain masih berusaha pulang, cuma jalannya lebih panjang. Tiap lantai selesai = selangkah lebih dekat ke pintu utama. Bos makin marah tiap lantai karena pemain makin dekat ke kabur.

**Aturan cerita yang mengikat semua level berikut:**
- Tiap lantai = 1 lantai gedung, 1 bos (hantu yang sama, makin agresif).
- Core loop TIDAK berubah: patrol → kerjain tugas (berisik) → bos datang → mancing → tugas kelar → kode pintu → kabur.
- Tiap tugas selesai: satu area kantor lampunya nyala, bos sedikit lebih cepat.
- Pintu keluar tiap lantai terkunci sampai semua tugas utama lantai itu selesai.

---

## 2. Peta lantai 2

- Grid **48x28 tile (1536x896 px)**, sama kayak lantai 1 — tileset, props, dan sistem map dipakai ulang.
- **15 ruangan, susunan beda dari lantai 1.** Ruang bos di ujung (direksi lama, kanan atas), sel di dalamnya.
- Ruangan (posisi di-tentukan pas implementasi, pakai Rect2 kayak lantai 1):
  DIREKSI LAMA (ruang bos + sel), ARSIP LAMA, SERVER UTAMA, RUANG RAPAT BESAR,
  PERPUSTAKAAN, PANTRY, TOILET, LOBBY TANGGA, KEUANGAN, HR, IT, FOTOKOPI,
  GUDANG, SERBAGUNA, ISTIRAHAT.
- Pintu keluar lantai 2 di ujung bawah (LOBBY TANGGA), terkunci sampai 5 tugas selesai.
- Tempat ngumpet: bawah meja + lemari (sama kayak lantai 1, posisi baru).

---

## 3. Lima tugas utama (lebih susah, jenis minigame sama)

Minigame dipakai ulang dengan parameter lebih susah — pemain langsung paham cara mainnya, tapi tantangannya naik. Ini sesuai konsep: tugas itu kerja lembur, bukan teka-teki baru tiap lantai.

| # | Tugas | Lokasi | Minigame | Lebih susah dari lantai 1 |
|---|-------|--------|----------|---------------------------|
| 1 | Server Utama | SERVER UTAMA | Panel Listrik (Simon) | **5 ronde** (lantai 1: 4) |
| 2 | Komputer Direksi | DIREKSI LAMA (dekat ruang bos!) | Excel | **8 soal** (lantai 1: 7) |
| 3 | Arsip Lama | ARSIP LAMA | Fotokopi | **8 lembar** (lantai 1: 7) |
| 4 | Cari Berkas Lama | GUDANG | Cari (kertas berhalaman) | **4 halaman, 4 ronde** (lantai 1: 3 halaman, 3 ronde) |
| 5 | Urut Catatan Lama | RUANG RAPAT BESAR | Urut (tanggal) | **6 tanggal** (lantai 1: 5) |
| + | Pintu Keluar | LOBBY TANGGA | Keypad | **5 digit** dari 5 tugas, memory-only (sama) |
| + | Tuas Sel | DIREKSI LAMA | Mash | sama |

**Catatan desain:** Komputer Direksi sengaja ditaruh DEKAT ruang bos — tugas paling berisiko di lantai 2, sesuai konsep §7 (ada tugas yang lebih aman berdua). Di solo, pemain harus mancing bos menjauh dulu sebelum buka Excel.

---

## 4. Eskalasi bos lantai 2

Bos yang sama, makin marah karena pemain lolos dari lantai 1 (fiksi). Angka:

| Stat | Lantai 1 | Lantai 2 |
|------|----------|----------|
| SPEED_PATROL | 130 | 140 |
| SPEED_CHASE | 240 | 255 |
| SPEED_SEARCH | 160 | 170 |
| VISION_RANGE | 340 | 350 |
| HEARING_WALK / SPRINT | 160 / 360 | 180 / 380 |
| TELEPORT_MIN / MAX | 14 / 20 | 12 / 18 |
| FIRST_TELEPORT | 25 / 35 | 20 / 30 |
| Enrage (semua tugas kelar) | +0.3, teleport x0.6 | sama |

Prinsip: naiknya KECIL (5-10%) tiap lantai. Bos tidak boleh jadi mustahil — yang naik itu tekanan, bukan hukuman.

---

## 5. Nerf antar level (konsep §8)

Hasil lantai 1 kebawa ke lantai 2:

| Hasil lantai 1 | Nerf di lantai 2 |
|----------------|------------------|
| **Happy Ending (3 bintang, tidak ketangkep)** | Tanpa nerf |
| **Ending Pahit (1-2 bintang, ketangkep 1-2x)** | Gerak -20%, senter lebih redup (energy 2.5 ke 1.8), tugas +25% langkah (soal/ronde/lembar nambah) |

- Nerf bisa numpuk **max 2x** (buat lantai 3+).
- Nerf berlaku per pemain (co-op: yang dikurung yang kena nerf, temannya tidak).
- Layar akhir tiap level menunjukkan bintang + nerf yang kebawa, jadi konsekuensinya jelas sebelum lanjut.

---

## 6. Bintang + layar akhir

Per level: **3 bintang** = tidak ketangkep sama sekali; **2 bintang** = ketangkep 1x; **1 bintang** = ketangkep 2x / ending pahit. Layar akhir: judul ending (Happy / Pahit), bintang, tombol "Lanjut ke Lantai 2" (kalau ada) dan "Ulangi Lantai".

---

## 7. Arsitektur: data level harus jadi data (ini kuncinya)

**Larangan:** Level 2 BUKAN copy-paste `level_1.gd` + `level_1.tscn` dengan angka diganti. Itu yang bikin level berikut melenceng dari konsep lama-lama.

**Syarat:** Semua yang beda antar level masuk ke SATU config per level (`LEVEL_CONFIGS` — dict di `level_config.gd` atau resource):

- `TASK_DEFS` (id, label, posisi, need, time, noise, kind)
- `PATROL_LOOP` + `patrol_start_index`
- `ALL_ROOMS` + `BOSS_ROOM` + `CELL_POS`
- `HIDE_SPOT_POSITIONS` + `LOCKED_DOORS`
- Stat bos lantai itu (chase, patrol, teleport, vision, hearing)
- `nerf` yang berlaku

`level_1.gd` jadi `level.gd` yang diparameterisasi config. Yang dipakai ulang tanpa diubah: `boss.gd`, `worker_char.gd`, `task_popup.gd` (kind diparameterisasi), `sfx.gd`, `network.gd`, tileset, props. Map tiap lantai tetap di-bake jadi `.tscn` sendiri (`level_2.tscn`).

**Menu:** pilih lantai — lantai 2 terbuka setelah lantai 1 tamat (disimpan di `user://progress.cfg`). Solo + LAN tetap jalan di lantai 2.

---

## 8. Yang TIDAK berubah di level berikut

- Tema Pulang, bos hantu bos lama (Nasha Pale Figure), 1 bos per lantai.
- Kode pintu dari tugas, memory-only, 5 digit.
- Sistem kurung + self-rescue + 3x ketangkep = game over (solo).
- Aturan aset: gratis + dideklarasikan, tanpa AI.
- Tutorial cuma muncul di lantai 1 (pemain lantai 2 diasumsikan sudah bisa main).

---

## 9. Checklist implementasi (nanti, sesudah Gimersia)

1. `level_config.gd` + `LEVEL_CONFIGS` (lantai 1 dipindah ke config dulu, tes hijau, baru tambah lantai 2).
2. `level_2.tscn` (bake map baru) + `LEVEL_CONFIGS[2]`.
3. Nerf: `worker_char.nerf_level` (gerak, senter) + `task_popup` langkah tugas x1.25.
4. Layar akhir: bintang + tombol lanjut lantai.
5. Menu pilih lantai + `user://progress.cfg`.
6. Tes: `test_level2` (config lantai 2 valid, tugas 5, bos stat naik, nerf jalan).
7. Video playthrough lantai 2 (bot demo, sama kayak lantai 1).
