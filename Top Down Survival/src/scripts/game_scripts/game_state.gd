extends Node2D

const PLAYER_SCENE = preload("res://src/actors/Player.tscn")
const TREE_SCENE  = preload("res://src/actors/Tree.tscn")

#TODO: Move this to a json file in the future
const ITEM_SCENES = {
	"wood": preload("res://src/actors/items/Wood.tscn")
}

onready var players = $Players
onready var trees = $Trees
onready var items = $Items

onready var player_spawn = $PlayerSpawn
	
	
	
	
remote func spawn_player(player_id: int):
	print("Spawning player " + str(player_id))
	
	var new_player = PLAYER_SCENE.instance()
	new_player.name = str(player_id)
	players.add_child(new_player, true)
	
	new_player.set_network_master(player_id)
	new_player.position = player_spawn.position
	

remote func despawn_player(player_id: int):
	print("Despawning player " + str(player_id))
	var player = players.get_node(str(player_id))
	
	if player:
		players.remove_child(player)
		player.queue_free()
	
	
	
	
remote func spawn_tree(tree_id: int, tree_position: Vector2):
	var new_tree = TREE_SCENE.instance()
	
	new_tree.name = str(tree_id)
	trees.add_child(new_tree, true)
	
	new_tree.global_position = tree_position
	
	
remote func despawn_tree(tree_id: int):
	var tree = trees.get_node(str(tree_id))
	
	if tree:
		trees.remove_child(tree)
		tree.queue_free()
	
	
	
	
remote func spawn_item(item_type: String, item_id: int, item_position: Vector2):
	var new_item_scene = ITEM_SCENES[item_type]
	
	if new_item_scene:
		var new_item = new_item_scene.instance()
		
		new_item.name = str(item_type) + "-" + str(item_id)
		items.add_child(new_item, true)
		
		new_item.global_position = item_position
	
	else:
		print("Item of type '" + str(item_type) + "' not found")
	
	
remote func despawn_item(item_type: String, item_id: int):
	var item_name = str(item_type) + "-" + str(item_id)
	var item = items.get_node(item_name)
	
	if item:
		items.remove_child(item)
		item.queue_free()
