# CODEMAP — Terror Lembur

Dibangun otomatis oleh `tools/build_codemap.py` (GDScript tidak didukung tree-sitter engram/graphify, jadi extractor ini regex + struktural).
Sumber query: `.planning/codemap.json`. Regenerasi: `python3 tools/build_codemap.py`.

- File .gd: 78, fungsi: 517, signal: 0, scene .tscn: 28

## File script utama

- `scripts/boss.gd` — class `-` extends `CharacterBody2D`
  - funcs (33): _enter_tree, _ready, _get_or_create, _build_visual, _process, _circle_points, _physics_process, _update_bob, _update_stuck, _refresh_mark, _set_mark, _nearest_player_pos, _pick_waypoint, _request_path, _steer_to, _in_other_room, _update_patrol, _update_suspicious, _update_chase, _enter_search, _nearest_desk_in_range, _update_search, _update_return, _move_toward, _update_detection, _nearest_audible_player, _nearest_visible_player, _has_line_of_sight, _has_line_of_sight_to, _check_catch, _start_telegraph, _do_teleport, send_back_to_room
- `scripts/level_1.gd` — class `-` extends `Node2D`
  - funcs (105): _indo_name, _prop_name, _ready, set_solo_mode, _setup_music, _update_music, _load_muted, _toggle_mute, _tutorial_is_done, _refresh_tutorial_label, _finish_tutorial, _task_done, _update_tutorial, _update_first_encounter, _end_first_encounter, _any_main_task_done, _build_tilemap_layers, _set_wall, _wall_bitmask, _autotile_walls, _floor_tile_for, _wall_h, _wall_v, _lock_door, _create_locked_door_markers, _init_desk_positions, _build_astar, _prop_collision_aabb, _mark_rect_solid, _nearest_walkable, find_path, _open_locked_doors, _build_partitions, _build_darkness, _blood_spot, _paper, _rug, _build_horror_static, _build_horror_lights, _build_cell, _build_tasks, _build_popup, _build_pickups, _update_pickups, show_hud, _build_intro, _show_intro, _dismiss_intro, _is_demo, play_sfx, flash_red, _build_hud, _process, _is_player, _generate_code, _reveal_code_digit, _popup_kind, _popup_title, _task_ready, try_open_task_popup, on_boss_heard_task, popup_set_progress, popup_task_done, popup_task_cancel, _on_popup_closed, _update_self_rescue, _on_task_done, _enrage_boss, _unlock_all, _main_tasks_done, _any_locked, _locked_count, _player_count, _check_endings, _finish_level, _show_end, _toggle_pause, _unhandled_input, _restart_game, _update_hud, _heartbeat_volume, _update_haunt, _update_exit_opening, _boss_distance, add_shake, _my_player, nearest_interactable, nearest_desk, is_lit, boss_room_center, _room_of, teleport_destination, report_noise, consume_noise, on_player_caught, _fx_caught, on_boss_chase, on_boss_lost, on_boss_telegraph, on_boss_teleported, spawn_throwable, _build_props, _place_prop, _place_modern, _place_prop_scene
- `scripts/network.gd` — class `-` extends `Node`
  - funcs (23): _ready, _process, _make_peer, host, solo, join, spawn_player, _on_peer_connected, _on_peer_disconnected, _on_connected_to_server, _on_connection_failed, _on_server_disconnected, _set_status, _hide_menu, _show_hud, _best_lan_ip, _compute_broadcast_targets, _start_broadcast, _stop_broadcast, _start_listening, _stop_listening, _refresh_server_list, _build_menu
- `scripts/pickup_item.gd` — class `-` extends `Node2D`
  - funcs (2): _ready, _process
- `scripts/prop.gd` — class `Prop` extends `Node2D`
  - funcs (1): _ready
- `scripts/sfx.gd` — class `SFX` extends `Node`
  - funcs (17): set_muted, _ready, play, _build_all, _to_wav, _noise, _heartbeat, _tick, _complete, _sting, _whisper, _alarm, _thud, _pickup, _shout, _step, _hide
- `scripts/task_point.gd` — class `-` extends `Node2D`
  - funcs (5): _ready, setup, _process, _draw, is_complete
- `scripts/task_popup.gd` — class `TaskPopup` extends `CanvasLayer`
  - funcs (44): _title_f, _body_f, _ready, _stylebox, _panel, _panelc, _build_ui, _make_label, _clear_content, open_popup, close_popup, _refresh_progress, _wrong, _right, _grid_cell, _excel_cell, _excel_gen_grid, _excel_formula_for, _next_excel, _refresh_excel_input, press_digit, press_backspace, _submit_excel, _start_simon_round, _simon_light, _build_foto, _refresh_foto_papers, _draw_foto_bar, _build_keypad, _refresh_keypad, _build_mash, _refresh_mash_handle, _next_cari, _cari_flip, _build_cari, _gen_urut, _build_urut, _urut_mark_done, _urut_reset_marks, press_number, press_space, _process, _demo_step, _unhandled_input
- `scripts/throwable.gd` — class `-` extends `Node2D`
  - funcs (5): _enter_tree, _ready, launch, _physics_process, _draw
- `scripts/ui_theme.gd` — class `UITheme` extends `RefCounted`
  - funcs (12): title_font, body_font, panel_style, button_style, apply_button, apply_panel, bar_bg_style, bar_fill_style, apply_progress_bar, apply_line_edit, make_label, make_vignette
- `scripts/worker_char.gd` — class `-` extends `CharacterBody2D`
  - funcs (16): _enter_tree, _ready, _physics_process, _demo_update, _demo_flee, _demo_far_point, _demo_move_to, _update_actions, _update_interact, _toggle_hide, _unhide, _throw, _process, _dir_name, set_locked, give_throwable

## Scene

- `scenes/boss.tscn` — root Boss (CharacterBody2D), 8 node, script: `res://scripts/boss.gd`
- `scenes/level_1.tscn` — root Level1 (Node2D), 189 node, script: `res://scripts/level_1.gd`, `res://scripts/prop.gd`, `res://scripts/network.gd`
- `scenes/pickup_item.tscn` — root PickupItem (Node2D), 3 node, script: `res://scripts/pickup_item.gd`
- `scenes/props/dispenser.tscn` — root Dispenser (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/flipchart.tscn` — root Flipchart (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/jam_dinding.tscn` — root Jam_Dinding (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/komputer.tscn` — root Komputer (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/kursi_belakang.tscn` — root Kursi_Belakang (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/kursi_depan.tscn` — root Kursi_Depan (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/kursi_kanan.tscn` — root Kursi_Kanan (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/kursi_kiri.tscn` — root Kursi_Kiri (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/lampu_meja.tscn` — root Lampu_Meja (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/laptop.tscn` — root Laptop (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/layar_proyektor.tscn` — root Layar_Proyektor (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/lemari.tscn` — root Lemari (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/meja.tscn` — root Meja (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/meja_rapat.tscn` — root Meja_Rapat (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/mug.tscn` — root Mug (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/papan_tulis.tscn` — root Papan_Tulis (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/props/rak_buku.tscn` — root Rak_Buku (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/sofa.tscn` — root Sofa (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/tanaman.tscn` — root Tanaman (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/tanaman_tinggi.tscn` — root Tanaman_Tinggi (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/tempat_sampah.tscn` — root Tempat_Sampah (Node2D), 4 node, script: `res://scripts/prop.gd`
- `scenes/props/tumpukan_kertas.tscn` — root Tumpukan_Kertas (Node2D), 2 node, script: `res://scripts/prop.gd`
- `scenes/task_point.tscn` — root TaskPoint (Node2D), 2 node, script: `res://scripts/task_point.gd`
- `scenes/throwable.tscn` — root Throwable (Node2D), 3 node, script: `res://scripts/throwable.gd`
- `scenes/worker_char.tscn` — root CharacterBody2D (CharacterBody2D), 6 node, script: -

## Tools

- `tools/bake_map.gd` — 2 funcs
- `tools/diag_astar.gd` — 2 funcs
- `tools/diag_boss_after_catch.gd` — 2 funcs
- `tools/diag_bosstrack.gd` — 2 funcs
- `tools/diag_chase.gd` — 2 funcs
- `tools/diag_desk.gd` — 2 funcs
- `tools/diag_desks.gd` — 2 funcs
- `tools/diag_early_catch.gd` — 2 funcs
- `tools/diag_fe.gd` — 3 funcs
- `tools/diag_patrol.gd` — 2 funcs
- `tools/diag_patrolbias.gd` — 2 funcs
- `tools/diag_rescue.gd` — 2 funcs
- `tools/diag_vision.gd` — 2 funcs
- `tools/diag_waypoints.gd` — 2 funcs
- `tools/diag_wp1.gd` — 2 funcs
- `tools/make_tileset.gd` — 1 funcs
- `tools/render_boss.gd` — 3 funcs
- `tools/render_boss_mark.gd` — 3 funcs
- `tools/render_cari.gd` — 4 funcs
- `tools/render_exit_sign.gd` — 1 funcs
- `tools/render_gameover.gd` — 2 funcs
- `tools/render_gray.gd` — 3 funcs
- `tools/render_hide.gd` — 3 funcs
- `tools/render_popups.gd` — 4 funcs
- `tools/render_popups_v2.gd` — 4 funcs
- `tools/test_bossaggro.gd` — 4 funcs
- `tools/test_bossdesk.gd` — 4 funcs
- `tools/test_bossmove.gd` — 5 funcs
- `tools/test_bosspol.gd` — 5 funcs
- `tools/test_bossvision.gd` — 5 funcs
- `tools/test_bosswarn.gd` — 6 funcs
- `tools/test_earlyfair.gd` — 3 funcs
- `tools/test_flow.gd` — 5 funcs
- `tools/test_fps.gd` — 2 funcs
- `tools/test_fps_empty.gd` — 2 funcs
- `tools/test_grid.gd` — 2 funcs
- `tools/test_hearing.gd` — 4 funcs
- `tools/test_hide.gd` — 4 funcs
- `tools/test_intro.gd` — 4 funcs
- `tools/test_light.gd` — 5 funcs
- `tools/test_music.gd` — 5 funcs
- `tools/test_mute.gd` — 5 funcs
- `tools/test_path.gd` — 2 funcs
- `tools/test_patrol.gd` — 6 funcs
- `tools/test_patrolbias.gd` — 4 funcs
- `tools/test_phase33.gd` — 5 funcs
- `tools/test_phase36.gd` — 5 funcs
- `tools/test_phase37.gd` — 5 funcs
- `tools/test_phase38.gd` — 5 funcs
- `tools/test_phase39.gd` — 5 funcs
- `tools/test_phase42.gd` — 6 funcs
- `tools/test_phase43.gd` — 5 funcs
- `tools/test_phase44.gd` — 6 funcs
- `tools/test_phase45.gd` — 7 funcs
- `tools/test_phase46.gd` — 5 funcs
- `tools/test_phase47.gd` — 6 funcs
- `tools/test_popup.gd` — 7 funcs
- `tools/test_rescue.gd` — 4 funcs
- `tools/test_search.gd` — 5 funcs
- `tools/test_searchdesk.gd` — 3 funcs
- `tools/test_solo.gd` — 5 funcs
- `tools/test_stamina.gd` — 5 funcs
- `tools/test_taskwarn.gd` — 4 funcs
- `tools/test_tension.gd` — 5 funcs
- `tools/test_tutorial.gd` — 6 funcs
- `tools/test_vision.gd` — 4 funcs
- `tools/test_win.gd` — 5 funcs
