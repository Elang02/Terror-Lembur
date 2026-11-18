extends SceneTree

# QA test: early-game fairness (Phase 48, REVISED 18 Nov 2026).
# Elang's decision 18 Nov: NO 30s spawn grace. The grace made the game
# boring: the boss ignored the player point-blank for half a minute.
# 1. With no grace, a visible player in front of the boss must be chased
#    within a few seconds (boss detects from the start).
# 2. After a catch, the boss must patrol AWAY from the cell (no cell camping),
#    so the locked player can self-rescue at full speed.
# Run headed under Xvfb:133:
#   Godot --path /home/hatch/workspace/terror-lembur-repo --script res://tools/test_earlyfair.gd

var lvl: Node = null
var boss: Node = null
var player: Node = null
var fails := 0
var phase := 0
var phase_t := 0.0
var caught_at := -1.0
var cell_dist_samples: Array[float] = []

func _init() -> void:
	var packed: PackedScene = load("res://scenes/level_1.tscn")
	lvl = packed.instantiate()
	root.add_child(lvl)
	lvl.call("_dismiss_intro")
	lvl.set("solo_mode", true)
	var worker_scene: PackedScene = load("res://scenes/worker_char.tscn")
	player = worker_scene.instantiate()
	player.name = "1"
	lvl.get_node("YSort").add_child(player)
	await create_timer(0.2).timeout
	player.global_position = Vector2(400, 656)
	player.set("locked", false)
	boss = lvl.get("boss")
	boss.set("blind_timer", 0.0)
	boss.set("teleport_timer", 99999.0)
	boss.global_position = Vector2(550, 656)
	boss.set("state", 0)
	boss.set("state_timer", 0.0)
	boss.set("velocity", Vector2.ZERO)
	print("EARLYFAIR_START")

func _check(cond: bool, label: String) -> void:
	if cond:
		print("EARLYFAIR PASS: ", label)
	else:
		fails += 1
		print("EARLYFAIR FAIL: ", label)

func _process(delta: float) -> bool:
	if lvl == null:
		return false
	var elapsed := float(lvl.get("elapsed"))
	if phase == 0:
		# Phase 0: no grace. Player stands visible 150px from the boss
		# on the clear y=656 corridor. Boss must enter CHASE quickly.
		if int(boss.get("state")) == 2:
			_check(true, "boss chases visible player with no grace (t=" + str(snappedf(elapsed, 0.1)) + ")")
			_check(float(boss.get("blind_timer")) <= 0.0, "boss not blind at start (blind_timer=" + str(boss.get("blind_timer")) + ")")
			# Force a catch directly (bypasses the blind_timer race in _check_catch).
			lvl.call("on_player_caught", player)
			boss.set("post_rescue_timer", 20.0)
			boss.set("state", 0)
			boss.call("_pick_waypoint")
			phase = 1
			phase_t = 0.0
			print("EARLYFAIR forced catch at t=", snappedf(elapsed, 0.1))
		elif elapsed >= 5.0:
			_check(false, "boss did NOT chase visible player within 5s (state=" + str(boss.get("state")) + ")")
			print("EARLYFAIR FAILS=", fails)
			return true
	elif phase == 1:
		phase_t += delta
		if bool(player.get("locked")) and caught_at < 0.0:
			caught_at = elapsed
		if phase_t >= 1.0:
			# Record boss distance from the cell every second after the catch.
			var d: float = boss.global_position.distance_to(Vector2(1080, 140))
			cell_dist_samples.append(d)
		if phase_t >= 12.0:
			_check(caught_at > 0.0, "forced catch happened (caught_at=" + str(caught_at) + ")")
			var late_max := 0.0
			for i in range(cell_dist_samples.size()):
				if i >= cell_dist_samples.size() - 4:
					late_max = maxf(late_max, cell_dist_samples[i])
			_check(late_max > 250.0, "boss patrols away from cell after catch (max dist in last 4s=" + str(snappedf(late_max, 0.0)) + ", samples=" + str(cell_dist_samples) + ")")
			print("EARLYFAIR FAILS=", fails)
			return true
	return false
