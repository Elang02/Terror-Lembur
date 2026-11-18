extends SceneTree

# Teleport bos harus mendarat di sel yang bisa dilewati. teleport_destination
# di level memilih titik acak +-260px dari pemain tanpa mengecek A*: titik
# itu bisa jatuh di dalam tembok/prop, lalu bos diam ~2,5 dtk (blind 1,5 dtk
# + stuck recovery 1 dtk) sebelum snap ke sel terdekat.

var lvl: Node2D
var boss: Node2D
var me: Node
var passes := 0
var fails := 0

func ok(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		passes += 1
		print("TEST OK: " + test_name)
	else:
		fails += 1
		print("TEST FAIL: " + test_name + " " + detail)

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
		quit(1)
		return
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	me = pscene.instantiate()
	me.name = "1"
	lvl.get("ysort").add_child(me)
	await process_frame
	await process_frame
	var astar: AStarGrid2D = lvl.get("astar")
	if astar == null:
		print("TEST FAIL: astar missing")
		quit(1)
		return
	var solid_landings := 0
	var tries := 0
	var min_player_dist := 1e9
	for i in 40:
		me.set("locked", false)
		me.global_position = Vector2(400, 656)
		me.set("hiding", false)
		boss.call("_do_teleport")
		var cell := Vector2i(int(boss.global_position.x / 32.0), int(boss.global_position.y / 32.0))
		if astar.is_point_solid(cell):
			solid_landings += 1
		tries += 1
		var d := boss.global_position.distance_to(me.global_position)
		if d < min_player_dist:
			min_player_dist = d
		boss.set("teleport_timer", 99999.0)
		boss.set("blind_timer", 0.0)
		await process_frame
	print("BOSSTELEPORT solid_landings=" + str(solid_landings) + "/" + str(tries) + " min_player_dist=" + str(snappedf(min_player_dist, 1.0)))
	ok("teleport never lands the boss inside a solid cell", solid_landings == 0, "solid_landings=" + str(solid_landings) + "/" + str(tries))
	print("=== BOSSTELEPORT TEST: " + str(passes) + " passed, " + str(fails) + " failed ===")
	quit(0 if fails == 0 else 1)
