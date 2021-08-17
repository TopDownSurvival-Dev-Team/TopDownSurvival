extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")

onready var players = $Players


func _ready():
	print("Game world started!")


remote func spawn_player_s(id):
	print("Spawning player " + str(id))
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player)
	rpc("spawn_player", id)
