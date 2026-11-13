# Terror Lembur — Progress Report (untuk konsultasi minggu 2)

Tim: Terror Lembur (Pemrograman Gim + Gimersia Inspire 2026)
Tanggal: 14 Nov 2026
Checkpoint: 19 Nov 2026 23:59 WIB | Submit: 29 Nov 2026 23:59 WIB

## Sejauh mana

**Game sudah bisa dimainkan awal sampai akhir (2 pemain LAN dan solo).**

Selesai dan terverifikasi:
- Map 1 lantai kantor, 15 ruangan, 48x28 tile, 141 prop (node asli di scene, bisa dibuka di editor).
- Bos AI: A* pathfinding, 5 state (Patrol, Curiga, Kejar, Nyari, Balik patrol),
  vision cone 260px/70 derajat, pendengaran, teleport 20-30 dtk (telegraph 1 dtk,
  buta 1,5 dtk), nangkep lalu kurung di sel.
- 4 tugas + tuas sel + pintu keluar terkunci. Progress tugas persist kalau ke-interupsi.
- Mekanik: ngumpet (28 spot), senter, teriak, lempar mug, sprint + stamina.
- Mode solo (baru, 14 Nov): semua tugas bisa dikerjakan sendiri (2x waktu),
  self-rescue dari sel (tahan E 15 dtk, berisik), ketangkep 3x = game over,
  bos 0,9x kecepatan di solo. Test headless 8/8 lulus.
- Sprite bos: Nasha Pale Figure (bukan AI), sudah terpasang dan terverifikasi di render in-game.
  Tanda status bos ("?" / "!") terverifikasi muncul di atas kepala bos.
- Flow fix (baru, 14 Nov): bos marah pas pintu keluar kebuka (+0,3 kecepatan,
  teleport 0,6x cooldown). Teleport tidak pernah mendarat dalam 150px dari pemain.
  Test headless 3/3 lulus.
- HUD, menu, layar akhir (Happy / Pahit / Game Over, 1-3 bintang).
- Dokumen: one-pager (2 halaman A4), KONSEP.md sudah diupdate ke tema Pulang +
  hantu bos lama, DESIGN.md (MDA, core loop, art keywords, grayscale test lulus).

## Kesulitan

1. **Kurator main sendirian, game tadinya cuma 2 pemain LAN.** Ini blocker terbesar.
   Solusi: mode solo single-player murni (sudah jadi dan dites).
2. **Sprite bos yang bagus dan bukan AI.** Mourncrest Wraith (pilihan pertama) ternyata
   AI-generated dan dilarang Gimersia. Solusi: Nasha Pale Figure (gratis, bukan AI).
3. **Belum ada build WebGL, halaman itch.io, video gameplay.** Ini target minggu ini.
4. **Belum ada playtest orang luar.** Tim belum sempat. Rencana: playtest setelah
   build WebGL jadi, sebelum 19 Nov.
5. **ENet/LAN belum bisa dites di sandbox** (UDP diblokir). Tes LAN 2 PC harus di PC asli.
   Fallback: join manual pakai IP.

## Yang dibutuhkan

- **Keputusan tim:** tidak ada yang pending saat ini. Mode solo (A) dan sprite bos
  (Pale Figure) sudah diputuskan Elang 14 Nov 2026.
- **Dari mentor (Kris):** review one-pager + progress ini. Apakah scope-nya sudah
  cukup ramping buat 15 hari? Apakah ada risiko yang kami lewatkan?
- **Akses:** halaman itch.io butuh login Elang sendiri (tidak bisa diwakilkan).
  Push ke GitHub butuh token Elang (dipakai sekali, tidak disimpan).

## Rencana minggu 2 (17-20 Nov)
- Build WebGL + tes di browser.
- Halaman itch.io + screenshot + paragraf progres (checkpoint 19 Nov).
- Video gameplay 60 detik - 2 menit.
- Playtest orang luar, perbaiki yang ketemu.

## Rencana minggu 3 (24-29 Nov)
- Polish (bukan fitur baru): grayscale sudah lulus, perbaiki bug yang ketemu di playtest.
- 3 screenshot + deskripsi + cara bermain + deklarasi aset + surat pernyataan.
- Submit 29 Nov 23:59 WIB.
