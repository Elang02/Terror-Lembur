@tool
extends Node2D

var task_id := -1
var label_text := ""
var need_players := 1
var time_needed := 8.0
var noise_radius := 150.0
var progress := 0.0
var done := false
var pulse := 0.0

var hits_needed := 3
var hits := 0
var marker_pos := 0.0
var marker_dir := 1.0
var marker_speed := 1.2
var base_speed := 1.2
var zone_center := 0.5
var zone_size := 0.26
var active := false
var miss_flash := 0.0

func _ready() -> void:
	set_multiplayer_authority(1)

func setup(id: int, text: String, need: int, time_s: float, noise_r: float, hits_n: int = 3, speed: float = 1.2, zone: float = 0.26) -> void:
	task_id = id
	label_text = text
	need_players = need
	time_needed = time_s
	noise_radius = noise_r
	hits_needed = hits_n
	marker_speed = speed
	base_speed = speed
	zone_size = zone
	randomize_zone()

func randomize_zone() -> void:
	var half := zone_size * 0.5
	zone_center = randf_range(half + 0.05, 1.0 - half - 0.05)

func try_hit() -> bool:
	var half := zone_size * 0.5
	if marker_pos >= zone_center - half and marker_pos <= zone_center + half:
		hits += 1
		progress = clampf(float(hits) / float(hits_needed), 0.0, 1.0)
		marker_speed = base_speed + 0.15 * float(hits)
		randomize_zone()
		return true
	miss_flash = 0.5
	progress = maxf(0.0, progress - 0.5 / float(hits_needed))
	hits = int(round(progress * float(hits_needed)))
	return false

func _process(delta: float) -> void:
	pulse += delta
	if miss_flash > 0.0:
		miss_flash = maxf(0.0, miss_flash - delta)
	queue_redraw()

func _draw() -> void:
	if done:
		draw_circle(Vector2.ZERO, 14, Color(0.2, 0.9, 0.3, 0.9))
		draw_string(ThemeDB.fallback_font, Vector2(-4, 5), "✓", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0, 0, 0, 1))
		return
	var a := 0.6 + 0.3 * sin(pulse * 4.0)
	draw_circle(Vector2.ZERO, 14, Color(1, 0.85, 0.2, a))
	draw_arc(Vector2.ZERO, 14, 0, TAU, 24, Color(1, 1, 1, 0.9), 2.5)
	var bar_w := 56.0
	var bar_pos := Vector2(-bar_w * 0.5, -38)
	draw_rect(Rect2(bar_pos, Vector2(bar_w, 8)), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(bar_pos, Vector2(bar_w * clampf(progress, 0.0, 1.0), 8)), Color(1, 0.85, 0.2, 1))
	if active:
		var tbar := Rect2(Vector2(-bar_w * 0.5, -26), Vector2(bar_w, 8))
		var bg := Color(0.7, 0.1, 0.1, 0.9) if miss_flash > 0.0 else Color(0, 0, 0, 0.7)
		draw_rect(tbar, bg)
		var zx0 := -bar_w * 0.5 + (zone_center - zone_size * 0.5) * bar_w
		draw_rect(Rect2(Vector2(zx0, -26), Vector2(zone_size * bar_w, 8)), Color(0.2, 0.9, 0.3, 1.0))
		var mx := -bar_w * 0.5 + marker_pos * bar_w
		draw_rect(Rect2(Vector2(mx - 1.5, -28), Vector2(3, 12)), Color(1, 1, 1, 1))
	var tw := label_text.length() * 9.0
	draw_rect(Rect2(Vector2(-tw * 0.5 - 4, -58), Vector2(tw + 8, 18)), Color(0, 0, 0, 0.6))
	draw_string(ThemeDB.fallback_font, Vector2(0, -44), label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 1))

func is_complete() -> bool:
	return done
