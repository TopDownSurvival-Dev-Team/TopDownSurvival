extends Node2D

const PLAYER_SCENE = preload("res://src/actors/Player.tscn")
const TREE_SCENE  = preload("res://src/actors/Tree.tscn")

onready var player_spawn = $PlayerSpawn
onready var players = $Players
onready var trees = $Trees


func _ready():
	rpc_id(1, "spawn_player_s", Network.local_player_id)
	
	
remote func spawn_player(player_id):
	print("Spawning player " + str(player_id))
	
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(player_id)
	players.add_child(new_player, true)
	
	new_player.set_network_master(player_id)
	new_player.position = player_spawn.position
	

remote func despawn_player(player_id):
	print("Despawning player " + str(player_id))
	var player = players.get_node(str(player_id))
	players.remove_child(player)
	player.queue_free()
	
	
remote func spawn_tree(tree_id, tree_position):
	var new_tree = TREE_SCENE.instance()
	
	new_tree.name = str(tree_id)
	trees.add_child(new_tree, true)
	
	new_tree.global_position = tree_position
