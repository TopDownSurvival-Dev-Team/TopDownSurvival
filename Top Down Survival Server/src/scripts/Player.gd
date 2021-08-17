extends Node2D

remote func update_player(transform):
	rpc_unreliable("remote_update", transform)
