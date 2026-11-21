# Tes headless

Semua tes di `tools/test_*.gd` jalan tanpa jendela, tanpa aset suara nyata:

```bash
tools/run_tests.sh        # default 60 fps
tools/run_tests.sh 10     # fps lain
```

## Aturan: durasi dalam detik, bukan frame

Dulu tes menghitung frame sambil menganggap jalannya 10 fps ("20 frame ~ 2
detik"). Akibatnya di 60 fps sembilan tes gagal padahal kodenya benar: 20
frame cuma 0,33 detik, jadi stamina belum terkuras dan timer bos belum habis.

Sekarang semua tunggu-menunggu lewat `tools/tlib.gd`:

```gdscript
var tl = preload("res://tools/tlib.gd").new()
await tl.wait(self, 2.0)   # 2 detik game time, fps berapa pun
```

Waktu game diambil dari `get_process_delta_time()`, jadi hasilnya sama di 10,
60, atau 144 fps. Kalau ada tes yang hijau di satu fps tapi merah di fps lain,
itu berarti ada kode game yang masih bergantung frame — bukan tesnya yang
salah.

## Hasil terakhir

`FULL60 pass=50 fail=0` dan `pass=50 fail=0` di 10 fps, dijalankan di VM
Ubuntu 24.04 (Godot 4.7.2 headless).

Yang tidak tercakup tes: suara sungguhan (VM tanpa ALSA, Godot pakai driver
dummy) dan sesi LAN dua pemain (butuh dua proses).
