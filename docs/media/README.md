# Media submission

Tangkapan layar dan rekaman diambil dari build Linux di VM Ubuntu 24.04
(Godot 4.7.2, Xvfb 1280x720, ffmpeg x11grab).

- `play1.png` — HUD lengkap: daftar tugas 0/5, timer, peringatan "BOS MENGEJAR",
  kerucut lampu bos, prompt "C: ngumpet di bawah meja".
- `play2.png`, `play3.png` — variasi ruangan saat senter menyala.
- `intro.png` — layar cerita sebelum lantai 1 dimulai.
- `demo.mp4` — 42 detik, 1280x720 25 fps, H.264, tanpa audio (VM tidak punya ALSA).

Cara ambil ulang: unit `godot-demo.service` menyalakan `Xvfb :0` + game,
lalu `ffmpeg -f x11grab -video_size 1280x720 -i :0` untuk still/video.
