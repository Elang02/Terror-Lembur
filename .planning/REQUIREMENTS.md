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

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Dayung Pulang as Gimersia entry | Elang chose Terror Lembur (A) on 13 Nov 2026. Dayung deprioritized. |
| AI-generated visual assets | Banned by Gimersia Section VIII. Mourncrest Wraith excluded. |
| Paid asset packs | Elang wants free only (13 Nov 2026). |
| Level 2 / campaign | Single level only for Gimersia. Too big for 15 days. |
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

**Coverage:**
- v1 requirements: 46 total
- Mapped to phases: 46
- Unmapped: 0 ✓

---
*Requirements defined: 2026-11-14*
*Last updated: 2026-11-14 after initial definition*
