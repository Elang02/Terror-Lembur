extends SceneTree
var frames := 0
var start_msec := 0
func _init() -> void:
	var sp := Sprite2D.new()
	root.add_child(sp)
	await create_timer(1.0).timeout
	start_msec = Time.get_ticks_msec()
	process_frame.connect(_on_frame)
	await create_timer(15.0).timeout
	var elapsed := (Time.get_ticks_msec() - start_msec) / 1000.0
	print("=== FPS EMPTY ===")
	print("window_s=%.1f frames=%d avg_fps=%.1f" % [elapsed, frames, frames / elapsed])
	quit()
func _on_frame() -> void:
	frames += 1
