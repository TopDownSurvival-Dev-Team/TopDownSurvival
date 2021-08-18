extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")

onready var players = $Players


func _ready():
	print("Game world started!")
	
	
func send_existing_players_to(id):
	print("Sending players to " + str(id))
	
	for player_id in Network.players.keys():
		if player_id != id:
			rpc_id(id, "spawn_player", player_id)
		
		
remote func spawn_player(id):
	print("Spawning player " + str(id))
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player)
	rpc("spawn_player", id)
