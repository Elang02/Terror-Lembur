# Level 1 versi TileMap — Revisi 3 (bisa diedit di editor)

`scenes/level_1.tscn` sekarang memakai **TileSet baru** yang dirakit dari
3 pack asli itch.io. Semua tile sudah "dicat" di `TileMapLayer`, jadi map
bisa diubah langsung pakai kuas TileMap di Godot, tanpa menjalankan script.

![Desain](desain_map_level1.png)

Preview polos tanpa penanda: `map_preview_tilemap.png`.

Versi lama disimpan di `scenes/level_1_lama.tscn`.

> ⚠️ Jangan jalankan `tools/build_level_1.tscn` / `build_level_1.gd` (generator
> lama), karena akan **menimpa** `level_1.tscn` dengan map lama.

## Struktur scene

```
Level1 (Node2D, level_1.gd)
├── CanvasModulate
├── Floor          (TileMapLayer, z -10)  lantai, tanpa collision
├── Walls          (TileMapLayer, z -5)   dinding, ada collision
├── DekorDinding   (TileMapLayer, z -4)   jam, jendela, whiteboard, CCTV (tanpa collision)
├── Props          (TileMapLayer, z 5)    furnitur, ada collision
├── DekorKecil     (TileMapLayer, z 6)    laptop, mug, kertas di meja & lantai (tanpa collision)
├── Labels         (Label nama ruangan)
├── Lights         (PointLight2D)
├── Spawns         (Marker2D: PlayerSpawn1-2, EnemySpawn1-8, Patrol1-8, Revive1-8)
├── Tasks          (7 TaskStation)
├── HidingSpots    (22 HidingSpot)
├── Doors          (DoorA, DoorB)
├── ExitDoor, Cage, ReviveItem, Players, Enemy, HUD
```

Nama node `Floor`, `Walls`, `Props`, `Tasks`, `Spawns`, dst. **jangan diganti**,
karena `level_1.gd` mencarinya berdasarkan nama.

## TileSet: `assets/tiles/lembur/tileset_lembur.tres`

| Source | Gambar | Isi |
|---|---|---|
| 0 – Dinding (Imersa) | `dinding_lembur.png` | Dinding 3/4 view (tutup, muka, vertikal, ujung, sudut) |
| 1 – Lantai | `lantai_lembur.png` | 8 lantai: kayu, karpet abu, ubin terang, karpet rapat, ubin krem, ubin putih, karpet biru, kayu gelap |
| 2 – Props / Furnitur | `props_lembur.png` | Furnitur dipotong per kotak 32×32. Lihat `katalog_props_lembur.png` |

Physics layer 0 = collision layer 1 ("World"), sama seperti sebelumnya.

## Aturan penting waktu mengedit

1. **Musuh (pathfinding) membaca tile.** Cell bisa dilewati kalau ada
   tile di `Floor` dan **tidak** ada tile di `Walls` maupun `Props`.
   Jadi setiap furnitur yang kamu taruh di `Props` otomatis jadi
   penghalang. Dekorasi tembok sebaiknya di `DekorDinding`, dan barang kecil yang boleh dilewati (kertas, mug) di `DekorKecil`.
2. **Furnitur besar = beberapa tile.** Di panel TileMap, drag-pilih
   seluruh kotak furnitur di atlas (misalnya sofa 3×2), lalu cat sekaligus.
3. **Dinding lurus dari atas ke bawah ruangan** dibuat 2 baris (baris
   tutup abu-abu + baris muka terang). Dinding vertikal 1 kolom.
4. **Pintu terkunci** (`DoorA`, `DoorB`) memakai `door_cells` di Inspector.
   Kalau dipindah, isi juga koordinat cell barunya di sana.
5. Setelah mengubah map, pastikan semua ruangan tetap bisa dicapai
   **walaupun pintu A/B tertutup** (pintu itu hanya jalan pintas).

## Rumus posisi (kalau mau memindah node)

posisi piksel = (kolom × 32 + 16, baris × 32 + 16) untuk tengah cell.
Ukuran map: 64 × 40 cell (2048 × 1280 px). Area hitam di pojok atas = luar gedung (tidak ada lantai).
