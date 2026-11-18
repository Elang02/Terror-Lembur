extends SceneTree

# Reproduksi: bos SEARCH ke meja, nyangkut di pinggir meja, diam dengan "?"
# selamanya karena timeout SEARCH tidak jalan saat lagi jalan ke meja.
# Meja (320,320): sel jalan diagonal terdekatnya 68px dari tengah meja,
# sementara syarat "sampai" cuma 45px.

var lvl: Node2D
var boss: Node2D
var me: Node
var passes := 0
var fails := 0

func ok(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		passes += 1
		print("TEST OK: " + name)
	else:
		fails += 1
		print("TEST FAIL: " + name + " " + detail)

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _run() -> void:
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	lvl.call("_dismiss_intro")
	boss = lvl.get("boss")
	if boss == null:
		print("TEST FAIL: boss node missing")
		quit()
		return
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	me = pscene.instantiate()
	me.name = "1"
	lvl.get("ysort").add_child(me)
	await process_frame
	await process_frame
	me.global_position = Vector2(740, 760)
	# Cari meja yang sel jalan diagonal terdekatnya paling jauh dari tengah.
	var desks: Array = lvl.get("desk_positions")
	var worst_d := Vector2.ZERO
	var worst_cell := Vector2.ZERO
	var worst := 0.0
	for d in desks:
		var dc := Vector2i(int(d.x / 32.0), int(d.y / 32.0))
		for ox in [-1, 1]:
			for oy in [-1, 1]:
				var cell := Vector2i(dc.x + ox, dc.y + oy)
				var w: Vector2i = lvl.call("_nearest_walkable", cell)
				if w != cell:
					continue
				var cc := Vector2(cell.x * 32 + 16, cell.y * 32 + 16)
				var dist := cc.distance_to(d)
				if dist > worst:
					worst = dist
					worst_d = d
					worst_cell = cc
	print("SEARCHDESK worst desk=" + str(worst_d) + " cell=" + str(worst_cell) + " dist=" + str(snappedf(worst, 1.0)))
	boss.set("teleport_timer", 99999.0)
	boss.set("blind_timer", 999.0)
	boss.set("slow_mult", 1.0)
	boss.global_position = worst_cell
	boss.set("path", PackedVector2Array())
	boss.set("state", 3)
	boss.set("state_timer", 0.0)
	boss.set("search_center", worst_d)
	boss.set("search_desk_target", worst_d)
	boss.set("search_desk_checked", true)
	boss.set("search_desk_pause", 0.0)
	# Path sengaja dikosongkan: ini keadaan yang terjadi di game nyata saat
	# stuck recovery mengosongkan path sesudah bos kejebak di pinggir meja.
	# Sebelum perbaikan, bos diam selamanya di SEARCH dengan tanda "?".
	var start_pos: Vector2 = boss.global_position
	var min_desk := 1e9
	var frames := 0
	while frames < 1500:
		await process_frame
		frames += 1
		var nd := boss.global_position.distance_to(worst_d)
		if nd < min_desk:
			min_desk = nd
		if float(lvl.get("elapsed")) > 13.0:
			break
	var end_state: int = boss.get("state")
	var end_target: Vector2 = boss.get("search_desk_target")
	var moved := boss.global_position.distance_to(start_pos)
	print("SEARCHDESK end_state=" + str(end_state) + " target_cleared=" + str(end_target == Vector2.ZERO) + " min_desk=" + str(snappedf(min_desk, 1.0)) + " moved=" + str(snappedf(moved, 1.0)) + " elapsed=" + str(snappedf(float(lvl.get("elapsed")), 1.0)))
	ok("boss leaves SEARCH within 13s (not stuck at desk with '?')", end_state != 3, "state=" + str(end_state) + " target=" + str(end_target))
	ok("boss got close to the desk (min dist <= 70px)", min_desk <= 70.0, "min_desk=" + str(snappedf(min_desk, 1.0)))
	print("=== SEARCHDESK TEST: " + str(passes) + " passed, " + str(fails) + " failed ===")
	quit()
