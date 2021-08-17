extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")

onready var players = $Players


remote func spawn_player_s(id):
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player)
	rpc("spawn_player", id)
