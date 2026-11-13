extends Node2D

var taken := false
var bob := 0.0
var gambar: Sprite2D

func _ready() -> void:
	set_multiplayer_authority(1)
	gambar = $Gambar

func _process(delta: float) -> void:
	bob += delta
	if gambar != null:
		gambar.position.y = sin(bob * 3.0) * 2.0
		gambar.visible = not taken
