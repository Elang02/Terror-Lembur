# Roadmap: Terror Lembur

## Overview

From a LAN-only 2-PC build to a solo-playable Gimersia submission in 15 days. Phase 1 (solo mode) is the biggest blocker and comes first. Phases 2-3 fix the boss, flow, and design. Phase 4 delivers the 19 Nov checkpoint package. Phase 5 completes the 29 Nov submission. Phase 6 verifies everything on real hardware.

## Phases

- [ ] **Phase 1: Mode Solo** - One player can play start to finish alone
- [ ] **Phase 2: Monster & Boss Visual** - Sprite chosen, wired, patrol and state mark confirmed
- [ ] **Phase 3: Flow Fixes & Design Docs** - Flow critiques addressed, concept updated, art direction locked
- [ ] **Phase 4: Checkpoint Package** - WebGL build, itch.io page, screenshot, progress paragraph (due 19 Nov 23:59 WIB)
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

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Mode Solo | 0/4 | Not started | - |
| 2. Monster & Boss Visual | 0/3 | Not started | - |
| 3. Flow Fixes & Design Docs | 0/5 | Not started | - |
| 4. Checkpoint Package | 0/3 | Not started | - |
| 5. Final Submission | 0/3 | Not started | - |
| 6. Testing & Verification | 0/4 | Not started | - |
