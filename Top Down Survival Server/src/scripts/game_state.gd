extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")
const TREE_SCENE = preload("res://src/scenes/Tree.tscn")
const ITEM_SCENE = preload("res://src/scenes/Item.tscn")

const MAX_TREE_COUNT = 100
const TREE_POS_RANGE = Vector2(5000, 5000)

const MAX_ITEM_COUNT = 99

onready var inventory = $HUD/Inventory
onready var players = $Players
onready var trees = $Trees
onready var items = $Items


func _ready():
	print("Game world started!")
	
	# Randomize RNG seed
	randomize()
	
	# Wait till connected to game server hub
	GameServerHub.connect_to_hub()
	yield(GameServerHub.network, "connection_succeeded")
	
	# Connect signals
	Network.connect("player_joined_game", self, "send_world_to")
	Network.connect("player_joined_game", self, "spawn_player_s")
	Network.connect("player_left_game", self, "despawn_player_s")
	
	# Load world before letting players connect
	var world_data = Database.get_world_data()
	
	if world_data.empty():
		generate_world()
		save_world()
	else:
		load_world(world_data)
	
	Network.start_server()
	
	
func load_world(data: Array):
	print("Loading world...")
	# TODO
	
	
func save_world():
	print("Saving world...")
	# TODO
	
	
func generate_world():
	print("Generating world...")
	
	print("Generating natural structures")
	
	for _i in range(MAX_TREE_COUNT):
		var new_tree_pos = Vector2(
			randi() % int(TREE_POS_RANGE.x) - TREE_POS_RANGE.x / 2,
			randi() % int(TREE_POS_RANGE.y) - TREE_POS_RANGE.y / 2
		)
		spawn_tree_s(new_tree_pos)
	
	
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
		var scene_id = item_info[1].to_int()
		
		rpc_id(id, "spawn_item", item.item_id, item.quantity, scene_id, item.global_position)
	
	
	
	
func spawn_player_s(id: int):
	print("Spawning player " + str(id))
	
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(id)
	players.add_child(new_player, true)
	rpc("spawn_player", id)
	
	
func despawn_player_s(id: int):
	print("Despawning player " + str(id))
	
	var player = players.get_node(str(id))
	if player:
		players.remove_child(player)
		player.queue_free()
		rpc("despawn_player", id)
	
	
	
	
func spawn_tree_s(tree_position: Vector2):
	var scene_id = randi() % MAX_TREE_COUNT
	
	# Make sure scene_id is unique
	while trees.get_node_or_null(str(scene_id)) != null:
		scene_id = randi() % MAX_TREE_COUNT
		
	var new_tree = TREE_SCENE.instance()
	new_tree.name = str(scene_id)
	new_tree.connect("on_break", self, "on_tree_break")
	trees.add_child(new_tree, true)
	new_tree.global_position = tree_position
	
	
func despawn_tree_s(scene_id: int):
	var tree = trees.get_node(str(scene_id))
	
	if tree:
		rpc("despawn_tree", scene_id)
		trees.remove_child(tree)
		tree.queue_free()
	
	
func on_tree_break(tree: GameTree):
	# Spawn wood at current position
	spawn_item_s(tree.ITEM_DROP, tree.wood_quantity, tree.global_position)
	
	# Despawn tree
	despawn_tree_s(tree.name.to_int())
	
	
	
	
func spawn_item_s(item_id: String, quantity: int, item_position: Vector2):
	# Limit number of item nodes currently existing
	if items.get_child_count() >= MAX_ITEM_COUNT:
		var remove_item: Item = items.get_child(0)
		
		# Get item info
		var item_info = remove_item.name.split("-", false, 1)
		var r_item_id = remove_item.item_id
		var r_scene_id = item_info[1].to_int()
		
		rpc("despawn_item", r_item_id, r_scene_id)
		items.remove_child(remove_item)
		remove_item.queue_free()
	
	# Create the item
	var new_item = ITEM_SCENE.instance()
	
	# Gather item info
	var item_type = GameData.item_data[item_id]["name"]
	var scene_id = randi() % MAX_ITEM_COUNT
	var scene_name = str(item_type) + "-" + str(scene_id)
	
	# Make sure scene_name is unique
	while items.get_node_or_null(scene_name) != null:
		scene_id = randi() % MAX_ITEM_COUNT
		
		scene_name = str(item_type) + "-" + str(scene_id)
	
	new_item.init(scene_name, item_id, quantity)
	new_item.connect("picked_up", self, "on_item_picked_up")
	
	items.add_child(new_item, true)
	new_item.global_position = item_position
	
	rpc("spawn_item", item_id, quantity, scene_id, item_position)
	
	
func despawn_item_s(item_id: String, scene_id: int):
	var item_type = GameData.item_data[item_id]["name"]
	var scene_name = str(item_type) + "-" + str(scene_id)
	var item = items.get_node(scene_name)
	
	if item:
		rpc("despawn_item", item_id, scene_id)
		items.remove_child(item)
		item.queue_free()
		
		
func on_item_picked_up(item: Item, player_id: int):
	# Remove item from scene
	var scene_id = item.name.split("-")[1].to_int()
	despawn_item_s(item.item_id, scene_id)
	
	# Update player inventory
	inventory.add_item_s(player_id, item.item_id, item.quantity)
