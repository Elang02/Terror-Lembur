class_name Prop
extends Node2D

@export var is_hide_spot := false

func _ready() -> void:
	if is_hide_spot:
		add_to_group("hide_spot")
