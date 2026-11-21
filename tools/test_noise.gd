extends SceneTree
## Bunyi yang basi tidak boleh memancing bos.
##
## Dulu noise_queue cuma dibatasi jumlahnya (8), tanpa umur. Suara generator
## dari 30 detik lalu tetap di antrean, dan begitu bos masuk radiusnya ia
## berjalan ke ruangan yang sudah kosong. Sekarang bunyi kedaluwarsa 10 detik.

var lvl: Node2D
var failed := 0

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _fail(msg: String) -> void:
	failed += 1
	print("TEST FAIL: " + msg)

func _ok(msg: String) -> void:
	print("TEST OK: " + msg)

func _run() -> void:
	var tl = preload("res://tools/tlib.gd").new()
	await tl.wait(self, 0.5)
	lvl.set_solo_mode(true)

	var boss: Node2D = lvl.get("boss")

	# 1. Bunyi baru langsung bisa dipakai (bos harus dalam radius bunyi).
	lvl.set("noise_queue", [])
	boss.global_position = Vector2(400, 700)
	lvl.report_noise(Vector2(400, 656), 400.0)
	var fresh: Vector2 = lvl.consume_noise()
	if fresh == Vector2(400, 656):
		_ok("fresh noise is consumed at its position")
	else:
		_fail("fresh noise not consumed: " + str(fresh))

	# 2. Bunyi yang lebih tua dari NOISE_TTL dibuang, bukan disimpan.
	boss.global_position = Vector2(736, 430)
	lvl.report_noise(Vector2(736, 400), 400.0)
	# NOISE_TTL = 10 detik (const di scripts/level_1.gd).
	await tl.wait(self, 11.0)
	var stale: Vector2 = lvl.consume_noise()
	if stale == Vector2.ZERO:
		_ok("noise older than 10s expires instead of luring the boss")
	else:
		_fail("stale noise still lures the boss: " + str(stale))

	# 3. Setelah bunyi lama dibuang, bunyi baru tetap jalan.
	boss.global_position = Vector2(190, 600)
	lvl.report_noise(Vector2(190, 560), 400.0)
	var again: Vector2 = lvl.consume_noise()
	if again == Vector2(190, 560):
		_ok("noise reported after the expiry still works")
	else:
		_fail("noise after expiry not consumed: " + str(again))

	print("=== NOISE TEST: " + str(3 - failed) + " passed, " + str(failed) + " failed ===")
	quit(0 if failed == 0 else 1)
