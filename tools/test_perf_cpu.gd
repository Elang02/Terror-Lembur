extends SceneTree

const LEVEL := "res://scenes/level_1.tscn"
const PHASE_FRAMES := 20

var mode := "base"
var phase := 0
var phase_frames := 0
var cpu_start := 0
var results: Array = []

func _cpu_ticks() -> int:
	var f := FileAccess.open("/proc/self/stat", FileAccess.READ)
	if f == null:
		return -1
	var line := f.get_line()
	f.close()
	var close_paren := line.rfind(")")
	var rest: String = line.substr(close_paren + 2)
	var fields: PackedStringArray = rest.split(" ")
	return int(fields[11]) + int(fields[12])

func _init() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("mode="):
			mode = a.trim_prefix("mode=")
	var packed: PackedScene = load(LEVEL)
	var lvl: Node = packed.instantiate()
	root.add_child(lvl)
	lvl.call("_dismiss_intro")
	var player: Node = load("res://scenes/worker_char.tscn").instantiate()
	player.name = "1"
	lvl.get_node("YSort").add_child(player)
	await create_timer(0.5).timeout
	player.global_position = Vector2(400, 656)
	await create_timer(1.0).timeout
	cpu_start = _cpu_ticks()
	process_frame.connect(_on_frame)
	while phase < 3:
		await process_frame
	quit()

func _on_frame() -> void:
	phase_frames += 1
	if phase_frames >= PHASE_FRAMES:
		var cpu_now := _cpu_ticks()
		var cpu_ms := float(cpu_now - cpu_start) * 10.0 / phase_frames
		cpu_start = cpu_now
		results.append([phase, cpu_ms])
		print("PHASE %d cpu_ms_per_frame=%.1f" % [phase, cpu_ms])
		phase_frames = 0
		phase += 1
		if phase == 1:
			_apply_mode(root.get_node("Level1"), mode, true)
		elif phase == 2:
			_apply_mode(root.get_node("Level1"), mode, false)
		if phase >= 3:
			var a_cpu: float = (results[0][1] + results[2][1]) * 0.5
			var b_cpu: float = results[1][1]
			print("=== ABA-CPU mode=%s base_cpu=%.1f mode_cpu=%.1f ratio=%.2f ===" % [mode, a_cpu, b_cpu, a_cpu / b_cpu])
			process_frame.disconnect(_on_frame)

func _apply_mode(lvl: Node, m: String, on: bool) -> void:
	match m:
		"nolights":
			_set_lights(lvl, not on)
		"noboss":
			var b = lvl.get("boss")
			if b != null:
				b.set_physics_process(not on)
				b.set_process(not on)
				b.visible = not on
		"nolevelprocess":
			lvl.set_process(not on)
		"notiles":
			for n in ["FloorLayer", "WallLayer"]:
				var t := lvl.get_node_or_null(n)
				if t != null:
					t.visible = not on
		"noprops":
			for c in lvl.get_node("YSort").get_children():
				if c is CharacterBody2D:
					continue
				c.visible = not on
			for c in lvl.get_children():
				if c is Polygon2D:
					c.visible = not on
		"notaskredraw":
			for t in lvl.get("tasks"):
				(t as Node).set_process(not on)
		"nohudupdate":
			lvl.set_meta("perf_no_hud", on)

func _set_lights(lvl: Node, enabled: bool) -> void:
	var stack: Array = [lvl]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is PointLight2D:
			(n as PointLight2D).enabled = enabled
		if n is CanvasModulate:
			n.visible = enabled
		for c in n.get_children():
			stack.append(c)
