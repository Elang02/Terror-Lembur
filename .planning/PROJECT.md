# Terror Lembur

## What This Is

Terror Lembur is a top-down 2D horror co-op game for Gimersia Inspire 2026. Two office workers are trapped in a dark office at night with the ghost of their old boss, who can teleport. They can only go home if they work together: complete office tasks, rescue a captured teammate, and escape through the exit. The game is built in Godot 4.7, currently LAN 2-PC, and must become solo-playable for curators.

## Core Value

A solo curator can play the game start to finish, feel fear and tension, and reach an ending. If the solo experience does not work, nothing else matters.

## Requirements

### Validated

- ✓ LAN 2-PC multiplayer works (ENet port 7000, WebSocket test mode) — existing
- ✓ Boss AI with A* pathfinding, patrol/chase/search/return states, teleport — existing
- ✓ 4 tasks (Generator, Computer, Archive, Exit) + cell lever rescue — existing
- ✓ Hide mechanic (28 spots), flashlight, shout, throwable mugs — existing
- ✓ Map: 48x28 tiles, 15 rooms, TileMap + 141 prop instances — existing
- ✓ HUD (task panel, timer, boss status, stamina, prompts) + end screens — existing
- ✓ Locked doors open when main tasks finish — existing
- ✓ Menu with Host/Join, single best LAN IP display — existing

### Active

- [ ] Solo-playable mode (curator plays alone, complete experience)
- [ ] Monster sprite chosen and wired (non-AI, Gimersia-legal)
- [ ] WebGL build + itch.io page + gameplay video + screenshots
- [ ] Concept document updated to Pulang theme + ghost boss
- [ ] MDA defined in design docs
- [ ] Art direction: 3 keywords agreed, grayscale readability test
- [ ] Flow fixes (spawn = exit, teleport fairness, self-rescue)
- [ ] Playtesting with outsiders
- [ ] Full playthrough verified on real PCs
- [ ] GitHub push (15 local commits) + PR #1 updated

### Out of Scope

- Level 2 / campaign (multiple office floors) — single level only for Gimersia
- Bad-ending cross-level nerf — needs level 2, not applicable
- Dayung Pulang — no longer the Gimersia entry, deprioritized
- AI-generated visual assets — banned by Gimersia rules
- Paid asset packs — Elang wants free only

## Context

- Competition: Gimersia Inspire 2026 (Kemenekraf + AGI). Theme: Pulang. Checkpoint 19 Nov 2026 23:59 WIB (itch.io page + screenshot + progress paragraph). Submission 29 Nov 2026 23:59 WIB (WebGL/Windows build + 60s-2min video + 3 screenshots + description + asset declaration + statement + 2 representatives data).
- Team of 5: Elang, Joshua Sahusilawane, Adrianus Ivan Ariseto, Cornelius Dicho Dharmawan, Edward Antonio Herlambang Hutauruk. Roles not yet confirmed.
- Repo: edwardedo03/Terror-Lembur (public). Local clone 15 commits ahead, push blocked (needs Elang's classic PAT, transient use only). PR #1 open, mergeable.
- Engine: Godot 4.7. Assets: Imersa Office Pixel Art (credit required), Rubber Studio Modern Office Tileset, Gridwright walls, Creepster + Special Elite fonts.
- Week-1 matrikulasi videos studied (14 Nov 2026): Game Design (Datu Yoga), Programming (Livander), Art (Yaqufa), Production (Kristian). Key learnings: solo mode = Must, 1 polished level > 10 unpolished, grayscale test before coloring, build early + test on another laptop, "game yang bagus adalah game yang selesai", one-pager + progress report for week-2 consultation.
- Sandbox blocks UDP entirely, so ENet and LAN auto-detect cannot be tested here. Real LAN test needed on Elang's 2 PCs.
- using-superpowers skill is DISABLED (archived 10 Nov 2026 at Elang's request). GSD is the workflow now.

## Constraints

- **Competition**: AI visual assets banned (Section VIII). Third-party assets must be declared in submission form.
- **Timeline**: Checkpoint 19 Nov 2026 23:59 WIB. Submission 29 Nov 2026 23:59 WIB. 15 days from 14 Nov.
- **Tech stack**: Godot 4.7, ENet (LAN), WebGL export for itch.io. All team members must use same Godot version.
- **Budget**: Free assets only (Elang, 13 Nov 2026).
- **Team**: 5 people, course slide says 1-4. Unresolved.
- **Credentials**: GitHub token never stored. Used transiently only, then discarded. Elang must provide it again for push.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Terror Lembur is the Gimersia entry (not Dayung Pulang) | Elang chose A, 13 Nov 2026 18:31 WIB. Theme Pulang, boss is ghost of old boss. | ✓ Good |
| Solo mode = Must, LAN co-op = Should/Could | Production Must/Should/Could framework. Curators play alone. | — Pending |
| Boss AI uses A* pathfinding | Elang: monster must navigate around walls, not through them. | ✓ Good |
| Mourncrest Wraith banned for Gimersia | AI-generated (PixelLab), violates AI visual asset ban. | ✓ Good |
| @tool removed, visuals as real nodes | Elang: lecturer/dino way is real nodes in scene, not @tool. | ✓ Good |
| Cables removed from map | Elang: looked like a defect, not sensible mess. | ✓ Good |
| Free assets only | Elang, 13 Nov 2026: "saya maunya yang free, kalo gak free gausah" | ✓ Good |
| GSD workflow (not using-superpowers) | Elang, 14 Nov 2026: "mending pake GSD kali ya" | — Pending |
| Solo mode approach (A/B/C) | Single-player murni vs AI companion vs local co-op one screen | — Pending |
| Monster sprite pick (2/3/4) | Nasha Pale Figure vs Nasha Antlered Shadow vs N3XUS Ghost | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-14 after GSD initialization*
