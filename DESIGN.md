# DESIGN.md — Terror Lembur UI

## Direction contract (UI task + layar hasil)

THESIS: UI-nya kertas kerja lembur, bukan panel game generik. Satu dunia:
meja kantor malam hari, lampu amber, formulir dan stempel. Yang ditolak:
panel abu-abu default Godot, teks kuning di tengah, bintang unicode,
tombol default.

OWN-WORLD: dasar gelap hangat #14110D, garis rambut #3A342C, tinta kertas
#ECE5D8, abu hangat #9A917F, satu aksen amber #E8A33D (lampu kerja),
hijau sage #8FB573 untuk berhasil, merah bata #C0452F untuk gagal.
Judul: Noto Sans Display ExtraCondensed Bold, huruf besar. Data dan
label: DejaVu Sans Mono. Sudut kotak, tanpa bayangan, tanpa gradasi.
Penilaian 0-3 digambar sebagai tiga kotak, bukan bintang unicode.

STORY: pemain yang sedang mengerjakan tugas melihat lembar kerja yang
jelas: nama tugas, instruksi, progres, status. Di akhir, pemain membaca
penilaian shift-nya seperti lembar evaluasi: waktu, tertangkap, tugas,
penilaian, lalu dua aksi.

FIRST VIEWPORT: popup tugas 640x470 di tengah layar yang digelapkan;
judul besar di atas, garis rambut, instruksi rata kiri, area game,
status dengan kotak penanda, bar progres tipis + persen mono, petunjuk
bawah dua sisi. Layar hasil: panel 640 di tengah layar gelap; judul
besar, garis rambut, tiga baris statistik beraturan, baris penilaian
kotak, dua tombol aksi.

FORM: direction ini dipilih langsung dari brief Elang ("ubah UI-nya aja,
biar ga AI slop, pake impeccable") + dunia game-nya sendiri; seed: none
(pinned).

FINISH: unreviewed and undocumented is unfinished; this build ends with
the finish review, the verdict, DESIGN.md, and every shipping raster
carrying its provenance.
