extends Node
## Net test headless (bukan bagian game):
##   godot --headless --path . res://tests/net_test.tscn -- --net-role=host
##   godot --headless --path . res://tests/net_test.tscn -- --net-role=client
## Host membuat server lalu masuk level; client join 127.0.0.1 lalu masuk
## level. NetChecker mencetak hasil setelah 8 detik.

var _role: String = "host"


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--net-role="):
			_role = arg.get_slice("=", 1)
	var checker: Node = load("res://tests/net_checker.gd").new()
	checker.name = "NetChecker"
	# Root sedang setup saat _ready scene pertama: tambah & ganti scene deferred.
	get_tree().root.add_child.call_deferred(checker)
	if _role == "host":
		var err: Error = NetworkManager.host_game()
		print("NETTEST host_game err=", err)
		get_tree().change_scene_to_file.call_deferred("res://scenes/level_1.tscn")
	else:
		NetworkManager.connected_to_host.connect(_on_connected)
		NetworkManager.connection_failed.connect(_on_failed)
		var err2: Error = NetworkManager.join_game("127.0.0.1")
		print("NETTEST join_game err=", err2)


func _on_connected() -> void:
	print("NETTEST client connected to host")
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")


func _on_failed() -> void:
	print("NETTEST client connection FAILED")
	get_tree().quit(1)
