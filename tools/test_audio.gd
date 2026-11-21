extends SceneTree
## Semua efek suara harus benar-benar berbunyi.
##
## VM build tidak punya ALSA, jadi tes ini tidak memutar audio: ia membaca
## data PCM yang dihasilkan scripts/sfx.gd. Kalau ada suara yang keluar
## sebagai array nol (peak 0), gamenya jadi bisu di bagian itu dan tidak ada
## tes lain yang menangkapnya.

const EXPECTED := [
	"heartbeat", "tick", "complete", "sting", "whisper", "alarm",
	"thud", "pickup", "shout", "step", "hide",
]

var failed := 0

func _fail(msg: String) -> void:
	failed += 1
	print("TEST FAIL: " + msg)

func _ok(msg: String) -> void:
	print("TEST OK: " + msg)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var sfx = load("res://scripts/sfx.gd").new()
	root.add_child(sfx)
	await process_frame
	var streams: Dictionary = sfx.get("_streams")

	var missing: Array[String] = []
	for name in EXPECTED:
		if not streams.has(name):
			missing.append(name)
	if missing.is_empty():
		_ok("all " + str(EXPECTED.size()) + " sound effects are built")
	else:
		_fail("missing sound effects: " + str(missing))

	var silent: Array[String] = []
	var short: Array[String] = []
	var quiet_db: Array[String] = []
	for name in streams.keys():
		var wav := streams[name] as AudioStreamWAV
		if wav == null:
			_fail(str(name) + " is not an AudioStreamWAV")
			continue
		var bytes: PackedByteArray = wav.data
		if bytes.size() < 200:
			short.append(str(name) + " (" + str(bytes.size()) + " bytes)")
			continue
		# FORMAT_16_BITS: peak amplitude dari sampel 16-bit signed.
		var peak := 0
		var i := 0
		while i + 1 < bytes.size():
			var s := bytes.decode_s16(i)
			peak = maxi(peak, absi(s))
			i += 2
		if peak == 0:
			silent.append(str(name))
		elif peak < 1000:
			quiet_db.append(str(name) + " peak=" + str(peak))

	if silent.is_empty():
		_ok("no silent stream (every effect has non-zero PCM)")
	else:
		_fail("silent streams: " + str(silent))
	if short.is_empty():
		_ok("every stream is longer than a blip")
	else:
		_fail("streams too short: " + str(short))
	if quiet_db.is_empty():
		_ok("every stream peaks above -30 dBFS")
	else:
		_fail("streams too quiet: " + str(quiet_db))

	# Mix rate dan format dipakai player; kalau salah, suara jadi chipmunk.
	var hb := streams.get("heartbeat") as AudioStreamWAV
	if hb != null and hb.mix_rate == 22050 and hb.format == AudioStreamWAV.FORMAT_16_BITS:
		_ok("streams are 22050 Hz 16-bit mono")
	else:
		_fail("unexpected stream format: " + str(hb))

	print("=== AUDIO TEST: failed=" + str(failed) + " ===")
	quit(0 if failed == 0 else 1)
