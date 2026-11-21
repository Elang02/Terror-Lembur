#!/usr/bin/env bash
# Jalankan seluruh tes headless dan cetak ringkasan.
#
# Pemakaian:
#   tools/run_tests.sh            # 60 fps (default, sama seperti game jalan)
#   tools/run_tests.sh 10         # 10 fps
#   tools/run_tests.sh 144        # pakai fps lain
#
# Tes ditulis dengan durasi DETIK (lihat tools/tlib.gd), jadi hasilnya harus
# sama di fps berapa pun. Kalau ada yang gagal cuma di satu fps, itu tanda
# ada kode game yang masih bergantung frame.
set -u
GODOT="${GODOT:-/opt/godot/godot}"
FPS="${1:-60}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

pass=0
fail=0
failed=""

for f in tools/test_*.gd; do
	[ -e "$f" ] || continue
	name="$(basename "$f" .gd)"
	out="$(timeout 240 "$GODOT" --headless --path "$ROOT" --fixed-fps "$FPS" -s "res://$f" 2>&1)"
	if printf '%s\n' "$out" | grep -q 'TEST FAIL'; then
		fail=$((fail + 1))
		failed="$failed $name"
		printf 'FAIL %s\n' "$name"
		printf '%s\n' "$out" | grep 'TEST FAIL' | sed 's/\x1b\[[0-9;]*m//g' | sed 's/^/    /'
	else
		pass=$((pass + 1))
	fi
done

printf '\nSUMMARY fps=%s pass=%d fail=%d%s\n' "$FPS" "$pass" "$fail" "${failed:+ failed:$failed}"
[ "$fail" -eq 0 ]
