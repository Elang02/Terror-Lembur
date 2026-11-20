# Aset itch.io — sudah terpasang

Art placeholder sudah diganti dengan tiga paket itch.io (lihat
`../../CREDITS.md` untuk kredit & lisensi). Yang terpasang:

| Bagian | Sumber | File di project |
|---|---|---|
| Lantai, dinding, meja rapat, tanaman, rak server | Imersa Free (32px) | `assets/tiles/office_atlas.png` |
| Ubin, lantai server, meja+monitor, rak, sofa, boks, counter | RubberStudio (16px, upscale 2×) | `assets/tiles/office_atlas.png` |
| Karakter pemain & enemy (idle/jalan 4 arah) | Imersa Free | `assets/characters/office_worker/` |
| Dekorasi overlay (kulkas, fotokopi, UPS, tower, palem, partisi) | nacl1234 (diskala ke tinggi 56px) | `assets/decor/` |

Paket asli (file unduhan itch.io) TIDAK disertakan di project —
hanya art yang sudah terpasang. Unduh paket asli dari halaman
itch.io masing-masing kalau mau mengambil potongan lain.

## Cara mengubah atlas

Atlas dibangun oleh script `tools/build_office_atlas.py` (di luar
project). Index cell-nya sama dengan atlas placeholder lama (8×2),
jadi grid, TileSet, dan collision tidak berubah. Setelah mengubah
script/atlas:

```bash
godot --headless --import
godot --headless res://tools/build_level_1.tscn
```

## Cara menambah dekorasi

Dekorasi overlay TIDAK punya collision dan harus menempel di cell
prop yang sudah solid (supaya tidak mengubah pathfinding). Tambahkan
entri di `decor_defs` pada `tools/build_level_1.gd`, lalu jalankan
generator seperti di atas.

## Cara mengganti karakter

`scenes/player.tscn` dan `scenes/enemy.tscn` memakai `AnimatedSprite2D`
dengan `SpriteFrames` Imersa (animasi `idle_*` / `walk_*` 4 arah).
P2 dibedakan lewat tint di `scripts/player.gd` (`_base_tint`), enemy
lewat tint gelap di `scripts/enemy.gd`. Untuk karakter lain, ganti
`sprite_frames` di scene dengan `.tres` yang animasinya bernama sama.

## Uji ulang

Setelah mengubah art, jalankan dari editor (F5) dan smoke test:

```bash
godot --headless --path . res://tests/smoke_test.tscn
```

Smoke test memeriksa jumlah tile per layer (2504 / 445 / 308) — kalau
kamu menambah/mengurangi tile saat merapikan, sesuaikan angka yang
diharapkan di `tests/smoke_test.gd` dengan jumlah barumu.
