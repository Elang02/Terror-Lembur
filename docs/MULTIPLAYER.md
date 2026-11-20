# Multiplayer 2 PC — Terror Lembur

Transport: **ENet (UDP), port 7777**, maksimal 2 peer.
Arsitektur: **host otoritatif** (PC 1). Host menjalankan AI enemy,
progress tugas, pintu, kurungan, dan ending. Client mengirim niat
(tekan/lepas E); host memvalidasi dan menyebar hasilnya via RPC.
Posisi pemain/enemy disinkronkan 20 Hz (RPC unreliable + lerp).

## Cara main 2 PC

1. Kedua PC di **Wi-Fi/LAN yang sama**.
2. Di PC 1 (host): jalankan game → **Buat Game (Host)**.
3. Cari **IP LAN PC 1**:
   - Windows: `ipconfig` di Command Prompt → IPv4 Address
     (biasanya `192.168.x.x`).
   - macOS/Linux: `ip addr` / `ifconfig`.
4. Di PC 2: jalankan game → isi **IP Host** dengan IP LAN PC 1 →
   **Gabung Game (Join)**.
5. Kalau gagal terhubung:
   - Pastikan host sudah menekan Buat Game **sebelum** client Join.
   - Matikan VPN di kedua PC (VPN sering memisahkan LAN).
   - Izinkan Godot/game lewat **Windows Firewall** (izinkan UDP 7777,
     jaringan Private). Firewall adalah penyebab gagal paling umum.
   - Coba `ping <IP host>` dari PC 2. Kalau ping gagal, masalahnya
     jaringan, bukan game.
   - Router dengan "AP isolation" / "client isolation" aktif akan
     memblokir antar-perangkat — matikan di pengaturan router, atau
     pakai hotspot dari salah satu PC/HP sebagai jaringan bersama.

## Tes 2 pemain di 1 PC

Jalankan game 2 kali (2 window/editor): window 1 Host, window 2 Join
ke `127.0.0.1`. Bisa juga export 2 build dan jalankan berdampingan.
Catatan: menjalankan dari editor 2 kali butuh 2 instance editor / 1
editor + 1 build.

## Perilaku penting

- **POV per pemain**: tiap PC menampilkan kameranya sendiri (Camera2D
  hanya aktif untuk pemain lokal). Tidak ada split-screen.
- **Terputus di tengah level**: game dijeda + panel "Partner terputus"
  muncul. Kembali ke Menu Utama untuk main lagi. Tidak ada reconnect
  otomatis di base ini.
- **Join terlambat**: client yang masuk level meminta sinkronisasi
  penuh ke host (`request_sync_rpc`) — pemain, tugas, pintu, posisi
  enemy, kurungan, dan item bangkit disamakan. Bergabung di tengah
  level yang sudah berjalan didukung, tapi tidak diuji intensif.
- **Solo**: mode tes 1 pemain (tanpa peer). Pintu keluar bisa dibuka
  sendiri, kurungan terbuka otomatis setelah 12 detik. Bintang solo
  tetap tercatat — bedakan dengan run co-op saat menyeimbangkan.
- **Keamanan**: tidak ada anti-cheat. Client dipercaya untuk posisi
  pemainnya sendiri (otoritas per pemain). Cukup untuk main bareng
  teman di LAN; jangan dipakai untuk server publik tanpa validasi
  tambahan (lihat skill `godot-multiplayer-networking` di GDAS).

## File terkait

- `scripts/autoloads/network_manager.gd` — peer ENet, mode SOLO/HOST/
  CLIENT, sinyal peer join/leave.
- `scripts/level_1.gd` — otoritas state + semua RPC game
  (`request_sync_rpc`, `request_press_rpc`, `_task_completed_rpc`,
  `_player_downed_rpc`, `_level_finished_rpc`, dll).
- `scripts/player.gd` / `scripts/enemy.gd` — sinkronisasi posisi
  (`_sync_state` / `_sync_enemy`, unreliable 20 Hz).
- `scripts/main_menu.gd` — alur Host/Join/Solo + timeout koneksi 5 dtk.
- `tests/net_test.gd` + `tests/net_checker.gd` — uji headless host/client
  (butuh socket UDP yang tidak diblokir sandbox).
