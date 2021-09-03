extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")
const TREE_SCENE = preload("res://src/scenes/Tree.tscn")

const MAX_TREE_COUNT = 100
const TREE_POS_RANGE = Vector2(5000, 5000)

const MAX_ITEM_COUNT = 999

onready var players = $Players
onready var trees = $Trees
onready var items = $Items


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
	
	for _i in range(MAX_TREE_COUNT):
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
		
		
	print("Sending items to " + str(id))
	for item in items.get_children():
		# Get item info
		var item_info = item.name.split("-", false, 1)
		var item_type = str(item_info[0])
		var item_id = int(item_info[1])
		
		rpc_id(id, "spawn_item", item_type, item_id, item.global_position)
		
		
		
		
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
		
		
		
		
func spawn_item_s(item_type: String, item_position: Vector2):
	# Limit number of items currently existing
	if items.get_child_count() >= MAX_ITEM_COUNT:
		var remove_item = items.get_child(0)
		
		# Get item info
		var item_info = remove_item.name.split("-", false, 1)
		var r_item_type = str(item_info[0])
		var r_item_id = int(item_info[1])
		
		rpc("despawn_item", r_item_type, r_item_id)
		items.remove_child(remove_item)
		remove_item.queue_free()
	
	var new_item = Node2D.new()
	var item_id = randi() % MAX_ITEM_COUNT
	var item_name = str(item_type) + "-" + str(item_id)
	
	# Make sure item_name is unique
	while items.get_node(item_name) != null:
		item_id = randi() % MAX_ITEM_COUNT
		item_name = str(item_type) + "-" + str(item_id)
	
	new_item.name = item_name
	items.add_child(new_item, true)
	new_item.global_position = item_position
	
	rpc("spawn_item", item_type, item_id, item_position)
	

func despawn_item_s(item_type: String, item_id: int):
	var item_name = str(item_type) + "-" + str(item_id)
	var item = items.get_node(item_name)
	
	if item:
		rpc("despawn_item", item_type, item_id)
		items.remove_child(item)
		item.queue_free()
