# FSM Bos — Terror Lembur

Dokumen ini rumahnya angka dan aturan FSM bos. Angka di sini diambil dari `scripts/boss.gd`
dan `scripts/level_1.gd` di HEAD `9641c56` (18 Nov 2026). Kalau ada dokumen lain yang
menyebut angka bos beda, yang ini yang benar — perbaiki dokumen lain itu, jangan dokumen ini.

> **Catatan:** bos ini hantu bos lama. Tidak ada arah hadap (facing) dalam deteksi sejak
> 18 Nov 2026: penglihatan omnidirectional (340px + garis pandang), pendengaran tembus
> tembok. `facing` di kode cuma dipakai buat arah visual senter merah.

## Konstanta (scripts/boss.gd)

| Konstanta | Nilai | Arti |
|---|---|---|
| `SPEED_PATROL` | 130 | Kecepatan jalan saat patroli |
| `SPEED_CHASE` | 340 | Kecepatan saat mengejar (lebih cepat dari sprint pemain 300; kabur dengan putus LOS, bukan lari) |
| `SPEED_SEARCH` | 160 | Kecepatan saat mencari |
| `SPEED_RETURN` | 100 | Kecepatan saat kembali ke ruang bos |
| `VISION_RANGE` | 340 px | Jarak pandang maksimum |
| `CATCH_DIST` | 40 px | Jarak tangkap |
| `TELEPORT_MIN` / `TELEPORT_MAX` | 14 / 20 dtk | Jeda antar teleport |
| `FIRST_TELEPORT_MIN` / `FIRST_TELEPORT_MAX` | 25 / 35 dtk | Teleport pertama (diubah PACE-01) |
| `BLIND_TIME` | 1,5 dtk | Buta setelah teleport |
| `CHASE_TIRED` | 12,0 dtk | Kejaran berakhir setelah 12 detik |
| `CHASE_WINDUP` | 0,5 dtk | Bos diam dulu sebelum mulai mengejar |
| `CHASE_LOST_MAX` | 2,0 dtk | Kejaran putus kalau pemain tidak terlihat selama 2 detik |
| `HEARING_WALK` | 200 px | Jarak dengar langkah jalan |
| `HEARING_SPRINT` | 360 px | Jarak dengar langkah lari (sprint) |
| Proximity (lihat) | 120 px / 60 px | Terlihat walau tanpa LOS kalau <120px (pemain biasa) atau <60px (pemain ngumpet) |
| Sniff | 100 px | Bos patroli mencium pemain ngumpet dalam 100px |

Perkalian kecepatan (dari `level_1.gd`): `boss_speed_mult` naik +0,1 per tugas selesai,
+0,3 saat enrage (semua tugas utama selesai), maksimal 1,8. Enrage juga bikin
`teleport_mult` 0,6 (teleport lebih sering). Chase tercepat: 340 × 1,8 = 612.

## Lima state

| State | Enum | Perilaku |
|---|---|---|
| `PATROL` | 0 | Jalan antar waypoint di `PATROL_LOOP` (8 titik). Sampai (<24px) atau timeout 30 dtk → 25% ke ruang bos, sisanya `_pick_waypoint` (waypoint terdekat ke pemain; menjauh saat `post_rescue`). Tiap 5 dtk dicek ulang: kalau waypoint yang dituju >400px dari pemain terdekat, `_pick_waypoint` dipanggil lagi supaya bos tidak jalan jauh melintasi peta sementara pemain kerja sendirian (18 Nov malam, fix kejar-kejaran). Waypoint <50px dilewati. Kalau tidak ada waypoint yang bisa dipakai: urutan berurutan, lalu ruang bos. Sniff: pemain ngumpet dalam 100px → `SUSPICIOUS`. |
| `SUSPICIOUS` | 1 | Berdiri diam ("?"). Setelah 1,5 dtk → `SEARCH`. |
| `CHASE` | 2 | Mengejar pemain ("!"). Re-path tiap 0,4 dtk. Wind-up 0,5 dtk diam dulu. Kalau pemain tidak terlihat, timer hilang jalan; >2,0 dtk → `on_boss_lost` + `SEARCH`. Kalau pemain terlihat, target di-update dan timer hilang di-reset. Setelah 12 dtk mengejar → `on_boss_lost` + `SEARCH`. |
| `SEARCH` | 3 | Mencari di sekitar titik terakhir pemain terlihat ("?"). Timeout: >5 dtk (tanpa target meja) atau >10 dtk → `RETURN` (ruang bos). Desk-check: meja terdekat dalam 300px didatangi (sampai <45px), lalu diam 1,5 dtk. Kalau tidak ada meja: mengorbit titik pencarian (radius 60px, 1,2 rad/dtk, re-path 1,0 dtk, setengah kecepatan). Timeout SEARCH selalu jalan, termasuk saat mendekati meja (fix `9c3a96d`). |
| `RETURN` | 4 | Kembali ke ruang bos (100 × `speed_mult`). >8 dtk → teleport ke tengah ruang bos + `PATROL` + pilih waypoint baru. >3 dtk dan sudah dalam 40px dari ruang bos → `PATROL`. |

Tanda di atas kepala bos (`_refresh_mark`): "?" saat `SUSPICIOUS`/`SEARCH`, "!" saat `CHASE`.

## Transisi legal (LEGAL_TRANSITIONS)

Semua transisi lewat `_change_state` — satu-satunya jalur. Fungsi ini menolak transisi
ke state yang sama dan menolak transisi yang tidak ada di tabel (kecuali `forced=true`).
Setiap transisi yang berhasil memancarkan sinyal `state_changed` dan dicatat di
`state_history` (20 entri terakhir, format `[t] OLD -> NEW`).

| Dari \ Ke | PATROL | SUSPICIOUS | CHASE | SEARCH | RETURN |
|---|---|---|---|---|---|
| PATROL | — | ya | ya | tidak | ya |
| SUSPICIOUS | ya | — | ya | ya | tidak |
| CHASE | ya | tidak | — | ya | tidak |
| SEARCH | ya | tidak | ya | — | ya |
| RETURN | ya | ya | ya | tidak | — |

Transisi paksa (bypass tabel, `forced=true`):
- `_do_teleport` → `PATROL` (setelah teleport).
- `send_back_to_room` → `PATROL` (habis pemain kabur dari sel: teleport ke
  waypoint patroli TERJAUH dari sel, buta 5,0 dtk, `post_rescue` 10,0 dtk,
  path dibersihkan. Sejak 18 Nov malam: bukan lagi ke tengah ruang bos,
  karena ruang bos cuma 70px dari sel dan bos jadi camping di depan sel
  lalu nangkep lagi pemain yang baru kabur, v45).

Satu pengecualian: `level_1.gd` mengatur `state = PATROL` langsung untuk first
encounter (baris ~533). Itu sengaja, bukan lewat `_change_state`.

## Deteksi

Urutan per frame fisika (`_physics_process`): server-only → paused → intro terbuka
(bos beku) → `blind`/`post_rescue` berkurang → telegraph → timer teleport → `state_timer`
→ update state → `_update_detection` → tanda → `move_and_slide` → `_check_catch` →
`_update_stuck` → bob (±2px). Kalau `blind > 0`, deteksi dan tangkap dilewati, tapi
bos tetap bergerak.

### Vision — `_nearest_visible_player`

Pemain terlihat kalau salah satu ini benar:
- Jarak <120px (pemain biasa) atau <60px (pemain ngumpet) — tanpa perlu garis pandang.
- Pemain tidak ngumpet, jarak ≤340px, dan garis pandang (raycast, mask 1, tembok +
  prop menghalangi) bersih.

Yang TIDAK ada: tidak ada syarat senter menyala, tidak ada syarat area terang, tidak
ada cone arah hadap. Gate kegelapan dihapus 18 Nov 2026 (`1dd370d`). Pemain yang
terkunci (`locked`) dilewati. Pemain ngumpet di luar 60px tidak pernah terlihat.

### Hearing — `_nearest_audible_player`

- Pemain terkunci, ngumpet, atau diam (kecepatan <50) dilewati.
- Jarak dengar: 360px kalau sprint, 200px kalau jalan. Tembus tembok.
- Hanya pemain terdekat yang didengar.

### Noise

`report_noise` dari level (buka popup, lempar mug, salah jawab, teriak) masuk antrean
(maks 8). Noise mengarahkan bos yang sedang `PATROL`/`RETURN` ke `SUSPICIOUS` menuju
titik suara. **Keputusan tertunda (18 Nov):** noise saat ini TIDAK mengarahkan ulang
bos yang sedang `SEARCH`; langkah kaki sudah mengarahkan ulang `SEARCH`.

### Alur `_update_detection`

1. Kalau `blind > 0`: tidak ada deteksi.
2. Ada pemain terlihat → `CHASE`.
3. Kalau tidak, ada noise di antrean → `SUSPICIOUS` (hanya dari `PATROL`/`RETURN`).
4. Kalau tidak, ada pemain terdengar → `SUSPICIOUS` (dari `PATROL`/`RETURN`) atau
   refresh titik pencarian (kalau sedang `SEARCH`).

## Teleport

Timer teleport berkurang tiap frame, KECUALI saat `CHASE`: teleport tidak
boleh nyala di tengah kejar-kejaran, karena itu yang memutus chase setelah
~1 detik (18 Nov malam, fix kejar-kejaran). Saat masuk `CHASE`, timer
teleport di-reset acak 14–20 dtk supaya tidak langsung nyala begitu chase
selesai. Saat habis: telegraph 1,0 dtk (bos berkedip),
lalu `_do_teleport`:
- Tujuan dari `level.teleport_destination()`: ±260px di sekitar pemain acak, ≥120px
  dari semua pemain, tidak pernah di Toilet, tidak pernah di ruangan pemain yang
  sedang ngumpet, maks 8 percobaan, fallback tengah ruang bos.
- Tujuan di-snap ke sel walkable terdekat (`level._nearest_walkable`) — 0/40 teleport
  mendarat di tembok (fix GDAS `f868c57`; sebelumnya 14/40 = 35%).
- Setelah teleport: buta 1,5 dtk, timer di-reset acak 14–20 dtk (× `teleport_mult`),
  state paksa ke `PATROL`.

## Ketangkep

`_check_catch` (dilewati kalau `blind > 0` atau pemain `locked`):
- Jarak bos–pemain <40px → `level.on_player_caught`: pemain dipindah ke sel
  (`CELL_POS` (1080,140)), dikunci, popup ditutup.
- Bos kembali ke `PATROL` + `_pick_waypoint` (menjauh) + `post_rescue_timer` = 20,0 dtk.
- Solo: 3x ketangkep = GAME OVER. Co-op: kedua pemain dikurung bersamaan = GAME OVER.

## First encounter (level_1.gd)

Hanya di playthrough pertama (tutorial belum selesai), detik ke-12 sampai ke-40,
tanpa popup/intro terbuka, pemain tidak terkunci:
- Bos diteleport ke (400,656), `slow_mult` 0,5, `blind_timer` 10,0 dtk, state `PATROL`.
- Berakhir kalau pemain ngumpet selagi bos <250px, atau blind habis → `slow_mult`
  kembali 1,0 + grace buta 2,0 dtk.

Spawn grace 30 detik DIHAPUS 18 Nov 2026 (`5d65427`): bos berbahaya sejak detik 0.

## Stuck recovery + steering

- `_update_stuck`: dilewati saat wind-up. Bergerak ≤5px dalam 1,0 dtk tanpa path →
  snap ke tengah sel walkable terdekat. Bergerak ≤5px dalam 1,0 dtk dengan path →
  loncat ke titik path berikutnya + re-path.
- `_steer_to`: kalau path A* kosong, bos jalan lurus ke target (`_move_toward`) —
  tidak diam di tempat (fix `9641c56`). Kalau ada path, ikuti waypoint A* (lanjut
  kalau <16px). `_move_toward` berhenti dalam 4px, velocity di-lerp, `facing` =
  arah gerak (cuma buat visual senter).
- Grid A*: 48×28, sel 32px, diagonal hanya kalau tidak ada halangan. Sel walkable
  yang bersebelahan prop punya weight 5,0 (bos cenderung menghindari). Koridor bawah
  (baris 20) sempit: prop di kolom 17 dan 20 memutus jalur A* di sana — bos masih
  bisa lewat dengan steering lurus, tapi bisa tersangkut sebentar di prop saat
  mengejar lewat koridor itu.

## Riwayat perubahan penting

| Tanggal | Perubahan |
|---|---|
| 17 Nov 2026 | Facing dihapus (`86d96c5`): deteksi omnidirectional + dengar langkah (jalan 200px / lari 360px tembus tembok) |
| 18 Nov 2026 | Gate kegelapan dihapus (`1dd370d`); FSM terpusat lewat `_change_state` + `LEGAL_TRANSITIONS` + `state_history` + sinyal `state_changed`; bos beku saat intro; SEARCH timeout diperbaiki (`9c3a96d`) |
| 18 Nov 2026 | Spawn grace 30 dtk dihapus (`5d65427`) |
| 18 Nov 2026 | Teleport di-snap ke sel walkable (GDAS `f868c57`): 14/40 → 0/40 mendarat di tembok |
| 18 Nov 2026 | Bos bisa nangkap (`9641c56`): chase 240 → 340, wind-up 1,0 → 0,5 dtk, chase tahan 8 → 12 dtk, lost-sight 0,5 → 2,0 dtk, steering lurus kalau A* kosong |
| 18 Nov 2026 | Bos ngejar beneran: teleport tidak nyala selama CHASE (timer di-reset tiap masuk CHASE); patroli retarget tiap 5 dtk ke waypoint dekat pemain; habis pemain kabur dari sel, bos teleport ke waypoint terjauh dari sel (bukan ruang bos) supaya tidak camping di depan sel |

*Terakhir dicek dari kode: 18 Nov 2026, HEAD `9641c56` + fix kejar-kejaran (belum commit).*
