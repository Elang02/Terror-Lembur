extends RefCounted
## Helper durasi untuk seluruh suite tes.
##
## Kenapa ada: tes-tes ini dulu menghitung FRAME sambil menganggap
## jalannya 10 fps ("20 frame ~ 2 detik"). Begitu dijalankan di 60 fps,
## 20 frame cuma 0,33 detik, jadi tes gagal padahal gamenya benar — dan
## sebaliknya, bug yang cuma muncul di fps tinggi bisa lolos.
##
## Aturan: tulis durasi dalam DETIK. Satu detik game time sama di fps
## berapa pun, jadi hasil tes tidak lagi bergantung pada mesin.

## Tunggu `seconds` detik waktu game.
func wait(tree: SceneTree, seconds: float) -> void:
	var acc := 0.0
	while acc < seconds:
		await tree.process_frame
		acc += tree.root.get_process_delta_time()
