extends SceneTree

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

func _nearest_desk_dist(p: Vector2) -> float:
	var best := 1e9
	for n in get_nodes_in_group("hide_spot"):
		var d := (n as Node2D).global_position.distance_to(p)
		if d < best:
			best = d
	return best

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
	me.global_position = Vector2(400, 400)
	var spot: Vector2 = lvl.get("FIRST_ENCOUNTER_SPOT")
	ok("first encounter spot is open (nearest desk >= 80px)", _nearest_desk_dist(spot) >= 80.0, "nearest=" + str(snappedf(_nearest_desk_dist(spot), 1.0)))
	boss.set("teleport_timer", 99999.0)
	boss.global_position = spot
	boss.set("path", PackedVector2Array())
	boss.set("slow_mult", 0.5)
	boss.set("blind_timer", 999.0)
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.call("_pick_waypoint")
	var last_pos: Vector2 = boss.global_position
	var samples := 0
	var stall_windows := 0
	var min_step := 1e9
	var min_desk := 1e9
	var max_desk_close := 0
	var start_pos: Vector2 = boss.global_position
	var furthest := 0.0
	var scanned_this_window := false
	while samples < 600:
		await process_frame
		samples += 1
		if float(boss.get("scan_timer")) > 0.0:
			scanned_this_window = true
		if samples % 30 == 0:
			var p: Vector2 = boss.global_position
			var step := p.distance_to(last_pos)
			var nd := _nearest_desk_dist(p)
			if not scanned_this_window:
				if step < min_step:
					min_step = step
				if step < 5.0:
					stall_windows += 1
			scanned_this_window = false
			if nd < min_desk:
				min_desk = nd
			if nd < 45.0:
				max_desk_close += 1
			var d0 := p.distance_to(start_pos)
			if d0 > furthest:
				furthest = d0
			last_pos = p
		if float(lvl.get("elapsed")) > 45.0:
			break
	ok("boss never stalls after first encounter teleport (0 stall windows)", stall_windows == 0, "stall_windows=" + str(stall_windows))
	ok("boss keeps moving (min 30-frame step >= 20px)", min_step >= 20.0, "min_step=" + str(snappedf(min_step, 1.0)))
	ok("boss travels away from the teleport spot (>= 300px)", furthest >= 300.0, "furthest=" + str(snappedf(furthest, 1.0)))
	ok("boss never clips through a desk (min desk distance >= 35px)", min_desk >= 35.0, "min_desk=" + str(snappedf(min_desk, 1.0)) + " close_windows(<45px)=" + str(max_desk_close))
	print("BOSS_DESK min_step=" + str(snappedf(min_step, 1.0)) + " min_desk=" + str(snappedf(min_desk, 1.0)) + " furthest=" + str(snappedf(furthest, 1.0)) + " stall_windows=" + str(stall_windows))
	print("=== BOSS_DESK TEST: " + str(passes) + " passed, " + str(fails) + " failed ===")
	quit()
