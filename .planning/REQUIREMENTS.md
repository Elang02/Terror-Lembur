# Requirements: Terror Lembur

**Defined:** 2026-11-14
**Core Value:** A solo curator can play the game start to finish, feel fear and tension, and reach an ending.

## v1 Requirements

Requirements for Gimersia submission. Each maps to roadmap phases.

### Solo Mode

- [ ] **SOLO-01**: One player can start the game alone (no second PC, no network) and reach an ending
- [ ] **SOLO-02**: Solo player can complete all main tasks (Generator, Computer, Archive, Exit) alone
- [ ] **SOLO-03**: Solo player can rescue themselves or the game remains fair when caught alone
- [ ] **SOLO-04**: Boss difficulty is balanced for one player (not tuned for two)

### Build & Submission

- [ ] **BUILD-01**: WebGL build exports cleanly and runs in a browser
- [ ] **BUILD-02**: itch.io page published before 19 Nov 2026 23:59 WIB
- [ ] **BUILD-03**: Gameplay video 60 seconds to 2 minutes recorded
- [ ] **BUILD-04**: Minimum 3 screenshots for submission (menu, gameplay, ending)
- [ ] **BUILD-05**: Game description + cara bermain written for submission form
- [ ] **BUILD-06**: Third-party asset declaration prepared for submission form
- [ ] **BUILD-07**: Statement of work period + theme match prepared
- [ ] **BUILD-08**: Data of 2 team representatives prepared for Bandung
- [ ] **BUILD-09**: Progress paragraph written for 19 Nov checkpoint

### Boss & Monster

- [ ] **BOSS-01**: Monster sprite chosen (non-AI, Gimersia-legal) and wired as real nodes in boss.tscn
- [ ] **BOSS-02**: Boss reads ~2x player height and is visually distinct from players
- [ ] **BOSS-03**: Boss "?" / "!" state mark visually confirmed in a screenshot
- [ ] **BOSS-04**: Boss patrol loop (8 points) visually confirmed in a playthrough
- [ ] **BOSS-05**: Boss searchlight color decided (red vs cold white)

### Design Docs

- [ ] **DESIGN-01**: Concept document (KONSEP.md) updated to Pulang theme + ghost of old boss
- [ ] **DESIGN-02**: MDA defined in design docs (Mechanics, Dynamics, Aesthetics)
- [ ] **DESIGN-03**: Core loop stated in one sentence (concept pitch)
- [ ] **DESIGN-04**: Theme Pulang felt through mechanics (tasks = requirement to go home, exit opens after tasks, failure = cannot go home)

### Art Direction

- [ ] **ART-01**: 3 art keywords agreed by team (mood, form/style, color — specific, not ambiguous)
- [ ] **ART-02**: Dark office scene readability tested in grayscale before coloring
- [ ] **ART-03**: Asset detail hierarchy checked (props quieter than players and boss)
- [ ] **ART-04**: Visual consistency checked across Imersa (32px), Rubber Studio (16px), Gridwright packs

### Scope & Team

- [ ] **SCOPE-01**: Must/Should/Could scope locked and agreed by team
- [ ] **SCOPE-02**: Roadmap for remaining days locked (checkpoint 19 Nov, submission 29 Nov)
- [ ] **SCOPE-03**: Team roles confirmed (Game Designer, Programmer Gameplay, Programmer AI & Networking, Artist, Sound Designer)
- [ ] **SCOPE-04**: Progress report written for week-2 consultation with Kris (one-pager done, progress report pending)

### Flow Fixes

- [ ] **FLOW-01**: Spawn = exit problem addressed (boss enrage / blackout when exit unlocks, or other fix)
- [ ] **FLOW-02**: Teleport fairness addressed (boss does not land too close to a player mid-task, or warning is clearer)
- [ ] **FLOW-03**: Both-locked game over addressed (slow noisy self-rescue option, or other fix)

### Quality & Testing

- [ ] **TEST-01**: Playtesting done with people outside the team
- [ ] **TEST-02**: LAN auto-detect tested on real 2-PC LAN
- [ ] **TEST-03**: ENet transport tested on real LAN (sandbox blocks UDP)
- [ ] **TEST-04**: Full playthrough (all tasks to exit to ending) verified on real PCs
- [ ] **TEST-05**: WebGL build tested on another laptop (judges use different devices)
- [ ] **TEST-06**: Performance profiled (141 props, TileMap, lights — runs smoothly on real PC)
- [ ] **TEST-07**: Boss hitbox verified smaller than visual (PvE fairness)

### Git & Collaboration

- [ ] **GIT-01**: 15 local commits pushed to fork + PR #1 updated (needs Elang's classic PAT, transient use)
- [ ] **GIT-02**: All team members use same Godot version (4.7)

### Polish

- [ ] **POLISH-01**: Hiding prompt em dash removed ("NGUMPET — gerak atau tekan C buat keluar" violates em dash ban)
- [ ] **POLISH-02**: Red light in boss room + red searchlight evaluated (too much red or fine)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Campaign

- **CAMP-01**: Level 2 / campaign (multiple office floors)
- **CAMP-02**: Bad-ending cross-level nerf (requires level 2)

## v3 Requirements — Improvement Round (mentor evaluation, 14 Nov 2026)

From Elang's request to evaluate the game against the 4 Gimersia week-1 mentor videos
(Game Design Datu Yoga, Programming Livander, Art Yaqufa, Production Kristian).
Each maps to roadmap Phases 7-10, which run BEFORE Phase 5 (submission) and Phase 6 (testing).

### Audio & Suasana (Production: audio is the unsung hero)

- [x] **AUDIO-01**: Ambient/BGM loop plays during gameplay (free license, non-AI, declared in submission)
- [x] **AUDIO-02**: Music intensity scales with boss state (calm in patrol, tense in chase)
- [x] **AUDIO-03**: Ambient does not drown procedural SFX (heartbeat, footsteps, whispers stay audible)

### Tutorial In-Game (Gimersia rule: tutorial wajib ada di dalam game)

- [x] **TUT-01**: In-game tutorial guides a first-time player step by step (not just menu text)
- [x] **TUT-02**: Tutorial covers: walk to first task, hold E to work, hide when boss is near, reach the exit
- [x] **TUT-03**: Tutorial does not block experienced players (skippable, or only on first run)

### Ketegangan Awal (Game Design: risk of losing must be felt from the start)

- [x] **TENSE-01**: First boss contact happens within ~12s of game start (faster first teleport and/or patrol start closer to first task)
- [x] **TENSE-02**: Early tension is fair (boss does not spawn-camp the first task, player still has room to learn)

### Polish Bos & FSM (Art: boss must not glide; Game Design: SEARCH should threaten hiding)

- [x] **BOSSPOL-01**: Boss has a walk animation or procedural bobbing so it does not glide (2-4 frames or bob)
- [x] **BOSSPOL-02**: Walk animation reads clearly at ~2x player height, keeps the Pale Figure silhouette
- [x] **FSM-01**: SEARCH state occasionally checks a nearby desk/hide spot (boss walks to nearest desk, pauses briefly) so hiding is not 100% safe

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Dayung Pulang as Gimersia entry | Elang chose Terror Lembur (A) on 13 Nov 2026. Dayung deprioritized. |
| AI-generated visual assets | Banned by Gimersia Section VIII. Mourncrest Wraith excluded. |
| Paid asset packs | Elang wants free only (13 Nov 2026). |
| Level 2 / campaign | Single level only for Gimersia. Too big for 15 days. Design done in Phase 40 (`.planning/LEVEL-2-DESIGN.md`, requirements LVL2-01..08, Phase 41 planned); implementation after submission 29 Nov 2026. |
| Bad-ending cross-level nerf | Needs level 2, not applicable to single level. |
| 3D realism art style | Not recommended for game jams (Art session). |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SOLO-01 | Phase 1 | Pending |
| SOLO-02 | Phase 1 | Pending |
| SOLO-03 | Phase 1 | Pending |
| SOLO-04 | Phase 1 | Pending |
| BOSS-01 | Phase 2 | Pending |
| BOSS-02 | Phase 2 | Pending |
| BOSS-03 | Phase 2 | Pending |
| BOSS-04 | Phase 2 | Pending |
| BOSS-05 | Phase 2 | Pending |
| FLOW-01 | Phase 3 | Pending |
| FLOW-02 | Phase 3 | Pending |
| FLOW-03 | Phase 3 | Pending |
| DESIGN-01 | Phase 3 | Pending |
| DESIGN-02 | Phase 3 | Pending |
| DESIGN-03 | Phase 3 | Pending |
| DESIGN-04 | Phase 3 | Pending |
| ART-01 | Phase 3 | Pending |
| ART-02 | Phase 3 | Pending |
| ART-03 | Phase 3 | Pending |
| ART-04 | Phase 3 | Pending |
| SCOPE-01 | Phase 3 | Pending |
| SCOPE-02 | Phase 3 | Pending |
| SCOPE-03 | Phase 3 | Pending |
| SCOPE-04 | Phase 3 | Pending |
| BUILD-01 | Phase 4 | Pending |
| BUILD-02 | Phase 4 | Pending |
| BUILD-09 | Phase 4 | Pending |
| BUILD-03 | Phase 5 | Pending |
| BUILD-04 | Phase 5 | Pending |
| BUILD-05 | Phase 5 | Pending |
| BUILD-06 | Phase 5 | Pending |
| BUILD-07 | Phase 5 | Pending |
| BUILD-08 | Phase 5 | Pending |
| TEST-01 | Phase 6 | Pending |
| TEST-02 | Phase 6 | Pending |
| TEST-03 | Phase 6 | Pending |
| TEST-04 | Phase 6 | Pending |
| TEST-05 | Phase 6 | Pending |
| TEST-06 | Phase 6 | Pending |
| TEST-07 | Phase 6 | Pending |
| GIT-01 | Phase 6 | Pending |
| GIT-02 | Phase 6 | Pending |
| POLISH-01 | Phase 6 | Pending |
| POLISH-02 | Phase 6 | Pending |
| AUDIO-01 | Phase 7 | Pending |
| AUDIO-02 | Phase 7 | Pending |
| AUDIO-03 | Phase 7 | Pending |
| TUT-01 | Phase 8 | Pending |
| TUT-02 | Phase 8 | Pending |
| TUT-03 | Phase 8 | Pending |
### Senter Smooth (Production grade: senter harus mulus, bukan patah-patah)

- [x] **LIGHT-01**: Senter pemain mengarah analog (diagonal) dan berputar mulus mengikuti arah gerak, tanpa lompat 90 derajat
- [x] **LIGHT-02**: Senter merah bos berputar mulus mengikuti arah gerak bos, tanpa lompat di titik waypoint
- [x] **LIGHT-03**: Toggle senter (R) fade mulus (energy lerp) bukan mati/nyala instan

### Audio Production (Production grade: pemain bisa bisukan game)

- [x] **AUD-04**: Toggle mute (M) untuk semua audio (musik + SFX), tersimpan antar sesi
- [x] **AUD-05**: Tidak ada bunyi pop/klik saat toggle mute atau ganti state musik

### Production Build (Production grade: build final terverifikasi)

- [x] **PROD-01**: Full solo playthrough jalan tanpa script error
- [x] **PROD-02**: Export Web + Windows dibangun ulang dari kode terbaru, zip itch.io terverifikasi
- [x] **PROD-03**: Video gameplay baru (60-120 detik) yang menunjukkan senter mulus

| TENSE-01 | Phase 9 | Pending |
| TENSE-02 | Phase 9 | Pending |
| BOSSPOL-01 | Phase 10 | Pending |
| BOSSPOL-02 | Phase 10 | Pending |
| FSM-01 | Phase 10 | Pending |
### Task Minigames (Elang 14 Nov 2026: tugas jangan cuma mencet tombol, benar-benar ngerjakan sesuatu)

- [x] **TASK-01**: Tiap tugas utama (Generator, Komputer, Arsip, Pintu Keluar, Tuas Sel) pakai timing skill-check: penanda bergerak, tekan E pas di zona hijau buat dapat hit
- [x] **TASK-02**: Tiap tugas terasa beda (jumlah hit, kecepatan penanda, lebar zona beda per tugas; kecepatan naik tiap hit)
- [x] **TASK-03**: Miss ada konsekuensi (bunyi berisik yang manggil bos + progress berkurang setengah hit)
- [x] **TASK-04**: Minigame kelihatan dan bisa dimainkan di multiplayer (state penanda/zona tersinkron ke semua pemain)
- [x] **TASK-05**: Tutorial, HUD, dan menu menjelaskan cara main yang baru (bukan lagi "tahan E")
- [x] **TASK-06**: Demo bot bisa menyelesaikan tugas dengan minigame (buat video), dan semua test lama tetap hijau

### Task Popups (Elang 14 Nov 2026: tugas harus kayak Excel/panel beneran, popup, interaktif — bukan bar kecil)

- [x] **POP-01**: Tiap tugas dibuka sebagai popup fullscreen (latar gelap, panel tengah): judul, instruksi, area interaktif, progress, footer Esc = batalkan (progres hilang), bos tetap bergerak selagi popup dibuka
- [x] **POP-02**: Komputer = Laporan Excel (kuis hitung cepat, 5 soal, tombol 1-3)
- [x] **POP-03**: Generator = Panel Listrik (Simon hafalan lampu, 3 ronde, tombol 1-4)
- [x] **POP-04**: Arsip = Fotokopi (timing bar SPASI, 5 lembar) + Pintu Keluar = Keypad (ketik kode 4 digit) + Tuas Sel = tarik tuas (mash SPASI)
- [x] **POP-05**: Pemain terkunci geraknya selagi popup dibuka; tugas 2 orang tetap butuh 2 pemain di dekatnya buat dibuka
- [x] **POP-06**: Demo bot bisa mainkan semua popup (buat video), dan semua test lama tetap hijau

| LIGHT-01 | Phase 11 | Pending |
| LIGHT-02 | Phase 11 | Pending |
| LIGHT-03 | Phase 11 | Pending |
| AUD-04 | Phase 12 | Pending |
| AUD-05 | Phase 12 | Pending |
| PROD-01 | Phase 13 | Pending |
| PROD-02 | Phase 13 | Pending |
| PROD-03 | Phase 13 | Pending |
### Task Popups (Elang 14 Nov 2026: tugas harus kayak Excel/panel beneran, popup, interaktif — bukan bar kecil)

- [ ] **POP-01**: Tiap tugas dibuka sebagai popup fullscreen (latar gelap, panel tengah): judul, instruksi, area interaktif, progress, footer Esc = batalkan (progres hilang), bos tetap bergerak selagi popup dibuka
- [ ] **POP-02**: Komputer = Laporan Excel (kuis hitung cepat, 5 soal, tombol 1-3)
- [ ] **POP-03**: Generator = Panel Listrik (Simon hafalan lampu, 3 ronde, tombol 1-4)
- [ ] **POP-04**: Arsip = Fotokopi (timing bar SPASI, 5 lembar) + Pintu Keluar = Keypad (ketik kode 4 digit) + Tuas Sel = tarik tuas (mash SPASI)
- [ ] **POP-05**: Pemain terkunci geraknya selagi popup dibuka; tugas 2 orang tetap butuh 2 pemain di dekatnya buat dibuka
- [ ] **POP-06**: Demo bot bisa mainkan semua popup (buat video), dan semua test lama tetap hijau

| TASK-01 | Phase 14 | Done |
| TASK-02 | Phase 14 | Done |
| TASK-03 | Phase 14 | Done |
| TASK-04 | Phase 14 | Done |
| TASK-05 | Phase 14 | Done |
| TASK-06 | Phase 14 | Done |
### Task Popups v2 — Kode dari tugas + visual kayak aplikasi beneran (Elang 14 Nov 2026: keypad didapat dari tugas satu persatu dan harus diingat; popup jangan AI slop)

- [ ] **POP2-01**: Kode pintu 4 digit didapat dari tugas: Komputer = digit 1, Arsip = digit 2, Generator = digit 3, digit 4 dari catatan di pintu pas semua tugas selesai; pemain harus ingat, keypad tidak menampilkan kodenya (kode tampil di panel TUGAS sebagai referensi)
- [ ] **POP2-02**: Excel tampil kayak spreadsheet beneran (header hijau, formula bar, grid sel dengan garis, kolom A B C, opsi di dalam sel)
- [ ] **POP2-03**: Panel Listrik tampil kayak panel beneran (lampu BULAT dengan glow, panel metal + sekrup, bukan kotak warna)
- [ ] **POP2-04**: Keypad tampil kayak keypad pintu beneran (layar LCD, tombol digit); Fotokopi kayak mesin fotokopi (kertas keluar); Tuas Sel kayak tuas beneran (gagang geser)
- [ ] **POP2-05**: Demo bot + semua test tetap hijau, video baru
- [ ] **INTRO-01**: Layar cerita pembuka (6 baris, jam 23.00, lembur, hantu bos lama) muncul pas pertama main, tombol apa saja buat lanjut, pemain terkunci selama intro, demo auto-lanjut 4 detik
- [ ] **INTRO-02**: Video direkam dari menu (menu 3 detik lalu auto-start solo di mode demo), lalu intro, tutorial, gameplay, sampai menang
- [ ] **HARD-01**: Kode pintu HANYA diingat pemain (hapus dari panel TUGAS); digit tampil 5 detik pas tugas selesai, lalu hilang; keypad tidak menampilkan kode
- [ ] **HARD-02**: Tugas lebih panjang: Excel 7 soal, Simon 4 ronde, Fotokopi 7 lembar, Tuas Sel lebih berat
- [ ] **HARD-03**: Bos solo lebih cepat (speed_mult 0.9 jadi 1.0, lebih cepat dari jalan kaki, harus sprint buat kabur) dan bisa menggagalkan tugas (popup ketutup kalau ketangkep pas lagi kerja)
- [ ] **HARD-04**: Demo bot + semua test tetap hijau, video baru yang lebih tegang
- [ ] **BOSS-01**: Bos lebih agresif: patrol 120, chase 240, search 140, teleport tiap 14-20 dtk (dulu 20-30), chase 8 dtk (dulu 6), vision 300 (dulu 260)
- [ ] **BOSS-02**: Bos bisa lihat pemain dari dekat walau gelap (150px dalam cone, tanpa senter), jadi senter mati bukan lagi invisibilitas gratis
- [ ] **BOSS-03**: Bos datang ke tugas yang lagi dikerjain (popup buka = bos dengar suara dari 700px dan menyelidiki), jadi tugas itu momen paling berbahaya
- [ ] **BOSS-04**: Teleport lebih dekat ke pemain (120px, dulu 150px)
- [ ] **BOSS-05**: Demo bot + semua test tetap hijau, video baru yang menunjukkan bos ketemu pemain
- [ ] **HIDE-01**: Ngumpet beneran di bawah meja: pemain nempel ke meja (di atas titik tengah meja, jadi meja ketutupin dia di YSort), sprite jongkok (scale y 0.6) + transparan (alpha 0.5), nama hilang, senter mati
- [ ] **HIDE-02**: Unhide balikin semua (scale, alpha, nama, senter); test_hide 10/10; regression hijau
- [ ] **BAL-01**: Bos cuma menyelidiki tugas kalau sudah dalam 350px (dulu 700px, terlalu jauh, bos datang dari seberang peta)
- [ ] **BAL-02**: Teleport pertama bos ditunda ke 15-20 dtk (dulu 8-12 dtk, pemain baru mulai tugas pertama langsung ketemu bos)
- [ ] **BAL-03**: Teks menu CARA BERMAIN sebut semua 5 tugas + mekanik kode pintu (dulu cuma 3 popup, kode tidak disebut)
- [ ] **BAL-04**: Teks ENDING PAHIT tanpa "level berikut" (cuma ada 1 level)
- [ ] **BAL-05**: Timer tidak jalan selama intro cerita (dulu intro 4 dtk ikut kehitung, tidak adil buat bintang)
- [ ] **WARN-01**: Pas buka popup tugas dan bos dalam 350px, muncul peringatan "BOS MENDENGAR SUARAMU! Dia menuju ke tugasmu!" + bunyi alarm, 3 detik; kalau bos jauh tidak ada peringatan
- [ ] **BOSS-01**: Bos bisa nangkep pemain dari arah mana pun (CATCH_DIST 30 → 40; dari atas jarak kontak 36px dulu di luar jangkauan)
- [ ] **BOSS-02**: Penglihatan bos dalam gelap 150px → 200px (pemain nggak bisa seenaknya lewat dalam gelap)
- [ ] **BOSS-03**: Bos lepas dari nyangkut di meja/tembok lebih cepat (stuck detector 2.0 dtk → 1.0 dtk + repath baru pas lepas)
- [ ] **HIDE-01**: Ngumpet bener-bener di bawah meja: collision pemain mati pas ngumpet (fisika nggak bisa dorong keluar), alpha 0.5 → 0.35
- [ ] **LOS-01**: Bos TIDAK bisa lihat nembus tembok (raycast garis pandang sudah ada, dibuktikan tes: tembok blokir, koridor terbuka kelihatan)
- [ ] **HEAR-01**: Bos bisa DENGAR pemain lewat FSM: jalan kaki kedengeran 120px, lari (sprint) kedengeran 300px; dengar → SUSPICIOUS ("?") → SEARCH; diam dan ngumpet itu sunyi (tidak kedengeran); suara nembus tembok (kayak noise queue)
- [ ] **PATROL-01**: Bos patroli di dekat pemain (pilih waypoint terdekat ke pemain, bukan keliling peta berurutan), jadi ketemu pemain beneran, bukan jalan jauh sendirian
- [ ] **VID-01**: Video rekaman berhenti sendiri 5 dtk setelah game selesai (marker DEMO_END + tools/record_demo.sh), bukan jalan terus 180 dtk pas layar akhir
- [ ] **RESCUE-01**: Bos menjaga sel: kalau bos dalam 150px dari sel pas pemain self-rescue, kabur melambat jadi 30% (tidak beku total, pemain tidak bisa terjebak selamanya); peringatan "BOS MENJAGA SEL! Kaburmu melambat, tunggu dia pergi!"
- [ ] **RESCUE-02**: Waktu self-rescue 15 dtk → 10 dtk, supaya kabur tidak kelamaan
- [ ] **POPUP-01**: Popup tugas pakai font game (Creepster judul, Special Elite isi), bukan font default Godot
- [ ] **POPUP-02**: Tiap popup nyatu sama tema horor kantor: Excel jadi terminal CRT hijau fosfor di layar hitam, Panel Listrik jadi panel tua berkarat + strip BAHAYA merah darah, Fotokopi jadi mesin tua + zona amber + kertas kuning tua, Keypad jadi keypad karatan + LCD fosfor redup, Tuas Sel jadi tuas besi berkarat; progress bar merah darah; teks instruksi pakai suara game (bukan instruksi minigame generik)
- [ ] **POPUP-03**: Layout rapih: panel ngikutin tinggi isi (CenterContainer, bukan fix 540px), tidak ada ruang kosong gede di dalam popup; jarak antar elemen konsisten 8px
- [ ] **POPUP-04**: Tidak ada teks yang keluar kotak: semua panel dalam pakai PanelContainer dengan content margin (12px kiri/kanan, 6px atas/bawah), teks strip BAHAYA dipendekin biar muat
- [ ] **POPUP-05**: Excel interaktif kayak spreadsheet beneran: tabel data 3 kolom (A,B,C) x 4 baris (2-5) + nomor baris, formula bar nunjukin rumus Excel asli (SUM, AVERAGE, MAX, MIN, kali, tambah), player hitung hasilnya dan ketik ke sel HASIL (tombol 0-9, Backspace hapus, ENTER/SPASI submit); sel HASIL ke-highlight border fosfor + kursor blok berkedip; salah = noise + input kehapus, ulang soal yang sama; 7 soal, 7 rumus beda, 1 tabel yang sama
- [ ] **POPUP-06**: Peringatan bos LANGSUNG di dalam popup tugas: label di bawah judul, update tiap frame dari jarak bos ke pemain; bos <200px = merah berkedip "BOS SUDAH SANGAT DEKAT! Esc buat kabur!", bos 200-350px = amber "Bos mendekat...", bos >=350px = sembunyi; alpha denyut tidak pernah di bawah 0.5 biar selalu terbaca; pemain yang lagi kerja jadi bisa mutusin Esc atau nekat lanjut
- [ ] **BAL-06**: Bos lebih cepat + lebih sensitif: chase 240 -> 270, patrol 120 -> 130, search 140 -> 160, vision 300 -> 340px + cone 1.2 -> 1.35 rad, dark vision 200 -> 240px, dengar jalan 120 -> 160px, dengar lari 300 -> 360px
- [ ] **BAL-07**: Sprint jadi sumber daya terbatas: drain 30 -> 50/detik (bar penuh cuma ~2 detik sprint), regen 22 -> 8/detik (isi pelan, ~12.5 detik buat penuh)
- [ ] **TASK-01**: Dua tugas utama baru di area atas peta supaya pemain explore seluruh map, bukan cuma bawah: Gudang (128,176, kiri atas) dan Rapat (700,128, atas tengah); total tugas utama jadi 5, semuanya nyambung sama cerita lembur (berkas + catatan rapat buat nyelesain laporan)
- [ ] **TASK-02**: Minigame baru beda mekanik: Gudang = Cari Berkas (grid 3x3 kotak, cari item target, tekan angka 1-9, 3 ronde, salah = noise); Rapat = Catatan Rapat (urutkan 5 tanggal dari paling lama, tekan angka 1-5, salah urutan = noise + ulang dari awal)
- [ ] **TASK-03**: Kode pintu jadi 5 digit (tiap tugas utama kasih 1 digit, catatan pintu dihapus); keypad 5 digit, menu CARA BERMAIN update (5 digit + daftar 7 tugas); demo bot rutenya nambah Gudang + Rapat (Komputer, Arsip, Generator, Gudang, Rapat, Pintu Keluar)
- [ ] **TASK-04**: Cari Berkas jadi dokumen kertas berhalaman (bukan grid kotak): kertas kuning tua + judul "BERKAS ARSIP KANTOR" + stempel merah "RAHASIA" + daftar 4 berkas per halaman; 3 halaman per ronde, 12 berkas total, target di 1 halaman acak; panah kiri-kanan ganti halaman, angka 1-4 pilih berkas; salah = noise; 3 ronde; nama berkas gaya dokumen kantor (SLIP GAJI, SURAT PEMECATAN, NOTULEN RAPAT, dst)
- [ ] **GATE-01**: Pintu keluar ala exit gate Dead by Daylight: kode benar TIDAK langsung menang; pintu terbuka 6 detik (progress tampil di bar tugas + prompt "PINTU SEDANG TERBUKA... X%", alarm + noise 400px ke bos), setelah terbuka pemain harus tekan E di pintu buat kabur (prompt "E: KABUR LEWAT PINTU KELUAR!"); ketangkep saat pintu terbuka tidak reset pintunya, tinggal kabur lagi dari sel lalu jalan ke pintu
- [ ] **HEART-01**: Terror radius ala Dead by Daylight: detak jantung makin KENCANG + makin CEPAT saat bos mendekat (volume -14 dB di 320px sampai -2 dB saat sangat dekat; interval sudah scaling 0.45-1.0 detik)
- [ ] **HAUNT-01**: Ghost event ala Phasmophobia: tiap 25-45 detik acak saat bos jauh (>350px) dan tidak di intro, muncul satu event: bisikan ("Kamu dengar bisikan di lorong...") atau benda jatuh ("Sesuatu jatuh di kejauhan..." + shake kecil); tidak pernah muncul saat bos dekat
- [ ] **SNIFF-01**: Ngumpet ala Amnesia tidak 100% aman dari patroli: bos PATROL yang lewat dalam 100px dari pemain ngumpet jadi CURIGA ke arah meja itu (lalu SEARCH + desk-check seperti biasa); ngumpet jauh dari rute patroli tetap aman
- [ ] **BOT-01**: Demo bot main kayak manusia: (a) di dalam popup, kalau bos <200px (peringatan merah) bot tutup popup (Esc, progres reset, sama kayak pemain) lalu kabur; (b) saat jalan, kalau bos CHASE dalam 250px atau jarak <100px bot kabur; di pintu keluar, bot tunggu pintu terbuka lalu tekan E buat menang
- [ ] **BOT-02**: Bot kabur yang bener (perbaikan BOT-01, v23: bot ngumpet di meja terdekat pas dikejar, padahal bos lihat dia ke sana + SNIFF-01, jadi ketangkep; cuma 1/5 tugas): saat dikejar bot LARI dulu ke waypoint patroli terjauh dari bos (sprint, 300 vs chase 270) sampai kejarannya putus (bos bukan CHASE + jarak >250px); baru ngumpet, dan cuma di meja yang jaraknya >200px dari bos; ngumpet sampai bos >350px baru lanjut rute
- [ ] **BOT-03**: Bot kabur lebih pintar (perbaikan BOT-02, v24: bot tetap ketangkep 3x di 1:02 in-game, 1/5 tugas; kejarannya nggak putus karena bot lari lurus di koridor dan bos tetap lihat dia): (a) titik kabur = waypoint patroli terjauh dari bos yang TIDAK kelihatan bos (cek raycast LOS), jadi lari ke balik tembok dan kejaran putus; (b) bot tidak buka popup tugas kalau bos dalam 350px — mundur dulu, tunggu bos pergi, baru kerjakan
- [ ] **BAL-08**: Kejar bos 270 -> 240 (aturan DbD: killer cuma ~15% lebih cepat dari survivor lari; 240 = 20% lebih cepat dari jalan 200, 20% lebih lambat dari sprint 300; kejaran diputusin LOS, bukan kecepatan mentah; enrage akhir game 240 x 1.6 = 384, tetap lebih cepat dari sprint)
- [ ] **LOS-02**: Kejaran putus karena LOS hilang -> peringatan "Dia kehilangan jejakmu!" (teks + tick pelan), biar pemain belajar aturan mainnya: putus pandangan = selamat
- [ ] **MUG-02**: Prompt lempar barang diajarin jadi alat mancing: "Q: lempar barang (mancing bos)" — mug yang dilempar udah bikin noise 300px dan bos datang ke titik jatuhnya, tinggal diajarin ke pemain
- [ ] **PACE-01**: Teleport pertama 15-20 detik -> 25-35 detik (bedah kode: teleport pertama bisa jatuhin bos 120px dari pemain pas dia lagi ngerjain Excel 7 soal; patroli yang kelihatan tetap kasih tegang, teleport kejutan datang belakangan)
- [ ] **CELL-01**: Habis kabur dari sel, bos buta 3 -> 5 detik + patroli MENJAUH dari pemain 10 detik (dulu patroli terdekat-ke-pemain bikin bos balik ke sel; ini yang bikin spiral mati di v23/v24/v25)
- [ ] **OPEN-01**: Patroli pertama bos dari ujung jauh (index 2 = (1328,272)), bukan (272,448) yang 137px dari Komputer (bedah kode gap #1: tugas pertama praktis mustahil dibuka tanpa diganggu)
- [ ] **CHASE-01**: Kejaran punya wind-up 1 detik — bos diam dulu pas "!" + alarm bunyi, pemain dapat ancang-ancang buat putus pandangan (bedah kode gap #2: kejaran dari jarak <200px hampir mustahil menang di koridor terbuka; _update_stuck juga dijaga biar nggak loncat pas wind-up)
- [ ] **SHOUT-01**: Di solo, hint teriak jujur soal harganya: "F: teriak (bos datang ke kamu!)" (bedah kode gap #5: teriak manggil bos ke posisi pemain sendiri — di solo itu jebakan buat pemain baru)
- [ ] **TELE-02**: Teleport tidak masuk ruangan pemain yang lagi ngumpet (konsep §6: "nggak bisa teleport ke ruangan yang sama persis dengan pemain yang lagi ngumpet di bawah meja") — destination di ruangan yang sama dengan pemain ngumpet ditolak, coba lagi (max 8x, fallback ruang bos)
- [ ] **PRESS-01**: Meter TEKANAN di HUD (panel status kanan atas): eskalasi bos kelihatan — speed_mult 1.0-1.8 dipetakan ke 0-100%, warna hijau-kuning-merah; pemain tahu bos makin agresif tiap tugas selesai (riset Phasmophobia: pressure dial yang kelihatan)
- [ ] **CODE-01**: Digit kode tidak pernah hilang karena tertimpa pesan lain — label kode TERPISAH dari label warning, tampil 10 detik lalu hilang sendiri (memory-only tetap: tidak ada cara cek ulang, tidak tampil kode lengkap). Bug yang diperbaiki: digit ke-5 selalu tertimpa pesan enrage "BOS MARAH!" di frame yang sama
- [ ] **FEED-01**: E di tugas yang belum siap memberi alasan 2 detik ("Selesaikan semua tugas dulu!" / "Butuh 2 orang!" / "Tidak ada yang dikurung!"), bukan diam total
- [ ] **FEED-02**: Tutorial langkah 2 terima popup tugas apa pun (bukan cuma Komputer); langkah 4 selesai saat tugas pertama selesai (bukan semua tugas)
- [ ] **FEED-03**: Prompt jujur soal sprint yang berisik ("SHIFT: lari (berisik!)") + CARA BERMAIN menyebut lari itu berisik
- [ ] **FEED-04**: Pesan teleport jujur soal jarak ("Bos muncul di dekatmu!" kalau <200px, "Bos muncul di kejauhan..." kalau jauh)
- [ ] **FEED-05**: Intro cuma ditutup tombol E/klik, bukan WASD (pemain yang langsung jalan tidak lagi melewatkan cerita tanpa sadar)
- [ ] **PAUSE-01**: P jeda di solo — bos, timer, musik, dan popup ikut berhenti; panel "JEDA — P lanjut | R ulang dari awal"; co-op tidak bisa jeda (butuh kesepakatan host)
- [ ] **MUG-01**: Mug lempar muncul lagi 60 detik setelah diambil, di titik acak dari 6 titik awal (Q tidak jadi tombol mati di akhir game)
- [ ] **LVL2-01**: Cerita lantai 2: pintu keluar lantai 1 menuju tangga; pintu utama gedung dikunci hantu; jalan keluar lewat lantai 2 (ruang direksi lama). Tema Pulang tetap.
- [ ] **LVL2-02**: 5 tugas lantai 2 (Server Utama/Simon 5 ronde, Komputer Direksi/Excel 8 soal, Arsip Lama/Fotokopi 8 lembar, Cari Berkas Lama/4 halaman 4 ronde, Urut Catatan Lama/6 tanggal) + Pintu Keluar keypad 5 digit + Tuas Sel
- [ ] **LVL2-03**: Peta lantai 2: grid 48x28, 15 ruangan susunan beda, ruang bos di ujung (direksi lama), sel di ruang bos, pintu keluar di lobby tangga
- [ ] **LVL2-04**: Eskalasi bos lantai 2: chase 255, patrol 140, teleport 12-18 dtk (pertama 20-30 dtk), vision 350, hearing 180/380
- [ ] **LVL2-05**: Nerf antar level (konsep §8): Bad Ending lantai 1 → gerak -20%, senter redup, tugas +25% langkah; Happy Ending → tanpa nerf; max 2x
- [ ] **LVL2-06**: Bintang per level (3 = tidak ketangkep, 2 = 1x, 1 = 2x/pahit) + layar akhir tawarkan lanjut ke lantai berikut
- [ ] **LVL2-07**: Data level jadi data (LEVEL_CONFIGS): TASK_DEFS, PATROL_LOOP, ruangan, CELL_POS, BOSS_ROOM, hide spot, stat bos per level — level 2 = config + peta baru, bukan copy level_1.gd
- [ ] **LVL2-08**: Menu pilih lantai (lantai 2 terbuka setelah lantai 1 tamat); solo + LAN tetap jalan di lantai 2

| POP-01 | Phase 15 | Done |
| POP-02 | Phase 15 | Done |
| POP-03 | Phase 15 | Done |
| POP-04 | Phase 15 | Done |
| POP-05 | Phase 15 | Done |
| POP-06 | Phase 15 | Done |
| POP2-01 | Phase 16 | Done |
| POP2-02 | Phase 16 | Done |
| POP2-03 | Phase 16 | Done |
| POP2-04 | Phase 16 | Done |
| POP2-05 | Phase 16 | Done |
| INTRO-01 | Phase 17 | Done |
| INTRO-02 | Phase 17 | Done |
| HARD-01 | Phase 18 | Done |
| HARD-02 | Phase 18 | Done |
| HARD-03 | Phase 18 | Done |
| HARD-04 | Phase 18 | Done |
| BOSS-01 | Phase 19 | Done |
| BOSS-02 | Phase 19 | Done |
| BOSS-03 | Phase 19 | Done |
| BOSS-04 | Phase 19 | Done |
| BOSS-05 | Phase 19 | Done |
| HIDE-01 | Phase 20 | Done |
| HIDE-02 | Phase 20 | Done |
| BAL-01 | Phase 21 | Done |
| BAL-02 | Phase 21 | Done |
| BAL-03 | Phase 21 | Done |
| BAL-04 | Phase 21 | Done |
| BAL-05 | Phase 21 | Done |
| WARN-01 | Phase 22 | Done |
| BOSS-01 | Phase 23 | Done |
| BOSS-02 | Phase 23 | Done |
| BOSS-03 | Phase 23 | Done |
| HIDE-01 | Phase 23 | Done |
| LOS-01 | Phase 24 | Done |
| HEAR-01 | Phase 24 | Done |
| PATROL-01 | Phase 25 | Done |
| VID-01 | Phase 25 | Done |
| RESCUE-01 | Phase 26 | Done |
| RESCUE-02 | Phase 26 | Done |
| POPUP-01 | Phase 27 | Done |
| POPUP-02 | Phase 27 | Done |
| POPUP-03 | Phase 27 | Done |
| POPUP-04 | Phase 27 | Done |
| POPUP-05 | Phase 28 | Done |
| BAL-06 | Phase 29 | Done |
| BAL-07 | Phase 29 | Done |
| POPUP-06 | Phase 30 | Done |
| TASK-01 | Phase 31 | Done |
| TASK-02 | Phase 31 | Done |
| TASK-03 | Phase 31 | Done |
| TASK-04 | Phase 32 | Done |
| GATE-01 | Phase 33 | Done |
| HEART-01 | Phase 33 | Done |
| HAUNT-01 | Phase 33 | Done |
| SNIFF-01 | Phase 33 | Done |
| BOT-01 | Phase 33 | Done |
| BOT-02 | Phase 34 | Done |
| BOT-03 | Phase 35 | Done |
| BAL-08 | Phase 36 | Done |
| LOS-02 | Phase 36 | Done |
| MUG-02 | Phase 36 | Done |
| PACE-01 | Phase 37 | Done |
| CELL-01 | Phase 37 | Done |
| OPEN-01 | Phase 38 | Done |
| CHASE-01 | Phase 38 | Done |
| SHOUT-01 | Phase 38 | Done |
| TELE-02 | Phase 39 | Done |
| PRESS-01 | Phase 42 | Done |
| CODE-01 | Phase 43 | Done |
| FEED-01 | Phase 44 | Done |
| FEED-02 | Phase 44 | Done |
| FEED-03 | Phase 44 | Done |
| FEED-04 | Phase 44 | Done |
| FEED-05 | Phase 44 | Done |
| PAUSE-01 | Phase 45 | Done |
| MUG-01 | Phase 45 | Done |
| LVL2-01 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-02 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-03 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-04 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-05 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-06 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-07 | Phase 41 | Planned (design done in Phase 40) |
| LVL2-08 | Phase 41 | Planned (design done in Phase 40) |

**Coverage:**
- v1 requirements: 46 total
- v3 requirements: 11 total
- v4 requirements: 8 total
- v5 requirements: 6 total
- v6 requirements: 6 total
- v7 requirements: 5 total
- v8 requirements: 2 total
- v9 requirements: 4 total
- v10 requirements: 5 total
- v11 requirements: 2 total
- v12 requirements: 5 total
- v13 requirements: 4 total
- v14 requirements: 2 total
- v15 requirements: 2 total
- v16 requirements: 2 total
- v17 requirements: 2 total
- v18 requirements: 1 total
- v19 requirements: 1 total
- v20 requirements: 2 total
- v21 requirements: 5 total
- v22 requirements: 1 total
- v23 requirements: 1 total
- v24 requirements: 3 total
- Mapped to phases: 155
- Unmapped: 0 ✓

---
*Requirements defined: 2026-11-14*
*Last updated: 2026-11-14 after initial definition*
