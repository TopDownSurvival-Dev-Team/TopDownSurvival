extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")
const TREE_SCENE = preload("res://src/scenes/Tree.tscn")

const MAX_TREE_COUNT = 100
const TREE_POS_RANGE = Vector2(5000, 5000)

onready var players = $Players
onready var trees = $Trees


func _ready():
	print("Game world started!")
	
	# Randomize RNG seed
	randomize()
	
	# Load world before letting players connect
	load_world()
	Network.start_server()
	
	
func load_world():
	# In the future this will load the game world from a save file
	# For now, it just randomly spawns natural structures
	print("Loading world")
	
	print("Loading natural structures")
	
	for i in range(MAX_TREE_COUNT):
		var tree_id = randi() % MAX_TREE_COUNT
		
		# Make sure tree_id is unique
		while trees.get_node(str(tree_id)) != null:
			tree_id = randi() % MAX_TREE_COUNT
			
		var new_tree = TREE_SCENE.instance()
		new_tree.name = str(tree_id)
		trees.add_child(new_tree, true)
		
		var new_tree_pos = Vector2(
			randi() % int(TREE_POS_RANGE.x) - TREE_POS_RANGE.x / 2,
			randi() % int(TREE_POS_RANGE.y) - TREE_POS_RANGE.y / 2
		)
		new_tree.global_position = new_tree_pos
	
	
func send_world_to(id):
	print("Sending players to " + str(id))
	for player_id in Network.players.keys():
		if player_id != id:
			rpc_id(id, "spawn_player", player_id)
			
	print("Sending natural structures to " + str(id))
	
	for tree in trees.get_children():
		rpc_id(id, "spawn_tree", int(tree.name), tree.global_position)
		
		
		
		
remote func spawn_player_s(id):
	print("Spawning player " + str(id))
	
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player, true)
	
	rpc("spawn_player", id)
	
	
func despawn_player_s(id):
	print("Despawning player " + str(id))
	
	var player = players.get_node(str(id))
	players.remove_child(player)
	player.queue_free()
	
	rpc("despawn_player", id)
	
	
	
	
func despawn_tree_s(tree_id: int):
	var tree = trees.get_node(str(tree_id))
	
	if tree:
		rpc("despawn_tree", tree_id)
		trees.remove_child(tree)
		tree.queue_free()
