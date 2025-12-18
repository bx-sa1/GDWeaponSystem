extends Node3D

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	look_at(player.global_position)
