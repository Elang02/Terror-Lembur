extends SceneTree

var lvl: Node2D
var player: Node2D

func _init() -> void:
	var scene := load("res://scenes/level_1.tscn") as PackedScene
	lvl = scene.instantiate() as Node2D
	root.add_child(lvl)
	call_deferred("_run")

func _run() -> void:
	for i in range(5):
		await process_frame
	lvl.set_solo_mode(true)
	var ysort: Node = lvl.get_node_or_null("YSort")
	var pscene := load("res://scenes/worker_char.tscn") as PackedScene
	player = pscene.instantiate() as Node2D
	player.name = "1"
	ysort.add_child(player, true)
	for i in range(5):
		await process_frame
	player.global_position = Vector2(740, 760)
	# Force 3 catches = solo game over.
	lvl.call("on_player_caught", player)
	for i in range(5):
		await process_frame
	lvl.call("on_player_caught", player)
	for i in range(5):
		await process_frame
	lvl.call("on_player_caught", player)
	for i in range(30):
		await process_frame
	print("GAMEOVER game_over=" + str(lvl.get("game_over")) + " result=" + str(lvl.get("game_result")))
	var net: Node = lvl.get_node_or_null("Network")
	if net != null:
		var m: CanvasLayer = net.get("menu")
		if m != null:
			m.visible = false
	if lvl.has_method("show_hud"):
		lvl.call("show_hud")
	for i in range(10):
		await process_frame
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	cam.zoom = Vector2(1, 1)
	lvl.add_child(cam)
	cam.make_current()
	for i in range(5):
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png("/tmp/gameover.png")
	print("GAMEOVER screenshot saved")
	quit(0)
