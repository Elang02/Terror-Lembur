# Prop Scenes + Collision Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Perbaiki collision yang terlalu besar (player tidak bisa lewat celah yang kelihatan cukup) dan ubah tiap barang jadi scene reusable (.tscn) yang tinggal ditempel ke map.

**Architecture:** Player capsule dikecilkan dan dibuat eksplisit; tiap tipe prop jadi satu scene di `scenes/props/` (Node2D + Sprite2D + StaticBody2D dengan collision yang sudah diukur pas); `level_1.gd` instance scene prop itu; `level_1.tscn` di-rebake jadi berisi instance scene prop; hide spot diambil dari group `hide_spot` agar ikut pindah kalau prop digeser di editor.

**Tech Stack:** Godot 4.7, GDScript, TileMapLayer + TileSet (Gridwright walls, Imersa floor/props).

**Spec:** Permintaan Elang 13 Nov 2026 ~15:38 WIB: collision terlalu besar (meja bikin gabisa lewat padahal celah besar; player + barang collisionnya kebesaran); level 1 harus dibuat scene satu-satu per barang biar bisa dipakai berkali-kali (misal meja: collision seberapa + scriptnya, tinggal tempel ke map); pakai using-superpowers.

## Global Constraints

- Bahasa Indonesia untuk nama node (Meja, Kursi, dst) — sudah jadi standar di `level_1.tscn`.
- Jangan ada em dash di teks game/chat.
- Commit author/committer = Vicentius Elang Krisnanto <elangk123@gmail.com>.
- Token GitHub TIDAK disimpan; push butuh token transient dari Elang.
- `export PATH="$HOME/workspace/tools/git-lfs:$PATH"` SEBELUM `git add`/`git commit`.
- Jangan pakai `git checkout` untuk revert; pakai `git show HEAD:<file> > <file>`.
- Jangan pakai `pkill -f` (bisa bunuh shell sendiri); kill pakai PID eksplisit.
- Tes = WS host+client (`--host --bot --ws` + `--join 127.0.0.1 --bot --ws`), hitung POS, 0 script error; screenshot Xvfb + ffmpeg x11grab.
- `level_1.tscn` di-rebake pakai `tools/bake_map.gd` (owner diset rekursif biar child ikut kepack); uid scene dipertahankan.
- Aset tetap FREE (Gridwright free sample, Imersa free, Rubber Studio free sample).

## Review Focus

- Player tetap tidak bisa lewat celah 2-tile pintu (64px) setelah capsule dikecilkan — harus bisa.
- Hide spot tidak ikut pindah saat meja digeser di editor (group tidak terisi) — ngumpet (C) harus tetap jalan di 28 titik.
- Prop scene instance di `.tscn` kehilangan texture/collision setelah re-import (ext_resource path salah) — game harus render + collision sama seperti sebelum refactor.
- Collision prop baru terlalu kecil sampai player bisa jalan menembus visual meja — harus tetap nempel di badan visual prop.
- Boss/patroli dan task tetap jalan setelah refactor (tidak ada yang pecah karena node prop berubah jadi instance).

---

### Task 1: Kecilkan player collision

**Files:**
- Modify: `scenes/worker_char.tscn` (CapsuleShape2D sub-resource)

**Interfaces:**
- Consumes: CapsuleShape2D default height 30.0 (terbukti via cap test) — inilah penyebab player 14x30 dan terasa gemuk vertikal.
- Produces: CapsuleShape2D radius 6.0, height 16.0 (12x16) — eksplisit di `.tscn`.

- [ ] **Step 1: Ubah CapsuleShape2D di `worker_char.tscn` jadi radius 6.0, height 16.0**
- [ ] **Step 2: Check-only worker_char.gd + editor import, pastikan 0 error**
- [ ] **Step 3: Commit**

### Task 2: Script prop reusable (`scripts/prop.gd`)

**Files:**
- Create: `scripts/prop.gd`

**Interfaces:**
- Consumes: tidak ada.
- Produces: `class_name Prop extends Node2D`, `@export var is_hide_spot := false`; `_ready()` tambah ke group `hide_spot` kalau `is_hide_spot` true. Dipakai semua prop scene.

- [ ] **Step 1: Tulis `scripts/prop.gd`**
- [ ] **Step 2: Check-only, pastikan 0 error**
- [ ] **Step 3: Commit**

### Task 3: Buat scene prop reusable di `scenes/props/`

**Files:**
- Create: `scenes/props/meja.tscn`, `kursi_depan.tscn`, `kursi_belakang.tscn`, `kursi_kiri.tscn`, `kursi_kanan.tscn`, `komputer.tscn`, `laptop.tscn`, `lemari.tscn`, `tanaman.tscn`, `tanaman_tinggi.tscn`, `jam_dinding.tscn`, `dispenser.tscn`, `tempat_sampah.tscn`, `lampu_meja.tscn`, `mug.tscn`, `tumpukan_kertas.tscn`, `meja_rapat.tscn`, `flipchart.tscn`, `layar_proyektor.tscn`, `papan_tulis.tscn`, `sofa.tscn`, `rak_buku.tscn` (22 file)

**Interfaces:**
- Consumes: `scripts/prop.gd`; tekstur Imersa (`assets/office_assets/main/...`) + Rubber Studio modern (`assets/office_assets/modern/objects/`).
- Produces: Tiap scene = root Node2D (script `prop.gd`, nama jenis misal `Meja`) + anak `Gambar` (Sprite2D, texture + offset `Vector2(0, -h/2 + 16)`) + anak `Collision` (StaticBody2D layer 1 mask 0 + CollisionShape2D RectangleShape2D di `(0, 8)`) kalau solid. Collision baru (lebih kecil, inset): Meja (56,18), Kursi (20,14), Lemari (24,18), Tanaman (20,12), Tanaman_Tinggi (14,12), Dispenser (16,12), Tempat_Sampah (12,10), Meja_Rapat (88,32), Flipchart (20,10), Sofa (38,16), Rak_Buku (26,16). Non-solid (tanpa Collision): Komputer, Laptop, Jam_Dinding, Lampu_Meja, Mug, Tumpukan_Kertas, Layar_Proyektor, Papan_Tulis. `is_hide_spot=true` di scene Meja + Meja_Rapat (semua meja adalah hide spot).

- [ ] **Step 1: Buat generator `tools/make_prop_scenes.py` yang menulis ke-22 `.tscn` dari tabel di atas**
- [ ] **Step 2: Jalankan generator, verifikasi tiap `.tscn` ada dan `grep` nama + texture + collision benar**
- [ ] **Step 3: Editor import, pastikan 0 error dan scene bisa dibuka**
- [ ] **Step 4: Commit**

### Task 4: Refactor `level_1.gd` ke instance scene prop + hide spot dari group

**Files:**
- Modify: `scripts/level_1.gd`

**Interfaces:**
- Consumes: scene prop dari Task 3; group `hide_spot` dari `prop.gd`.
- Produces: `_place_prop()` / `_place_modern()` instance scene prop (bukan bangun node dari nol); `_init_desk_positions()` kumpulkan posisi dari group `hide_spot` (bukan dari const HIDE_SPOTS); HIDE_SPOTS const dihapus; `is_hide_spot` di-set true pada instance lemari/rak di posisi hide spot lama (Gudang/Arsip/Server) saat bake.

- [ ] **Step 1: Tambah dict `PROP_SCENES` (rel path -> scene path) dan ubah `_place_prop`/`_place_modern` jadi instance scene + set position + set `is_hide_spot` kalau posisi ada di daftar hide spot lama**
- [ ] **Step 2: Ubah `_init_desk_positions()` jadi ambil dari `get_tree().get_nodes_in_group("hide_spot")`**
- [ ] **Step 3: Hapus const HIDE_SPOTS; hapus pemakaian `_indo_name` untuk penamaan root (nama sudah dari scene) tapi pertahankan `_prop_name` untuk penomoran instance bila perlu**
- [ ] **Step 4: Check-only `level_1.gd`, pastikan 0 error**
- [ ] **Step 5: Commit**

### Task 5: Re-bake `level_1.tscn` jadi instance scene prop

**Files:**
- Modify: `scenes/level_1.tscn` (via `tools/bake_map.gd`)
- Modify: `tools/bake_map.gd` (bila perlu sesuaikan urutan bake)

**Interfaces:**
- Consumes: Task 3 + Task 4.
- Produces: `level_1.tscn` berisi FloorLayer + WallLayer + instance scene prop (ext_resource ke `scenes/props/*.tscn`) + horror static + sel; uid dipertahankan.

- [ ] **Step 1: Jalankan bake, verifikasi jumlah node + ada `instance = ExtResource` ke prop scene**
- [ ] **Step 2: Editor import, pastikan 0 error**
- [ ] **Step 3: Commit**

### Task 6: Verifikasi game jalan + celah bisa dilewati + ngumpet jalan

**Files:**
- Test: WS host+client + screenshot (tidak ada file yang diubah)

**Interfaces:**
- Consumes: Task 1-5.
- Produces: Bukti host/client POS > 0, 0 script error; screenshot map + player; verifikasi hide spot 28 titik dari group.

- [ ] **Step 1: WS host+client test (host-ready wait, stdbuf), hitung POS kedua sisi, 0 script error**
- [ ] **Step 2: Screenshot Xvfb, pastikan prop + tembok + HUD render; player terlihat**
- [ ] **Step 3: Verifikasi hide spot (headless atau baca group) = 28 titik**
- [ ] **Step 4: Commit (bila ada perbaikan dari temuan tes)**

### Task 7: Zip + kirim ke Elang

**Files:**
- `~/workspace/user/files/Terror-Lembur.zip` (via `build_zip.sh`)

- [ ] **Step 1: Build zip via `build_zip.sh`, verifikasi `unzip -l` (level_1.tscn + prop scenes + office_tileset.tres ada)**
- [ ] **Step 2: Update MEMORY.md (collision + prop scene)**
- [ ] **Step 3: Kirim zip + screenshot ke Elang + jelaskan cara pakai scene prop**
