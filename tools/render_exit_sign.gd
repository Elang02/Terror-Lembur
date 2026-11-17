extends SceneTree

# Render check: exit sign label near the exit door, verify the full text fits.
const LEVEL := "res://scenes/level_1.tscn"

func _init() -> void:
	var packed: PackedScene = load(LEVEL)
	var lvl: Node = packed.instantiate()
	root.add_child(lvl)
	lvl.call("_dismiss_intro")
	lvl.set_solo_mode(true)
	lvl.get_node("Network").call("_hide_menu")
	# hide HUD layers so we see the world label clearly
	for cl in lvl.get_children():
		if cl is CanvasLayer:
			cl.visible = false
	var player: Node = load("res://scenes/worker_char.tscn").instantiate()
	player.name = "1"
	lvl.get_node("YSort").add_child(player)
	await create_timer(0.5).timeout
	# stand near the exit so the camera centers on the sign area
	player.global_position = Vector2(800, 700)
	await create_timer(1.0).timeout
	# hide menu + HUD right before capture (menu rebuilds/shows on start)
	lvl.get_node("Network").call("_hide_menu")
	for cl in lvl.find_children("*", "CanvasLayer", true, false):
		if cl.name != "HUD":
			cl.visible = false
	# let a few frames render
	for i in range(5):
		await process_frame
	lvl.get_node("Network").call("_hide_menu")
	var img: Image = root.get_texture().get_image()
	img.save_png("/tmp/exit_sign_check.png")
	print("RENDER_SAVED /tmp/exit_sign_check.png")
	quit()
