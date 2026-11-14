#!/bin/bash
# record_demo.sh - Records a demo gameplay video with audio.
# Stops automatically a few seconds after the game ends (DEMO_END marker
# in the Godot log), so the video does not keep going after the stars.
# Usage: ./tools/record_demo.sh <output.mp4> [max_seconds]
set -u
VIDEO="${1:?usage: record_demo.sh <output.mp4> [max_seconds]}"
MAX_SECS="${2:-240}"
LOG=/tmp/demo_record.log
GODOT=~/workspace/tools/godot/Godot_v4.7-stable_linux.x86_64
REPO=/home/hatch/workspace/terror-lembur-repo
rm -f ~/.local/share/godot/app_userdata/Terror_Lembur/tutorial.cfg
rm -f "$LOG"
export PATH="$HOME/workspace/tools/git-lfs:$PATH"
(DISPLAY=:133 "$GODOT" --audio-driver PulseAudio --path "$REPO" -- --demo > "$LOG" 2>&1 &
echo $! > /tmp/demo_godot.pid)
sleep 2
(ffmpeg -y -f x11grab -video_size 1280x720 -framerate 30 -i :133 \
  -f pulse -i game_out.monitor -c:v libx264 -pix_fmt yuv420p -crf 23 \
  -c:a aac -b:a 128k "$VIDEO" > /tmp/ffmpeg_record.log 2>&1 &
echo $! > /tmp/demo_ffmpeg.pid)
GODOT_PID=$(cat /tmp/demo_godot.pid)
FFMPEG_PID=$(cat /tmp/demo_ffmpeg.pid)
echo "recording $VIDEO (godot $GODOT_PID, ffmpeg $FFMPEG_PID)"
for i in $(seq 1 "$MAX_SECS"); do
  if grep -q "DEMO_END" "$LOG" 2>/dev/null; then
    echo "game ended, keeping 5s of the end screen..."
    sleep 5
    kill "$FFMPEG_PID" 2>/dev/null
    kill "$GODOT_PID" 2>/dev/null
    echo "recording stopped, video: $VIDEO"
    exit 0
  fi
  if ! kill -0 "$GODOT_PID" 2>/dev/null; then
    echo "godot exited early, stopping ffmpeg"
    kill "$FFMPEG_PID" 2>/dev/null
    exit 0
  fi
  sleep 1
done
echo "timeout (${MAX_SECS}s), stopping recording"
kill "$FFMPEG_PID" 2>/dev/null
kill "$GODOT_PID" 2>/dev/null
exit 0
