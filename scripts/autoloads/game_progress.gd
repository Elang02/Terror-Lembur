extends Node
## GameProgress (Autoload) — simpan bintang & waktu terbaik per level.
## Disimpan di user://terror_lembur_progress.cfg (per PC).

const SAVE_PATH: String = "user://terror_lembur_progress.cfg"

var _cfg := ConfigFile.new()


func _ready() -> void:
	_cfg.load(SAVE_PATH)


func record_level_result(level_id: String, stars: int, time_sec: float, ending: String, success: bool) -> void:
	if not success:
		return
	var prev_stars: int = int(_cfg.get_value(level_id, "stars", 0))
	if stars > prev_stars:
		_cfg.set_value(level_id, "stars", stars)
	var prev_time: float = float(_cfg.get_value(level_id, "best_time", 0.0))
	if prev_time <= 0.0 or time_sec < prev_time:
		_cfg.set_value(level_id, "best_time", time_sec)
	_cfg.set_value(level_id, "ending", ending)
	_cfg.set_value(level_id, "completions", int(_cfg.get_value(level_id, "completions", 0)) + 1)
	_cfg.save(SAVE_PATH)


func get_stars(level_id: String) -> int:
	return int(_cfg.get_value(level_id, "stars", 0))


func get_best_time(level_id: String) -> float:
	return float(_cfg.get_value(level_id, "best_time", 0.0))


func get_ending(level_id: String) -> String:
	return String(_cfg.get_value(level_id, "ending", ""))
