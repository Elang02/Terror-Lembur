# Terror Lembur — Design Notes (MDA, Core Loop, Art)

Dokumen ini merangkum keputusan desain yang dipakai buat Gimersia Inspire 2026.
Sumber: one-pager Terror Lembur (14 Nov 2026), 4 video kelas umum Gimersia minggu 1,
dan hasil tes di repo ini.

## MDA

### Mechanics (aturan)
- Gerak top-down (WASD), senter (R), ngumpet di bawah meja (C), teriak (F, cooldown 5 dtk),
  lempar barang (Q), sprint + stamina (Shift).
- 4 tugas: Generator (2 orang / 1 orang 16 dtk solo), Komputer (1 orang 10 dtk),
  Arsip (1 orang 6 dtk), Pintu Keluar (2 orang 5 dtk / 1 orang 10 dtk solo).
  Tuas Sel (1 orang 3 dtk) buat bebaskan teman yang dikurung.
- Bos AI: Patrol, Curiga, Kejar, Nyari, Balik patrol. A* pathfinding (grid 48x28).
  Vision cone 260px/70 derajat, pendengaran (suara task, teriak, lemparan).
  Teleport tiap 20-30 dtk, telegraph 1 dtk, buta 1,5 dtk sesudah teleport.
  Teleport tidak pernah mendarat dalam 150px dari pemain.
- Ketangkep: diseret ke sel di ruang bos. Co-op: teman bebaskan pakai Tuas Sel (3 dtk).
  Solo: tahan E 15 dtk buat membobol kunci (berisik), bos buta 2 dtk sesudah kabur.
  Ketangkep 3 kali di solo = game over. Keduanya dikurung di co-op = game over.
- Pintu keluar terkunci sampai 3 tugas utama selesai. Pas kebuka, bos marah:
  +0,3 kecepatan, teleport 0,6x cooldown.
- Tiap tugas selesai: satu area kantor lampunya nyala, bos +0,1 kecepatan.

### Dynamics (yang terjadi saat main)
- Pembagian peran yang bisa ganti: tukang task vs tukang mancing.
  Tukang mancing bikin ribut (teriak, lempar, senter) buat narik bos menjauh dari tukang task.
- Ketegangan teleport: bos bisa muncul di mana saja, tapi tidak pernah terlalu dekat.
  Pemain harus terus bergerak dan waspada.
- Penyelamatan: teman dikurung berarti satu pemain harus masuk sarang bos (ruang direktur)
  buat menahan tuas sel, sementara bos bisa balik kapan saja.
- Pelarian terakhir: pintu kebuka, bos marah, lari ke pintu keluar sambil diuber.

### Aesthetics (yang dirasakan pemain)
- Takut: kantor gelap, bos bisa muncul tiba-tiba, detak jantung makin cepat kalau bos dekat.
- Tegang: tugas butuh waktu lama di tempat (5-16 detik) sementara bos berkeliaran.
- Lega: tiap tugas selesai (lampu nyala, area jadi aman), dan akhirnya kabur lewat pintu keluar.
- Kerja sama (co-op): rasa saling bergantung, satu mancing, satu ngerjain tugas.

## Core loop
1. Lihat tugas yang belum selesai di HUD, jalan ke sana.
2. Tahan E buat ngerjain tugas (berisik, bos bisa dengar).
3. Bos mendekat: kabur, ngumpet, atau pancing dia menjauh.
4. Tugas selesai, area jadi terang, bos makin cepat.
5. Ulangi sampai 3 tugas utama selesai.
6. Pintu keluar kebuka, bos marah, lari ke pintu keluar.
7. Menang (kabur) atau kalah (ketangkep 3x solo / keduanya dikurung co-op).

## Spektrum mekanik
Utama: **timing** (kapan ngerjain tugas, kapan kabur, kapan mancing).
Pendamping: **tactical** (rute, posisi ngumpet, siapa mancing siapa ngerjain tugas).
Tidak dicampur ujung spektrum yang berlawanan (tidak ada speed murni atau planning berat).

## Art direction

### 3 keyword (dikunci 14 Nov 2026)
1. **Mencekam** (mood): gelap, tegang, tidak aman.
2. **Pixel Gelap Kontras** (form/style): pixel art top-down, gelap dominan,
   elemen penting terang dan kontras.
3. **Dingin + Aksen Hangat** (warna): palet dingin (biru-abu gelap) untuk kantor,
   aksen hangat (kuning senter, merah darah dan senter bos) untuk hal penting.

### Grayscale test (14 Nov 2026, LULUS)
Render area Lobby diubah ke grayscale. Hasil:
- Senter pemain (kerucut cahaya) adalah elemen paling terang, posisi pemain langsung kebaca.
- Marker tugas (lingkaran kuning) dan label "PINTU KELUAR" terbaca.
- Tata ruang kebaca dari kontras lantai (gelap) vs dinding (terang).
- Warna menambah suasana, tapi tidak dibutuhkan buat readability.
- File: `terror-lembur-gray-test.png` (warna), `terror-lembur-gray-test-gray.png` (grayscale).

### Konsistensi aset (14 Nov 2026, LULUS)
- Imersa Office (32px, meja 68x53) + Rubber Studio (bookshelf 32x48, sofa 48x32,
  whiteboard 32x32) + Gridwright (dinding 16px di-scale 2x ke 32px).
- Semua prop dalam rentang ukuran yang sebanding, tidak ada yang jomplang.
  Screenshot in-game mengonfirmasi prop terlihat koheren.
- Bos: Nasha Pale Figure (39x80, scale 1,25 = 100px, ~2x tinggi pemain).
  Bukan AI, lisensi gratis komersial, dikredit di CREDITS.md.
- Aset visual AI dilarang buat Gimersia. Mourncrest Wraith (AI-generated) tidak dipakai.

## Must / Should / Could
- **Must:** mode solo utuh (bisa tamat sendirian), 1 level playable awal-akhir,
  build WebGL/Windows jalan, halaman itch.io, video gameplay, 3 screenshot,
  deskripsi + cara bermain, deklarasi aset, surat pernyataan.
- **Should:** co-op LAN 2 PC, sprite bos Nasha Pale Figure, enrage + teleport fairness,
  self-rescue, playtest orang luar.
- **Could (potong dulu):** level 2, nerf lintas level, variasi bos, mode online.
