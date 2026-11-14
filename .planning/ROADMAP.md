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
- [ ] 16-01: Sistem kode pintu dari tugas (level code_digits, reveal per tugas, HUD tampilkan kode, keypad pakai kode level)
- [ ] 16-02: Visual Excel + Panel Listrik kayak perangkat beneran
- [ ] 16-03: Visual Keypad + Fotokopi + Tuas Sel kayak perangkat beneran
- [ ] 16-04: Test + full regression + video baru

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
| 16. Task Popups v2 | 0/4 | Not started | - |
| 5. Final Submission | 2/3 | Prep done (video + screenshots + docs); submission itself pending | - |
| 6. Testing & Verification | 1/4 | Partial (win test + patrol test done; playtest/LAN/push blocked on Elang) | - |
