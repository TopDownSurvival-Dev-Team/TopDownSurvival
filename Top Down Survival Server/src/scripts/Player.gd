extends Node2D

remote func update_player(transform, current_animation):
	rpc_unreliable("remote_update", transform, current_animation)
