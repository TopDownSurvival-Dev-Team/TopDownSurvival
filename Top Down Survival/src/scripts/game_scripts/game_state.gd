extends Node2D

const PLAYER_SCENE = preload("res://src/actors/Player.tscn")

onready var player_spawn = $PlayerSpawn
onready var players = $Players


func _ready():
	rpc_id(1, "spawn_player_s", Network.local_player_id)
	
	
remote func spawn_player(id):
	print("Spawning player " + str(id))
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player)
	new_player.set_network_master(id)
	new_player.position = player_spawn.position
	

remote func despawn_player(id):
	print("Despawning player " + str(id))
	var player = players.get_node(str(id))
	players.remove_child(player)
	player.queue_free()
