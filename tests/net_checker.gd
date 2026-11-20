extends Node
## NetChecker — node persisten (anak root) untuk tests/net_test.tscn.
## Setelah N detik, mencetak keadaan sesi lalu keluar. Dipakai untuk
## verifikasi host+client headless, bukan bagian dari game.

var wait_seconds: float = 8.0
var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= wait_seconds:
		var players: Array[Node] = get_tree().get_nodes_in_group("Player")
		var level: Node = get_tree().get_first_node_in_group("LevelManager")
		print("NETCHECK role_mode=%d local_id=%d connected=%s players=%d tasks=%d enemy=%s" % [
			NetworkManager.mode, NetworkManager.local_peer_id(),
			str(NetworkManager.connected_ids), players.size(),
			level._tasks.size() if level != null else -1,
			str(level.get_node_or_null("Enemy").global_position) if level != null and level.get_node_or_null("Enemy") != null else "none",
		])
		for p: Node in players:
			print("NETCHECK player peer=%d index=%d pos=%s authority=%d" % [p.peer_id, p.player_index, str(p.global_position), p.get_multiplayer_authority()])
		get_tree().quit(0)
