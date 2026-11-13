#!/bin/bash
# Build Terror-Lembur.zip from the repo. MUST include every root file the
# game loads at runtime (esp. office_tileset.tres) + .godot from --import.
set -e
REPO=~/workspace/terror-lembur-repo
OUT=~/workspace/user/files/Terror-Lembur.zip
STAGE=/tmp/terror-zip-stage
rm -rf "$STAGE"
mkdir -p "$STAGE/Terror-Lembur"
cd "$REPO"
cp -r project.godot icon.svg office_tileset.tres CREDITS.md scenes scripts assets tools "$STAGE/Terror-Lembur/"
cd "$STAGE/Terror-Lembur"
~/workspace/tools/godot/Godot_v4.7-stable_linux.x86_64 --headless --path . --import > /dev/null 2>&1
cd "$STAGE"
rm -f "$OUT"
zip -qr "$OUT" Terror-Lembur
echo "built $OUT"
unzip -l "$OUT" | grep -E "office_tileset.tres|project.godot" 
ls -lh "$OUT"
