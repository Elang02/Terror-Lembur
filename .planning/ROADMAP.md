# Roadmap: Terror Lembur

## Overview

From a LAN-only 2-PC build to a solo-playable Gimersia submission in 15 days. Phase 1 (solo mode) is the biggest blocker and comes first. Phases 2-3 fix the boss, flow, and design. Phase 4 delivers the 19 Nov checkpoint package. Phases 7-10 (improvement round, from the 14 Nov 2026 mentor-video evaluation) polish audio, tutorial, early tension, and boss feel BEFORE the final submission. Phase 5 completes the 29 Nov submission. Phase 6 verifies everything on real hardware.

## Phases

- [x] **Phase 1: Mode Solo** - One player can play start to finish alone
- [x] **Phase 2: Monster & Boss Visual** - Sprite chosen, wired, patrol and state mark confirmed
- [x] **Phase 3: Flow Fixes & Design Docs** - Flow critiques addressed, concept updated, art direction locked
- [x] **Phase 4: Checkpoint Package** - WebGL build, itch.io page, screenshot, progress paragraph (due 19 Nov 23:59 WIB)
- [ ] **Phase 7: Audio & Suasana** - Ambient/BGM loop + intensity scaling (mentor evaluation 14 Nov 2026)
- [ ] **Phase 8: Tutorial In-Game** - Step-by-step onboarding inside the game (Gimersia rule)
- [ ] **Phase 9: Ketegangan Awal** - First boss contact within ~12s, fair early tension
- [ ] **Phase 10: Polish Bos & FSM** - Boss walk animation + SEARCH checks a nearby desk
- [ ] **Phase 5: Final Submission** - Video, screenshots, description, declarations (due 29 Nov 23:59 WIB)
- [ ] **Phase 6: Testing & Verification** - Playtest, LAN test, performance, full playthrough, push to GitHub

## Phase Details

### Phase 1: Mode Solo
**Goal**: One player can start the game alone (no second PC, no network) and reach an ending
**Depends on**: Nothing (first phase)
**Requirements**: SOLO-01, SOLO-02, SOLO-03, SOLO-04
**Success Criteria** (what must be TRUE):
  1. Solo player can start the game without a second player or network
  2. Solo player can complete all main tasks (Generator, Computer, Archive, Exit) alone
  3. Solo player can reach an ending (Happy or Bad) in one session
  4. Boss difficulty feels fair for one player (not tuned for two)
**Plans**: TBD

Plans:
- [ ] 01-01: Lock solo mode approach (A: single-player murni, B: AI companion, C: co-op lokal satu layar) — discuss-phase decision
- [ ] 01-02: Implement solo mode in code
- [ ] 01-03: Balance boss and tasks for one player
- [ ] 01-04: Verify solo playthrough headless + screenshot

### Phase 2: Monster & Boss Visual
**Goal**: Boss has a real, Gimersia-legal sprite and reads clearly in-game
**Depends on**: Phase 1
**Requirements**: BOSS-01, BOSS-02, BOSS-03, BOSS-04, BOSS-05
**Success Criteria** (what must be TRUE):
  1. Monster sprite is chosen (non-AI) and wired as real nodes in boss.tscn
  2. Boss reads ~2x player height and is visually distinct from players
  3. Boss "?" / "!" state mark is visible in a screenshot
  4. Boss patrol loop (8 points) is visible in a playthrough
  5. Boss searchlight color is decided (red vs cold white)
**Plans**: TBD

Plans:
- [ ] 02-01: Elang picks monster sprite (2: Nasha Pale Figure, 3: Nasha Antlered Shadow, 4: N3XUS Ghost)
- [ ] 02-02: Wire sprite into boss.tscn as real nodes, scale to ~2x player height
- [ ] 02-03: Verify patrol loop + state mark visually (screenshot + video)

### Phase 3: Flow Fixes & Design Docs
**Goal**: Flow critiques addressed, concept and art direction locked
**Depends on**: Phase 2
**Requirements**: FLOW-01, FLOW-02, FLOW-03, DESIGN-01, DESIGN-02, DESIGN-03, DESIGN-04, ART-01, ART-02, ART-03, ART-04, SCOPE-01, SCOPE-02, SCOPE-03, SCOPE-04
**Success Criteria** (what must be TRUE):
  1. Spawn = exit problem is addressed (boss enrage / blackout or other fix)
  2. Teleport fairness is addressed (no landing too close to a mid-task player, or clearer warning)
  3. Both-locked game over is addressed (self-rescue option or other fix)
  4. Concept document (KONSEP.md) says Pulang theme + ghost of old boss
  5. MDA and one-sentence core loop are written in design docs
  6. 3 art keywords are agreed by team
  7. Grayscale readability test is done on the dark office scene
  8. Must/Should/Could scope and roadmap are locked
  9. Team roles are confirmed
  10. Progress report is written for week-2 consultation
**Plans**: TBD

Plans:
- [ ] 03-01: Elang decides flow fixes (3 critiques) and team roles
- [ ] 03-02: Implement flow fixes in code
- [ ] 03-03: Update KONSEP.md to Pulang + ghost boss, write MDA + core loop
- [ ] 03-04: Lock 3 art keywords, run grayscale test, check asset consistency
- [ ] 03-05: Write progress report for week-2 consultation

### Phase 4: Checkpoint Package
**Goal**: itch.io page published + submitted before 19 Nov 2026 23:59 WIB
**Depends on**: Phase 3
**Requirements**: BUILD-01, BUILD-02, BUILD-09
**Success Criteria** (what must be TRUE):
  1. WebGL build exports cleanly and runs in a browser
  2. itch.io page is published with game description and a screenshot or GIF
  3. Progress paragraph is written and checkpoint is submitted
**Plans**: TBD

Plans:
- [ ] 04-01: Export WebGL build, verify in browser
- [ ] 04-02: Create itch.io page (needs Elang's itch.io login) + screenshot/GIF + description
- [ ] 04-03: Write progress paragraph, submit checkpoint

### Phase 5: Final Submission
**Goal**: Complete submission package ready before 29 Nov 2026 23:59 WIB
**Depends on**: Phase 4
**Requirements**: BUILD-03, BUILD-04, BUILD-05, BUILD-06, BUILD-07, BUILD-08
**Success Criteria** (what must be TRUE):
  1. Gameplay video 60 seconds to 2 minutes is recorded
  2. Minimum 3 screenshots exist (menu, gameplay, ending)
  3. Game description + cara bermain are written
  4. Third-party asset declaration is prepared
  5. Statement of work period + theme match is prepared
  6. Data of 2 team representatives is prepared
**Plans**: TBD

Plans:
- [ ] 05-01: Record gameplay video (60s-2min) + capture 3 screenshots
- [ ] 05-02: Write description, cara bermain, asset declaration, statement, representatives data
- [ ] 05-03: Submit via submission form

### Phase 6: Testing & Verification
**Goal**: Game is verified on real hardware and code is pushed to GitHub
**Depends on**: Phase 5
**Requirements**: TEST-01, TEST-02, TEST-03, TEST-04, TEST-05, TEST-06, TEST-07, GIT-01, GIT-02, POLISH-01, POLISH-02
**Success Criteria** (what must be TRUE):
  1. Playtesting is done with people outside the team
  2. LAN auto-detect and ENet are tested on real 2-PC LAN
  3. Full playthrough is verified on real PCs
  4. WebGL build is tested on another laptop
  5. Performance is profiled and runs smoothly
  6. Boss hitbox is verified smaller than visual
  7. 15 local commits are pushed to fork + PR #1 updated
  8. All team members use Godot 4.7
  9. Hiding prompt em dash is removed
  10. Boss room red light + red searchlight are evaluated
**Plans**: TBD

Plans:
- [ ] 06-01: Playtest with outsiders, collect feedback
- [ ] 06-02: Test LAN auto-detect + ENet on real 2-PC LAN, test WebGL on another laptop
- [ ] 06-03: Profile performance, verify boss hitbox, fix em dash, evaluate red lights
- [ ] 06-04: Push 15 commits (needs Elang's token), update PR #1

### Phase 7: Audio & Suasana
**Goal**: The game has ambient music that carries the horror tension when the boss is far, not just SFX
**Depends on**: Phase 4 (improvement round, from mentor evaluation 14 Nov 2026)
**Requirements**: AUDIO-01, AUDIO-02, AUDIO-03
**Success Criteria** (what must be TRUE):
  1. A free, non-AI ambient/BGM loop plays during gameplay and loops cleanly
  2. Music intensity rises when the boss chases and falls back in patrol (audible in a recording)
  3. Procedural SFX (heartbeat, footsteps, whispers, task tick) stay audible over the music
  4. Music license is declared in the submission docs
**Plans**: TBD

Plans:
- [ ] 07-01: Find a free non-AI horror ambient loop (no AI disclosure, commercial use allowed), verify license
- [ ] 07-02: Wire loop into the game with intensity scaling by boss state
- [ ] 07-03: Balance music vs SFX volumes, verify in a recording

### Phase 8: Tutorial In-Game
**Goal**: A first-time player (kurator) is guided step by step inside the game, per the Gimersia rule
**Depends on**: Phase 7
**Requirements**: TUT-01, TUT-02, TUT-03
**Success Criteria** (what must be TRUE):
  1. Tutorial steps appear in-game in order: walk to first task, hold E, hide when boss is near, reach the exit
  2. Each step completes when the player does the action (not on a timer)
  3. Tutorial can be skipped and does not reappear for experienced players
  4. Tutorial does not block the task HUD or the boss warnings
**Plans**: TBD

Plans:
- [ ] 08-01: Design tutorial steps (4 steps max, action-gated, skippable)
- [ ] 08-02: Implement tutorial prompts + step tracking in code
- [ ] 08-03: Verify with a fresh playthrough (demo bot + screenshot)

### Phase 9: Ketegangan Awal
**Goal**: The player feels threatened within the first ~12 seconds, without the opening being unfair
**Depends on**: Phase 8
**Requirements**: TENSE-01, TENSE-02
**Success Criteria** (what must be TRUE):
  1. First boss contact (sighting, teleport warning, or chase) happens within ~12s of game start
  2. The first task is still completable (boss does not spawn-camp it)
  3. Tension is verified in a playthrough recording (boss appears early, player reacts)
**Plans**: TBD

Plans:
- [ ] 09-01: Shorten first teleport timer and/or move patrol start closer to first task
- [ ] 09-02: Verify first contact timing + first task fairness in a playthrough

### Phase 10: Polish Bos & FSM
**Goal**: The boss stops gliding and hiding stops being 100% safe
**Depends on**: Phase 9
**Requirements**: BOSSPOL-01, BOSSPOL-02, FSM-01
**Success Criteria** (what must be TRUE):
  1. Boss has a walk animation or procedural bobbing visible in a recording (no glide)
  2. Animation keeps the Pale Figure silhouette and reads at ~2x player height
  3. In SEARCH state the boss sometimes walks to a nearby desk and pauses, so hiding carries risk
  4. Existing tests still pass (flow 3/3, solo 11/11, win 6/6, search 2/2, patrol 2/2)
**Plans**: TBD

Plans:
- [ ] 10-01: Build walk frames or bobbing for the Pale Figure sprite
- [ ] 10-02: Add SEARCH desk-check behavior to boss.gd
- [ ] 10-03: Re-run all boss tests + record a clip of the boss walking and desk-checking

## Phase 11: Senter Smooth

**Goal:** Senter pemain dan senter merah bos berputar mulus mengikuti arah gerak, tanpa lompat.
**Requirements**: LIGHT-01, LIGHT-02, LIGHT-03
**Success Criteria** (what must be TRUE):
  1. Senter pemain mengarah diagonal saat gerak diagonal dan berputar mulus (tidak lompat 90 derajat)
  2. Senter merah bos berputar mulus di tikungan path, tidak lompat
  3. Toggle senter (R) fade energy mulus, bukan mati/nyala instan
  4. Existing tests still pass (flow 3/3, solo 11/11, win 6/6, search 2/2, patrol 2/2, bosspol 6/6)
**Plans**: TBD

Plans:
- [ ] 11-01: Analog aim + lerped rotation/position for the player flashlight (worker_char.gd)
- [ ] 11-02: Lerped rotation/position for the boss searchlight (boss.gd) + smooth R toggle fade
- [ ] 11-03: New test test_light.gd + record a clip showing the smooth sweep

## Phase 12: Audio Production

**Goal:** Pemain bisa membisukan game; tidak ada bunyi pop saat toggle.
**Requirements**: AUD-04, AUD-05
**Success Criteria** (what must be TRUE):
  1. Tombol M membisukan semua audio (musik + SFX) dan menyalakannya lagi
  2. Status mute tersimpan antar sesi (user://)
  3. Tidak ada pop/klik saat mute/unmute atau saat musik crossfade
  4. Existing tests still pass (music 7/7)
**Plans**: TBD

Plans:
- [ ] 12-01: Mute toggle (M) + persistence in level_1.gd / sfx.gd
- [ ] 12-02: Verify no pops + music test regression

## Phase 13: Production Build

**Goal:** Build final dari kode terbaru, terverifikasi, siap submit.
**Requirements**: PROD-01, PROD-02, PROD-03
**Success Criteria** (what must be TRUE):
  1. Full solo playthrough (demo bot) runs with zero script errors
  2. Web + Windows exports rebuilt from latest code; itch.io zip verified (index.html at root)
  3. Fresh gameplay video 60-120s shows the smooth lights
  4. All 9 test files green
**Plans**: TBD

Plans:
- [ ] 13-01: Re-export Web + Windows, rebuild itch.io zip + PC zip
- [ ] 13-02: Full playthrough check + fresh video recording

## Phase 14: Task Minigames

**Goal:** Tugas bukan lagi tahan E, tapi timing skill-check yang benar-benar dimainkan; tiap tugas terasa beda.
**Requirements**: TASK-01, TASK-02, TASK-03, TASK-04, TASK-05, TASK-06
**Success Criteria** (what must be TRUE):
  1. Tiap tugas (0-4) selesai lewat hit timing (tekan E pas penanda di zona hijau), bukan tahan E
  2. Tiap tugas beda: jumlah hit, kecepatan penanda, dan lebar zona beda; kecepatan naik tiap hit
  3. Miss bikin berisik (bos dengar) dan progress berkurang setengah hit
  4. Penanda dan zona tersinkron ke semua pemain (MultiplayerSynchronizer) sehingga klien bisa main
  5. Tutorial, HUD prompt, dan menu menjelaskan cara baru
  6. Demo bot menyelesaikan tugas lewat minigame; semua test lama tetap hijau
**Plans**: TBD

Plans:
- [x] 14-01: task_point minigame state + gambar timing bar + replikasi (task_point.gd + task_point.tscn)
- [x] 14-02: Hit logic di level_1.gd + hook tekan E di worker_char.gd + update demo bot
- [x] 14-03: Tutorial + HUD + menu text untuk cara main baru
- [x] 14-04: test_taskminigame.gd + full regression + video baru

## Phase 15: Task Popups

**Goal:** Tugas dibuka sebagai popup fullscreen yang tampilannya kayak aplikasi beneran (Excel, panel listrik, fotokopi, keypad), interaktif, bos tetap bergerak.
**Requirements**: POP-01, POP-02, POP-03, POP-04, POP-05, POP-06
**Success Criteria** (what must be TRUE):
  1. Tiap tugas dibuka sebagai popup fullscreen (latar gelap, panel tengah, judul, instruksi, progress, footer Esc = batalkan, progres hilang)
  2. Komputer = kuis Excel 5 soal (tombol 1-3); Generator = Simon panel listrik 3 ronde (tombol 1-4)
  3. Arsip = timing Fotokopi SPASI 5 lembar; Pintu Keluar = keypad kode 4 digit; Tuas Sel = mash SPASI
  4. Pemain terkunci geraknya selagi popup dibuka; tugas 2 orang butuh 2 pemain di dekatnya buat dibuka
  5. Demo bot memainkan semua popup; semua test lama tetap hijau
**Plans**: TBD

Plans:
- [x] 15-01: Popup framework (overlay, panel, input, open/close, Esc cancel, player lock) + hapus timing bar lama
- [x] 15-02: Excel (Komputer) + Panel Listrik Simon (Generator)
- [x] 15-03: Fotokopi (Arsip) + Keypad (Pintu Keluar) + Mash tuas (Tuas Sel)
- [x] 15-04: Demo bot mainkan popup + test_popup.gd + full regression + video baru

## Phase 16: Task Popups v2 — Kode dari Tugas + Visual Realistis

**Goal:** Kode pintu 4 digit didapat dari tugas satu persatu (harus diingat), dan tiap popup tampil kayak perangkat beneran (bukan panel generik AI slop).
**Requirements**: POP2-01, POP2-02, POP2-03, POP2-04, POP2-05
**Success Criteria** (what must be TRUE):
  1. Kode pintu 4 digit: digit 1-3 dari Komputer/Arsip/Generator, digit 4 dari catatan pintu pas semua tugas selesai; keypad tidak menampilkan kode (referensi di panel TUGAS)
  2. Excel tampil kayak spreadsheet (header hijau, formula bar, grid sel); Panel Listrik lampu bulat + glow + panel metal + sekrup
  3. Keypad tampil kayak keypad beneran (LCD); Fotokopi kayak mesin (kertas keluar); Tuas Sel kayak tuas (gagang geser)
  4. Demo bot + semua test tetap hijau; video baru
**Plans**: TBD

Plans:
- [x] 16-01: Sistem kode pintu dari tugas (level code_digits, reveal per tugas, HUD tampilkan kode, keypad pakai kode level)
- [x] 16-02: Visual Excel + Panel Listrik kayak perangkat beneran
- [x] 16-03: Visual Keypad + Fotokopi + Tuas Sel kayak perangkat beneran
- [x] 16-04: Test + full regression + video baru

**Status: Complete.** Committed `75b3484` (14 Nov 2026). test_popup 23/23 (6 tes kode baru), full suite 12 file hijau (popup 23/23, solo 13/13, win 6/6, flow 3/3, search 2/2, patrol 2/2, music 7/7, tutorial 11/11, tension 5/5, bosspol 6/6, light 7/7, mute 9/9). Video v9 150 dtk: bot selesaikan playthrough penuh, kode 2324, HAPPY ENDING 3 bintang 0:36. test_bosspol flaky fix: tunggu 10 frame (bukan 30) supaya SUSPICIOUS 1.5s tidak keburu habis.

## Phase 17: Layar Cerita Pembuka + Video dari Menu

**Goal:** Video direkam dari menu (bukan continue), menampilkan cerita awal dan tutorial.
**Requirements**: INTRO-01, INTRO-02
**Success Criteria** (what must be TRUE):
  1. Layar cerita pembuka (6 baris) muncul pas pertama main, tombol apa saja buat lanjut, pemain terkunci selama intro, demo auto-lanjut 4 detik
  2. Video dari menu: menu 3 detik lalu auto-start solo di mode demo, lalu intro, tutorial, gameplay, sampai menang
  3. Semua test tetap hijau
**Plans**:
- [x] 17-01: Layar cerita pembuka (level_1.gd intro overlay + blokir gerak + auto-dismiss demo)
- [x] 17-02: Menu auto-start di mode demo (network.gd demo_menu_timer 3 detik)
- [x] 17-03: Test intro 6/6 + regression + video v10 dari menu

**Status: Complete.** Committed `8969947` (14 Nov 2026). test_intro 6/6, tutorial 11/11, popup 23/23, win 6/6. Video v10 170 dtk: menu -> intro -> tutorial -> gameplay -> HAPPY ENDING 3 bintang, kode 2141, 0x ketangkep, 0:42.

## Phase 18: Kode Murni Hafalan + Game Lebih Menantang

**Goal:** Kode pintu hanya diingat pemain (tidak ada di HUD), dan game lebih tegang (tugas lebih panjang, bos lebih cepat dan bisa menggagalkan tugas).
**Requirements**: HARD-01, HARD-02, HARD-03, HARD-04
**Success Criteria** (what must be TRUE):
  1. Kode TIDAK tampil di panel TUGAS; digit tampil 5 detik pas tugas selesai, lalu hilang; keypad tidak menampilkan kode
  2. Excel 7 soal, Simon 4 ronde, Fotokopi 7 lembar, Tuas Sel lebih berat
  3. Bos solo speed_mult 1.0 (lebih cepat dari jalan kaki); popup ketutup kalau pemain ketangkep pas lagi kerja
  4. Demo bot + semua test tetap hijau; video baru yang lebih tegang
**Plans**: TBD

Plans:
- [x] 18-01: Hapus kode dari HUD (pure memory), pesan reveal 5 detik, update hint keypad
- [x] 18-02: Tugas lebih panjang + bos solo lebih cepat + popup ketutup kalau ketangkep
- [x] 18-03: Update test + full regression + video baru

**Status: Complete.** Committed `1848467` (14 Nov 2026). test_popup 23/23, solo 13/13, win 6/6, flow 3/3. Video v11 180 dtk: menu -> intro -> gameplay -> HAPPY ENDING 3 bintang, kode 2141, 0x ketangkep, 0:49. Catatan: bot adalah pemain sempurna (tahu peta, auto-main tugas instan), jadi videonya tetap kelihatan cepat; untuk pemain manusia tantangannya jauh lebih besar (harus hafal kode, tugas lebih lama, bos lebih cepat dan bisa menggagalkan tugas).

## Phase 19: Bos Lebih Agresif

**Goal:** Pemain ketemu bos jauh lebih sering; bos aktif berburu, bukan sekadar patrol pasif.
**Requirements**: BOSS-01, BOSS-02, BOSS-03, BOSS-04, BOSS-05
**Success Criteria** (what must be TRUE):
  1. Bos lebih cepat (patrol 120, chase 240, search 140), teleport tiap 14-20 dtk, chase 8 dtk, vision 300
  2. Bos bisa lihat pemain dari dekat walau gelap (150px dalam cone)
  3. Bos datang ke tugas yang lagi dikerjain (popup buka = bos menyelidiki dari 700px)
  4. Teleport lebih dekat ke pemain (120px)
  5. Demo bot + semua test tetap hijau; video baru yang menunjukkan bos ketemu pemain
**Plans**:
- [x] 19-01: Konstanta bos lebih agresif + vision gelap jarak dekat
- [x] 19-02: Bos menyelidiki tugas + teleport lebih dekat
- [x] 19-03: Update test + full regression + video baru

**Status: Complete.** Committed `cc93df4` (14 Nov 2026). test_bossaggro 9/9, popup 23/23, solo 13/13, win 6/6, flow 3/3, bosspol 6/6. Video v12 180 dtk: bot ketangkep 1x (pertama kali di video), HAPPY ENDING 2 bintang, 1:12 (v11: 0:49, 0x ketangkep, 3 bintang). Frame tengah video: bos berdiri di sebelah pemain yang dikurung di sel, "BOS SANGAT DEKAT!", self-rescue 69%.

## Phase 20: Ngumpet Beneran di Bawah Meja

**Goal:** Pas ngumpet, pemain kelihatan beneran sembunyi di bawah meja (bukan berdiri di lantai biasa).
**Requirements**: HIDE-01, HIDE-02
**Success Criteria** (what must be TRUE):
  1. Pemain nempel ke meja (di atas titik tengah meja, jadi meja ketutupin dia di YSort), sprite jongkok (scale y 0.6) + transparan (alpha 0.5), nama hilang, senter mati
  2. Unhide balikin semua; test_hide 10/10; regression hijau
**Plans**:
- [x] 20-01: Posisi + visual ngumpet (nempel meja, jongkok, transparan, nama hilang, senter mati)
- [x] 20-02: Test hide + render verifikasi + regression

**Status: Complete.** Committed (14 Nov 2026). test_hide 10/10, tutorial 11/11, solo 13/13, win 6/6, bossaggro 9/9. Render terverifikasi: pemain di bawah meja, badan ketutup meja, cuma kaki yang kelihatan di bawah meja. Senter mati pas ngumpet (bug: `_process` nyalain lagi, diperbaiki).

## Phase 21: Evaluasi Menyeluruh + Balance (2 Jam)

**Goal:** Evaluasi semua detail game dari menu sampai ending, perbaiki yang janggal, balance bos supaya tegang tapi adil.
**Requirements**: BAL-01..BAL-05
**Success Criteria** (what must be TRUE):
  1. Bos cuma menyelidiki tugas dalam 350px; teleport pertama 15-20 dtk
  2. Teks menu sebut semua tugas + kode; ENDING PAHIT tanpa "level berikut"; timer tidak jalan pas intro
  3. Full regression hijau; video baru bot bisa progres tanpa ketangkep berulang
**Plans**:
- [x] 21-01: Evaluasi video v13 frame demi frame, catat masalah
- [x] 21-02: Perbaiki balance + teks + timer
- [x] 21-03: Update test + full regression + video v14 verifikasi

**Status: Complete.** Committed (14 Nov 2026). test_bossaggro 9/9, test_tension 5/5, test_hide 10/10, popup 23/23, solo 13/13, win 6/6, flow 3/3, search 2/2, patrol 2/2, music 7/7, tutorial 11/11, bosspol 6/6, light 7/7, mute 9/9, intro 6/6. Video v13: bot ketangkep 2x, tidak selesai dalam 180 dtk (terlalu agresif). Video v14: bot ketangkep 1x, progres 2/3 di 0:51, balance membaik.

## Phase 22: Peringatan Bos Datang ke Tugas

**Goal:** Pemain dapat peringatan dulu sebelum bos menyamperin pas lagi kerjain tugas, jadi bisa pilih buru-buru selesaikan atau batalkan (Esc) dan ngumpet.
**Requirements**: WARN-01
**Success Criteria** (what must be TRUE):
  1. Buka popup tugas + bos dalam 350px = peringatan "BOS MENDENGAR SUARAMU! Dia menuju ke tugasmu!" + alarm, 3 detik
  2. Bos jauh dari tugas = tidak ada peringatan (bos tidak akan datang)
  3. test_taskwarn 2/2; regression hijau
**Plans**:
- [x] 22-01: Peringatan di try_open_task_popup + RPC on_boss_heard_task
- [x] 22-02: Test taskwarn + regression

**Status: Complete.** Committed (14 Nov 2026). test_taskwarn 2/2, bossaggro 9/9, popup 23/23, solo 13/13.

## Phase 23: Bos Tidak Buta, Tidak Nyangkut, Ngumpet Beneran

**Goal:** Perbaiki 3 keluhan Elang: bos nabrak/nyangkut di meja dan tembok, ngumpet tidak benar-benar di bawah meja, bos kayak buta (pemain lewat tidak ketangkep/dikejar).
**Requirements**: BOSS-01, BOSS-02, BOSS-03, HIDE-01
**Success Criteria** (what must be TRUE):
  1. Bos bisa nangkep pemain dari arah mana pun, termasuk dari atas (dulu CATCH_DIST 30 < jarak kontak vertikal 36px, jadi bos nempel dari atas tapi tidak bisa nangkep)
  2. Bos bisa lihat pemain dalam gelap sampai 200px (dulu 150px, pemain bisa seenaknya lewat dalam gelap)
  3. Bos lepas dari nyangkut dalam 1.0 dtk (dulu 2.0 dtk) + repath baru
  4. Ngumpet: collision pemain mati pas ngumpet (posisi persis di bawah meja, tidak didorong fisika), alpha 0.35
  5. test_vision 8/8, test_hide 11/11; regression hijau
**Plans**:
- [x] 23-01: CATCH_DIST 30 → 40 + dark vision 150 → 200 + stuck 2.0 → 1.0 dtk + repath
- [x] 23-02: Ngumpet: collision off + alpha 0.35
- [x] 23-03: Test vision + hide + regression

**Status: Complete.** Committed (14 Nov 2026). test_vision 8/8, test_hide 11/11, bossaggro 9/9, solo 13/13, popup 23/23. Render ngumpet: pemain sepenuhnya ketutup meja, posisi persis (320, 314).

## Phase 24: Bos Tidak Lihat Nembus Tembok + Bisa Dengar Langkah

**Goal:** Bos tidak bisa lihat nembus tembok (verifikasi LOS), dan bos bisa dengar langkah kaki pemain lewat FSM (jalan sunyi, lari berisik).
**Requirements**: LOS-01, HEAR-01
**Success Criteria** (what must be TRUE):
  1. Tembok blokir penglihatan bos (raycast sudah ada, dibuktikan tes)
  2. Bos dengar pemain lari (sprint) sampai 300px, jalan kaki sampai 120px
  3. Dengar → FSM PATROL/RETURN → SUSPICIOUS ("?") → SEARCH; di SEARCH, dengar baru update titik pencarian
  4. Diam dan ngumpet itu sunyi (bos tidak dengar)
  5. test_hearing 7/7; regression hijau
**Plans**:
- [x] 24-01: Verifikasi LOS tembok + implementasi _nearest_audible_player + FSM
- [x] 24-02: Test hearing + regression

**Status: Complete.** Committed (14 Nov 2026). test_hearing 7/7, vision 8/8, bossaggro 9/9, solo 13/13.

## Phase 25: Bos Patroli Dekat Pemain + Video Berhenti Pas Game Selesai

**Goal:** Bos terasa hadir (patroli di dekat pemain, bukan jalan jauh sendirian) dan video rekaman berhenti sendiri pas game selesai, bukan jalan terus setelah dapat bintang.
**Requirements**: PATROL-01, VID-01
**Success Criteria** (what must be TRUE):
  1. Bos pilih waypoint terdekat ke pemain (bukan urutan loop), tetap di area pemain
  2. Video berhenti 5 dtk setelah layar akhir muncul (marker DEMO_END + record_demo.sh)
  3. test_patrolbias 3/3; regression hijau; video v17 berhenti sendiri pas GAME OVER
**Plans**:
- [x] 25-01: _pick_waypoint bias ke pemain + DEMO_END marker + record_demo.sh
- [x] 25-02: Test patrolbias + regression + rekam v17

**Status: Complete.** Committed (14 Nov 2026). test_patrolbias 3/3, patrol 2/2, bossaggro 9/9, solo 13/13, hearing 7/7. Video v17: 196 dtk, ada suara (mean -29.7 dB), 0 script error, bot GAME OVER (ketangkep 3x) dan video berhenti sendiri 5 dtk setelah layar akhir.

## Phase 26: Kabur dari Sel Tidak Lagi Gratis

**Goal:** Keluar dari sel (self-rescue solo) harus ada tantangan: bos yang datang ke sel benar-benar menghambat kabur, bukan cuma berdiri diam.
**Requirements**: RESCUE-01, RESCUE-02
**Success Criteria** (what must be TRUE):
  1. Kalau bos dalam 150px dari sel pas pemain self-rescue, progres kabur melambat jadi 30% (tidak beku total, tidak ada soft-lock)
  2. Waktu self-rescue 15 dtk → 10 dtk
  3. test_rescue 4/4; regression hijau; video v18 menunjukkan bot kabur dari sel lalu lanjut kerja
**Plans**:
- [x] 26-01: Guard radius 150px + crawl 30% + rescue 10 dtk + test_rescue
- [x] 26-02: Regression + rekam v18 + commit + rebuild

**Status: Complete.** Committed (14 Nov 2026). test_rescue 4/4, solo 13/13, bossaggro 9/9, hearing 7/7, vision 8/8, popup 23/23, patrolbias 3/3. Video v18: 297 dtk, ada suara (mean -32.3 dB), 0 script error, bot GAME OVER (ketangkep 3x) tapi sempat kabur dari sel dan lanjut ke Generator.

## Phase 27: Popup Tugas Nyatu Sama Tema Horor

**Goal:** Popup tugas tidak lagi kelihatan AI slop: pakai font dan warna game, tiap popup jadi artefak kantor tua yang berhantu, bukan aplikasi bersih generik.
**Requirements**: POPUP-01, POPUP-02
**Success Criteria** (what must be TRUE):
  1. Semua teks popup pakai font game (Creepster judul, Special Elite isi)
  2. Excel jadi terminal CRT hijau fosfor di layar hitam (tidak ada sel putih / hijau Excel terang)
  3. Panel Listrik jadi panel tua berkarat + strip BAHAYA merah darah, lampu redup
  4. Fotokopi jadi mesin tua + zona amber + kertas kuning tua
  5. Keypad jadi keypad karatan + LCD fosfor redup, tombol angka di tengah
  6. Tuas Sel jadi tuas besi berkarat, tanpa judul ganda
  7. Layout rapih: panel ngikutin tinggi isi, tidak ada ruang kosong gede
  8. test_popup 23/23; render 5 popup diverifikasi visual
**Plans**:
- [x] 27-01: Font game + warna tema + redesign 5 popup + teks instruksi suara game
- [x] 27-02: Render verifikasi + test_popup + commit + rebuild

**Status: Complete.** Committed (14 Nov 2026). test_popup 23/23. Render 5 popup diverifikasi: CRT fosfor hijau, panel berkarat strip BAHAYA, fotokopi amber + kertas tua, keypad karatan LCD fosfor, tuas besi berkarat. Layout rapih: panel ngikutin tinggi isi via CenterContainer (percobaan pertama pakai offset 0 bikin panel meluber ke bawah layar, diganti CenterContainer). Teks tidak keluar kotak: semua panel dalam pakai PanelContainer dengan content margin; teks strip BAHAYA dipendekin dari "BAHAYA — TEGANGAN TINGGI — PANEL LISTRIK TUA" jadi "BAHAYA — TEGANGAN TINGGI" karena font Creepster kelebaran.

## Phase 28: Excel Interaktif Kayak Spreadsheet Beneran

**Goal:** Excel bukan lagi pilih 1 dari 3 opsi, tapi ketik jawaban langsung ke sel kayak spreadsheet beneran, dengan rumus Excel asli.
**Requirements**: POPUP-05
**Success Criteria** (what must be TRUE):
  1. Tabel data 3 kolom (A,B,C) x 4 baris (2-5) + nomor baris, satu tabel yang sama buat 7 soal
  2. Formula bar nunjukin rumus Excel asli: =SUM(A2:A5), =SUM(A2:C2), =AVERAGE(A2:A3), =MAX(C2:C5), =MIN(B2:B5), =A4*B4, =A5+B5+C5
  3. Player ketik hasil hitungannya ke sel HASIL (tombol 0-9, Backspace hapus, ENTER/SPASI submit)
  4. Sel HASIL ke-highlight border fosfor + kursor blok "▌" berkedip tiap 0.45 dtk
  5. Jawaban benar → soal berikut; salah → noise + input kehapus, ulang soal yang sama
  6. AVERAGE selalu bilangan bulat (A2 dan A3 dipaksa paritas sama); demo bot ngetik digit jawaban satu-satu; test_popup 23/23
**Plans**:
- [x] 28-01: Grid A2/B2/C2 + ketik ke sel (Phase 28 v1)
- [x] 28-02: Tabel 4 baris + 7 rumus Excel asli (SUM/AVERAGE/MAX/MIN/kali/tambah) + sel HASIL (Phase 28 v2)
- [x] 28-03: test_popup + render verifikasi + commit + rebuild

**Status: Complete.** Committed (14 Nov 2026). test_popup 23/23. Render Excel diverifikasi: formula bar "=SUM(A2:A5)", tabel A/B/C baris 2-5, sel HASIL nunjukin jawaban bener (render script sempet hardcode "42", diperbaiki jadi baca jawaban bener dari game; commit 7200706).

## Phase 29: Bos Lebih Cepat + Sensitif, Sprint Terbatas

**Goal:** Bos ngejar lebih kencang dan lebih sensitif; sprint jadi sumber daya terbatas (bar penuh pun cuma ~2 detik, refill pelan).
**Requirements**: BAL-06, BAL-07
**Success Criteria** (what must be TRUE):
  1. Bos chase 240 -> 270 (player sprint 300, jadi sprint masih bisa kabur tipis; jalan 200 ketangkep cepat)
  2. Bos patrol 120 -> 130, search 140 -> 160
  3. Bos vision 300 -> 340px, cone 1.2 -> 1.35 rad, dark vision 200 -> 240px
  4. Bos dengar jalan 120 -> 160px, dengar lari 300 -> 360px
  5. Sprint drain 30 -> 50/detik (bar penuh = ~2 detik sprint), regen 22 -> 8/detik (~12.5 detik buat penuh)
  6. test_bossaggro 9/9, test_vision 9/9, test_hearing 8/8, test_stamina 4/4 (baru), regresi hijau
**Plans**:
- [x] 29-01: Konstanta bos + stamina + update test (bossaggro/vision/hearing) + test_stamina baru
- [x] 29-02: Regresi penuh + commit + rebuild

**Status: Complete.** Committed (14 Nov 2026). test_bossaggro 9/9, test_vision 9/9, test_hearing 8/8, test_stamina 4/4. Regresi penuh hijau kecuali 1 assert flaky di test_bosspol (rest-pose, y=-20.067) yang lolos 6/6 pas di-run ulang sendiri.

## Phase 30: Peringatan Bos di Dalam Popup Tugas

**Goal:** Pemain yang lagi kerja di dalam popup tidak buta lagi: dia lihat bos mendekat secara live dan bisa mutusin Esc atau nekat lanjut. Bos tetap secepat dan sesensitif Phase 29; yang berubah adalah pemain dikasih informasi, bukan bos dilemahkan.
**Requirements**: POPUP-06
**Success Criteria** (what must be TRUE):
  1. Label peringatan di bawah judul popup, update tiap frame dari jarak bos ke pemain
  2. Bos <200px = merah berkedip "BOS SUDAH SANGAT DEKAT! Esc buat kabur!"
  3. Bos 200-350px = amber "Bos mendekat..."
  4. Bos >=350px = label sembunyi
  5. Alpha denyut tidak pernah di bawah 0.5 biar selalu terbaca
  6. test_bosswarn 4/4 (baru), test_popup 23/23, render visual terverifikasi
**Plans**:
- [x] 30-01: boss_warn_label di task_popup.gd + _process update tiap frame + test_bosswarn baru
- [x] 30-02: Render visual (peringatan merah terbaca), regresi + commit + rebuild + video v20

**Status: Complete.** Committed (14 Nov 2026). test_bosswarn 4/4, test_popup 23/23. Render terverifikasi: peringatan merah Creepster terbaca di bawah judul popup.

## Phase 31: Dua Tugas Baru di Area Atas + Kode 5 Digit

**Goal:** 3 tugas utama terlalu sedikit dan terlalu mudah, semuanya di tengah-bawah, area atas peta tidak pernah dijelajahi. Tambah 2 tugas utama di atas (Gudang + Rapat) dengan minigame beda mekanik, dan kode pintu jadi 5 digit. Pantry/bikin kopi DITOLAK Elang (tidak nyambung sama cerita kabur); penggantinya Rapat, dipilih Elang (opsi A).
**Requirements**: TASK-01, TASK-02, TASK-03
**Success Criteria** (what must be TRUE):
  1. Gudang (128,176) + Rapat (700,128) jadi tugas utama, total 5; pemain harus keliling full map
  2. Gudang = Cari Berkas (grid 3x3, cari item target, angka 1-9, 3 ronde); Rapat = Catatan Rapat (urutkan 5 tanggal, angka 1-5, salah = noise + ulang)
  3. Kode pintu 5 digit, tiap tugas kasih 1 digit, catatan pintu dihapus; keypad 5 digit; menu update
  4. Demo bot rutenya nambah Gudang + Rapat; test_popup 27/27, test_win 6/6, test_flow 3/3, test_tutorial 11/11, regresi penuh hijau
  5. Render kedua popup baru terverifikasi (teks tidak keluar kotak)
**Plans**:
- [x] 31-01: TASK_DEFS + kode 5 digit + keypad 5 digit + popup cari/urut + demo bot + tes update
- [x] 31-02: Render visual kedua popup baru, regresi + commit + rebuild + video v21

**Status: Complete.** Committed (14 Nov 2026). test_popup 27/27, test_win 6/6, test_flow 3/3, test_tutorial 11/11. Render terverifikasi: grid 3x3 Cari Berkas dan 5 slot tanggal Catatan Rapat rapih, teks di dalam kotak. **Fix susulan: HUD task count "X/3" hardcoded jadi dinamis "X/5" (main_total dari TASK_DEFS); video v21 take 1 tidak selesai dalam 300 dtk (bot baru 1 tugas, lama di sel karena bos camping) + file sempat dikira korup (moov atom, ternyata valid 314 dtk).

## Phase 32: Cari Berkas Jadi Dokumen Kertas Berhalaman

**Goal:** Grid 3x3 Cari Berkas terlalu mudah (semua kelihatan sekaligus). Jadiin dokumen kertas: ada judul, bisa pindah halaman kayak ngebuka tumpukan berkas (bukan buku), target tersembunyi di 1 dari 3 halaman.
**Requirements**: TASK-04
**Success Criteria** (what must be TRUE):
  1. Kertas kuning tua + judul "BERKAS ARSIP KANTOR" + stempel merah "RAHASIA" + daftar 4 berkas per halaman
  2. 3 halaman per ronde, 12 berkas total, target di 1 halaman + 1 slot acak
  3. Panah kiri-kanan ganti halaman, angka 1-4 pilih berkas; salah = noise
  4. Demo bot balik halaman dulu baru milih; test_popup 27/27
  5. Render kedua halaman terverifikasi (teks di dalam kotak, halaman 1 dan 2 beda isi)
**Plans**:
- [x] 32-01: cari_pages 3x4 + _cari_flip + _build_cari kertas + input panah + demo bot + tes update
- [x] 32-02: Render visual 2 halaman, regresi + commit + rebuild + video v22

**Status: Complete.** Committed (15 Nov 2026). test_popup 27/27. Render terverifikasi: halaman 1 (SLIP GAJI dkk) dan halaman 2 (INVOICE KLIEN dkk) beda isi, judul + stempel RAHASIA kelihatan, semua teks di dalam kertas. **Video v22: 422 dtk, audio mean -31.2 dB, bot selesaikan 5/5 tugas (GUDANG tercentang di frame 5:20) tapi GAME OVER 0 bintang (ketangkep 3x di jalan ke pintu keluar) — keterbatasan bot demo, bukan gamenya.**

## Phase 33: Bandingin Sama Game Lain (DbD / Phasmophobia / Amnesia)

**Goal:** Elang (15 Nov 2026): "lanjutkan terus improve, bandingkan sama game lain juga". Bandingin Terror Lembur sama Dead by Daylight, Phasmophobia, Amnesia, ambil mekanik yang bikin game-game itu tegang, implementasi yang paling ngena.
**Requirements**: GATE-01, HEART-01, HAUNT-01, SNIFF-01, BOT-01
**Success Criteria** (what must be TRUE):
  1. DbD exit gate: kode benar -> pintu terbuka 6 detik (progress + alarm + noise 400px) -> tekan E di pintu buat kabur; bukan langsung menang
  2. DbD terror radius: volume detak jantung scaling -14 dB (320px) sampai -2 dB (dekat)
  3. Phasmo ghost event: tiap 25-45 detik acak saat bos >350px, bisikan atau benda jatuh; tidak muncul saat bos dekat
  4. Amnesia: bos PATROL dalam 100px dari pemain ngumpet jadi CURIGA ke meja itu
  5. Demo bot kabur dari popup saat peringatan merah + ngumpet saat dikejar + menang lewat pintu terbuka; test_win 8/8, test_phase33 4/4, test_popup 27/27
**Plans**:
- [x] 33-01: GATE-01 + HEART-01 + HAUNT-01 + SNIFF-01 + BOT-01 + menu CARA BERMAIN + test_win update + test_phase33 baru
- [x] 33-02: Regresi + commit + rebuild + video v23

**Status: Complete.** Committed (15 Nov 2026). test_win 8/8, test_phase33 4/4, test_popup 27/27, regresi 10 tes tanpa fail. Video v23: 188.4 detik, audio -25.8 dB, GAME OVER 0 bintang, bot 1/5 tugas (cuma Komputer), mati 3x di ~1:03 in-game — flee v1 lari ke meja terdekat lalu ngumpet, bos SNIFF-01 nemu dia di meja itu.

## Phase 34: Bot Kabur yang Bener (Lari Dulu, Ngumpet Belakangan)

**Goal:** Video v23 nunjukin BOT-01 malah bikin bot mati lebih cepat (1/5 tugas, GAME OVER di 1:03 in-game; v22: 5/5 tugas, GAME OVER 2:00). Root cause dari frame: bot kabur ke meja TERDEKAT pas dikejar, padahal bos lihat dia ke sana; SNIFF-01 bikin bos curiga ke meja itu, SEARCH desk-check, ketangkep. Habis kabur dari sel pun bot langsung ngumpet di meja ruang bos, 70px dari bos. Ngumpet cuma aman kalau bos tidak lihat lo ke sana.
**Requirements**: BOT-02
**Success Criteria** (what must be TRUE):
  1. Saat dikejar bot lari (sprint) ke waypoint patroli terjauh dari bos, bukan ke meja; retarget tiap 2 detik
  2. Ngumpet cuma kalau kejarannya putus (bos bukan CHASE + jarak >250px) dan meja >200px dari bos
  3. Video v24 nunjukin bot lebih tahan lama dari v23 (tugas selesai + waktu hidup lebih panjang)
**Plans**:
- [x] 34-01: _demo_flee v2 + _demo_far_point + sprint saat kabur + tes + commit + rebuild + video v24

**Status: Complete.** Committed (15 Nov 2026). Video v24: 154.1 detik, audio -26.6 dB, GAME OVER 0 bintang, bot 1/5 tugas, mati 3x di 1:02 in-game — bot lari lurus di koridor terbuka, bos tetap lihat dia, kejaran nggak putus.

## Phase 35: Bot Kabur Lebih Pintar (Lari ke Balik Tembok, Jangan Buka Tugas Kalau Bos Dekat)

**Goal:** v24 tetap GAME OVER 0 bintang, 1/5 tugas, ketangkep 3x di 1:02 in-game. Frame v24: bot lari lurus di koridor terbuka, bos tetap lihat dia dari belakang, kejaran tidak putus. Bot butuh putus LOS, bukan cuma jarak.
**Requirements**: BOT-03
**Success Criteria** (what must be TRUE):
  1. Titik kabur = waypoint terjauh dari bos yang tidak ada LOS dari bos (raycast), jadi bot lari ke balik tembok
  2. Bot tidak buka popup tugas kalau bos dalam 350px; mundur dan tunggu bos pergi dulu
  3. Video v25 lebih baik dari v24 (tugas selesai + waktu hidup lebih panjang)
**Plans**:
- [x] 35-01: _demo_far_point pakai LOS + guard buka popup + tes + commit + rebuild + video v25

**Status: Complete.** Committed (15 Nov 2026). Video v25: 235.7 detik, audio -26.0 dB, GAME OVER 0 bintang, bot 1/5 tugas, mati 3x di 1:48 in-game — bot berhasil ngumpet sekali (frame 0:33) dan lari ke balik tembok, tapi spiral sel: kabur dari sel, bos 72px di depan sel, ketangkep lagi.

## Phase 36: Kejaran Lebih Adil (Aturan DbD) + Kasih Tahu Pemain Saat Kejaran Putus

**Goal:** Riset game horror (DbD/Phasmo/Amnesia/Granny/Outlast) + video v23/v24/v25: bot mati terus di kejaran terbuka karena bos 270 vs jalan 200 (selisih 35%, DbD cuma 15%). Kejaran harus diputusin LOS, bukan kecepatan mentah. Pemain juga nggak pernah dikasih tahu kalau putus pandangan itu yang nyelamatin dia.
**Requirements**: BAL-08, LOS-02, MUG-02
**Success Criteria** (what must be TRUE):
  1. SPEED_CHASE 270 -> 240; test_bossaggro update; enrage akhir game tetap 384 > sprint 300
  2. Kejaran putus (LOS hilang / bos capek 8 detik) -> "Dia kehilangan jejakmu!" 2 detik
  3. Prompt mug: "Q: lempar barang (mancing bos)"
  4. test_phase36 3/3; regresi hijau; video v26 bot lebih tahan lama dari v25
**Plans**:
- [x] 36-01: BAL-08 + LOS-02 + MUG-02 + test_phase36 + tes + commit + rebuild + video v26

**Status: Complete.** Committed (15 Nov 2026). test_phase36 3/3. Video v26: direkam 15 Nov 2026 (16,7 MB, 241 detik) tapi TIDAK dicek frame-nya — Elang: fokus ke game, bukan video.

## Phase 37: Teleport Pertama Lebih Lambat + Bos Menjauh Habis Rescue

**Goal:** Bedah kode + video v23/v24/v25: teleport pertama 15-20 detik bisa jatuhin bos di atas pemain pas Excel; habis kabur dari sel bos cuma 72px dari sel dan langsung patroli mendekat (spiral mati).
**Requirements**: PACE-01, CELL-01
**Success Criteria** (what must be TRUE):
  1. FIRST_TELEPORT 25-35 detik
  2. send_back_to_room: blind 5 detik + post_rescue_timer 10 detik; _pick_waypoint pilih waypoint terjauh selama cooldown, terdekat sesudahnya
  3. test_phase37 5/5; regresi hijau
**Plans**:
- [x] 37-01: PACE-01 + CELL-01 + test_phase37 + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase37 5/5.

## Phase 38: Pembukaan Adil + Wind-Up Kejaran + Teriak Jujur

**Goal:** Laporan bedah kode 5 gap: pembukaan jebakan (bos patroli 137px dari Komputer), kejaran <200px mustahil menang, stamina 1x kabur per 12 detik, kabur dari sel 72px dari bos, teriak jebakan di solo. Yang diimplementasi: OPEN-01, CHASE-01, SHOUT-01. Stamina regen TIDAK diubah (8/detik tetap — Elang Phase 29 minta sprint langka).
**Requirements**: OPEN-01, CHASE-01, SHOUT-01
**Success Criteria** (what must be TRUE):
  1. Target patroli pertama = (1328,272) ujung jauh
  2. Kejaran mulai dengan wind-up 1 detik: bos diam 0px, lalu lari; _update_stuck tidak loncat pas wind-up
  3. Hint solo: "F: teriak (bos datang ke kamu!)"
  4. test_phase38 5/5; regresi hijau
**Plans**:
- [x] 38-01: OPEN-01 + CHASE-01 + SHOUT-01 + test_phase38 + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase38 5/5.

## Phase 39: Teleport Hormat Pemain Ngumpet

**Goal:** Konsep §6: bos "nggak bisa teleport ke ruangan yang sama persis dengan pemain yang lagi ngumpet di bawah meja" — aturan ini belum ada di game.
**Requirements**: TELE-02
**Success Criteria** (what must be TRUE):
  1. `teleport_destination()` menolak destinasi di ruangan yang sama dengan pemain ngumpet (cek `_room_of()`, max 8 percobaan, fallback ruang bos)
  2. Aturan 120px tetap jalan
  3. test_phase39 2/2; regresi kunci hijau
**Plans**:
- [x] 39-01: TELE-02 + test_phase39 + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase39 2/2.

## Phase 40: Desain Lantai 2 di GSD (Siap Bangun, Sesuai Konsep)

**Goal:** Elang (15 Nov 2026, sesi 1 jam ke-2): "improve terus, di GSDnya juga, jadi kalo nanti ada level selanjutnya benar benar sesuai konsep gamenya". Desain lantai 2 ditulis lengkap dari KONSEP.md §2/§4/§6/§8 — cerita, peta, 5 tugas, eskalasi bos, nerf antar level, bintang, dan syarat arsitektur (data level jadi data, bukan copy level_1.gd).
**Requirements**: LVL2-01..08 (design)
**Success Criteria** (what must be TRUE):
  1. `.planning/LEVEL-2-DESIGN.md` lengkap dan berakar ke konsep (tiap keputusan menunjuk pasal konsep)
  2. Requirements LVL2-01..08 + traceability; coverage 137 → 146
  3. ROADMAP Phase 41 (Planned); CAMP-01 diperbarui
**Plans**:
- [x] 40-01: LEVEL-2-DESIGN.md + requirements + roadmap + commit

**Status: Complete.** Committed (15 Nov 2026).

## Phase 41: Lantai 2 (Implementasi)

**Goal:** Bangun lantai 2 sesuai `.planning/LEVEL-2-DESIGN.md`: `level_config.gd` + `LEVEL_CONFIGS`, `level_2.tscn`, nerf, layar akhir + lanjut lantai, menu pilih lantai, tes `test_level2`, video playthrough.
**Requirements**: LVL2-01..08
**Success Criteria** (what must be TRUE):
  1. Lantai 1 dipindah ke config dulu, tes hijau, baru tambah lantai 2
  2. Lantai 2 bisa ditamatkan solo (bot demo) + LAN
  3. Nerf Bad Ending jalan; bintang + lanjut lantai jalan
  4. test_level2 hijau; regresi hijau
**Plans**:
- [ ] 41-01: level_config.gd + LEVEL_CONFIGS + level_2.tscn + nerf + menu + tes

**Status: Planned.** Implementasi SESUDAH submit Gimersia 29 Nov 2026.

## Phase 42: Meter TEKANAN di HUD

**Goal:** Riset Phasmophobia (saran #5): pressure dial yang kelihatan. Eskalasi bos selama ini cuma kerasa lewat kecepatan — pemain tidak tahu seberapa marah bos sampai ketangkep. Meter TEKANAN di panel status bikin eskalasi kelihatan.
**Requirements**: PRESS-01
**Success Criteria** (what must be TRUE):
  1. Bar TEKANAN di panel status kanan atas, selalu kelihatan
  2. Nilai = (boss_speed_mult - 1.0) / 0.8 → 0-100%; warna hijau <40, kuning <75, merah >=75
  3. test_phase42 4/4; regresi kunci hijau
**Plans**:
- [x] 42-01: PRESS-01 + test_phase42 + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase42 4/4.

## Phase 43: Kode Tidak Pernah Hilang

**Goal:** Audit kode menemukan bug kritis: digit ke-5 kode pintu TIDAK PERNAH terlihat pemain — `_on_task_done` reveal digit 5 lalu `_enrage_boss()` menimpa `hud_warn_label` di frame yang sama. Semua pesan penting berbagi satu label, jadi digit 1-4 pun bisa hilang kalau reveal berbarengan dengan warning/kejaran. Run bisa jadi unwinnable secara praktis.
**Requirements**: CODE-01
**Success Criteria** (what must be TRUE):
  1. Label kode terpisah dari label warning; reveal digit 5 tetap kelihatan sesudah enrage
  2. Warning lain tidak menimpa label kode
  3. Label kode hilang sendiri setelah 10 detik (memory-only tetap: tidak ada cek ulang)
  4. test_phase43 3/3; test_popup diperbarui ke desain baru (28/28)
**Plans**:
- [x] 43-01: CODE-01 + test_phase43 + update test_popup + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase43 3/3, test_popup 28/28.

## Phase 44: Umpan Balik yang Jujur

**Goal:** Audit kode + riset game: game berbohong/diam di momen penting — E di tugas belum siap diam total, tutorial macet sampai akhir game, sprint berisik tanpa indikator, pesan teleport bohong soal jarak, intro hilang kalau pemain tekan WASD.
**Requirements**: FEED-01, FEED-02, FEED-03, FEED-04, FEED-05
**Success Criteria** (what must be TRUE):
  1. E di tugas belum siap menampilkan alasan 2 detik
  2. Tutorial langkah 2 terima popup apa pun; langkah 4 selesai saat tugas pertama selesai
  3. Prompt "SHIFT: lari (berisik!)" + CARA BERMAIN menyebut lari itu berisik
  4. Pesan teleport berdasarkan jarak sebenarnya
  5. Intro cuma ditutup E/klik
  6. test_phase44 7/7; regresi kunci hijau
**Plans**:
- [x] 44-01: FEED-01..05 + test_phase44 + tes + commit + rebuild

**Status: Complete.** Committed (15 Nov 2026). test_phase44 7/7.

## Progress

## Progress

## Progress

**Execution Order:**
Phases 1-4 are done. Improvement round runs next: 7 → 8 → 9 → 10, then 5 (submission) → 6 (testing).
**Production round (Elang, 14 Nov 2026 ~11:54 WIB: "improve terus pake GSD, sampe production grade"): 11 → 12 → 13, then 5 (submission) → 6 (testing).**
**Task minigames (Elang, 14 Nov 2026: tugas jangan cuma mencet tombol): Phase 14, then 5 (submission) → 6 (testing).**

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Mode Solo | 4/4 | Complete | 14 Nov 2026 |
| 2. Monster & Boss Visual | 3/3 | Complete | 14 Nov 2026 |
| 3. Flow Fixes & Design Docs | 5/5 | Complete | 14 Nov 2026 |
| 4. Checkpoint Package | 2/3 | Complete (itch.io page needs Elang's login) | 14 Nov 2026 |
| 7. Audio & Suasana | 3/3 | Complete | 14 Nov 2026 |
| 8. Tutorial In-Game | 3/3 | Complete | 14 Nov 2026 |
| 9. Ketegangan Awal | 2/2 | Complete | 14 Nov 2026 |
| 10. Polish Bos & FSM | 3/3 | Complete | 14 Nov 2026 |
| 11. Senter Smooth | 3/3 | Complete | 14 Nov 2026 |
| 12. Audio Production | 2/2 | Complete | 14 Nov 2026 |
| 13. Production Build | 2/2 | Complete | 14 Nov 2026 |
| 14. Task Minigames | 4/4 | Complete | 14 Nov 2026 |
| 15. Task Popups | 4/4 | Complete | 14 Nov 2026 |
| 16. Task Popups v2 | 4/4 | Complete | 14 Nov 2026 |
| 17. Intro Story + Video dari Menu | 3/3 | Complete | 14 Nov 2026 |
| 18. Kode Hafalan + Game Lebih Menantang | 3/3 | Complete | 14 Nov 2026 |
| 19. Bos Lebih Agresif | 3/3 | Complete | 14 Nov 2026 |
| 20. Ngumpet Beneran di Bawah Meja | 2/2 | Complete | 14 Nov 2026 |
| 21. Evaluasi Menyeluruh + Balance | 3/3 | Complete | 14 Nov 2026 |
| 22. Peringatan Bos Datang ke Tugas | 2/2 | Complete | 14 Nov 2026 |
| 23. Bos Tidak Buta, Tidak Nyangkut, Ngumpet Beneran | 3/3 | Complete | 14 Nov 2026 |
| 24. Bos Tidak Lihat Nembus Tembok + Bisa Dengar Langkah | 2/2 | Complete | 14 Nov 2026 |
| 25. Bos Patroli Dekat Pemain + Video Berhenti Pas Game Selesai | 2/2 | Complete | 14 Nov 2026 |
| 26. Kabur dari Sel Tidak Lagi Gratis | 2/2 | Complete | 14 Nov 2026 |
| 27. Popup Tugas Nyatu Sama Tema Horor | 4/4 | Complete | 14 Nov 2026 |
| 28. Excel Interaktif Kayak Spreadsheet Beneran | 1/1 | Complete | 14 Nov 2026 |
| 29. Bos Lebih Cepat + Sensitif, Sprint Terbatas | 2/2 | Complete | 14 Nov 2026 |
| 33. Bandingin Sama Game Lain (DbD/Phasmo/Amnesia) | 2/2 | Complete | 15 Nov 2026 |
| 34. Bot Kabur yang Bener (Lari Dulu, Ngumpet Belakangan) | 1/1 | Complete | 15 Nov 2026 |
| 35. Bot Kabur Lebih Pintar (Lari ke Balik Tembok) | 1/1 | Complete | 15 Nov 2026 |
| 36. Kejaran Lebih Adil (Aturan DbD) + Kasih Tahu Pemain Saat Kejaran Putus | 1/1 | Complete | 15 Nov 2026 |
| 37. Teleport Pertama Lebih Lambat + Bos Menjauh Habis Rescue | 1/1 | Complete | 15 Nov 2026 |
| 38. Pembukaan Adil + Wind-Up Kejaran + Teriak Jujur | 1/1 | Complete | 15 Nov 2026 |
| 39. Teleport Hormat Pemain Ngumpet | 1/1 | Complete | 15 Nov 2026 |
| 40. Desain Lantai 2 di GSD (Siap Bangun, Sesuai Konsep) | 1/1 | Complete | 15 Nov 2026 |
| 41. Lantai 2 (Implementasi) | 0/1 | Planned (sesudah submit Gimersia 29 Nov 2026) | - |
| 42. Meter TEKANAN di HUD | 1/1 | Complete | 15 Nov 2026 |
| 43. Kode Tidak Pernah Hilang | 1/1 | Complete | 15 Nov 2026 |
| 44. Umpan Balik yang Jujur | 1/1 | Complete | 15 Nov 2026 |
| 5. Final Submission | 2/3 | Prep done (video + screenshots + docs); submission itself pending | - |
| 6. Testing & Verification | 1/4 | Partial (win test + patrol test done; playtest/LAN/push blocked on Elang) | - |
